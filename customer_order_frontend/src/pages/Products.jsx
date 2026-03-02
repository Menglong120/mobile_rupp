import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { 
  Plus, 
  Search, 
  Edit2, 
  Trash2, 
  Package, 
  Image as ImageIcon,
  X,
  Loader2
} from 'lucide-react';

const Products = () => {
  const [products, setProducts] = useState([]);
  const [categories, setCategories] = useState([]); // Fetch categories from DB
  const [loading, setLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingId, setEditingId] = useState(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('all');
  const [formData, setFormData] = useState({
    name: '',
    price: '',
    description: '',
    stock: '',
    category_id: '',
    image: null
  });

  const [preview, setPreview] = useState(null);

  useEffect(() => {
    fetchProducts();
    fetchCategories();
  }, []);

  const fetchProducts = async () => {
    try {
      const response = await axios.get('http://127.0.0.1:8000/api/products');
      setProducts(response.data);
    } catch (error) {
      console.error('Error fetching products:', error);
    } finally {
      setLoading(false);
    }
  };

  const filteredProducts = products.filter(product => {
    const matchesSearch = product.name.toLowerCase().includes(searchTerm.toLowerCase()) || 
                          (product.category?.name || '').toLowerCase().includes(searchTerm.toLowerCase());
    const matchesCategory = selectedCategory === 'all' || product.category?.id.toString() === selectedCategory.toString();
    return matchesSearch && matchesCategory;
  });

  const fetchCategories = async () => {
    try {
      const response = await axios.get('http://127.0.0.1:8000/api/categories');
      setCategories(response.data);
      if (response.data.length > 0 && !formData.category_id) {
        setFormData(prev => ({ ...prev, category_id: response.data[0].id }));
      }
    } catch (error) {
      console.error('Error fetching categories:', error);
    }
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData({ ...formData, [name]: value });
  };

  const handleImageChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      setFormData({ ...formData, image: file });
      setPreview(URL.createObjectURL(file));
    }
  };

  const handleEdit = (product) => {
    setEditingId(product.id);
    setFormData({
      name: product.name,
      price: product.price,
      description: product.description,
      stock: product.stock,
      category_id: product.category?.id || '',
      image: null
    });
    setPreview(product.image || null);
    setIsModalOpen(true);
  };

  const handleDelete = async (id) => {
    if (!window.confirm('Are you sure you want to delete this shoe?')) return;
    try {
      await axios.delete(`http://127.0.0.1:8000/api/products/${id}`);
      fetchProducts();
    } catch (error) {
      console.error('Error deleting product:', error);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    
    const data = new FormData();
    data.append('name', formData.name);
    data.append('price', formData.price);
    data.append('description', formData.description || '');
    data.append('stock', formData.stock);
    data.append('category_id', formData.category_id);
    if (formData.image) data.append('image', formData.image);
    
    // For PUT requests with files in Laravel, we often use POST with _method=PUT
    if (editingId) data.append('_method', 'PUT');

    try {
      const url = editingId 
        ? `http://127.0.0.1:8000/api/products/${editingId}`
        : 'http://127.0.0.1:8000/api/products';
      
      await axios.post(url, data);
      setIsModalOpen(false);
      setEditingId(null);
      fetchProducts();
      setFormData({ name: '', price: '', description: '', stock: '', category_id: categories[0]?.id || '', image: null });
      setPreview(null);
    } catch (error) {
      console.error('Detailed Save Error:', error.response?.data);
      const errorMessage = error.response?.data?.message || 'Error saving product';
      const validationErrors = error.response?.data?.errors 
        ? Object.entries(error.response.data.errors).map(([k, v]) => `${k}: ${v}`).join('\n')
        : '';
      alert(`${errorMessage}\n${validationErrors}`);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center bg-white p-6 rounded-2xl border border-gray-100 shadow-sm animate-in fade-in slide-in-from-top duration-500">
        <div>
          <h1 className="text-3xl font-black text-gray-900 tracking-tight">Inventory Hub</h1>
          <div className="flex items-center gap-2 mt-1">
            <span className="w-2 h-2 rounded-full bg-green-500 shadow-[0_0_8px_rgba(34,197,94,0.6)]"></span>
            <p className="text-gray-400 text-sm font-semibold italic uppercase tracking-wider">{products.length} Products Live</p>
          </div>
        </div>
        <button 
          onClick={() => setIsModalOpen(true)}
          className="bg-primary text-white px-6 py-3 rounded-2xl font-bold hover:bg-primary/90 hover:scale-105 active:scale-95 transition-all flex items-center gap-3 shadow-lg shadow-primary/20"
        >
          <div className="bg-white/20 p-1 rounded-lg">
             <Plus className="w-5 h-5" />
          </div>
          Create New Shoe
        </button>
      </div>

      <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden animate-in fade-in slide-in-from-bottom duration-700">
        <div className="p-5 border-b border-gray-100 flex flex-wrap items-center justify-between gap-4 bg-gray-50/30">
          <div className="relative flex-1 min-w-[300px]">
            <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input 
              type="text" 
              placeholder="Search by shoe name or category..." 
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="pl-12 pr-6 py-3 w-full border border-gray-200 rounded-2xl bg-white shadow-inner focus:ring-4 focus:ring-primary/5 focus:border-primary outline-none transition-all placeholder:text-gray-400 font-bold"
            />
          </div>
          <div className="flex flex-wrap gap-2">
            <button 
              onClick={() => setSelectedCategory('all')}
              className={`px-4 py-2 rounded-xl text-xs font-black uppercase tracking-widest transition-all ${
                selectedCategory === 'all' 
                ? 'bg-primary text-white shadow-lg shadow-primary/20' 
                : 'bg-white border border-gray-100 text-gray-500 hover:border-primary hover:text-primary'
              }`}
            >
              All
            </button>
            {categories.map(cat => (
              <button 
                key={cat.id} 
                onClick={() => setSelectedCategory(cat.id)}
                className={`px-4 py-2 rounded-xl text-xs font-black uppercase tracking-widest transition-all ${
                  selectedCategory.toString() === cat.id.toString()
                  ? 'bg-primary text-white shadow-lg shadow-primary/20' 
                  : 'bg-white border border-gray-100 text-gray-500 hover:border-primary hover:text-primary'
                }`}
              >
                {cat.name}
              </button>
            ))}
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead className="bg-gray-50 border-b border-gray-100 italic">
              <tr>
                <th className="px-8 py-5 font-black text-gray-400 text-[10px] uppercase tracking-[0.2em]">Shoe Profile</th>
                <th className="px-6 py-5 font-black text-gray-400 text-[10px] uppercase tracking-[0.2em]">Price</th>
                <th className="px-6 py-5 font-black text-gray-400 text-[10px] uppercase tracking-[0.2em]">Inventory</th>
                <th className="px-6 py-5 font-black text-gray-400 text-[10px] uppercase tracking-[0.2em]">Market Status</th>
                <th className="px-8 py-5 font-black text-gray-400 text-[10px] uppercase tracking-[0.2em] text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {loading && products.length === 0 ? (
                <tr>
                  <td colSpan="5" className="px-6 py-12 text-center">
                    <Loader2 className="w-8 h-8 text-primary animate-spin mx-auto mb-2" />
                    <p className="text-secondary font-black italic uppercase tracking-widest text-xs">Loading products...</p>
                  </td>
                </tr>
              ) : filteredProducts.length > 0 ? (
                filteredProducts.map((product) => (
                  <tr key={product.id} className="hover:bg-primary/5 group transition-all duration-300">
                    <td className="px-8 py-5">
                      <div className="flex items-center gap-5">
                        {product.image ? (
                          <div className="w-16 h-16 rounded-2xl bg-white border border-gray-100 p-1 shadow-sm group-hover:scale-110 transition-transform duration-500 overflow-hidden">
                            <img src={product.image} alt={product.name} className="w-full h-full object-contain" />
                          </div>
                        ) : (
                          <div className="w-16 h-16 rounded-2xl bg-gray-50 flex items-center justify-center border border-dashed border-gray-200 group-hover:bg-primary/10 transition-all duration-300">
                            <ImageIcon className="w-7 h-7 text-gray-400 group-hover:text-primary transition-colors" />
                          </div>
                        )}
                        <div>
                          <p className="text-base font-black text-gray-800 tracking-tight group-hover:text-primary transition-colors">{product.name}</p>
                          <p className="text-[10px] text-gray-400 font-bold uppercase tracking-[0.1em] mt-0.5">{product.category?.name || 'Uncategorized'} • ID #{product.id}</p>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-5">
                      <span className="text-lg font-black text-gray-900 tracking-tighter">${product.price}</span>
                    </td>
                    <td className="px-6 py-5">
                        <div className="flex flex-col">
                          <div className="flex items-center gap-2">
                             <div className={`w-2 h-2 rounded-full ${product.stock > 10 ? 'bg-green-500' : product.stock > 0 ? 'bg-yellow-500' : 'bg-red-500'}`}></div>
                             <span className="font-black text-gray-700">{product.stock} units</span>
                          </div>
                          <div className="w-20 h-1.5 bg-gray-100 rounded-full mt-2 overflow-hidden shadow-inner hidden md:block">
                            <div className={`h-full rounded-full transition-all duration-500 ${product.stock > 10 ? 'bg-green-500' : product.stock > 0 ? 'bg-yellow-500' : 'bg-red-500'}`} style={{width: `${Math.min((product.stock / 50) * 100, 100)}%`}}></div>
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-5">
                        <span className={`px-4 py-1.5 text-[10px] font-black uppercase tracking-widest rounded-xl flex items-center gap-2 w-fit italic transition-all ${
                          product.stock > 10 
                            ? 'bg-green-50 text-green-700 border border-green-100' 
                            : product.stock > 0 
                              ? 'bg-yellow-50 text-yellow-700 border border-yellow-100' 
                              : 'bg-red-50 text-red-700 border border-red-100'
                        }`}>
                          <span className={`w-1.5 h-1.5 rounded-full animate-pulse ${
                             product.stock > 10 ? 'bg-green-700' : product.stock > 0 ? 'bg-yellow-700' : 'bg-red-700'
                          }`}></span>
                          {product.stock > 10 ? 'Market Ready' : product.stock > 0 ? 'Urgent Restock' : 'Sold Out'}
                        </span>
                      </td>
                      <td className="px-8 py-5 text-right">
                      <div className="flex justify-end gap-3 opacity-0 group-hover:opacity-100 -translate-x-4 group-hover:translate-x-0 transition-all duration-300">
                        <button 
                          onClick={() => handleEdit(product)}
                          className="p-2.5 bg-white text-primary border border-gray-100 rounded-xl shadow-sm hover:bg-primary hover:text-white transition-all outline-none"
                        >
                          <Edit2 className="w-5 h-5" />
                        </button>
                        <button 
                          onClick={() => handleDelete(product.id)}
                          className="p-2.5 bg-white text-red-500 border border-gray-100 rounded-xl shadow-sm hover:bg-red-500 hover:text-white transition-all outline-none"
                        >
                          <Trash2 className="w-5 h-5" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan="5" className="px-6 py-20 text-center">
                    <Package className="w-12 h-12 text-gray-200 mx-auto mb-4" />
                    <p className="text-gray-400 font-black italic uppercase tracking-widest text-sm">No shoes found matching your search</p>
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm p-4 animate-in fade-in transition-all duration-200">
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-xl overflow-hidden animate-in zoom-in duration-300">
            <div className="p-6 border-b flex justify-between items-center bg-gradient-to-r from-primary to-accent">
              <h2 className="text-xl font-bold text-white">{editingId ? 'Edit Product' : 'Add New Product'}</h2>
              <button onClick={() => { setIsModalOpen(false); setEditingId(null); setFormData({name: '', price: '', description: '', stock: '', category_id: categories[0]?.id || '', image: null}); setPreview(null); }} className="text-white hover:bg-white/20 p-2 rounded-full transition-colors">
                <X className="w-5 h-5" />
              </button>
            </div>
            <form onSubmit={handleSubmit} className="p-6 space-y-5 max-h-[75vh] overflow-y-auto">
              <div>
                <label className="block text-sm font-bold text-gray-700 mb-1">Product Name</label>
                <input required name="name" value={formData.name} onChange={handleInputChange} type="text" className="w-full px-4 py-2.5 border rounded-xl outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all" placeholder="e.g. Nike Air Max Plus" />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-bold text-gray-700 mb-1">Price ($)</label>
                  <input required name="price" value={formData.price} onChange={handleInputChange} type="number" step="0.01" className="w-full px-4 py-2.5 border rounded-xl outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all" placeholder="0.00" />
                </div>
                <div>
                  <label className="block text-sm font-bold text-gray-700 mb-1">Category</label>
                  <select 
                    required 
                    name="category_id" 
                    value={formData.category_id} 
                    onChange={handleInputChange}
                    className="w-full px-4 py-2.5 border rounded-xl outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all bg-white"
                  >
                    {categories.map(cat => (
                      <option key={cat.id} value={cat.id}>{cat.name}</option>
                    ))}
                  </select>
                </div>
              </div>
              <div>
                <label className="block text-sm font-bold text-gray-700 mb-1">Stock Quantity</label>
                <input required name="stock" value={formData.stock} onChange={handleInputChange} type="number" className="w-full px-4 py-2.5 border rounded-xl outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all" placeholder="0" />
              </div>
              <div>
                <label className="block text-sm font-bold text-gray-700 mb-1">Description</label>
                <textarea required name="description" value={formData.description} onChange={handleInputChange} rows="3" className="w-full px-4 py-2.5 border rounded-xl outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all" placeholder="Product details..."></textarea>
              </div>
              <div>
                <label className="block text-sm font-bold text-gray-700 mb-1">Product Image</label>
                <div className={`mt-1 border-2 border-dashed rounded-2xl p-4 flex flex-col items-center justify-center transition-all relative ${preview ? 'border-primary/50 bg-primary/5' : 'border-gray-300 hover:border-primary/50'}`}>
                  {preview ? (
                    <div className="relative group w-full">
                      <img src={preview} className="h-40 w-full object-contain rounded-lg" alt="Preview" />
                      <button type="button" onClick={() => { setPreview(null); setFormData({...formData, image: null}); }} className="absolute top-2 right-2 bg-red-500 text-white p-1.5 rounded-full shadow-lg z-10 hover:bg-red-600 transition-colors">
                        <X className="w-4 h-4" />
                      </button>
                    </div>
                  ) : (
                    <label htmlFor="imageInput" className="text-center py-4 cursor-pointer w-full">
                      <ImageIcon className="w-10 h-10 text-gray-400 mx-auto mb-2" />
                      <p className="text-sm text-gray-500">Drag and drop or <span className="text-primary font-bold">browse</span></p>
                    </label>
                  )}
                  <input type="file" id="imageInput" className="hidden" onChange={handleImageChange} accept="image/*,.avif" />
                </div>
              </div>
              <div className="pt-4 border-t flex gap-4">
                <button type="button" onClick={() => { setIsModalOpen(false); setEditingId(null); setFormData({name: '', price: '', description: '', stock: '', category_id: categories[0]?.id || '', image: null}); setPreview(null); }} className="flex-1 px-4 py-3 border border-gray-300 rounded-xl font-bold hover:bg-gray-50 transition-colors">Cancel</button>
                <button type="submit" disabled={loading} className="flex-1 px-4 py-3 bg-primary text-white rounded-xl font-bold hover:bg-primary/90 transition-all flex items-center justify-center gap-2">
                  {loading ? <Loader2 className="w-5 h-5 animate-spin" /> : (editingId ? 'Update Product' : 'Save Product')}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default Products;
