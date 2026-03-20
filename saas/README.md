<p align="center"><a href="https://laravel.com" target="_blank"><img src="https://raw.githubusercontent.com/laravel/art/master/logo-lockup/5%20SVG/2%20CMYK/1%20Full%20Color/laravel-logolockup-cmyk-red.svg" width="400" alt="Laravel Logo"></a></p>

<p align="center">
<a href="https://github.com/laravel/framework/actions"><img src="https://github.com/laravel/framework/workflows/tests/badge.svg" alt="Build Status"></a>
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/packagist/dt/laravel/framework" alt="Total Downloads"></a>
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/packagist/v/laravel/framework" alt="Latest Stable Version"></a>
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/packagist/l/laravel/framework" alt="License"></a>
</p>

## Project Setup

This folder is the Laravel 12 backend + admin panel for the POS SaaS.

## Shared Hosting Install (No Terminal on Server)

These steps assume you can use FTP/cPanel File Manager and phpMyAdmin, but you cannot run commands on the server.

1. Prepare the app locally
Run these commands on your computer (not on the server):

```bash
composer install --no-dev --optimize-autoloader
cp .env.example .env
php artisan key:generate
npm install
npm run build
```

This creates `vendor/` and `public/build/`. Do not upload `node_modules/`.

2. Create the database in your hosting panel
Use the MySQL Database Wizard (or similar) to create a database and user. Save the DB name, user, and password.

3. Upload the application files
Upload this `saas/` folder to a private directory, for example `/home/youruser/saas` or `/home/youruser/app`. Include `vendor/`, `storage/`, `bootstrap/`, and `public/build/`.

4. Point the web root to `public/`
Choose one option depending on your hosting features.

Option A: If you can change the document root
Set the domain or subdomain document root to `/home/youruser/saas/public`.

Option B: If you cannot change the document root
Copy the contents of `public/` into `public_html` and edit `public_html/index.php` so it points to the real app path:

```php
<?php
$APP_ROOT = __DIR__ . '/../saas';

require $APP_ROOT . '/vendor/autoload.php';
$app = require $APP_ROOT . '/bootstrap/app.php';
```

If you used a different folder name, update `../saas` accordingly.

5. Create the `.env` file on the server
Copy `.env.example` to `.env` using the File Manager. Update at least `APP_URL`, `DB_HOST`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`, `APP_ENV=production`, and `APP_DEBUG=false`.

Generate the key locally and paste it into `APP_KEY`:

```bash
php artisan key:generate --show
```

6. Make storage writable
Set permissions for `storage` and `bootstrap/cache` to writable (typically 775).

7. Create tables without server terminal
If you cannot run `php artisan migrate` on the server, run migrations locally against a local database, export the SQL, then import that SQL into the hosting database using phpMyAdmin.

8. Verify
Open the site URL. If you change `.env` values later, delete cached files in `bootstrap/cache` (except `.gitignore`) so Laravel reloads config.

## About Laravel

Laravel is a web application framework with expressive, elegant syntax. We believe development must be an enjoyable and creative experience to be truly fulfilling. Laravel takes the pain out of development by easing common tasks used in many web projects, such as:

- [Simple, fast routing engine](https://laravel.com/docs/routing).
- [Powerful dependency injection container](https://laravel.com/docs/container).
- Multiple back-ends for [session](https://laravel.com/docs/session) and [cache](https://laravel.com/docs/cache) storage.
- Expressive, intuitive [database ORM](https://laravel.com/docs/eloquent).
- Database agnostic [schema migrations](https://laravel.com/docs/migrations).
- [Robust background job processing](https://laravel.com/docs/queues).
- [Real-time event broadcasting](https://laravel.com/docs/broadcasting).

Laravel is accessible, powerful, and provides tools required for large, robust applications.

## Learning Laravel

Laravel has the most extensive and thorough [documentation](https://laravel.com/docs) and video tutorial library of all modern web application frameworks, making it a breeze to get started with the framework. You can also check out [Laravel Learn](https://laravel.com/learn), where you will be guided through building a modern Laravel application.

If you don't feel like reading, [Laracasts](https://laracasts.com) can help. Laracasts contains thousands of video tutorials on a range of topics including Laravel, modern PHP, unit testing, and JavaScript. Boost your skills by digging into our comprehensive video library.

## Laravel Sponsors

We would like to extend our thanks to the following sponsors for funding Laravel development. If you are interested in becoming a sponsor, please visit the [Laravel Partners program](https://partners.laravel.com).

### Premium Partners

- **[Vehikl](https://vehikl.com)**
- **[Tighten Co.](https://tighten.co)**
- **[Kirschbaum Development Group](https://kirschbaumdevelopment.com)**
- **[64 Robots](https://64robots.com)**
- **[Curotec](https://www.curotec.com/services/technologies/laravel)**
- **[DevSquad](https://devsquad.com/hire-laravel-developers)**
- **[Redberry](https://redberry.international/laravel-development)**
- **[Active Logic](https://activelogic.com)**

## Contributing

Thank you for considering contributing to the Laravel framework! The contribution guide can be found in the [Laravel documentation](https://laravel.com/docs/contributions).

## Code of Conduct

In order to ensure that the Laravel community is welcoming to all, please review and abide by the [Code of Conduct](https://laravel.com/docs/contributions#code-of-conduct).

## Security Vulnerabilities

If you discover a security vulnerability within Laravel, please send an e-mail to Taylor Otwell via [taylor@laravel.com](mailto:taylor@laravel.com). All security vulnerabilities will be promptly addressed.

## License

The Laravel framework is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).
