import React from 'react';
import { NavLink } from 'react-router-dom';
import { 
  LayoutDashboard, 
  ShoppingBag, 
  Users, 
  Settings, 
  LogOut,
  Package,
  Tag
} from 'lucide-react';
import { clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

function cn(...inputs) {
  return twMerge(clsx(inputs));
}

const Sidebar = () => {
  const menuItems = [
    { icon: LayoutDashboard, label: 'DashBoard', path: '/' },
    { icon: ShoppingBag, label: 'Shoes Hub', path: '/products' },
    { icon: Tag, label: 'Categories', path: '/categories' },
    { icon: Package, label: 'Live Orders', path: '/orders' },
    { icon: Users, label: 'Customers', path: '/customers' },
    { icon: Settings, label: 'Settings', path: '/settings' },
  ];

  return (
    <aside className="w-72 bg-white border-r border-gray-100 h-screen sticky top-0 flex flex-col transition-all duration-300 shadow-2xl shadow-gray-100/50">
      <div className="p-10 border-b border-gray-50 flex items-center justify-center">
        <div className="flex items-center gap-3">
          <div className="p-3 bg-primary rounded-2xl shadow-lg shadow-primary/30">
            <ShoppingBag className="w-8 h-8 text-white" />
          </div>
          <div>
            <h1 className="text-2xl font-black text-gray-900 leading-tight tracking-tighter uppercase italic px-1 bg-primary text-white rounded skew-y-1">Mekong Shoes</h1>
            <span className="text-[10px] font-black tracking-[0.2em] text-gray-400 uppercase italic pl-1">Admin Dashboard</span>
          </div>
        </div>
      </div>
      
      <nav className="flex-1 p-8 space-y-4 overflow-y-auto">
        {menuItems.map((item) => {
          const ItemIcon = item.icon;
          return (
            <NavLink
              key={item.path}
              to={item.path}
              className={({ isActive }) => cn(
                "flex items-center gap-4 px-6 py-4 rounded-3xl transition-all duration-300 group hover:translate-x-2",
                isActive 
                  ? "bg-primary text-white shadow-xl shadow-primary/30 scale-105" 
                  : "text-gray-400 font-bold hover:bg-gray-50 hover:text-primary"
              )}
            >
              {({ isActive }) => (
                <>
                  <ItemIcon className={cn("w-6 h-6 transition-all", isActive ? "scale-110" : "group-hover:rotate-12")} />
                  <span className="text-sm tracking-wider font-black uppercase italic">{item.label}</span>
                </>
              )}
            </NavLink>
          );
        })}
      </nav>

      <div className="p-8 border-t border-gray-50">
        <button className="flex items-center gap-4 px-6 py-4 w-full text-red-600 bg-red-50 hover:bg-red-600 hover:text-white rounded-3xl transition-all duration-300 font-black italic shadow-lg shadow-red-100 hover:shadow-red-200 uppercase tracking-widest text-xs">
          <LogOut className="w-5 h-5 group-hover:rotate-45" />
          Logout Account
        </button>
      </div>
    </aside>
  );
};

export default Sidebar;
