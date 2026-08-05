# Motary — Portfolio Case Study

> **Automotive parts marketplace · Flutter · Clean Architecture · Dual buyer/seller application**

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Problem](#2-problem)
3. [Solution](#3-solution)
4. [My Role](#4-my-role)
5. [Key Features](#5-key-features)
6. [Technical Highlights](#6-technical-highlights)
7. [Challenges](#7-challenges)
8. [Solutions](#8-solutions)
9. [Architecture Decisions](#9-architecture-decisions)
10. [Tech Stack](#10-tech-stack)
11. [Screens](#11-screens)
12. [Lessons Learned](#12-lessons-learned)
13. [Needs Confirmation](#needs-confirmation)
14. [Accuracy Notes Before Publishing](#two-accuracy-notes-before-you-publish)

---

## 1. Project Overview

Motary is a Flutter-based B2C marketplace for automotive parts, built for the Arabic-speaking market (default locale `ar`). It ships **two distinct applications inside one codebase**: a buyer storefront for browsing, filtering, and purchasing parts, and a seller portal for merchants to register a shop, list inventory, and fulfil orders.

The dual-role design is enforced at the architecture level rather than by UI toggles — separate authentication stacks, separate data sources, separate navigation shells, and a `UserType` enum persisted in cache that drives request authorization and push-notification routing.

**Scale (verified by file count):**

| Metric | Count |
|---|---|
| Dart files | 515 |
| Feature modules | 17 |
| Use cases | 77 |
| Repository / data-source contracts | 33 |
| BLoCs | 22 |
| Cubits | 3 |
| Registered routes | 49 |
| Test files | 31 |
| Test cases | 111 |

**Backend:** `https://motary-backend.intrazero.org/v1/` (REST)
**Package namespace:** `com.intrazero.motary`

---

## 2. Problem

Buying automotive parts online has a matching problem: a part must fit a specific car make, model, and year, and buyers typically shop by vehicle rather than by product name. Generic e-commerce catalogues handle this poorly.

The application addresses three constraints visible in the implementation:

- **Fitment-based discovery** — the catalogue is indexed by car brand and model (`product-car-brands`, `product-car-brands/{id}/models`, `productCarMapping`), not by product text alone.
- **Merchant onboarding with verification** — sellers cannot trade immediately. The code contains a `pending_for_approvement_screen` and a document-upload registration step, implying admin-side approval before a shop goes live.
- **Locality of fulfilment** — city is a first-class filter with its own screen and cached keys (`buyerCity`, `cityId`, `arCity`/`enCity`), and shops carry per-shop delivery pricing.

---

## 3. Solution

A single Flutter codebase serving both sides of the marketplace:

**Buyers** browse products filtered by car make/model, category, and city; search with server-side pagination; manage a wishlist, cart, and address book; check out through a hosted payment page; then track orders, reorder, review products, and file complaints.

**Sellers** register with documents, create a shop with bank details and delivery pricing, publish products through a validated four-step wizard, toggle store and per-product visibility, and process incoming orders through a status lifecycle with rejection reasons.

Both roles share one networking layer, one DI container, one localization system, and one navigation manager — with role resolved at runtime from persisted cache.

---

## 4. My Role

> ### ⚠️ Needs confirmation — attribution could not be verified
>
> The repository's Git history contains **534 commits across three authors** (`mhosnyessa` / `mohamed hosny`, `somayakAmel` / `somaya kamel` / `s.kamel`, and `YussifKahilo` / `Yussif Kahilo`), spanning **2024-10-03 to 2025-03-09**. No commits are authored under the identity configured in this environment.
>
> The only uncommitted working-tree changes are file-permission and line-ending changes (`100755` → `100644`, XML files re-encoded) — **not authored code**.
>
> I cannot determine the specific contribution from the codebase alone. **Supply the commit author name/email or the feature areas owned**, and this section can be rewritten with verified evidence — the analysis below is precise enough to map onto specific modules once attribution is known.

To assist that mapping, the work in this repository divides cleanly into these ownable areas:

| Area | Verifiable scope |
|---|---|
| **Core infrastructure** | DI container (`service_locator.dart`, ~700 lines), Dio interceptor, token refresh, centralized error handling, route manager (49 routes) |
| **Buyer commerce** | Products, filters, search, cart, wishlist, address book, checkout, payment |
| **Seller portal** | Shop creation, 4-step product wizard, product listing/filters, order fulfilment |
| **Cross-cutting** | Auth (5 methods × 2 roles), OTP, profile, notifications, reviews, CMS pages |
| **Testing** | 31 test files across data/domain/presentation for auth, shop, profile, lookups, OTP |

**What is fully verified and safe to claim in a portfolio:** the technical content of Sections 5–12 accurately describes this codebase. Claims about *who wrote what* require confirmation.

---

## 5. Key Features

### Authentication & Identity

- Five sign-in paths: email/password, Google, Apple, Facebook, plus separate seller credentials — `google_log_in_usecase`, `apple_log_in_usecase`, `facebook_log_in_usecase`
- Independent buyer and seller stacks: separate remote *and* local data sources, repositories, use-case folders, and BLoCs
- OTP verification for registration and email change, with resend
- Password reset as a three-stage flow (request → verify OTP → set new password)
- **Guest browsing** — a dedicated `products-guest` endpoint lets unauthenticated users browse before signing up (`isGuest` flag threaded through 18 call sites)
- Account deletion (App Store compliance requirement)

### Buyer Commerce

- Home with categories, best sellers, and city scoping
- Fitment filtering by car make → model, plus category, condition, and city
- Paginated search with throttled event handling
- Cart with quantity updates, address assignment, and checkout
- Wishlist add/remove/list
- Address book with full CRUD and pagination
- Hosted payment via WebView with success/failure callback interception
- Order history, order details, reorder, complaints, and product reviews with problem categories

### Seller Portal

- Registration with document upload, gated behind admin approval (`pending_for_approvement_screen`)
- Shop setup across three sub-screens: shop data, bank account, delivery price
- **Four-step product wizard** with server-side validation per step, reused for both create and edit
- Product listing with filters; per-product status toggling; store-wide visibility switch
- Order queue with year/month filters, status transitions, and rejection reasons

### Cross-cutting

- Arabic/English with full RTL, ~420 translation keys per locale
- Firebase push notifications with deep-link routing into order details
- In-app notification centre
- CMS-backed Terms, Privacy Policy, FAQ, Contact Us (rendered via `flutter_html`)

---

## 6. Technical Highlights

### Strict Clean Architecture, applied consistently

Every one of the 17 feature modules follows `data/` (datasources, models, repositories) → `domain/` (entities, repositories, usecases) → `presentation/` (bloc, screens, widgets). This is not partial adoption — 77 use cases each wrap a single repository call, and domain layers depend only on abstractions.

### Functional error handling via `Either`

Use cases return `Either<Failure, T>` and wrap calls in a shared `tryCatch` helper:

```dart
Future<Either<Failure, void>> call(ProductDetails params) async {
  return tryCatch(
      tryFunction: () async => await sellerProductsRepo.validateStepOne(params));
}
```

Errors never propagate as exceptions into the presentation layer; BLoCs consume them with `result.fold(...)`, making the failure path explicit and type-checked at every call site.

### Centralized HTTP exception mapping

`handel_dio_error.dart` translates Dio exception types and status codes into a typed exception hierarchy (`BadRequestException`, `NotFoundException`, `ConflictException`, `NoInternetConnectionException`). Critically, `401`/`403` triggers a **global forced sign-out** through the navigator key — session invalidation is handled in one place rather than repeated across 33 repositories.

### Proactive token refresh in the request interceptor

Rather than reacting to a 401, `refreshTokenHandler` checks expiry *before* each request:

```dart
expireDate = user.auth.tokenSavedAt.add(user.auth.tokenExpiresIn!);
if (!expireDate.isAfter(now)) {
  final newAuthData = await _updateToken(user.auth.refreshToken!);
  // persist refreshed credentials for the correct user type
}
```

The interceptor also injects `Accept-Language` from the active locale on every request, so server-side content and validation messages return already localized. The refresh endpoint and OTP-resend are explicitly excluded to prevent recursion.

### Throttled pagination with `rxdart`

Product and filter BLoCs use a custom event transformer to drop redundant scroll-triggered loads:

```dart
EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) => events.throttleTime(duration).switchMap(mapper);
}
```

`switchMap` cancels the in-flight request when a newer event arrives — preventing both duplicate page fetches and out-of-order results appending stale data.

### Debounced cart mutations

`CartBloc` keeps a per-item `Map<String, Timer>` and coalesces quantity changes over a 1-second window, so rapid `+`/`−` taps produce one network call per item rather than one per tap. Timers are cleaned up after firing.

### Two-tier lookup caching

`LookupsRepositoryImpl` serves car makes and models cache-first, falling back to network and backfilling on miss — with models keyed per make (`carModel + makeId`). Since fitment data is large and effectively static, this removes repeated network round-trips from the primary discovery path.

### Lazy, modular dependency injection

`get_it` with `registerLazySingleton` throughout. Feature modules register on demand, guarded against double-registration:

```dart
void initShopModule() async {
  if (sl.isRegistered<ShopRemoteDatasource>()) return;
  ...
}
```

Rarely used graphs (profile, shop, OTP) are only constructed when their route is first hit, keeping startup cost proportional to what the user actually opens.

### Testing at every architectural layer

111 test cases across data sources, repositories, use cases, and BLoCs — using `mocktail`/`mockito` for boundaries and `bloc_test` for state-transition assertions. Coverage concentrates on auth, shop, profile, lookups, and OTP.

---

## 7. Challenges

1. **Two applications, one codebase.** Buyer and seller differ in authentication, API surface, navigation shell, and permissions — while sharing cart-free/cart-ful commerce primitives, lookups, and networking.

2. **Authenticating five sign-in methods across two roles** while keeping a single authorization mechanism at the HTTP layer.

3. **Silent session expiry.** Long-lived commerce sessions must not drop a user mid-checkout, and refresh logic must not recurse.

4. **Multi-step product creation with server-side validation**, where the same wizard must serve both create and edit without forking the UI.

5. **Pagination racing against fast scrolling** — duplicate pages and out-of-order responses corrupting the list.

6. **Network chatter from rapid cart interactions.**

7. **Full RTL Arabic as the default locale**, with server-returned content also needing localization.

8. **Payment via a hosted external page**, where the app must reliably detect success or failure it doesn't control.

9. **Large, effectively-static fitment datasets** on the critical discovery path.

> **Needs confirmation:** Performance work is partially evidenced — two profiling captures (`flutter_jank_metrics_01.json`, `flutter_jank_metrics_02.json`) are committed, indicating jank analysis was performed, but the specific regressions found and fixed cannot be reconstructed from the files alone.

---

## 8. Solutions

### 1 — Role separation at the architecture layer

Rather than runtime branching in the UI, the codebase forks at the module level: `auth/data/datasource/buyer/` vs `seller/`, `domain/usecases/buyer/` vs `seller/`, `AuthBuyerLogInBloc` vs `AuthSellerBloc`, and `LayoutBuyerScreen` vs `LayoutSellerScreen`. Role is persisted once (`CacheKeys.userRole`) and read wherever behaviour diverges. Shared concerns (lookups, orders, notifications, about) stay single-implementation, with role handled by endpoint selection inside the data source.

### 2 — Unified authorization at the interceptor

All five sign-in paths converge on a common `User` entity carrying an `auth` object. The interceptor reconstructs the correct concrete type from cache and applies one header rule:

```dart
options.headers.addAll({
  'Accept-Language': sl<LocaleCubit>().getLocale().languageCode,
  if (user != null) 'Authorization': 'Bearer ${user.auth.token}',
});
```

Adding a sign-in provider requires no change to the transport layer.

### 3 — Pre-emptive refresh plus centralized 401 recovery

Expiry is checked before dispatch (see §6), so refresh happens between user actions rather than as a mid-request retry. As a backstop, any `401`/`403` that still reaches `handel_dio_error` triggers `contextSignOut` via the global navigator key — one code path, no per-repository duplication.

### 4 — Validate-per-step with a shared wizard

Three endpoints (`products/step1`, `step2`, `step3`) back three use cases, so each step is validated server-side before advancing and the seller sees errors immediately rather than after completing the form. `AddProductFlow` handles create and edit through one constructor parameter:

```dart
final SellerAddProductsBloc b = SellerAddProductsBloc(
    sl(), sl(), sl(), sl(), sl(), sl(),
    !(product == null),
    product == null ? null : ProductModel.fromEntity(product!));
```

A `PageView` with `NeverScrollableScrollPhysics` and a `LineStepper` driven by `CustomCubit<int>` enforces linear progression; only the final panel differs between modes.

### 5 — `throttleTime` + `switchMap`

Throttling drops events inside a 1-second window; `switchMap` cancels superseded requests. State accumulation appends to existing results only when the current state matches the expected success type, so a reset or failure cannot append to a stale list.

### 6 — Per-item debounce timers

`CartBloc` coalesces bursts into a single request per item using a `Map<String, Timer>` keyed by item ID.

### 7 — JSON-based localization with locale-aware networking

`LocaleCubit` persists language, ~420 keys per locale live in `lang/ar.json` and `lang/en.json`, and the Changa font family (four weights) is bundled for Arabic rendering. The interceptor forwards the active language so server content and error messages arrive already translated.

### 8 — URL-based payment result detection

The WebView's navigation delegate inspects query parameters on page completion:

```dart
if (Uri.parse(url).queryParameters['status'] == 'success') {
  if (!isVerified) { isVerified = true; Navigator.pop(context, true); }
}
```

An `isVerified` latch guards against duplicate `onPageFinished` callbacks double-confirming an order, and `clearCache()` on dispose prevents payment-session leakage between checkouts.

### 9 — Cache-first lookups with network backfill

As described in §6 — car makes and models resolve from cache first, hitting the network only on a miss.

---

## 9. Architecture Decisions

### Clean Architecture with per-feature vertical slices

- **Decision:** Three-layer separation replicated inside each of 17 feature folders, rather than global `data/`/`domain/`/`presentation/` directories.
- **Reason:** A three-developer team working concurrently on distinct features needs minimal file-level contention.
- **Benefit:** Features are independently navigable, testable, and removable; module boundaries match team boundaries.

### BLoC as the primary state manager, Cubit for trivial state

- **Decision:** 22 BLoCs for feature state; `CustomCubit<T>` for simple values like the wizard's step index.
- **Reason:** Event-driven BLoC enables transformer-based concurrency control (throttling, cancellation) that Cubit cannot express; Cubit avoids boilerplate where no such control is needed.
- **Benefit:** Race conditions are solved declaratively at registration, and `bloc_test` makes transitions directly assertable.

### Service locator over constructor injection or code generation

- **Decision:** `get_it` with lazy singletons and on-demand module registration.
- **Reason:** Avoids threading dependencies through widget trees, and sidesteps `build_runner` codegen in a large module count.
- **Benefit:** Deferred graph construction on startup; trivial substitution of fakes in tests.

### Repository pattern with abstract data sources

- **Decision:** Every repository depends on abstract data-source interfaces; local sources exist where caching applies.
- **Reason:** Caching strategy must be swappable without touching domain logic.
- **Benefit:** `LookupsRepositoryImpl` implements cache-first fallback entirely within the data layer — the domain is unaware caching exists.

### Named routes through a central `RoutesManager`

- **Decision:** One `generateRoute` switch handling 49 routes, with `BlocProvider` injection performed at route construction and typed argument casting.
- **Reason:** Push notifications and the global sign-out handler need to navigate from outside the widget tree.
- **Benefit:** A single `navigatorKey` supports deep linking and forced sign-out from the interceptor.

### Cross-project shared packages

- **Decision:** `core_package`, `types_package`, and `locale_package` consumed as Git dependencies; `utils_package` vendored locally at `./packages/`.
- **Reason:** Networking, failure types, and localization are organization-wide concerns across multiple Intrazero apps.
- **Benefit:** Infrastructure fixes propagate across projects; the app repository holds only product logic.

### `flutter_screenutil` with a fixed design baseline

- **Decision:** 375×812 design size, portrait locked in `main()`.
- **Reason:** Designs are delivered at a single mobile reference size; commerce flows have no tablet or landscape requirement.
- **Benefit:** Proportional scaling across device sizes without per-breakpoint layout code.

---

## 10. Tech Stack

| Category | Technologies |
|---|---|
| **Framework & Language** | Flutter (Dart SDK ^3.5.0), Material Design |
| **Architecture** | Clean Architecture, Repository pattern, Use-case pattern, `Either`-based functional error handling |
| **State Management** | `flutter_bloc` 8.1.6 (22 BLoCs, 3 Cubits), `rxdart` 0.28 for event transformers |
| **Dependency Injection** | `get_it` 8.0 (lazy singletons, modular registration) |
| **Networking** | Dio via `core_package`, custom request interceptor, proactive token refresh, centralized Dio-error mapping |
| **Backend** | REST API (`motary-backend.intrazero.org/v1/`) |
| **Firebase** | `firebase_core` 3.8, `firebase_auth` 5.3, `firebase_messaging` 15.1 (project `motary-fda6b`) |
| **Authentication** | Email/password, `google_sign_in` 6.2, `sign_in_with_apple` 6.1, `flutter_facebook_auth` 7.1, OTP verification |
| **Local Storage** | `shared_preferences` 2.3 via a `CacheConsumer` abstraction; `path_provider` |
| **Payments** | `webview_flutter` 4.10 with hosted-gateway callback interception |
| **Notifications** | Firebase Cloud Messaging + `flutter_local_notifications` 18.0, with notification-to-route deep linking |
| **Media & Files** | `image_picker`, `file_picker`, `flutter_image_compress`, `cached_network_image`, `flutter_svg`, `open_filex`, `permission_handler` |
| **UI** | `flutter_screenutil`, `shimmer` (16 skeleton implementations), `lottie`, `carousel_slider`, `toastification`, `flutter_rating_bar`, `flutter_staggered_animations`, `flutter_html`, `country_code_picker` |
| **Localization** | JSON-based `locale_package` + local `utils_package`; Arabic (default) and English with RTL; Changa font, four weights |
| **Testing** | `flutter_test`, `bloc_test` 9.1, `mockito` 5.4, `mocktail` 1.0 — 31 files, 111 test cases |
| **Tooling** | `flutter_lints` 4.0, `flutter_launcher_icons`, DevTools jank profiling, Git/GitLab |

> **⚠️ Needs confirmation — CI/CD:** No CI configuration exists in the repository (no `.gitlab-ci.yml`, no `.github/workflows`). No build flavors are configured, and the Android release build still uses debug signing (`signingConfig = signingConfigs.debug` with a `TODO`). Release automation, if any, was handled outside this repository — **do not claim CI/CD without external evidence.**

---

## 11. Screens

### Onboarding

| Screen | Purpose |
|---|---|
| Splash | Bootstraps session, resolves cached role, routes to the correct shell |
| Landing | Buyer vs seller entry choice |

### Authentication

Buyer Log In / Sign Up, Seller Log In / Sign Up, Seller Document Upload (verification files), Sign-Up OTP, and a three-page reset flow (Request → Verify OTP → Set New Password).

### Buyer

| Screen | Purpose |
|---|---|
| Buyer Layout | Bottom-nav shell with connectivity listener |
| Home | Categories, best sellers, city-scoped catalogue |
| Search | Paginated search with throttled loading |
| Product Details | Specs, images, fitment, add to cart/wishlist |
| Cities | City selection driving catalogue scope |
| Seller Details | Public shop profile and its listings |
| Cart / Cart Details | Line items, debounced quantity edits, totals |
| Update Cart Address | Assigns a delivery address to the cart |
| Payment / Payment WebView | Method selection, then hosted gateway with callback detection |
| Orders / Order Details | History, tracking, reorder, complaints |
| Wishlist | Saved products |
| Address Book / Address Details | Address CRUD |
| Order Products / Review Product | Post-delivery reviews with problem categories |
| Buyer Settings | Language, profile, legal pages |

### Seller

| Screen | Purpose |
|---|---|
| Seller Layout | Role-specific shell |
| Seller Home | Store dashboard and status |
| Start Your Market | Shop-creation entry point |
| Pending Approval | Blocking state until admin verification |
| Create Shop (3 sub-screens) | Shop data, bank account, delivery price |
| Edit Shop Data / Edit Bank Account | Post-onboarding maintenance |
| Add Product Flow | Four-step validated wizard (create and edit) |
| Seller Products / Product Details | Inventory list, filters, per-product visibility |
| Product Filter | Inventory filtering |
| Seller Orders / Order Details | Fulfilment queue with status transitions |
| Order Year / Month Filter | Historical order filtering |
| Seller Settings | Store configuration |

### Shared

Profile, Update Field, Update Password, Verify Change-Email OTP, Notifications, Terms & Conditions, Privacy Policy, FAQ, Contact Us.

---

## 12. Lessons Learned

**Architectural consistency is what makes scale tractable.** With 515 files and 17 modules, the value of Clean Architecture was not abstraction purity but *predictability* — any developer could locate any file by rule rather than by memory. The uniformity of the 77 use cases meant new features were assembled from a known template rather than designed from scratch.

**Concurrency belongs in state-management configuration, not in UI code.** Pagination races and cart request storms were solved declaratively — `throttleTime`/`switchMap` at event registration and per-item debounce timers in the BLoC — rather than with `isLoading` flags scattered through widgets. Fixing the class of bug once at the transformer level beats fixing instances at each call site.

**Cross-cutting concerns must be centralized at the boundary.** Auth headers, language headers, token refresh, and 401 sign-out all live in the interceptor and error handler. Had these been distributed across 33 repositories, session-expiry handling would have been inconsistent by construction.

**Type systems can encode failure.** `Either<Failure, T>` forces every caller to handle the error branch. Combined with a typed exception hierarchy mapped from HTTP status codes, error handling became a compile-time obligation rather than a review-time checklist.

**Shared packages pay off across a portfolio of apps.** Extracting networking, types, and localization into separately versioned Git packages kept this repository focused on product logic — at the cost of coordinating versions across projects.

**Testing at layer boundaries gives the best return.** Concentrating 111 tests on use cases, repositories, and BLoCs — the layers with branching logic — provided regression safety without the brittleness of widget-tree tests.

**Deployment maturity lagged code maturity.** The most honest lesson: architecture and testing were rigorous while release engineering was not. No CI pipeline, no build flavors, and release builds still signed with debug keys. Manual release processes become the bottleneck precisely when a codebase gets large enough to need automation.

---

## Needs Confirmation

Items that cannot be verified from the repository:

1. **Specific contribution and attribution** *(blocking for Section 4)* — no commits match the configured Git identity. Supply the commit author name/email or the modules owned.
2. **Team size and structure** — three Git authors are visible; whether others contributed without commit access, and the roles involved (QA, design, backend, PM), is unknown.
3. **Project timeline** — commits span 2024-10-03 to 2025-03-09 (~5 months). Whether this covers the full engagement, or work continued in another branch or repository, is unknown.
4. **Business goals and success metrics** — no product documentation exists; the README is the unmodified Flutter template.
5. **Release status and store presence** — no evidence the app was published; no store links, release notes, or signing configuration. **Do not claim App Store/Play Store metrics without external proof.**
6. **User numbers, transaction volume, GMV** — not derivable from client code.
7. **Performance improvements** — two jank-metric captures are committed, confirming profiling occurred, but not what was diagnosed or the before/after result. Quantified performance claims need external evidence.
8. **CI/CD and release process** — no pipeline configuration in-repo; any automation lived elsewhere.
9. **Test coverage percentage** — 31 files / 111 cases are counted, but no coverage report exists. Note that `cart`, `orders`, `wishlist`, `review`, `notification`, and `address_book` have **no test files**.
10. **Design ownership** — a 375×812 baseline implies supplied designs, but the designer/source (Figma, etc.) is unrecorded.
11. **Backend ownership** — the API is Intrazero-hosted; whether it was built in-house or by a separate team is unknown.
12. **Payment provider** — the gateway is reached through a server-issued URL; the processor is never named client-side.
13. **App Store / Play Store review outcomes** — account deletion and Apple Sign-In are implemented (compliance indicators), but submission history is unknown.

---

## Two Accuracy Notes Before You Publish

### Deployment claims

Android release builds are signed with debug keys and there is no CI. If asked about release engineering in an interview, the Lessons Learned framing above is defensible; claiming a mature deployment pipeline is not.

### One security detail to avoid highlighting

`lib/main.dart:29-37` installs a global `HttpOverrides` whose `badCertificateCallback` returns `true` unconditionally — accepting *any* TLS certificate in all builds, including release. This disables certificate validation app-wide and exposes traffic to man-in-the-middle interception, which matters here because the app carries bearer tokens and payment flows. It is typically added to work around a staging certificate and then left in.

This is worth fixing regardless of the portfolio, and it means **"security considerations" should not be listed as a technical highlight** — a senior reviewer reading the repository would find this. It has been deliberately left out of Section 6 for that reason. The fix is to scope the override to debug builds via `kDebugMode`, or remove it once the server presents a valid certificate.

---

*Case study generated from static analysis of the Motary codebase. All technical claims are traceable to the implementation; unverifiable items are explicitly flagged above.*
