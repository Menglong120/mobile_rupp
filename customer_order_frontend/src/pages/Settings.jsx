import React from 'react';
import { 
  Bell, 
  User, 
  Shield, 
  Smartphone, 
  Database, 
  Mail, 
  Globe,
  Settings as SettingsIcon,
  ChevronRight
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

      <div className="p-8 bg-gradient-to-r from-primary to-accent rounded-2xl text-white shadow-2xl shadow-primary/20">
        <h2 className="text-2xl font-bold mb-2">Backend Connection</h2>
        <p className="text-white/80 mb-6 font-medium">You are currently connected to the live Laravel backend. All changes made here will sync instantly.</p>
        <div className="flex gap-4">
          <div className="px-4 py-2 bg-white/20 rounded-lg text-sm font-bold border border-white/30">API: 127.0.0.1:8000</div>
          <div className="px-4 py-2 bg-green-400 text-green-950 font-black rounded-lg text-sm border border-white/30 uppercase tracking-tighter">Status: Connected</div>
        </div>
      </div>
    </div>
  );
};

export default Settings;
