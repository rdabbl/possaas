<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{{ t("Manager Portal") }}</title>
    <style>
        :root {
            color-scheme: light;
            --bg: #f8fafc;
            --card: #ffffff;
            --text: #0f172a;
            --muted: #64748b;
            --accent: #1d4ed8;
            --border: #e2e8f0;
        }
        :root[data-theme="dark"] {
            color-scheme: dark;
            --bg: #0b1220;
            --card: #0f172a;
            --text: #e2e8f0;
            --muted: #94a3b8;
            --accent: #38bdf8;
            --border: #1f2937;
        }
        body { margin:0; font-family: "Segoe UI", system-ui, -apple-system, sans-serif; background: var(--bg); color: var(--text); }
        .layout { display: flex; min-height: 100vh; }
        .sidebar {
            width: 240px;
            background: var(--card);
            border-right: 1px solid var(--border);
            padding: 20px 16px;
            box-sizing: border-box;
        }
        .brand a { color: var(--text); text-decoration: none; font-weight: 700; }
        nav { margin-top: 20px; display: flex; flex-direction: column; gap: 8px; }
        nav a {
            color: var(--muted);
            text-decoration: none;
            padding: 8px 10px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
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
        nav a.active { color: var(--accent); font-weight: 600; background: #eff6ff; }
        .content { flex: 1; display: flex; flex-direction: column; }
        header { background: var(--card); border-bottom: 1px solid var(--border); padding: 16px 24px; display:flex; align-items:center; justify-content: flex-end; flex-wrap: wrap; gap: 16px; }
        .header-right { display:flex; align-items:center; gap: 12px; }
        .header-controls { display: flex; align-items: center; gap: 12px; }
        .lang-select select { width: 160px; }
        .theme-toggle { display: inline-flex; align-items: center; gap: 8px; }
        .small { font-size: 12px; }
        .user-chip { color: var(--muted); font-size: 14px; }
        main { padding: 24px; max-width: 1100px; margin: 0 auto; width: 100%; }
        .card { background: var(--card); border: 1px solid var(--border); border-radius: 12px; padding: 16px; box-shadow: 0 1px 2px rgba(0,0,0,0.04); }
        .grid { display:grid; gap: 16px; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); }
        .muted { color: var(--muted); }
        .row { display:flex; gap: 12px; flex-wrap: wrap; }
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
        .qty-btn:hover { background: #f1f5f9; }
        .qty-btn:active { transform: translateY(1px); }
        .qty-input {
            width: 72px;
            text-align: center;
            padding: 6px 8px;
        }
        .btn { display:inline-block; padding: 8px 12px; background: var(--accent); color: #fff; border-radius: 8px; text-decoration:none; border:0; cursor:pointer; }
        .btn.secondary { background: #334155; }
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
        table { width:100%; border-collapse: collapse; }
        th, td { text-align:left; padding: 10px 8px; border-bottom: 1px solid var(--border); }
        th { font-size: 12px; text-transform: uppercase; color: var(--muted); letter-spacing:.04em; }
        input, select, textarea { padding: 8px; border: 1px solid var(--border); border-radius: 8px; width:100%; box-sizing:border-box; }
        label { font-size: 12px; color: var(--muted); display:block; margin-bottom:6px; }
        .field { margin-bottom: 12px; }
        .flash { padding: 10px; border-radius: 8px; margin-bottom: 12px; }
        .flash.success { background:#ecfdf3; color:#065f46; border:1px solid #a7f3d0; }
        .flash.error { background:#fef2f2; color:#991b1b; border:1px solid #fecaca; }
        ul { margin:0; padding-left:16px; }
        @media (max-width: 900px) {
            .layout { flex-direction: column; }
            .sidebar { width: 100%; border-right: 0; border-bottom: 1px solid var(--border); }
            nav { flex-direction: row; flex-wrap: wrap; }
        }
    </style>
</head>
<body>
<div class="layout">
    <aside class="sidebar">
        <div class="brand">
            <a href="{{ route('manager.dashboard') }}">{{ t("Manager Portal") }}</a>
        </div>
        <nav>
            <a href="{{ route('manager.dashboard') }}" class="{{ request()->routeIs('manager.dashboard') ? 'active' : '' }}"><span class="nav-icon"><svg viewBox="0 0 24 24"><path d="M3 11l9-8 9 8"></path><path d="M5 10v10h14V10"></path></svg></span>Dashboard</a>
            <a href="{{ route('manager.stores.index') }}" class="{{ request()->routeIs('manager.stores.*') ? 'active' : '' }}"><span class="nav-icon"><svg viewBox="0 0 24 24"><path d="M3 9l2-5h14l2 5"></path><path d="M5 9v11h14V9"></path><path d="M9 20v-6h6v6"></path></svg></span>Stores</a>
            <a href="{{ route('manager.payment_methods.index') }}" class="{{ request()->routeIs('manager.payment_methods.*') ? 'active' : '' }}"><span class="nav-icon"><svg viewBox="0 0 24 24"><rect x="2" y="5" width="20" height="14" rx="2"></rect><path d="M2 10h20"></path></svg></span>Payment Methods</a>
            <a href="{{ route('manager.printing_services.index') }}" class="{{ request()->routeIs('manager.printing_services.*') ? 'active' : '' }}"><span class="nav-icon"><svg viewBox="0 0 24 24"><path d="M6 9V2h12v7"></path><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"></path><rect x="6" y="14" width="12" height="8"></rect></svg></span>Printing Services</a>
            <a href="{{ route('manager.categories.index') }}" class="{{ request()->routeIs('manager.categories.*') ? 'active' : '' }}"><span class="nav-icon"><svg viewBox="0 0 24 24"><path d="M20.59 13.41L11 3.83V2h-3v3l9.59 9.59a2 2 0 0 0 2.83 0l.17-.17a2 2 0 0 0 0-2.83z"></path><circle cx="7.5" cy="7.5" r="1.5"></circle></svg></span>Categories</a>
            <a href="{{ route('manager.product_option_categories.index') }}" class="{{ request()->routeIs('manager.product_option_categories.*') ? 'active' : '' }}"><span class="nav-icon"><svg viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect></svg></span>Product Option Categories</a>
            <a href="{{ route('manager.product_options.index') }}" class="{{ request()->routeIs('manager.product_options.*') ? 'active' : '' }}"><span class="nav-icon"><svg viewBox="0 0 24 24"><path d="M6 2h12"></path><path d="M9 2v6l-5 9a4 4 0 0 0 3.5 6h9a4 4 0 0 0 3.5-6l-5-9V2"></path></svg></span>Product Options</a>
            <a href="{{ route('manager.products.index') }}" class="{{ request()->routeIs('manager.products.*') ? 'active' : '' }}"><span class="nav-icon"><svg viewBox="0 0 24 24"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path><path d="M3.27 6.96L12 12l8.73-5.04"></path><path d="M12 22V12"></path></svg></span>Products</a>
            <a href="{{ route('manager.catalog_transfer.index') }}" class="{{ request()->routeIs('manager.catalog_transfer.*') ? 'active' : '' }}"><span class="nav-icon"><svg viewBox="0 0 24 24"><path d="M12 3v12"></path><path d="M8 11l4 4 4-4"></path><path d="M4 17v2a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-2"></path></svg></span>Catalog Transfer</a>
            <a href="{{ route('manager.stock.index') }}" class="{{ request()->routeIs('manager.stock.*') ? 'active' : '' }}"><span class="nav-icon"><svg viewBox="0 0 24 24"><path d="M3 3v18h18"></path><path d="M7 14l3-3 4 4 5-6"></path></svg></span>Stock</a>
            <a href="{{ route('manager.customers.index') }}" class="{{ request()->routeIs('manager.customers.*') ? 'active' : '' }}"><span class="nav-icon"><svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg></span>Customers</a>
            <a href="{{ route('manager.taxes.index') }}" class="{{ request()->routeIs('manager.taxes.*') ? 'active' : '' }}"><span class="nav-icon"><svg viewBox="0 0 24 24"><line x1="19" y1="5" x2="5" y2="19"></line><circle cx="6.5" cy="6.5" r="2.5"></circle><circle cx="17.5" cy="17.5" r="2.5"></circle></svg></span>Taxes</a>
            <a href="{{ route('manager.discounts.index') }}" class="{{ request()->routeIs('manager.discounts.*') ? 'active' : '' }}"><span class="nav-icon"><svg viewBox="0 0 24 24"><path d="M20 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h7"></path><path d="M16 5h6v6"></path><path d="M10 14l12-12"></path></svg></span>Discounts</a>
            <a href="{{ route('manager.shipping.index') }}" class="{{ request()->routeIs('manager.shipping.*') ? 'active' : '' }}"><span class="nav-icon"><svg viewBox="0 0 24 24"><path d="M3 7h11v9H3z"></path><path d="M14 10h4l3 3v3h-7z"></path><circle cx="7" cy="19" r="2"></circle><circle cx="17" cy="19" r="2"></circle></svg></span>Shipping</a>
            <a href="{{ route('manager.loyalty.edit') }}" class="{{ request()->routeIs('manager.loyalty.*') ? 'active' : '' }}"><span class="nav-icon"><svg viewBox="0 0 24 24"><path d="M12 21s-7-4.35-7-10a4 4 0 0 1 7-2.65A4 4 0 0 1 19 11c0 5.65-7 10-7 10z"></path></svg></span>Loyalty</a>
            <a href="{{ route('manager.sales.index') }}" class="{{ request()->routeIs('manager.sales.*') ? 'active' : '' }}"><span class="nav-icon"><svg viewBox="0 0 24 24"><path d="M3 3v18h18"></path><path d="M8 14h2"></path><path d="M12 10h2"></path><path d="M16 7h2"></path></svg></span>Sales</a>
            <a href="{{ route('manager.users.index') }}" class="{{ request()->routeIs('manager.users.*') ? 'active' : '' }}"><span class="nav-icon"><svg viewBox="0 0 24 24"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M22 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg></span>Users</a>
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
