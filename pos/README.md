# Flutter POS Interface

This Flutter application mirrors the POS experience that currently exists in `resources/pos` (React).  
It consumes the same Laravel APIs, so new devices (tablets, kiosks, Android POS) can talk to the
existing back-office without duplicating business logic.

## Project goals

- Display the product catalog exposed by the Laravel API (`/products?page[size]=0]`).
- Drive a shopping cart, quantities, discounts, and customer selection with the same constraints as
  `PosMainPage.js`.
- Send completed sales through `/sales` (the same endpoint used by `posCashPaymentAction`).
- Keep the UI responsive so it works on both wide kiosks and smaller handheld screens.

## Directory overview

```
apps/pos_interface
 ├─ lib/
 │   ├─ app.dart                  → Registers controllers and bootstraps Provider
 │   ├─ core/                     → API client, config, shared models
 │   ├─ features/pos/             → POS-specific repository, state, and UI
 │   └─ main.dart                 → Entry point
 ├─ pubspec.yaml                  → Flutter/Provider/HTTP dependencies
 └─ README.md                     → This file
```

`PosController` mirrors the logic that lives inside `resources/pos/src/frontend/components/PosMainPage.js`.
It loads the catalog/customers, manages the cart, and posts sales through the same `/sales` endpoint.

## Running the app

1. Install dependencies (only required the first time or after a dependency change):
   ```bash
   cd apps/pos_interface
   flutter pub get
   ```
2. Run the app while pointing it to your Laravel backend:
   ```bash
   flutter run \
     --dart-define=API_BASE_URL=https://your-domain.test/api \
     --debug
   ```
   You can pass the same flag to `flutter build` when generating release bundles.

When the app launches you land on a login screen. Use the same credentials you would enter on the
React admin (the `/login` endpoint) and the token is cached locally via `shared_preferences`. The
token is attached automatically to each API call until you hit the logout button on the POS screen.

## Connecting to Laravel

- **Products** – `GET /products?page[size]=0&warehouse_id=:id`
- **Customers** – `GET /customers?page[size]=0`
- **Front settings** – `GET /front-setting` (used for default warehouse and currency symbol)
- **Sales** – `POST /sales` (payload shape matches what the React POS sends today)

You can reference the React implementation (e.g. `resources/pos/src/store/action/pos/posCashPaymentAction.js`)
when extending the payload or adding features such as holds, register closing, or receipt previews.

## Next steps

- Add token refresh/error handling (e.g., expired tokens) and remember the last logged-in user.
- Mirror hold/resume, register reports, and receipt printing flows from the React POS.
- Implement offline caching so the Flutter POS stays usable when the network is unstable.
