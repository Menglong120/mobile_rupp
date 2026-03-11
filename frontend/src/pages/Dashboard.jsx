import React, { useState, useEffect } from 'react';
import api from '../api';
import { 
  Users, 
  ShoppingBag, 
  DollarSign, 
  TrendingUp,
  Clock,
  Package,
  Truck,
  CheckCircle,
  Loader2
} from 'lucide-react';
import { 
  BarChart, 
  Bar, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  ResponsiveContainer,
  LineChart,
  Line,
  AreaChart,
  Area
} from 'recharts';
import { ArrowUpRight } from 'lucide-react';

const data = [
  { name: 'Mon', sales: 4000 },
  { name: 'Tue', sales: 3000 },
  { name: 'Wed', sales: 2000 },
  { name: 'Thu', sales: 2780 },
  { name: 'Fri', sales: 1890 },
  { name: 'Sat', sales: 2390 },
  { name: 'Sun', sales: 3490 },
];

const StatCard = ({ title, value, icon: Icon, trend, color, description, isLive }) => (
  <div className="bg-white p-5 rounded-2xl border border-gray-100 shadow-sm hover:shadow-xl hover:-translate-y-1 transition-all duration-300 group relative overflow-hidden">
    {isLive && (
      <div className="absolute top-0 right-0 p-2">
        <span className="flex h-2 w-2">
          <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75"></span>
          <span className="relative inline-flex rounded-full h-2 w-2 bg-green-500"></span>
        </span>
      </div>
    )}
    <div className="flex items-center justify-between mb-4">
      <div className={`p-3.5 rounded-2xl ${color} bg-opacity-10 group-hover:scale-110 transition-transform duration-300`}>
        <Icon className={`w-6 h-6 ${color.replace('bg-', 'text-')}`} />
      </div>
      <span className="text-xs font-black text-gray-400 uppercase tracking-widest italic">{trend}</span>
    </div>
    <div className="space-y-1">
      <h3 className="text-gray-500 text-xs font-black tracking-[0.15em] uppercase italic">{title}</h3>
      <p className="text-2xl font-black text-gray-900 tracking-tight">{value}</p>
      {description && <p className="text-[10px] text-gray-400 font-bold leading-tight uppercase tracking-tighter">{description}</p>}
    </div>
  </div>
);

const Dashboard = () => {
  const [stats, setStats] = useState({
    totalProducts: 0,
    totalOrders: 0,
    pendingOrders: 0,
    shippedOrders: 0,
    completedOrders: 0,
    processingOrders: 0,
    totalCustomers: 0,
    totalSales: 0
  });
  const [recentOrders, setRecentOrders] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchDashboardStats = async () => {
      try {
        const [prodRes, orderRes, custRes] = await Promise.all([
          api.get('/products'),
          api.get('/orders'),
          api.get('/customers')
        ]);
        
        const allOrders = orderRes.data || [];
        const totalSales = allOrders
          .filter(o => o.status === 'paid' || o.status === 'shipped' || o.status === 'completed')
          .reduce((acc, order) => acc + parseFloat(order.total_amount || 0), 0);
          
        const pendingCount = allOrders.filter(o => o.status === 'pending').length;
        const processingCount = allOrders.filter(o => o.status === 'processing').length;
        const shippedCount = allOrders.filter(o => o.status === 'shipped').length;
        const completedCount = allOrders.filter(o => o.status === 'completed').length;
        
        const orders = allOrders.slice(0, 5); // Get top 5 recent

        setStats({
          totalProducts: (prodRes.data || []).length,
          totalOrders: allOrders.length,
          pendingOrders: pendingCount,
          processingOrders: processingCount,
          shippedOrders: shippedCount,
          completedOrders: completedCount,
          totalCustomers: (custRes.data || []).length,
          totalSales: totalSales
        });
        setRecentOrders(orders);
        setLoading(false);
      } catch (error) {
        console.error('Error fetching stats:', error);
        setLoading(false);
      }
    };
    
    // Initial fetch
    fetchDashboardStats();
    
    // Auto-refresh every 5 seconds for real-time appearance
    const interval = setInterval(fetchDashboardStats, 5000);
    
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="space-y-4 animate-in fade-in duration-500 max-w-7xl mx-auto">
      <div className="flex justify-between items-center mb-2">
        <div>
          <h1 className="text-2xl font-black text-gray-900 tracking-tight">Overview</h1>
          <p className="text-[11px] text-gray-400 font-bold uppercase tracking-widest">Real-time statistics</p>
        </div>
        <button className="bg-primary text-white px-3 py-1.5 rounded-xl text-xs font-bold hover:bg-primary/90 transition-all shadow-md active:scale-95">
          Download Report
        </button>
      </div>

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard 
          title="Net Sales" 
          value={`$${stats.totalSales.toFixed(2)}`} 
          icon={DollarSign} 
          trend="Live" 
          color="bg-blue-600"
          description="Paid/Shipped/Completed"
          isLive={true}
        />
        <StatCard 
          title="Stock" 
          value={stats.totalProducts} 
          icon={Package} 
          trend="Items" 
          color="bg-emerald-600"
          description="Total shoe variants"
          isLive={true}
        />
        <StatCard 
          title="Customers" 
          value={stats.totalCustomers} 
          icon={Users} 
          trend="Total" 
          color="bg-orange-600"
          description="Verified accounts"
          isLive={true}
        />
        <StatCard 
          title="All Orders" 
          value={stats.totalOrders} 
          icon={ShoppingBag} 
          trend="Lifetime" 
          color="bg-indigo-600"
          description="Total orders placed"
          isLive={true}
        />
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard 
          title="Pending" 
          value={stats.pendingOrders} 
          icon={Clock} 
          trend="New" 
          color="bg-yellow-500"
          description="Needs check"
          isLive={true}
        />
        <StatCard 
          title="Processing" 
          value={stats.processingOrders} 
          icon={Loader2} 
          trend="Running" 
          color="bg-blue-500"
          description="Packing now"
          isLive={true}
        />
        <StatCard 
          title="Shipped" 
          value={stats.shippedOrders} 
          icon={Truck} 
          trend="On Way" 
          color="bg-purple-500"
          description="In delivery"
          isLive={true}
        />
        <StatCard 
          title="Completed" 
          value={stats.completedOrders} 
          icon={CheckCircle} 
          trend="Done" 
          color="bg-green-500"
          description="Delivered"
          isLive={true}
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-10">
        <div className="bg-white p-8 rounded-3xl border border-gray-100 shadow-xl hover:shadow-2xl transition-all duration-500">
          <div className="flex items-center justify-between mb-8">
            <div>
              <h3 className="text-xl font-black text-gray-900 tracking-tight italic uppercase">Sales Growth</h3>
              <p className="text-sm text-gray-400 font-bold uppercase tracking-widest mt-1">Weekly Performance</p>
            </div>
            <div className="p-3 bg-blue-50 rounded-2xl">
              <TrendingUp className="w-6 h-6 text-blue-600" />
            </div>
          </div>
          <div className="h-80 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={data}>
                <defs>
                  <linearGradient id="colorSales" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#3B82F6" stopOpacity={0.4}/>
                    <stop offset="95%" stopColor="#3B82F6" stopOpacity={0}/>
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#F3F4F6" />
                <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{fill: '#9CA3AF', fontSize: 12, fontWeight: 700}} dy={10} />
                <YAxis axisLine={false} tickLine={false} tick={{fill: '#9CA3AF', fontSize: 12, fontWeight: 700}} dx={-10} />
                <Tooltip 
                  contentStyle={{borderRadius: '16px', border: 'none', boxShadow: '0 20px 25px -5px rgb(0 0 0 / 0.1)', fontWeight: 'bold'}}
                />
                <Area type="monotone" dataKey="sales" stroke="#3B82F6" strokeWidth={4} fillOpacity={1} fill="url(#colorSales)" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="bg-white p-8 rounded-3xl border border-gray-100 shadow-xl overflow-hidden hover:shadow-2xl transition-all duration-500">
          <div className="flex items-center justify-between mb-8">
            <div>
              <h3 className="text-xl font-black text-gray-900 tracking-tight italic uppercase">Recent Activity</h3>
              <p className="text-sm text-gray-400 font-bold uppercase tracking-widest mt-1">Live Feed</p>
            </div>
            <button className="text-xs font-black text-blue-600 hover:text-blue-700 uppercase tracking-widest italic flex items-center gap-2 group">
              View All <ArrowUpRight className="w-4 h-4 group-hover:translate-x-1 group-hover:-translate-y-1 transition-transform" />
            </button>
          </div>
          <div className="space-y-6">
            {recentOrders.length > 0 ? recentOrders.map((order, i) => (
              <div key={i} className="flex items-center justify-between p-5 rounded-2xl hover:bg-gray-50 transition-colors border border-transparent hover:border-gray-100 group">
                <div className="flex items-center gap-5">
                  <div className="w-14 h-14 rounded-2xl bg-gradient-to-br from-gray-100 to-gray-200 flex items-center justify-center overflow-hidden font-black text-gray-500 text-lg group-hover:scale-110 transition-transform duration-300">
                    {order.items && order.items[0]?.product?.image ? (
                      <img src={order.items[0].product.image} alt="product" className="w-full h-full object-cover" />
                    ) : (
                      <span>#{order.oid.toString().slice(-2)}</span>
                    )}
                  </div>
                  <div>
                    <p className="text-gray-900 font-black text-base italic uppercase">{order.customer?.full_name?.split(' ')[0] || 'Walk-in'}</p>
                    <p className="text-sm text-gray-400 font-bold tracking-tight uppercase">{new Date(order.created_at).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit', hour12: true})}</p>
                  </div>
                </div>
                <div className="text-right">
                  <p className="text-gray-900 font-black text-xl italic tracking-tight">${parseFloat(order.total_amount).toFixed(2)}</p>
                  <span className={`text-[10px] font-black px-3 py-1.5 rounded-full uppercase tracking-widest italic ${
                    order.status === 'completed' ? 'bg-green-100 text-green-700' : 
                    order.status === 'pending' ? 'bg-yellow-100 text-yellow-700 animate-pulse' : 
                    'bg-blue-100 text-blue-700'
                  }`}>
                    {order.status}
                  </span>
                </div>
              </div>
            )) : (
              <div className="flex flex-col items-center justify-center py-12 text-gray-400">
                <Package className="w-16 h-16 mb-4 opacity-20" />
                <p className="font-black uppercase tracking-widest text-sm">No activity recorded</p>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
