<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{{ t("POS SaaS Admin") }}</title>
    <style>
        :root {
            color-scheme: light;
            --bg: #f5f5f7;
            --card: #ffffff;
            --text: #111827;
            --muted: #6b7280;
            --accent: #0f766e;
            --border: #e5e7eb;
        }
        :root[data-theme="dark"] {
            color-scheme: dark;
            --bg: #0b1220;
            --card: #0f172a;
            --text: #e2e8f0;
            --muted: #94a3b8;
            --accent: #14b8a6;
            --border: #1f2937;
        }
        body {
            margin: 0;
            font-family: "Segoe UI", system-ui, -apple-system, sans-serif;
            background: var(--bg);
            color: var(--text);
        }
        .layout { display: flex; min-height: 100vh; }
        .sidebar {
            width: 240px;
            background: var(--card);
            border-right: 1px solid var(--border);
            padding: 20px 16px;
            box-sizing: border-box;
        }
        .brand a { color: var(--text); text-decoration: none; font-weight: 700; }
        nav { margin-top: 20px; display: flex; flex-direction: column; gap: 16px; }
        .nav-section { display: flex; flex-direction: column; gap: 8px; }
        .nav-title { font-size: 11px; text-transform: uppercase; letter-spacing: .14em; color: var(--muted); padding: 0 10px; }
        nav a {
            color: var(--muted);
            text-decoration: none;
            padding: 8px 10px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        nav a:hover { background: rgba(15, 118, 110, 0.08); color: var(--text); }
        .nav-icon {
            width: 18px;
            height: 18px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            flex: 0 0 18px;
        }
        .nav-icon svg {
            width: 18px;
            height: 18px;
            stroke: currentColor;
            fill: none;
            stroke-width: 2;
            stroke-linecap: round;
            stroke-linejoin: round;
        }
        nav a.active { color: var(--accent); font-weight: 600; background: #ecfdf3; }
        .content { flex: 1; display: flex; flex-direction: column; }
        header {
            background: var(--card);
            border-bottom: 1px solid var(--border);
            padding: 16px 24px;
            display: flex;
            align-items: center;
            justify-content: flex-end;
            flex-wrap: wrap;
            gap: 16px;
        }
        .header-right { display: flex; align-items: center; gap: 12px; }
        .header-controls { display: flex; align-items: center; gap: 12px; }
        .lang-select select { width: 160px; }
        .theme-toggle { display: inline-flex; align-items: center; gap: 8px; }
        .small { font-size: 12px; }
        .user-chip { color: var(--muted); font-size: 14px; }
        main { padding: 24px; max-width: 1100px; margin: 0 auto; width: 100%; }
        .card {
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 16px;
            box-shadow: 0 1px 2px rgba(0,0,0,0.04);
        }
        .card-link { display: block; text-decoration: none; color: inherit; transition: transform .15s ease, box-shadow .15s ease, border-color .15s ease; }
        .card-link:hover { transform: translateY(-2px); box-shadow: 0 6px 14px rgba(0,0,0,0.12); border-color: var(--accent); }
        .grid { display: grid; gap: 16px; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); }
        .muted { color: var(--muted); }
        .row { display: flex; gap: 12px; flex-wrap: wrap; }
        .avatar {
            width: 36px;
            height: 36px;
            border-radius: 999px;
            background: linear-gradient(135deg, #0f766e, #10b981);
            color: #fff;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            font-weight: 700;
        }
        .qty-control { display: inline-flex; align-items: center; gap: 8px; }
        .qty-btn {
            width: 32px;
            height: 32px;
            border-radius: 8px;
            border: 1px solid var(--border);
            background: #fff;
            color: var(--text);
            font-weight: 600;
            cursor: pointer;
        }
        .qty-btn:hover { background: #f3f4f6; }
        .qty-btn:active { transform: translateY(1px); }
        .qty-input {
            width: 72px;
            text-align: center;
            padding: 6px 8px;
        }
        .btn {
            display: inline-block;
            padding: 8px 12px;
            background: var(--accent);
            color: #fff;
            border-radius: 8px;
            text-decoration: none;
            border: 0;
            cursor: pointer;
        }
        .btn.secondary { background: #374151; }
        .toggle-form { display: inline-flex; align-items: center; }
        .toggle {
            position: relative;
            display: inline-flex;
            width: 38px;
            height: 22px;
            align-items: center;
        }
        .toggle input { display: none; }
        .toggle span {
            position: absolute;
            inset: 0;
            background: #e5e7eb;
            border-radius: 999px;
            transition: background .2s ease;
        }
        .toggle span::before {
            content: "";
            position: absolute;
            width: 18px;
            height: 18px;
            left: 2px;
            top: 2px;
            background: #fff;
            border-radius: 50%;
            transition: transform .2s ease;
        }
        .toggle input:checked + span { background: var(--accent); }
        .toggle input:checked + span::before { transform: translateX(16px); }
        table { width: 100%; border-collapse: collapse; }
        th, td { text-align: left; padding: 10px 8px; border-bottom: 1px solid var(--border); }
        th { font-size: 12px; text-transform: uppercase; color: var(--muted); letter-spacing: .04em; }
        input, select, textarea {
            padding: 8px;
            border: 1px solid var(--border);
            border-radius: 8px;
            width: 100%;
            box-sizing: border-box;
        }
        label { font-size: 12px; color: var(--muted); display: block; margin-bottom: 6px; }
        .field { margin-bottom: 12px; }
        .flash { padding: 10px; border-radius: 8px; margin-bottom: 12px; }
        .flash.success { background: #ecfdf3; color: #065f46; border: 1px solid #a7f3d0; }
        .flash.error { background: #fef2f2; color: #991b1b; border: 1px solid #fecaca; }
        ul { margin: 0; padding-left: 16px; }
        @media (max-width: 900px) {
            .layout { flex-direction: column; }
            .sidebar { width: 100%; border-right: 0; border-bottom: 1px solid var(--border); }
            nav { flex-direction: column; }
        }
    </style>
</head>
<body>
<div class="layout">
    <aside class="sidebar">
        <div class="brand">
            <a href="{{ route('admin.dashboard') }}">{{ t("POS SaaS Admin") }}</a>
        </div>
        <nav>
            <div class="nav-section">
                <div class="nav-title">{{ t("SaaS Menu") }}</div>
                <a href="{{ route('admin.dashboard') }}" class="{{ request()->routeIs('admin.dashboard') ? 'active' : '' }}">
                    <span class="nav-icon">
                        <svg viewBox="0 0 24 24"><path d="M3 11l9-8 9 8"></path><path d="M5 10v10h14V10"></path></svg>
                    </span>
                    {{ t("Dashboard") }}
                </a>
                <a href="{{ route('admin.managers.index') }}" class="{{ request()->routeIs('admin.managers.*') ? 'active' : '' }}">
                    <span class="nav-icon">
                        <svg viewBox="0 0 24 24"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M22 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
                    </span>
                    {{ t("Managers") }}
                </a>
                <a href="{{ route('admin.plans.index') }}" class="{{ request()->routeIs('admin.plans.*') ? 'active' : '' }}">
                    <span class="nav-icon">
                        <svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2"></rect><path d="M16 2v4"></path><path d="M8 2v4"></path><path d="M3 10h18"></path></svg>
                    </span>
                    {{ t("Plans") }}
                </a>
                <a href="{{ route('admin.subscriptions.index') }}" class="{{ request()->routeIs('admin.subscriptions.*') ? 'active' : '' }}">
                    <span class="nav-icon">
                        <svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2"></rect><path d="M7 8h10"></path><path d="M7 12h6"></path><path d="M7 16h8"></path></svg>
                    </span>
                    {{ t("Subscriptions") }}
                </a>
                <a href="{{ route('admin.stores.index') }}" class="{{ request()->routeIs('admin.stores.*') ? 'active' : '' }}">
                    <span class="nav-icon">
                        <svg viewBox="0 0 24 24"><path d="M3 9l2-5h14l2 5"></path><path d="M5 9v11h14V9"></path><path d="M9 20v-6h6v6"></path></svg>
                    </span>
                    {{ t("Stores") }}
                </a>
                <a href="{{ route('admin.payment_methods.index') }}" class="{{ request()->routeIs('admin.payment_methods.*') ? 'active' : '' }}">
                    <span class="nav-icon">
                        <svg viewBox="0 0 24 24"><rect x="2" y="5" width="20" height="14" rx="2"></rect><path d="M2 10h20"></path></svg>
                    </span>
                    {{ t("Payment Methods") }}
                </a>
                <a href="{{ route('admin.currencies.index') }}" class="{{ request()->routeIs('admin.currencies.*') ? 'active' : '' }}">
                    <span class="nav-icon">
                        <svg viewBox="0 0 24 24"><path d="M12 1v22"></path><path d="M17 5H9a4 4 0 0 0 0 8h6a4 4 0 0 1 0 8H6"></path></svg>
                    </span>
                    {{ t("Currencies") }}
                </a>
                <a href="{{ route('admin.languages.index') }}" class="{{ request()->routeIs('admin.languages.*') ? 'active' : '' }}">
                    <span class="nav-icon">
                        <svg viewBox="0 0 24 24"><path d="M2 5h12"></path><path d="M2 9h12"></path><path d="M2 13h6"></path><path d="M14 17l4-10 4 10"></path><path d="M16 13h4"></path></svg>
                    </span>
                    {{ t("Languages") }}
                </a>
                <a href="{{ route('admin.translations.index') }}" class="{{ request()->routeIs('admin.translations.*') ? 'active' : '' }}">
                    <span class="nav-icon">
                        <svg viewBox="0 0 24 24"><path d="M4 4h16v10H4z"></path><path d="M8 20l4-4 4 4"></path></svg>
                    </span>
                    {{ t("Translations") }}
                </a>
                <a href="{{ route('admin.roles.index') }}" class="{{ request()->routeIs('admin.roles.*') ? 'active' : '' }}">
                    <span class="nav-icon">
                        <svg viewBox="0 0 24 24"><path d="M12 2l8 4v6c0 5-3.5 9-8 10-4.5-1-8-5-8-10V6l8-4z"></path></svg>
                    </span>
                    {{ t("Roles") }}
                </a>
                <a href="{{ route('admin.permissions.index') }}" class="{{ request()->routeIs('admin.permissions.*') ? 'active' : '' }}">
                    <span class="nav-icon">
                        <svg viewBox="0 0 24 24"><path d="M21 8v6"></path><path d="M3 8v6"></path><rect x="7" y="8" width="10" height="10" rx="2"></rect><path d="M12 8V5a3 3 0 0 1 6 0"></path></svg>
                    </span>
                    {{ t("Permissions") }}
                </a>
                <a href="{{ route('admin.reports.index') }}" class="{{ request()->routeIs('admin.reports.*') ? 'active' : '' }}">
                    <span class="nav-icon">
                        <svg viewBox="0 0 24 24"><path d="M3 3v18h18"></path><path d="M7 14l3-3 4 4 5-6"></path></svg>
                    </span>
                    {{ t("Reports") }}
                </a>
                <a href="{{ route('admin.data_transfer.index') }}" class="{{ request()->routeIs('admin.data_transfer.*') ? 'active' : '' }}">
                    <span class="nav-icon">
                        <svg viewBox="0 0 24 24"><path d="M12 3v12"></path><path d="M8 11l4 4 4-4"></path><path d="M4 17v2a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-2"></path></svg>
                    </span>
                    {{ t("Data Transfer") }}
                </a>
            </div>
        </nav>
    </aside>
    <div class="content">
        @php
            $headerLanguages = \App\Models\Language::orderBy('name')->get();
            $currentLang = app()->getLocale();
        @endphp
        <header>
            <div class="header-right">
                <div class="header-controls">
                    @if ($headerLanguages->count())
                        <div class="lang-select">
                            <select data-lang-select>
                                @foreach ($headerLanguages as $language)
                                    <option value="{{ $language->code }}" {{ $currentLang === $language->code ? 'selected' : '' }}>
                                        {{ $language->name }} ({{ strtoupper($language->code) }})
                                    </option>
                                @endforeach
                            </select>
                        </div>
                    @endif
                    <div class="theme-toggle">
                        <span class="muted small">{{ t("Dark") }}</span>
                        <label class="toggle">
                            <input type="checkbox" data-theme-toggle>
                            <span></span>
                        </label>
                    </div>
                </div>
                @if (auth()->check())
                    <div class="user-chip">{{ auth()->user()->name }}</div>
                    <form method="POST" action="{{ route('logout') }}">
                        @csrf
                        <button class="btn secondary" type="submit">{{ t("Logout") }}</button>
                    </form>
                @endif
            </div>
        </header>
        <main>
    @if (session('success'))
        <div class="flash success">{{ session('success') }}</div>
    @endif

    @if ($errors->any())
        <div class="flash error">
            <ul>
                @foreach ($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    @yield('content')
        </main>
    </div>
</div>
<script>
    const themeToggle = document.querySelector('[data-theme-toggle]');
    const langSelect = document.querySelector('[data-lang-select]');
    const toggleForms = document.querySelectorAll('[data-toggle-form]');

    const applyTheme = (theme) => {
        if (theme === 'dark') {
            document.documentElement.setAttribute('data-theme', 'dark');
        } else {
            document.documentElement.removeAttribute('data-theme');
        }
    };

    if (themeToggle) {
        const savedTheme = localStorage.getItem('theme');
        if (savedTheme) {
            applyTheme(savedTheme);
            themeToggle.checked = savedTheme === 'dark';
        }

        themeToggle.addEventListener('change', () => {
            const theme = themeToggle.checked ? 'dark' : 'light';
            localStorage.setItem('theme', theme);
            applyTheme(theme);
        });
    }

    if (langSelect) {
        langSelect.addEventListener('change', () => {
            const url = new URL(window.location.href);
            url.searchParams.set('lang', langSelect.value);
            window.location.href = url.toString();
        });
    }

    toggleForms.forEach((form) => {
        const input = form.querySelector('input[type=\"checkbox\"]');
        if (!input) {
            return;
        }
        input.addEventListener('change', () => form.submit());
    });

    const optionTypeSelects = document.querySelectorAll('[data-option-type]');
    optionTypeSelects.forEach((select) => {
        const form = select.closest('form');
        const stepFields = form ? form.querySelectorAll('[data-option-steps]') : [];
        const sync = () => {
            const show = select.value === 'quantity';
            stepFields.forEach((field) => {
                field.style.display = show ? '' : 'none';
            });
        };
        sync();
        select.addEventListener('change', sync);
    });
</script>
</body>
</html>
