# possaas

This repo contains two projects:
- `saas/` Laravel 12 backend + admin panel
- `pos/` Flutter POS app

**Shared Hosting Install (No Terminal on Server)**

These steps assume you can use FTP/cPanel File Manager and phpMyAdmin, but you cannot run commands on the server.

1. Prepare the Laravel app locally
Run these commands on your computer (not on the server):

```bash
cd saas
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
Upload the entire `saas/` folder to a private directory, for example `/home/youruser/saas` or `/home/youruser/app`. Include `vendor/`, `storage/`, `bootstrap/`, and `public/build/`.

4. Point the web root to `public/`
Choose one option depending on your hosting features.

Option A: If you can change the document root
Set the domain or subdomain document root to `/home/youruser/saas/public`.

Option B: If you cannot change the document root
Copy the contents of `saas/public` into `public_html` and edit `public_html/index.php` so it points to the real app path:

```php
<?php
$APP_ROOT = __DIR__ . '/../saas';

require $APP_ROOT . '/vendor/autoload.php';
$app = require $APP_ROOT . '/bootstrap/app.php';
```

If you used a different folder name, update `../saas` accordingly.

5. Create the `.env` file on the server
Copy `saas/.env.example` to `saas/.env` using the File Manager. Update at least `APP_URL`, `DB_HOST`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`, `APP_ENV=production`, and `APP_DEBUG=false`.

Generate the key locally and paste it into `APP_KEY`:

```bash
cd saas
php artisan key:generate --show
```

6. Make storage writable
Set permissions for `saas/storage` and `saas/bootstrap/cache` to writable (typically 775).

7. Create tables without server terminal
If you cannot run `php artisan migrate` on the server, run migrations locally against a local database, export the SQL, then import that SQL into the hosting database using phpMyAdmin.

8. Verify
Open the site URL. If you change `.env` values later, delete cached files in `saas/bootstrap/cache` (except `.gitignore`) so Laravel reloads config.

If you want a separate README for the Flutter `pos/` app, tell me and I will add it.
