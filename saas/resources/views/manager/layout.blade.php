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
            <a href="{{ route('manager.dashboard') }}" class="{{ request()->routeIs('manager.dashboard') ? 'active' : '' }}">Dashboard</a>
            <a href="{{ route('manager.stores.index') }}" class="{{ request()->routeIs('manager.stores.*') ? 'active' : '' }}">Stores</a>
            <a href="{{ route('manager.printing_services.index') }}" class="{{ request()->routeIs('manager.printing_services.*') ? 'active' : '' }}">Printing</a>
            <a href="{{ route('manager.categories.index') }}" class="{{ request()->routeIs('manager.categories.*') ? 'active' : '' }}">Categories</a>
            <a href="{{ route('manager.product_option_categories.index') }}" class="{{ request()->routeIs('manager.product_option_categories.*') ? 'active' : '' }}">Product Option Categories</a>
            <a href="{{ route('manager.product_options.index') }}" class="{{ request()->routeIs('manager.product_options.*') ? 'active' : '' }}">Product Options</a>
            <a href="{{ route('manager.products.index') }}" class="{{ request()->routeIs('manager.products.*') ? 'active' : '' }}">Products</a>
            <a href="{{ route('manager.stock.index') }}" class="{{ request()->routeIs('manager.stock.*') ? 'active' : '' }}">Stock</a>
            <a href="{{ route('manager.customers.index') }}" class="{{ request()->routeIs('manager.customers.*') ? 'active' : '' }}">Customers</a>
            <a href="{{ route('manager.taxes.index') }}" class="{{ request()->routeIs('manager.taxes.*') ? 'active' : '' }}">Taxes</a>
            <a href="{{ route('manager.discounts.index') }}" class="{{ request()->routeIs('manager.discounts.*') ? 'active' : '' }}">Discounts</a>
            <a href="{{ route('manager.shipping.index') }}" class="{{ request()->routeIs('manager.shipping.*') ? 'active' : '' }}">Shipping</a>
            <a href="{{ route('manager.loyalty.edit') }}" class="{{ request()->routeIs('manager.loyalty.*') ? 'active' : '' }}">Loyalty</a>
            <a href="{{ route('manager.sales.index') }}" class="{{ request()->routeIs('manager.sales.*') ? 'active' : '' }}">Sales</a>
            <a href="{{ route('manager.users.index') }}" class="{{ request()->routeIs('manager.users.*') ? 'active' : '' }}">Users</a>
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
