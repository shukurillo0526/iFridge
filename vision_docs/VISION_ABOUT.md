# iFridge VISION: Current State & Future Architecture

This document serves as the master blueprint for the iFridge ecosystem. It details the journey from a personal smart kitchen app to a three-sided food commerce marketplace, encompassing the current technical implementation, the business strategy, and the roadmap for upcoming phases.

---

## 1. The Core Vision & Evolution

Originally built to solve the "what's for dinner" problem by tracking physical inventory and providing AI-powered recipes (Cook Mode), iFridge has undergone a strategic pivot. The new **VISION** expands the platform into a comprehensive ecosystem connecting three key stakeholders:

1.  **Consumers (iFridge App):** The demand engine. Users can manage their kitchen inventory, discover recipes, and now, seamlessly order food from local restaurants via mobile order and pickup/delivery.
2.  **Restaurants (iFridge Business):** The supply side. A digital dashboard allowing restaurants to manage menus, process incoming orders without cashiers, and eventually integrate with self-service kiosk hardware.
3.  **Drivers (iFridge Fleet - Planned):** The logistics network. A shared delivery fleet that any restaurant on the platform can utilize, reducing overhead and breaking reliance on high-commission third-party apps.

---

## 2. Current State (What We Have Built)

The foundation of the marketplace ecosystem (Phase P) is fully implemented and operational.

### 2.1 The Consumer App (Frontend - Flutter)

The app now features a dual-mode navigation system (Cook vs. Order). The recent expansion heavily focused on the **Order Mode**:

*   **Cart Service (`cart_service.dart`):** A robust in-memory singleton. It handles adding/removing items, managing quantities, and binding the cart to a specific restaurant (auto-clearing if the user attempts to order from a different restaurant simultaneously). It also toggles the order type (pickup vs. delivery).
*   **Restaurant Discovery & Menu:** Users browse nearby restaurants and view menus. The `+` button natively adds items to the `CartService` and presents a dynamic quantity stepper (`- 1 +`).
*   **Floating Cart Bar:** Appears persistently across the restaurant's menu when items are in the cart, showing a live summary (item count and total price) and providing a quick link to checkout.
*   **Checkout Flow (`checkout_screen.dart`):** A comprehensive review screen. Users toggle between Pickup and Delivery, see a detailed price breakdown (subtotal, delivery fee, total), and place the order via the backend API.
*   **Order Confirmation & Tracking (`order_history_screen.dart`):** Upon success, the system generates a human-readable **Pickup Code** (e.g., `AB742`). The "My Orders" screen (accessible from the Profile/Manage tab) separates active and past orders, featuring a dynamic visual progress bar tracking the order's lifecycle state.

### 2.2 The Restaurant Dashboard (Frontend - Flutter)

Built directly into the existing app for business accounts:

*   **Incoming Orders Page (`incoming_orders_page.dart`):** A dedicated management interface featuring a 3-tab layout: **New**, **Preparing**, and **Ready**.
*   **Order Management:** Restaurant staff view incoming orders with full details (pickup code, item quantities, special instructions, customer notes) and advance the status with a single tap (e.g., "Start Preparing" moves the order from 'New' to 'Preparing').

### 2.3 The Backend API (FastAPI) & Database (Supabase)

The robust data layer powering the marketplace:

*   **Orders Database Schema (`007_orders.sql`):** A comprehensive PostgreSQL table tracking the full lifecycle (`confirmed` → `preparing` → `ready` → `picked_up` → `delivering` → `completed` → `cancelled`). It uses `JSONB` for flexible item storage, includes delivery coordinate fields, enforces strict Row Level Security (RLS), and features optimized indexes and an RPC function (`get_user_orders`) for efficient history retrieval.
*   **Orders Router (`orders.py`):** Six RESTful endpoints exposing the necessary CRUD operations:
    *   `POST /orders`: Creates orders and generates the unique pickup code.
    *   `GET /orders/{id}`: Fetches a specific order.
    *   `GET /orders/user/{id}`: Retrieves a user's order history.
    *   `GET /orders/active/{id}`: Retrieves active orders for real-time tracking.
    *   `PATCH /orders/{id}/status`: Allows restaurants to advance the order lifecycle.
    *   `POST /orders/{id}/cancel`: Handles user-initiated cancellations.

### 2.4 Production Hardening

The application has been hardened for release (Phase O):
*   UI layout fixes (resolving `Expanded` overflow issues).
*   Location service fallbacks for robust emulator testing.
*   ProGuard/R8 configuration for Android minification.
*   Secure `--dart-define` credential injection.

---

## 3. The Roadmap (Where We Are Going)

The foundation is solid. The next phases will flesh out the remaining pillars of the ecosystem.

### Phase 2: Payments & Real-Time Sync
*   **Payment Gateway Integration:** Integrating Stripe, Click, or Payme for secure, in-app transactions prior to order submission.
*   **Real-Time Subscriptions:** Migrating from pull-to-refresh to Supabase Realtime WebSockets so consumers see their order status change instantly as the restaurant updates it.
*   **Push Notifications:** Firebase Cloud Messaging (FCM) alerts for order readiness and driver assignment.

### Phase 3: Kiosk Mode (Pillar 2)
*   **iFridge Kiosk App:** Developing a specialized, full-screen web application intended to run on locked-down Android tablets positioned inside partner restaurants.
*   **Hardware Integration:** Supporting thermal receipt printers and local network syncing.

### Phase 4: Delivery Fleet (Pillar 3)
*   **iFridge Fleet App:** A new, dedicated Flutter application for gig-economy drivers.
*   **Dispatch Engine:** A backend service to match "Ready" delivery orders with the nearest available drivers.
*   **Live Tracking:** GPS integration allowing consumers to watch their delivery arrive on a map.

### Phase 5: Business Analytics
*   **Restaurant Insights:** Enhancing the iFridge Business dashboard with revenue charts, peak hour heatmaps, and menu item performance metrics to help owners optimize operations.

---

## 4. Technical Architecture Overview

*   **Frontend Framework:** Flutter (iOS, Android, Web)
*   **State Management:** Riverpod + local `setState` (transitioning to fully Riverpod)
*   **Local Caching:** Hive (Offline-first architecture)
*   **Backend Framework:** FastAPI (Python 3.12)
*   **Database & Auth:** Supabase (PostgreSQL, GoTrue)
*   **AI Intelligence:** Local Ollama (`qwen2.5:3b`, `moondream`, `nomic-embed-text`) with Cloud Fallbacks (Gemini/OpenAI)
*   **Vision:** FastAPI backend integrating Google Gemini 1.5 Flash (receipts) & Moondream (loose items)
*   **Hosting:** GitHub Pages (Frontend), Railway (Backend)
