<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Tenant Portal</title>
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
        header { background: var(--card); border-bottom: 1px solid var(--border); padding: 16px 24px; display:flex; align-items:center; justify-content: flex-end; gap: 16px; }
        .header-right { display:flex; align-items:center; gap: 12px; }
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
            <a href="{{ route('tenant.dashboard') }}">Tenant Portal</a>
        </div>
        <nav>
            <a href="{{ route('tenant.dashboard') }}" class="{{ request()->routeIs('tenant.dashboard') ? 'active' : '' }}">Dashboard</a>
            <a href="{{ route('tenant.stores.index') }}" class="{{ request()->routeIs('tenant.stores.*') ? 'active' : '' }}">Stores</a>
            <a href="{{ route('tenant.categories.index') }}" class="{{ request()->routeIs('tenant.categories.*') ? 'active' : '' }}">Categories</a>
            <a href="{{ route('tenant.ingredient_categories.index') }}" class="{{ request()->routeIs('tenant.ingredient_categories.*') ? 'active' : '' }}">Ingredient Categories</a>
            <a href="{{ route('tenant.ingredients.index') }}" class="{{ request()->routeIs('tenant.ingredients.*') ? 'active' : '' }}">Ingredients</a>
            <a href="{{ route('tenant.products.index') }}" class="{{ request()->routeIs('tenant.products.*') ? 'active' : '' }}">Products</a>
            <a href="{{ route('tenant.stock.index') }}" class="{{ request()->routeIs('tenant.stock.*') ? 'active' : '' }}">Stock</a>
            <a href="{{ route('tenant.customers.index') }}" class="{{ request()->routeIs('tenant.customers.*') ? 'active' : '' }}">Customers</a>
            <a href="{{ route('tenant.taxes.index') }}" class="{{ request()->routeIs('tenant.taxes.*') ? 'active' : '' }}">Taxes</a>
            <a href="{{ route('tenant.discounts.index') }}" class="{{ request()->routeIs('tenant.discounts.*') ? 'active' : '' }}">Discounts</a>
            <a href="{{ route('tenant.sales.index') }}" class="{{ request()->routeIs('tenant.sales.*') ? 'active' : '' }}">Sales</a>
            <a href="{{ route('tenant.users.index') }}" class="{{ request()->routeIs('tenant.users.*') ? 'active' : '' }}">Users</a>
        </nav>
    </aside>
    <div class="content">
        <header>
            <div class="header-right">
                @if (auth()->check())
                    <div class="user-chip">{{ auth()->user()->name }}</div>
                    <form method="POST" action="{{ route('logout') }}">
                        @csrf
                        <button class="btn secondary" type="submit">Logout</button>
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
</body>
</html>
