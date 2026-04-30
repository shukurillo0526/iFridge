# iFridge Design System

This document outlines the master design system and color rules for the iFridge application. It must be adhered to whenever adding new features or modifying the UI.

## 🎨 Color Palette

### Dark Mode (Default & Primary Target)
Dark Mode feels premium, modern, and focused on food.

| Element | Hex Code | Description |
| :--- | :--- | :--- |
| **Background** | `#0F1218` | Deep, soft navy-black |
| **Surface / Cards** | `#1C212E` | Slightly lighter than background |
| **Primary (Brand)** | `#E07A00` | Warm terracotta orange – makes people hungry |
| **Accent** | `#F4B942` | Rich gold |
| **Text Primary** | `#F8F9FA` | Bright white |
| **Text Secondary** | `#A1A8B8` | Soft gray |
| **Success / Positive** | `#00C48C` | Fresh green, only for success states |

### Light Mode
Light Mode feels clean, warm, and welcoming.

| Element | Hex Code | Description |
| :--- | :--- | :--- |
| **Background** | `#F8F6F2` | Warm off-white / cream – feels appetizing |
| **Surface / Cards** | `#FFFFFF` | Pure white |
| **Primary** | `#D96B00` | Same orange family, slightly darker for light mode |
| **Accent** | `#C89A2F` | Slightly toned-down gold |
| **Text Primary** | `#1F252C` | Deep charcoal |
| **Text Secondary** | `#5B6370` | Medium gray |
| **Success / Positive** | `#00A36C` | Fresh green |

## 📐 Quick Rules for Development

1. **Default Mode:** Make Dark Mode the default when the user opens the app.
2. **The Scan Button:** Keep the Scan button in the strong orange (`#E07A00` / `#D96B00`) in both modes.
3. **Gold Accent Usage:** Use the gold accent (`#F4B942`) ONLY for small highlights like timers or success/warning messages.
4. **No Bright Green Base:** Never use bright green as the main structural or brand color again.
5. **Dynamic Theming:** Never hardcode static color hexes in widgets. Always use `Theme.of(context)` properties or the `context.colorScheme` extensions to ensure colors automatically adapt when switching between Light and Dark mode.

## 🚨 Strict Dual-Mode Enforcement Rules

To ensure the app never breaks when users switch between Light and Dark modes, **hardcoded colors are strictly forbidden** outside of `lib/core/theme/app_theme.dart`.

### 1. The "No Colors.white / Colors.black" Rule
Do not use `Colors.white` or `Colors.black` in widgets. 
* **For Text/Icons:** Use `Theme.of(context).colorScheme.onSurface`. (This automatically maps to Charcoal in Light Mode, and White in Dark Mode).
* **For Subdued Text/Dividers:** Use `Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)`.
* **For Backgrounds/Cards:** Use `Theme.of(context).colorScheme.surface` or `scaffoldBackgroundColor`.

### 2. Avoid `isDark ? ... : ...` Ternaries for Colors
You rarely need to check `Theme.of(context).brightness == Brightness.dark`. The `ThemeData` automatically handles color inversions for you if you use the semantic names (e.g. `primary`, `surface`, `onSurface`).

### 3. Custom Painters
Custom painters (`CustomPainter`) do not have access to `BuildContext`. You must pass the required `Theme.of(context)` colors down to the painter via its constructor:
```dart
_MyPainter(
  gridColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
  textColor: Theme.of(context).colorScheme.onSurface,
)
```

### 4. Automated Enforcement
We have a linter script that enforces these rules. Run it before committing:
```bash
python scripts/enforce_theme.py
```
If it detects `Colors.white`, `Colors.black`, or `Color(0xFF...)` outside of `app_theme.dart`, the CI build will fail.

## 🧠 UX Psychology & Component Positioning

To make the app feel instantly intuitive and "perfect" for the user, we must position elements based on how humans naturally hold their phones and process information.

### 1. The "Thumb Zone" (Bottom-Heavy UI)
Modern phones are tall. Reaching the top of the screen requires uncomfortable hand stretching.
* **Primary Actions:** The most important buttons (e.g., "Take Photo", "Place Order", "Add Ingredient") MUST be pinned to the bottom of the screen, just above the navigation bar.
* **Secondary Actions:** The top `AppBar` should only be used for passive navigation (Back buttons) or infrequent actions (Settings gear, Notifications).

### 2. Jakob's Law (Familiarity)
*Users spend most of their time on other apps. They expect your app to work the same way.*
* **Navigation:** Always keep primary navigation at the bottom.
* **Profile / Settings:** Users expect to find their profile either as the far-right tab on the bottom bar, or as an avatar in the top-right corner.
* **Cart / Checkout:** If there is a floating cart or checkout button, it should anchor to the bottom-right or span the full width of the bottom screen.

### 3. Visual Hierarchy & The F-Pattern
Users don't read screens; they scan them in an F-shaped pattern (top-left to top-right, then down).
* **Top-Left:** Place the most critical identifying information here (e.g., "Expiring Soon" alerts, Restaurant Name).
* **Negative Space (Breathing Room):** Use ample white space between different sections (like "Flavor Profile" and "Shopping List") so the brain can categorize them as distinct concepts without feeling overwhelmed. 
* **One Call-to-Action (CTA):** Each screen should have exactly ONE bright orange button. If there are multiple actions, the others should be outlined or grayed out to guide the user's eye to the primary task.

### 4. The Law of Proximity
Elements that are close together are perceived as related.
* When placing text and buttons, group related items tightly (using 8px or 16px padding) and separate distinct groups with larger gaps (32px or 48px padding). This prevents the UI from looking like a messy, scattered grid.

## 📏 Layout & Spacing Rules

### 1. The 8-Point Grid System
All spacing, padding, and margins must align to an 8-point grid. Avoid random spacing values like `11` or `17`.
* Use `AppSpacing.md` (16px) or `AppSpacing.lg` (24px) from `lib/core/theme/app_spacing.dart`.

### 2. Component Positioning (Safe Areas & Scaffolds)
* Always ensure main UI containers respect `SafeArea` so they do not overlap with notches, dynamic islands, or physical buttons.
* If a screen has a `DualModeNavBar` at the bottom, ensure the `Scaffold` uses `extendBody: true` for the glassmorphism effect, AND ensure the bottom-most scrolling element has at least `120px` of bottom padding to clear the nav bar.
