# 🍔 FoodKart - Flutter Mobile Application

A cross-platform Flutter mobile application converted from the Full Stack Web (FSD) React + Node.js/Express + MongoDB **FoodKart** project. Designed and engineered for an **External Flutter Examination / Project Viva**.

---

## 🚀 Key Features Replicated from FSD to Flutter

1. **Brand Identity & Splash Screen**:
   - Custom animated FoodKart launch splash screen.
   - Food delivery brand color palette (Coral Red `#FF4757`, Gold `#FFA502`, Emerald `#2ED573`).

2. **Full Bottom Navigation**:
   - Seamless 5-tab navigation: **Home**, **Restaurants**, **Offers**, **Cart (with live badge counter)**, and **Profile**.

3. **Home Page**:
   - Deliver-to city header.
   - Hero banner with real-time multi-dimensional search (searches restaurant names, cuisines, as well as dish menu items and descriptions).
   - Horizontal scrolling **Exclusive Offers** carousel.
   - **Top Restaurants** list with ratings, delivery time, and cuisines.

4. **Explore Restaurants**:
   - Interactive category filter chips (**All**, **Continental**, **Andhra**, **Telangana**, **Tiffins**, **Juices**, **Biryani**, **North Indian**, **Desserts**).
   - Live search with instant query clearing and filter reset.

5. **Restaurant Menu & Details**:
   - Parallax/Hero banner with restaurant rating, delivery duration, and free delivery badge.
   - Promotional offer banner applied to the order.
   - Recommended menu cards with food thumbnails, descriptions, and dynamic **ADD / [-] Qty [+]** counter controls.
   - Bottom floating **View Cart** bar showing item count and total when items are in cart.

6. **Offers & Coupons**:
   - Categorized tabs: **All**, **Percentage**, **Flat**, **Freebies**.
   - Copyable promo coupon codes (`FOODKART1`, `FOODKART6`, etc.) with one-tap clipboard copy.

7. **Food Basket / Cart Management**:
   - Clean empty-cart illustration with "Browse Restaurants" quick action.
   - Cart item list with thumbnail, item name, individual item quantity steppers, and single-click removal.
   - Detailed price breakdown: **Subtotal**, **GST (18%)**, **Free Delivery**, and **Grand Total**.

8. **Payment & Checkout**:
   - Saved delivery address selection with radio buttons.
   - In-app **"Add New Address"** dialog with instant list refresh.
   - Estimated Delivery Time banner (e.g. *30 - 45 mins, Arriving around 08:35 PM*).
   - Amount confirmation verification field ensuring exact payable amount entry (matching original FSD security behavior).
   - Secure SSL Encrypted Payment notice.

9. **Order Success**:
   - Celebration checkmark animation, unique Order ID, delivery ETA, and quick navigation to Order History or Home.

10. **Order History & Live Status Tracking**:
    - Dedicated Order History screen with order dates, itemized breakdowns, total paid, and status tags (**Preparing**, **Out for Delivery**, **Delivered**).
    - **Floating Active Order Tracker**: Pulsing delivery truck button available throughout the app that opens a bottom sheet with a 4-step live progress bar, ETA, items list, and delivery address.

11. **My Favorites**:
    - Heart icon on restaurants and menu items to save favorite food spots.
    - Dedicated Favorites screen with quick access.

12. **User Profile & Address Book**:
    - User account summary (avatar, name, email, phone).
    - Profile editing modal for updating personal details.
    - Manage saved delivery addresses (Add new / Delete existing).
    - One-click logout.

13. **Authentication**:
    - Login and Signup screens with form validation.
    - Password visibility toggle.
    - Forgot Password recovery simulation.
    - **⚡ One-Click Demo Login (`Chaitanya`)**: Designed specifically for smooth, instant examiner demonstrations during viva!

---

## 🛠️ Architecture & Tech Stack

- **Framework**: Flutter 3.x (Dart 3.x)
- **State Management**: `Provider` (`ChangeNotifierProvider`, `MultiProvider`)
  - `AuthProvider`: User login, signup, session, and delivery address management.
  - `CartProvider`: Basket state, quantity manipulation, subtotal, 18% GST tax calculation.
  - `FavoritesProvider`: Toggling and managing favorite restaurant IDs.
  - `OrderProvider`: Placing orders, order history, active order tracking, and live status progress simulation.
  - `RestaurantProvider`: Querying, filtering categories, and search indexing.
- **Persistence**: `shared_preferences` (Persists user session, addresses, favorites, and orders across app restarts).
- **Network / API**: `http` (Configured to connect to the live FoodKart Express + MongoDB Atlas backend at `https://food-kart-five.vercel.app/api`, overridable via `--dart-define=API_URL=...`, with automatic fallback to local persistent storage if offline).
- **Styling**: `GoogleFonts.poppins`, Material 3 design, custom cards and shadows.
- **Image Handling**: `cached_network_image` with shimmer placeholders and error fallbacks.

---

## 📱 How to Run the App

### 1. Run on Chrome (Web)
```bash
cd food_kart_app
flutter run -d chrome
```

### 2. Run on Windows Desktop
```bash
cd food_kart_app
flutter run -d windows
```

### 3. Run or Build Release APK for Android
```bash
cd food_kart_app
flutter run
# Or build installable release APK:
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## 🎓 Viva & Exam Questions Guide

### Q1: What state management approach is used and why?
**Answer**: `Provider` (`ChangeNotifier`). It separates business logic from UI widgets, complies with Flutter best practices, and allows easy consumption of cart counts, authentication status, and order updates across any screen.

### Q2: How does the app handle offline vs online mode?
**Answer**: `ApiService` attempts to communicate with the Node.js / Express backend (`/api/restaurants`, `/api/orders`, `/api/auth`). If the backend server is unreachable or offline, the app seamlessly falls back to persistent storage (`SharedPreferences`) and the built-in catalog data so the entire user journey (browsing, cart, checkout, order tracking) works 100% reliably without crashes.

### Q3: How is the tax calculated in the cart?
**Answer**: GST is calculated as `subtotal * 0.18` (18%), exactly matching the business logic of the original Full Stack Web project.

### Q4: How does the Active Order Tracker simulate live delivery?
**Answer**: In `OrderProvider`, placing an order triggers asynchronous timers that transition the order status from *Preparing* to *Out for Delivery* (25s) and *Delivered* (60s), updating the stepper UI in real time.
