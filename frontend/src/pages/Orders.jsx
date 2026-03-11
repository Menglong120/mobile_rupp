import React, { useState, useEffect } from 'react';
import api from '../api';
import { 
  Package, 
  Search, 
  Eye, 
  CheckCircle, 
  Clock,
  Truck,
  AlertCircle,
  Loader2
} from 'lucide-react';

const Orders = () => {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [updatingId, setUpdatingId] = useState(null);
  const [selectedOrder, setSelectedOrder] = useState(null);

  useEffect(() => {
    fetchOrders();
    // Auto-refresh orders every 5 seconds to catch new activities
    const interval = setInterval(fetchOrders, 5000);
    return () => clearInterval(interval);
  }, []);

  const fetchOrders = async () => {
    try {
      const response = await api.get('/orders');
      setOrders(response.data);
    } catch (error) {
      console.error('Error fetching orders:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleStatusChange = async (orderId, newStatus) => {
    setUpdatingId(orderId);
    try {
      await api.put(`/orders/${orderId}/status`, {
        status: newStatus
      });
      fetchOrders();
    } catch (error) {
      console.error('Error updating status:', error);
      alert('Failed to update status');
    } finally {
      setUpdatingId(null);
    }
  };

  const getStatusStyle = (status) => {
    switch (status?.toLowerCase()) {
      case 'paid': return 'bg-emerald-100 text-emerald-700';
      case 'completed': return 'bg-green-100 text-green-700';
      case 'pending': return 'bg-yellow-100 text-yellow-700';
      case 'processing': return 'bg-blue-100 text-blue-700';
      case 'shipped': return 'bg-purple-100 text-purple-700';
      default: return 'bg-gray-100 text-gray-700';
    }
  };

  return (
    <div className="space-y-6 animate-in fade-in duration-500">
      <div className="bg-white p-6 rounded-xl border shadow-sm">
        <h1 className="text-2xl font-bold">Orders Management</h1>
        <p className="text-secondary text-sm">Track and manage customer orders and deliveries.</p>
      </div>

      <div className="bg-white rounded-xl border shadow-sm overflow-hidden">
        <div className="p-4 border-b flex items-center gap-4">
          <div className="relative flex-1 max-w-md">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input 
              type="text" 
              placeholder="Search by Order ID or Customer..." 
              className="pl-10 pr-4 py-2 w-full border rounded-lg focus:ring-2 focus:ring-primary/20 outline-none"
            />
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead className="bg-gray-50 border-b text-secondary uppercase text-xs font-bold tracking-wider">
              <tr>
                <th className="px-6 py-4">Order ID</th>
                <th className="px-6 py-4">Date</th>
                <th className="px-6 py-4">Customer ID</th>
                <th className="px-6 py-4">Total Amount</th>
                <th className="px-6 py-4">Status</th>
                <th className="px-6 py-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {loading ? (
                <tr>
                  <td colSpan="6" className="px-6 py-12 text-center">
                    <Loader2 className="w-8 h-8 text-primary animate-spin mx-auto mb-2" />
                    <p className="text-secondary font-medium">Loading orders...</p>
                  </td>
                </tr>
              ) : orders.length === 0 ? (
                <tr>
                  <td colSpan="6" className="px-6 py-12 text-center text-secondary">
                    No orders found.
                  </td>
                </tr>
              ) : orders.map((order) => (
                <tr key={order.oid} className="hover:bg-gray-50/50 transition-colors">
                  <td className="px-6 py-4 font-bold text-gray-900">#{order.oid}</td>
                  <td className="px-6 py-4 text-sm text-gray-600">
                    {new Date(order.created_at).toLocaleDateString()}
                  </td>
                  <td className="px-6 py-4">
                    <div className="flex flex-col">
                      <span className="font-bold text-gray-800">{order.customer?.full_name || 'Anonymous'}</span>
                      <span className="text-[10px] text-gray-400 font-bold uppercase tracking-widest">ID: #{order.customer_id}</span>
                    </div>
                  </td>
                  <td className="px-6 py-4 font-bold text-green-600">${parseFloat(order.total_amount).toFixed(2)}</td>
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-2">
                      <select 
                        disabled={updatingId === order.oid}
                        value={order.status}
                        onChange={(e) => handleStatusChange(order.oid, e.target.value)}
                        className={`px-3 py-1 rounded-xl text-xs font-black uppercase tracking-widest border-none outline-none cursor-pointer focus:ring-2 focus:ring-primary/20 transition-all ${getStatusStyle(order.status)}`}
                      >
                        <option value="pending">Pending</option>
                        <option value="paid">Paid</option>
                        <option value="processing">Processing</option>
                        <option value="shipped">Shipped</option>
                        <option value="completed">Completed</option>
                        <option value="cancelled">Cancelled</option>
                      </select>
                      {updatingId === order.oid && <Loader2 className="w-4 h-4 text-primary animate-spin" />}
                    </div>
                  </td>
                  <td className="px-6 py-4 text-right">
                    <button 
                      onClick={() => setSelectedOrder(order)}
                      className="p-2 text-primary hover:bg-primary/10 rounded-xl transition-all hover:scale-110 active:scale-90 shadow-sm"
                    >
                      <Eye className="w-5 h-5" />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Order Details Modal */}
      {selectedOrder && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4 animate-in fade-in zoom-in duration-200">
          <div className="bg-white rounded-2xl shadow-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            <div className="sticky top-0 bg-white border-b p-6 flex items-center justify-between">
              <div>
                <h2 className="text-xl font-bold">Order Details</h2>
                <p className="text-sm text-secondary tracking-widest font-black uppercase">Order ID: #{selectedOrder.oid}</p>
              </div>
              <button 
                onClick={() => setSelectedOrder(null)}
                className="p-2 hover:bg-gray-100 rounded-full transition-colors"
              >
                <AlertCircle className="w-6 h-6 text-gray-400 rotate-45" />
              </button>
            </div>

            <div className="p-6 space-y-8">
              {/* Customer and Shipping Section */}
              <div className="grid grid-cols-2 gap-8">
                <div className="space-y-3">
                  <h3 className="text-xs font-black uppercase tracking-widest text-gray-400 flex items-center gap-2">
                    <Package className="w-4 h-4" /> Customer Info
                  </h3>
                  <div className="bg-gray-50 p-4 rounded-xl border border-dashed border-gray-200">
                    <p className="font-bold text-gray-900">{selectedOrder.customer?.full_name}</p>
                    <p className="text-sm text-gray-600">{selectedOrder.customer?.email}</p>
                    <p className="text-sm text-gray-600">{selectedOrder.customer?.phone}</p>
                  </div>
                </div>
                <div className="space-y-3">
                  <h3 className="text-xs font-black uppercase tracking-widest text-gray-400 flex items-center gap-2">
                    <Truck className="w-4 h-4" /> Shipping Address
                  </h3>
                  <div className="bg-gray-50 p-4 rounded-xl border border-dashed border-gray-200">
                    <p className="text-sm text-gray-900 leading-relaxed font-medium">
                      {selectedOrder.address?.address_line || "No address details"}
                    </p>
                  </div>
                </div>
              </div>

              {/* Items Table */}
              <div className="space-y-3">
                <h3 className="text-xs font-black uppercase tracking-widest text-gray-400">Order Items</h3>
                <div className="border rounded-xl overflow-hidden shadow-sm">
                  <table className="w-full text-sm">
                    <thead className="bg-gray-50 text-gray-500 font-bold uppercase text-[10px] tracking-widest">
                      <tr>
                        <th className="px-4 py-3 text-left">Item</th>
                        <th className="px-4 py-3 text-center">Qty</th>
                        <th className="px-4 py-3 text-right">Price</th>
                        <th className="px-4 py-3 text-right">Total</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y">
                      {selectedOrder.items?.map((item, idx) => (
                        <tr key={idx} className="hover:bg-gray-50/50 transition-colors">
                          <td className="px-4 py-4">
                            <div className="flex items-center gap-4">
                              <div className="w-12 h-12 bg-gray-100 rounded-lg overflow-hidden flex-shrink-0 border p-1">
                                <img 
                                  src={item.product?.image_url} 
                                  alt={item.product?.name} 
                                  className="w-full h-full object-contain"
                                  onError={(e) => {
                                    e.target.src = 'https://via.placeholder.com/150?text=No+Image';
                                  }}
                                />
                              </div>
                              <div>
                                <p className="font-black uppercase tracking-tight text-gray-800">{item.product?.name}</p>
                                <p className="text-xs text-secondary font-black opacity-50 uppercase tracking-widest">Size: {item.size || 'N/A'}</p>
                              </div>
                            </div>
                          </td>
                          <td className="px-4 py-4 text-center font-bold text-gray-900">x{item.quantity}</td>
                          <td className="px-4 py-4 text-right font-medium text-gray-500">${parseFloat(item.price).toFixed(2)}</td>
                          <td className="px-4 py-4 text-right font-black text-primary">${(item.price * item.quantity).toFixed(2)}</td>
                        </tr>
                      ))}
                    </tbody>
                    <tfoot className="bg-gray-50/50 font-bold">
                      <tr>
                        <td colSpan="3" className="px-4 py-4 text-right uppercase text-xs tracking-widest">Grand Total</td>
                        <td className="px-4 py-4 text-right text-lg text-green-600">${parseFloat(selectedOrder.total_amount).toFixed(2)}</td>
                      </tr>
                    </tfoot>
                  </table>
                </div>
              </div>
            </div>

            <div className="sticky bottom-0 bg-white border-t p-6 flex justify-end">
              <button 
                onClick={() => setSelectedOrder(null)}
                className="px-6 py-2.5 bg-gray-900 text-white rounded-xl font-bold hover:bg-gray-800 transition-all active:scale-95 shadow-lg shadow-gray-200"
              >
                Close Details
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default Orders;
