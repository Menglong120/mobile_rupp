import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { Plus, Edit2, Trash2, Loader2, X, Tag } from 'lucide-react';

const Categories = () => {
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingCategory, setEditingCategory] = useState(null);
  const [categoryName, setCategoryName] = useState('');

  useEffect(() => {
    fetchCategories();
  }, []);

  const fetchCategories = async () => {
    try {
      const response = await axios.get('http://127.0.0.1:8000/api/categories');
      setCategories(response.data);
    } catch (error) {
      console.error('Error fetching categories:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      if (editingCategory) {
        await axios.put(`http://127.0.0.1:8000/api/categories/${editingCategory.id}`, { name: categoryName });
      } else {
        await axios.post('http://127.0.0.1:8000/api/categories', { name: categoryName });
      }
      setIsModalOpen(false);
      setEditingCategory(null);
      setCategoryName('');
      fetchCategories();
    } catch (error) {
      alert(error.response?.data?.message || 'Error saving category');
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('Are you sure? This will only work if no products belong to this category.')) return;
    try {
      await axios.delete(`http://127.0.0.1:8000/api/categories/${id}`);
      fetchCategories();
    } catch (error) {
      alert(error.response?.data?.message || 'Cannot delete category');
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center bg-white p-6 rounded-2xl border border-gray-100 shadow-sm">
        <div>
          <h1 className="text-3xl font-black text-gray-900 tracking-tight italic uppercase">Category Manager</h1>
          <p className="text-sm text-gray-400 font-bold uppercase tracking-widest mt-1">Organize your store collections</p>
        </div>
        <button 
          onClick={() => { setIsModalOpen(true); setEditingCategory(null); setCategoryName(''); }}
          className="flex items-center gap-2 bg-blue-600 text-white px-6 py-3 rounded-xl font-black uppercase tracking-widest italic hover:bg-blue-700 transition-all shadow-lg shadow-blue-200"
        >
          <Plus className="w-5 h-5" /> Add Category
        </button>
      </div>

      <div className="bg-white rounded-3xl border border-gray-100 shadow-xl overflow-hidden">
        <table className="w-full text-left">
          <thead>
            <tr className="bg-gray-50/50 border-b border-gray-100">
              <th className="px-8 py-5 text-xs font-black text-gray-400 uppercase tracking-[0.2em] italic">Category ID</th>
              <th className="px-8 py-5 text-xs font-black text-gray-400 uppercase tracking-[0.2em] italic">Name</th>
              <th className="px-8 py-5 text-right text-xs font-black text-gray-400 uppercase tracking-[0.2em] italic">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-50">
            {loading ? (
              <tr>
                <td colSpan="3" className="px-8 py-20 text-center">
                  <Loader2 className="w-10 h-10 text-blue-600 animate-spin mx-auto mb-4" />
                  <p className="font-black text-gray-400 uppercase tracking-widest text-sm italic">Loading Categories...</p>
                </td>
              </tr>
            ) : categories.map((cat) => (
              <tr key={cat.id} className="hover:bg-blue-50/30 group transition-colors">
                <td className="px-8 py-5 font-bold text-gray-400">#{cat.id}</td>
                <td className="px-8 py-5">
                  <div className="flex items-center gap-3">
                    <div className="p-2 bg-blue-100 rounded-lg text-blue-600"><Tag className="w-4 h-4" /></div>
                    <span className="font-black text-gray-800 text-lg uppercase italic">{cat.name}</span>
                  </div>
                </td>
                <td className="px-8 py-5 text-right">
                  <div className="flex justify-end gap-3">
                    <button 
                      onClick={() => { setEditingCategory(cat); setCategoryName(cat.name); setIsModalOpen(true); }}
                      className="p-2.5 bg-white text-blue-600 border border-gray-100 rounded-xl shadow-sm hover:bg-blue-600 hover:text-white transition-all"
                    >
                      <Edit2 className="w-5 h-5" />
                    </button>
                    <button 
                      onClick={() => handleDelete(cat.id)}
                      className="p-2.5 bg-white text-red-500 border border-gray-100 rounded-xl shadow-sm hover:bg-red-500 hover:text-white transition-all"
                    >
                      <Trash2 className="w-5 h-5" />
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm p-4">
          <div className="bg-white rounded-3xl shadow-2xl w-full max-w-md overflow-hidden">
            <div className="p-8 border-b flex justify-between items-center bg-gradient-to-r from-blue-600 to-blue-700">
              <h2 className="text-xl font-black text-white italic uppercase tracking-widest">{editingCategory ? 'Edit Category' : 'New Category'}</h2>
              <button onClick={() => setIsModalOpen(false)} className="text-white hover:bg-white/20 p-2 rounded-full transition-colors">
                <X className="w-5 h-5" />
              </button>
            </div>
            <form onSubmit={handleSubmit} className="p-8 space-y-6">
              <div>
                <label className="block text-xs font-black text-gray-400 uppercase tracking-widest italic mb-2">Category Name</label>
                <input 
                  required 
                  value={categoryName}
                  onChange={(e) => setCategoryName(e.target.value)}
                  type="text" 
                  className="w-full px-5 py-4 bg-gray-50 border-0 rounded-2xl outline-none focus:ring-2 focus:ring-blue-500/20 font-bold text-gray-800 transition-all" 
                  placeholder="e.g. Running Shoes" 
                />
              </div>
              <div className="flex gap-4">
                <button type="button" onClick={() => setIsModalOpen(false)} className="flex-1 px-4 py-4 border border-gray-200 rounded-2xl font-black uppercase tracking-widest italic text-gray-400 hover:bg-gray-50 transition-colors">Cancel</button>
                <button type="submit" className="flex-1 px-4 py-4 bg-blue-600 text-white rounded-2xl font-black uppercase tracking-widest italic hover:bg-blue-700 transition-all shadow-lg shadow-blue-200">
                  {editingCategory ? 'Update' : 'Create'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default Categories;
