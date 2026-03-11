import React, { useState, useEffect } from 'react';
import api from '../api';
import { 
  Bell, 
  User, 
  Shield, 
  Smartphone, 
  Database, 
  Mail, 
  Globe,
  Settings as SettingsIcon,
  ChevronRight,
  RefreshCw
} from 'lucide-react';

const SettingCard = ({ icon: Icon, title, description, badge }) => (
  <div className="flex items-center justify-between p-4 bg-white border border-gray-100 rounded-xl hover:shadow-md transition-all cursor-pointer group shadow-sm">
    <div className="flex items-center gap-4">
      <div className="p-3 bg-primary/10 rounded-xl border border-primary/20 transition-all group-hover:bg-primary group-hover:text-white text-primary">
         <Icon className="w-6 h-6" />
      </div>
      <div>
        <h3 className="font-bold text-gray-900 flex items-center gap-3">
          {title}
          {badge && <span className="text-[10px] uppercase font-bold px-2 py-0.5 bg-primary text-white rounded-full">{badge}</span>}
        </h3>
        <p className="text-sm text-secondary">{description}</p>
      </div>
    </div>
    <ChevronRight className="w-5 h-5 text-gray-400 group-hover:text-primary transition-colors" />
  </div>
);

const Settings = () => {
  const [systemStatus, setSystemStatus] = useState({
    status: 'checking',
    database: { name: '...', driver: '...', schema: '...' }
  });
  const [isRefreshing, setIsRefreshing] = useState(false);

  const checkStatus = async () => {
    setIsRefreshing(true);
    try {
      const response = await api.get('/system-status');
      setSystemStatus(response.data);
    } catch (error) {
      setSystemStatus({ status: 'disconnected', error: error.message });
    } finally {
      setIsRefreshing(false);
    }
  };

  useEffect(() => {
    checkStatus();
  }, []);

  return (
    <div className="max-w-4xl space-y-8 animate-in slide-in-from-bottom duration-500">
      <div className="flex items-center gap-4">
        <div className="w-16 h-16 rounded-2xl bg-primary flex items-center justify-center text-white shadow-xl shadow-primary/20">
          <SettingsIcon className="w-10 h-10" />
        </div>
        <div>
          <h1 className="text-3xl font-bold">Admin Settings</h1>
          <p className="text-secondary font-medium">Configure store preferences and backend rules.</p>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div className="space-y-4">
          <h2 className="text-xl font-bold text-gray-900 border-l-4 border-primary pl-4">Account Settings</h2>
          <SettingCard 
            icon={User} 
            title="Admin Profile" 
            description="Edit your profile and details"
          />
          <SettingCard 
            icon={Shield} 
            title="Security" 
            description="Change password & Two-Factor Auth"
            badge="NEW"
          />
           <SettingCard 
            icon={Bell} 
            title="Notifications" 
            description="Manage system alerts & email"
          />
        </div>

        <div className="space-y-4">
          <h2 className="text-xl font-bold text-gray-900 border-l-4 border-primary pl-4">System Settings</h2>
          <SettingCard 
            icon={Smartphone} 
            title="App Configuration" 
            description="Control mobile app banners & toggles"
          />
          <SettingCard 
            icon={Database} 
            title="Database Sync" 
            description="Force refresh data & purge logs"
          />
          <SettingCard 
            icon={Globe} 
            title="Site Details" 
            description="Change API URLs & store info"
          />
        </div>
      </div>

      <div className="p-8 bg-gradient-to-r from-primary to-accent rounded-2xl text-white shadow-2xl shadow-primary/20 relative">
        <button 
          onClick={checkStatus}
          disabled={isRefreshing}
          className="absolute top-8 right-8 p-2 bg-white/10 hover:bg-white/20 rounded-lg transition-colors"
        >
          <RefreshCw className={`w-5 h-5 ${isRefreshing ? 'animate-spin' : ''}`} />
        </button>

        <h2 className="text-2xl font-bold mb-2">Backend & Database</h2>
        <p className="text-white/80 mb-6 font-medium">Verified connection to your DigitalOcean PostgreSQL cloud instance.</p>
        
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
          <div className="p-4 bg-white/10 rounded-xl border border-white/20">
            <p className="text-[10px] font-black uppercase tracking-widest text-white/60 mb-1">API Base</p>
            <p className="text-xs font-bold truncate">{import.meta.env.VITE_API_BASE_URL || 'localhost:8000/api'}</p>
          </div>
          
          <div className="p-4 bg-white/10 rounded-xl border border-white/20">
            <p className="text-[10px] font-black uppercase tracking-widest text-white/60 mb-1">Database Info</p>
            <p className="text-xs font-bold uppercase tracking-tight">
              {systemStatus.database?.driver}: {systemStatus.database?.name} ({systemStatus.database?.schema})
            </p>
          </div>

          <div className="p-4 bg-white/10 rounded-xl border border-white/20">
            <p className="text-[10px] font-black uppercase tracking-widest text-white/60 mb-1">Status</p>
            <div className="flex items-center gap-2">
              <span className={`w-2 h-2 rounded-full ${systemStatus.status === 'connected' ? 'bg-green-400 animate-pulse' : 'bg-red-400'}`}></span>
              <p className="text-xs font-black uppercase tracking-widest italic">{systemStatus.status}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Settings;
