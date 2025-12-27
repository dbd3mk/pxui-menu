import React, { useState, useEffect } from 'react';
import { supabase } from './supabaseClient';
import {
    Shield,
    Key,
    Users,
    Settings,
    LogOut,
    Activity,
    Lock,
    User,
    Mail,
    Plus,
    Ban,
    Unlock,
    CheckCircle
} from 'lucide-react';
import './index.css';

function App() {
    const [user, setUser] = useState(null);
    const [profile, setProfile] = useState(null);
    const [loading, setLoading] = useState(true);
    const [authMode, setAuthMode] = useState('login');
    const [formData, setFormData] = useState({ email: '', password: '', username: '' });
    const [licenseKey, setLicenseKey] = useState('');
    const [machoKey, setMachoKey] = useState('');
    const [users, setUsers] = useState([]);
    const [licenses, setLicenses] = useState([]);
    const [activeTab, setActiveTab] = useState('dashboard');
    const [adminSubTab, setAdminSubTab] = useState('users');
    const [refreshing, setRefreshing] = useState(false);

    useEffect(() => {
        checkUser();
        const { data: authListener } = supabase.auth.onAuthStateChange(async (event, session) => {
            setUser(session?.user ?? null);
            if (session?.user) {
                fetchProfile(session.user.id, session.user);
                subscribeToProfile(session.user.id);
            }
        });
        return () => {
            authListener.subscription.unsubscribe();
            supabase.removeAllChannels();
        };
    }, []);

    useEffect(() => {
        if (profile?.role === 'admin') {
            fetchAllUsers();
            fetchLicenses();
        }
    }, [profile]);

    function subscribeToProfile(uid) {
        supabase
            .channel(`profile-${uid}`)
            .on('postgres_changes', {
                event: 'UPDATE',
                schema: 'public',
                table: 'profiles',
                filter: `id=eq.${uid}`
            }, payload => {
                setProfile(payload.new);
            })
            .subscribe();
    }

    async function fetchAllUsers() {
        const { data } = await supabase.from('profiles').select('*').order('created_at', { ascending: false });
        setUsers(data || []);
    }

    async function fetchLicenses() {
        setRefreshing(true);
        const { data, error } = await supabase
            .from('licenses')
            .select('*, profiles!used_by(username, macho_key)')
            .order('created_at', { ascending: false });

        if (error) console.error("Error fetching licenses:", error);
        setLicenses(data || []);
        setTimeout(() => setRefreshing(false), 600);
    }

    async function toggleBan(targetUser) {
        if (targetUser.role === 'admin') {
            alert("Security: You cannot ban another administrator!");
            return;
        }
        const { error } = await supabase.from('profiles').update({ is_banned: !targetUser.is_banned }).eq('id', targetUser.id);

        if (error) {
            alert("Error: " + error.message);
        } else {
            alert(targetUser.is_banned ? "User Unbanned!" : "User Banned!");
            fetchAllUsers();
        }
    }

    async function checkUser() {
        const { data: { session } } = await supabase.auth.getSession();
        setUser(session?.user ?? null);
        if (session?.user) {
            fetchProfile(session.user.id, session.user);
            subscribeToProfile(session.user.id);
        }
        setLoading(false);
    }

    async function fetchProfile(uid, sessionUser = null) {
        const { data, error } = await supabase.from('profiles').select('*').eq('id', uid).single();

        if (error || !data) {
            console.warn("Profile missing or inaccessible, attempting to fix...");
            const currentUser = sessionUser || user;
            const { data: newProfile } = await supabase
                .from('profiles')
                .upsert([{
                    id: uid,
                    username: currentUser?.email?.split('@')[0] || 'User',
                    role: 'client'
                }])
                .select()
                .single();

            if (newProfile) {
                setProfile(newProfile);
            } else {
                setProfile({ id: uid, role: 'client', username: currentUser?.email?.split('@')[0] || 'User' });
            }
            return;
        }

        if (data) setProfile(data);
    }

    const refreshData = () => {
        if (user) fetchProfile(user.id);
        if (profile?.role === 'admin') {
            fetchAllUsers();
            fetchLicenses();
        }
    };

    async function activateLicense() {
        if (!licenseKey) return alert("Please enter a license key.");
        setLoading(true);

        const { data: keyData, error: findError } = await supabase
            .from('licenses')
            .select('*')
            .eq('key', licenseKey)
            .eq('is_used', false)
            .single();

        if (findError || !keyData) {
            alert("Invalid or already used license key.");
            setLoading(false);
            return;
        }

        const { error: updateError } = await supabase
            .from('licenses')
            .update({
                is_used: true,
                used_by: user.id
            })
            .eq('id', keyData.id);

        if (updateError) {
            alert("Activation failed: " + updateError.message);
        } else {
            alert("License activated successfully!");
            // Force immediate refresh
            fetchAllUsers();
            fetchLicenses();
            fetchProfile(user.id);
        }
        setLoading(false);
    }

    async function syncMachoKey() {
        const keyToSync = machoKey || profile?.macho_key;
        if (!keyToSync) return alert("Please enter your Macho Key.");
        setLoading(true);
        const { error } = await supabase
            .from('profiles')
            .update({ macho_key: keyToSync })
            .eq('id', user.id);

        if (error) {
            alert("Error syncing key: " + error.message);
        } else {
            alert("Macho Key synced successfully!");
            fetchProfile(user.id);
            if (profile?.role === 'admin') {
                fetchAllUsers();
                fetchLicenses();
            }
        }
        setLoading(false);
    }

    const handleAuth = async (e) => {
        e.preventDefault();
        setLoading(true);
        if (authMode === 'register') {
            const { data, error } = await supabase.auth.signUp({ email: formData.email, password: formData.password });
            if (!error && data.user) {
                await supabase.from('profiles').insert([{ id: data.user.id, username: formData.username, role: 'client' }]);
                setAuthMode('login');
                alert('Account created!');
            } else alert(error.message);
        } else {
            const { error } = await supabase.auth.signInWithPassword({ email: formData.email, password: formData.password });
            if (error) alert(error.message);
        }
        setLoading(false);
    };

    if (loading) return <div style={{ display: 'flex', height: '100vh', alignItems: 'center', justifyContent: 'center' }}>Loading...</div>;

    if (!user) {
        return (
            <div className="auth-container">
                <div className="auth-card">
                    <div style={{ textAlign: 'center', marginBottom: '2rem' }}>
                        <h1 className="logo" style={{ fontSize: '2rem', marginBottom: '0.5rem' }}>PIXEL<span>UI</span></h1>
                        <p style={{ color: '#666', fontSize: '0.9rem' }}>{authMode === 'login' ? 'Sign in to your account' : 'Create a new account'}</p>
                    </div>
                    <form onSubmit={handleAuth}>
                        {authMode === 'register' && (
                            <div className="form-group">
                                <label>Username</label>
                                <input type="text" placeholder="Enter username" required onChange={e => setFormData({ ...formData, username: e.target.value })} />
                            </div>
                        )}
                        <div className="form-group">
                            <label>Email Address</label>
                            <input type="email" placeholder="Enter email" required onChange={e => setFormData({ ...formData, email: e.target.value })} />
                        </div>
                        <div className="form-group">
                            <label>Password</label>
                            <input type="password" placeholder="Enter password" required onChange={e => setFormData({ ...formData, password: e.target.value })} />
                        </div>
                        <button className="btn btn-primary" style={{ width: '100%' }}>
                            {authMode === 'login' ? 'Sign In' : 'Create Account'}
                        </button>
                    </form>
                    <p style={{ marginTop: '1.5rem', textAlign: 'center', fontSize: '0.85rem', color: '#666' }}>
                        {authMode === 'login' ? "Don't have an account? " : "Already have an account? "}
                        <span style={{ color: 'var(--primary)', cursor: 'pointer', fontWeight: '600' }} onClick={() => setAuthMode(authMode === 'login' ? 'register' : 'login')}>
                            {authMode === 'login' ? 'Register' : 'Login'}
                        </span>
                    </p>
                </div>
            </div>
        );
    }

    return (
        <div>
            <nav className="navbar">
                <div className="logo">PIXEL<span>UI</span></div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                    <div className="refresh-btn" onClick={refreshData} title="Refresh Data">
                        <Activity size={16} />
                    </div>
                    <span style={{ fontSize: '0.9rem', fontWeight: '500', color: 'var(--text-dim)' }}>{profile?.username}</span>
                    <button className="btn btn-outline" style={{ padding: '0.5rem 1rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }} onClick={() => supabase.auth.signOut()}>
                        <LogOut size={16} />
                        <span style={{ fontSize: '0.8rem' }}>Logout</span>
                    </button>
                </div>
            </nav>

            <div className="container">
                {profile?.is_banned ? (
                    <div className="card" style={{ textAlign: 'center', borderColor: '#feb2b2', background: '#fff5f5' }}>
                        <Ban size={48} color="#c53030" style={{ marginBottom: '1rem' }} />
                        <h2 style={{ color: '#c53030' }}>Access Denied</h2>
                        <p style={{ color: '#9b2c2c' }}>Your account has been suspended.</p>
                    </div>
                ) : (
                    <>
                        <div className="tabs">
                            <div className={`tab ${activeTab === 'dashboard' ? 'active' : ''}`} onClick={() => setActiveTab('dashboard')}>Dashboard</div>
                            <div className={`tab ${activeTab === 'license' ? 'active' : ''}`} onClick={() => setActiveTab('license')}>License</div>
                            {profile?.role === 'admin' && (
                                <div className={`tab ${activeTab === 'admin' ? 'active' : ''}`} onClick={() => setActiveTab('admin')}>Admin</div>
                            )}
                        </div>

                        {activeTab === 'dashboard' && (
                            <div className="card">
                                <div className="card-title"><Activity size={18} color="var(--primary)" /> System Status</div>
                                <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', color: '#2ecc71', fontWeight: '700', fontSize: '1.2rem', marginBottom: '1rem' }}>
                                    <CheckCircle size={20} /> UNDETECTED
                                </div>
                                <p style={{ color: '#666', fontSize: '0.9rem' }}>The menu is currently safe to use on all supported servers.</p>
                                <div style={{ marginTop: '2rem', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
                                    <div style={{ padding: '1.5rem', background: 'var(--input-bg)', borderRadius: '8px', border: '1px solid var(--border)' }}>
                                        <p style={{ fontSize: '0.75rem', color: 'var(--text-dim)', fontWeight: '700' }}>YOUR RANK</p>
                                        <p style={{ fontSize: '1.1rem', fontWeight: '600', color: 'white' }}>
                                            {profile ? (profile.role ? profile.role.toUpperCase() : 'CLIENT') : 'FETCHING...'}
                                        </p>
                                    </div>
                                    <div style={{ padding: '1.5rem', background: 'var(--input-bg)', borderRadius: '8px', border: '1px solid var(--border)' }}>
                                        <p style={{ fontSize: '0.75rem', color: 'var(--text-dim)', fontWeight: '700' }}>VERSION</p>
                                        <p style={{ fontSize: '1.1rem', fontWeight: '600', color: 'white' }}>v2.4.0</p>
                                    </div>
                                </div>
                            </div>
                        )}

                        {activeTab === 'license' && (
                            <div style={{ maxWidth: '600px' }}>
                                <div className="card">
                                    <div className="card-title"><Shield size={18} color="var(--primary)" /> Account Setup</div>
                                    <p style={{ color: 'var(--text-dim)', fontSize: '0.85rem', marginBottom: '1.5rem' }}>
                                        Enter your license key and sync your Macho key to start using PixelUI.
                                    </p>

                                    <div className="form-group">
                                        <label>Macho Auth Key (Required for Menu)</label>
                                        <input
                                            placeholder="Paste your Macho key from F8 console"
                                            defaultValue={profile?.macho_key}
                                            onChange={e => setMachoKey(e.target.value)}
                                        />
                                    </div>

                                    <div className="form-group">
                                        <label>License Key (Optional if already active)</label>
                                        <input
                                            placeholder="PXUI-XXXX-XXXX-XXXX"
                                            onChange={e => setLicenseKey(e.target.value)}
                                        />
                                    </div>

                                    <button
                                        className="btn btn-primary"
                                        style={{ width: '100%', marginTop: '1rem' }}
                                        onClick={async () => {
                                            setLoading(true);
                                            let success = false;

                                            // 1. Sync Macho Key if provided
                                            const keyToSync = machoKey || profile?.macho_key;
                                            if (keyToSync) {
                                                const { error } = await supabase.from('profiles').update({ macho_key: keyToSync }).eq('id', user.id);
                                                if (!error) success = true;
                                            }

                                            // 2. Activate License if provided
                                            if (licenseKey) {
                                                const { data: keyData } = await supabase.from('licenses').select('*').eq('key', licenseKey).eq('is_used', false).single();
                                                if (keyData) {
                                                    const { error: upErr } = await supabase.from('licenses').update({ is_used: true, used_by: user.id }).eq('id', keyData.id);
                                                    if (!upErr) success = true;
                                                    else alert("License Error: " + upErr.message);
                                                } else {
                                                    alert("Invalid or used license key.");
                                                }
                                            }

                                            if (success) {
                                                alert("Account updated successfully!");
                                                fetchProfile(user.id);
                                                if (profile?.role === 'admin') { fetchAllUsers(); fetchLicenses(); }
                                            }
                                            setLoading(false);
                                        }}
                                        disabled={loading}
                                    >
                                        {loading ? 'Processing...' : 'Save & Activate'}
                                    </button>
                                </div>
                            </div>
                        )}

                        {activeTab === 'admin' && profile?.role === 'admin' && (
                            <div className="card">
                                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '2rem' }}>
                                    <div className="card-title" style={{ marginBottom: 0 }}><Users size={18} color="var(--primary)" /> Admin Control</div>
                                    <div style={{ display: 'flex', gap: '0.5rem', background: 'var(--input-bg)', padding: '0.3rem', borderRadius: '8px' }}>
                                        <button className={`btn ${adminSubTab === 'users' ? 'btn-primary' : 'btn-outline'}`} style={{ padding: '0.4rem 1rem', fontSize: '0.8rem' }} onClick={() => setAdminSubTab('users')}>Users</button>
                                        <button className={`btn ${adminSubTab === 'keys' ? 'btn-primary' : 'btn-outline'}`} style={{ padding: '0.4rem 1rem', fontSize: '0.8rem' }} onClick={() => setAdminSubTab('keys')}>Keys</button>
                                    </div>
                                </div>

                                {adminSubTab === 'users' ? (
                                    <div>
                                        <div style={{ marginBottom: '2rem' }}>
                                            <button className="btn btn-primary" onClick={async () => {
                                                const newKey = `PXUI-${Math.random().toString(36).substr(2, 4).toUpperCase()}-${Math.random().toString(36).substr(2, 4).toUpperCase()}-${Math.random().toString(36).substr(2, 4).toUpperCase()}`;
                                                const { error } = await supabase.from('licenses').insert([{ key: newKey }]);
                                                if (error) alert("Error: " + error.message);
                                                else { fetchLicenses(); alert(`Key Generated: ${newKey}`); }
                                            }}>
                                                <Plus size={16} /> Generate Master Key
                                            </button>
                                        </div>
                                        <div>
                                            {users.map(u => (
                                                <div key={u.id} className="user-item">
                                                    <div>
                                                        <p style={{ fontWeight: '600', fontSize: '0.95rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                                                            {u.username} {u.role === 'admin' && <Shield size={14} color="var(--primary)" />}
                                                        </p>
                                                        <p style={{ fontSize: '0.8rem', color: '#888' }}>{u.macho_key || 'No key linked'}</p>
                                                    </div>
                                                    <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                                                        <span className={`status-tag ${u.is_banned ? 'status-banned' : 'status-active'}`}>{u.is_banned ? 'Banned' : 'Active'}</span>
                                                        <button onClick={() => toggleBan(u)} className="btn btn-outline" style={{ padding: '0.4rem 0.8rem', fontSize: '0.75rem', opacity: u.role === 'admin' ? 0.5 : 1 }} disabled={u.role === 'admin'}>{u.is_banned ? 'Unban' : 'Ban'}</button>
                                                    </div>
                                                </div>
                                            ))}
                                        </div>
                                    </div>
                                ) : (
                                    <div>
                                        <div style={{ marginBottom: '2rem', display: 'flex', gap: '1rem' }}>
                                            <button className="btn btn-primary" onClick={async () => {
                                                const newKey = `PXUI-${Math.random().toString(36).substr(2, 4).toUpperCase()}-${Math.random().toString(36).substr(2, 4).toUpperCase()}-${Math.random().toString(36).substr(2, 4).toUpperCase()}`;
                                                const { error } = await supabase.from('licenses').insert([{ key: newKey }]);
                                                if (error) alert("Error: " + error.message);
                                                else { fetchLicenses(); alert(`Key Generated: ${newKey}`); }
                                            }}>
                                                <Plus size={16} /> Generate Master Key
                                            </button>
                                            <button className={`btn btn-outline ${refreshing ? 'refreshing' : ''}`} onClick={fetchLicenses} disabled={refreshing}>
                                                <Activity size={16} className={refreshing ? 'spin' : ''} /> {refreshing ? 'Refreshing...' : 'Refresh Keys'}
                                            </button>
                                        </div>
                                        <div className="keys-grid">
                                            {licenses.map(l => (
                                                <div key={l.id} className="user-item" style={{ padding: '1.2rem', background: 'rgba(255,255,255,0.02)', borderRadius: '8px', marginBottom: '0.5rem' }}>
                                                    <div>
                                                        <p style={{ fontWeight: '700', color: 'white', letterSpacing: '1px' }}>{l.key}</p>
                                                        <p style={{ fontSize: '0.8rem', color: '#666', marginTop: '0.3rem' }}>
                                                            {l.profiles ? (
                                                                <span>Used by: <b style={{ color: 'var(--primary)' }}>{l.profiles.username || 'Unknown'}</b></span>
                                                            ) : (
                                                                <span style={{ color: '#2ecc71' }}>Available</span>
                                                            )}
                                                        </p>
                                                    </div>
                                                    {l.profiles && (
                                                        <div style={{ textAlign: 'right' }}>
                                                            <p style={{ fontSize: '0.7rem', color: '#555', textTransform: 'uppercase', fontWeight: '800' }}>Macho Key</p>
                                                            <p style={{ fontSize: '0.85rem', color: '#aaa', fontFamily: 'monospace' }}>{l.profiles.macho_key || 'N/A'}</p>
                                                        </div>
                                                    )}
                                                </div>
                                            ))}
                                            {licenses.length === 0 && <p style={{ textAlign: 'center', color: '#555', padding: '2rem' }}>No licenses found.</p>}
                                        </div>
                                    </div>
                                )}
                            </div>
                        )}
                    </>
                )}
            </div>
        </div>
    );
}

export default App;
