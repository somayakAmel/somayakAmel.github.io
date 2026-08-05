# Flowers — Flutter Marketplace App

> Portfolio case study. Every technical claim below is drawn from the project's actual implementation.
> Items that could not be verified from the codebase are marked **Needs confirmation** and listed in the final section.

---

## 1. Project Overview

**Flowers** is a cross-platform (iOS/Android) e-commerce marketplace built in Flutter for a flower/gift retail business, developed under the **Intrazero** organization (`com.intrazero.flowers`, API host `flowers.intrazero.org/v1/`).

The app is **Arabic-first** (default locale `ar`, with English support) and targets buyers browsing and ordering flower products from multiple sellers. It ships as version `1.0.0+8` against Flutter SDK `^3.5.0`.

The codebase contains both a **buyer** and a **seller** side, but the seller experience is largely **disabled in the current build** — seller auth, shop creation, and product-management DI modules are commented out in `lib/src/service_locator.dart` and `lib/src/routes_manager.dart`. The shipped product is effectively the **buyer marketplace**, with a small residual seller order-viewing surface still routed.

---

## 2. Problem

Buying flowers and gift arrangements online in this market requires solving several problems at once:

- **Multi-vendor discovery** — buyers need to browse products across many independent sellers/stores, each with their own catalogue, ratings, and location.
- **Localized commerce** — the primary audience is Arabic-speaking, requiring full RTL support and Arabic-formatted dates, not just translated strings.
- **Delivery is location-bound** — flowers are perishable and locally delivered, so orders depend on precise addresses and seller-to-buyer distance.
- **Trust in a marketplace** — buyers need seller ratings, product reviews, and a complaints/cancellation path.
- **Low-friction browsing** — requiring signup before browsing suppresses conversion.

---

## 3. Solution

A feature-modular Flutter client implementing:

- A **guest browsing mode** that hits dedicated unauthenticated endpoints (`products-guest`) so users can explore the catalogue before creating an account, with wishlist-dependent fields stripped from the response include-set for guests.
- **Multi-provider authentication** (email/password, Google, Apple, Facebook) with OTP email verification.
- A **product discovery stack** — categories, "For You" (FYP) feed, top-selling/best-seller sections, search with filters, and seller detail pages.
- **Cart → address → checkout → payment** flow, with payment completed in an embedded WebView and confirmed via navigation-URL interception.
- **Order lifecycle management** — order history, order details, scheduling, reorder, cancellation reasons, complaints, and post-delivery product reviews.
- **Google Maps-based address capture** with location autocomplete and a saved address book.
- **Firebase Cloud Messaging** push notifications that deep-link into order details.

---

## 4. My Role

> **Needs confirmation.** This is the one section that cannot be substantiated from the repository.

What the repository actually shows:

- Git history contains **195 commits across five author identities**: `mhosnyessa`/`Mohamed H Essa` (146), `mohamed hosny <m.hosny@intrazero.net>` (27), `s.kamel` (16), `Yussif Kahilo` (6). Commit range: **2025-01-21 → 2025-07-15**.
- **No commits are authored by the configured local Git identity** (`Meroothman`), and none match the account email on this machine.
- The uncommitted working-tree changes in this checkout are **file-permission mode changes only** (`100755` → `100644`) with **zero content modifications** — they carry no authorship signal.

**Therefore this checkout provides no evidence of specific contributions.** Before publishing this section, supply the role directly. To make it verifiable, use one of:

- The commit identity on the **origin remote** (this may be a clone where the relevant commits live under a different email, e.g. an `@intrazero.net` address) — run `git log --author="<your-email>"` against the full remote history.
- Merge requests / issue tickets on the GitLab instance (`gitlab.com/intrazero/...`).
- The specific features or modules owned, which can then be mapped back to concrete files.

**Do not claim ownership of the architecture as a whole** based on this repository alone — the Clean Architecture skeleton, the shared `core_package`/`types_package`/`locale_package`, and the DI structure predate and extend beyond this checkout.

---

## 5. Key Features

**Authentication & Account**
- Email/password login and registration with OTP email verification (`otp/verify`, `otp/resend`)
- Social sign-in: Google, Apple, Facebook
- Guest mode browsing
- Password reset flow (request → OTP verify → set new password)
- Profile management: name, phone, email (with re-verification OTP), password, profile image, language, notification mute, account deletion

**Product Discovery**
- Category browsing, "For You" feed, top-selling and best-seller sections
- Search with a dedicated filters screen (category, seller, and related filters)
- Product detail with image gallery, ratings, and reviews list
- Seller/store detail pages
- Blog content with in-app article and PDF viewing (`syncfusion_flutter_pdfviewer`)

**Cart & Checkout**
- Cart with per-item quantity updates and optimistic loading state per item ID
- Delivery address selection and update from within the cart
- Checkout and order scheduling (date picking)
- Waitlist join for unavailable products

**Orders**
- Buyer order history and detail; seller order list with month/year filters
- Order status updates, reorder, cancellation with reasons, complaint submission with reasons
- Payment via embedded WebView with status verification

**Address & Location**
- Saved address book (create, update, delete, paginated fetch)
- Google Maps picker with location autocomplete

**Engagement**
- Wishlist (add/remove/list)
- Product reviews and ratings after delivery
- Push notifications with in-app notification centre

**Content**
- Terms & conditions, privacy policy, FAQ, contact us (CMS-driven via `cms-pages`)

---

## 6. Technical Highlights

**Clean Architecture, feature-first.** Every feature under `lib/features/` splits into `data/` (datasources, models, repository impls), `domain/` (entities, repository interfaces, use cases), and `presentation/` (bloc, screens, widgets). The codebase contains **60 use case classes**, **18 Blocs**, and **6 Cubits**.

**Dependency Injection via GetIt.** `lib/src/service_locator.dart` registers all datasources, repositories, and use cases as lazy singletons, organized into per-feature init functions (`initCart()`, `initOrder()`, `initWishlist()`, …). Some modules are **lazily initialized at navigation time** — `SignUpOtpScreen` calls `initSignUpOtpModule()` from the route handler — with `sl.isRegistered<T>()` guards preventing duplicate registration.

**Shared internal packages.** The app depends on four in-house packages pulled from a GitLab monorepo of Flutter packages: `core_package` (API/cache consumers, Dio wiring), `types_package` (shared types, exceptions, `CacheConsumer`/`ApiConsumer` abstractions), `locale_package` (`LocaleCubit`), and a path-local `utils_package` (theme, strings, sizing, localization). This is a **multi-app platform strategy** — infrastructure is shared across Intrazero's Flutter apps rather than duplicated.

**Token refresh in the request interceptor.** `lib/src/core/api/app_interceptor.dart` intercepts every outbound request, loads the cached user, and calls `refreshTokenHandler()` — which compares `tokenSavedAt + tokenExpiresIn` against now and **proactively refreshes before expiry** rather than reacting to a 401. It also injects `Accept-Language` from `LocaleCubit` on every request, so the backend returns localized content server-side.

**Centralized error translation.** `lib/src/core/api/handel_dio_error.dart` maps `DioExceptionType` and HTTP status codes onto a typed exception hierarchy (`BadRequestException`, `UnauthorizedException`, `NotFoundException`, `ConflictException`, `InternalServerErrorException`, `NoInternetConnectionException`). A `401` additionally triggers a **global forced sign-out** via a static navigator key.

**Platform-adaptive navigation.** `lib/src/routes_manager.dart` uses `onGenerateRoute` with typed arguments (including Dart 3 **record types** — e.g. `(OrderBloc, int, String)` — for multi-argument routes). It returns `CupertinoPageRoute` on iOS and a custom 400ms `FadeTransition` on Android, so each platform keeps its native navigation feel.

**Bloc scoping strategy.** App-wide Blocs (cart, wishlist, orders, auth, locale, connectivity) live in a `MultiBlocProvider` at the root in `lib/src/app.dart`; screen-scoped Blocs are created per-route, and existing instances are forwarded across routes with `BlocProvider.value` to preserve state.

**Responsive sizing.** `flutter_screenutil` with a 375×812 design baseline, `splitScreenMode: true`, applied across the widget layer.

**Localization.** Custom JSON-based localization (`lang/ar.json`, `lang/en.json`) with **~486 keys per locale**, a custom `AppLocalizations` delegate, a `.tr(context)` extension, and locale persistence through `LocaleCubit`. Arabic is the default; the app ships Cairo and Changa font families for Arabic typography, and includes a dedicated Arabic date formatter.

**Push notifications with deep linking.** `lib/src/core/enums_and_classes/notification_service.dart` handles all three FCM states — foreground (`onMessage` + `flutter_local_notifications` on Android), background (`onMessageOpenedApp`), and terminated (`getInitialMessage`) — routing `clickable_type == 'order'` payloads directly to the order details screen.

**Perceived-performance work.** `shimmer` skeleton loaders across product cards, seller cards, dropdowns, and filter bars; `cached_network_image` for image caching; per-item loading IDs in `CartBloc` so only the tapped item shows a spinner rather than the whole list.

**Client-side image compression.** Profile image uploads run through `FlutterImageCompress.compressAndGetFile()` before multipart upload, reducing bandwidth on mobile connections.

**Offset-based pagination.** A shared `Pagination` model (`total`, `count`, `per_page`, `current_page`, `total_pages`) drives infinite scroll via `ScrollController` + `maxScrollExtent` listeners across product lists, order lists, and the address book.

---

## 7. Challenges

**1. Multi-provider auth converging on one session model.** Four sign-in paths (email, Google, Apple, Facebook) must all produce the same cached `Buyer` with valid `AuthData`, and email-unverified users must be diverted into the OTP flow rather than reaching the app.

**2. Token expiry across a large surface of authenticated endpoints.** With ~60 use cases hitting authenticated routes, per-call refresh logic would be unmaintainable and race-prone.

**3. Payment completion detection in a WebView.** The payment gateway runs as a web flow; the app must detect completion and determine success/failure without a native SDK callback.

**4. Arabic-first RTL with mixed content.** Default Arabic locale requires RTL layout, Arabic numerals/date formatting, and correct server-side content language — while still supporting English.

**5. Bloc state sharing across routes.** Cart, order, and address flows span multiple screens that must mutate the *same* Bloc instance rather than a fresh one.

**6. Scope reduction mid-project.** The seller-side feature set (shop creation, product management, seller auth) was evidently descoped — visible as large commented-out regions in the DI container, router, and test suite.

**7. Backend response shape coupling.** The API uses an `include` query-parameter convention (e.g. `ratings.rated_by,country,seller,product-category,images,store,isInWishlist`), so the client must construct different include-sets per auth state.

> **Needs confirmation:** two `flutter_jank_metrics_*.json` profiling artifacts sit in the repo root, indicating frame-performance investigation. The specific jank problem and its resolution are **not** documented in code and would need to be confirmed before being claimed.

---

## 8. Solutions

**1 → Repository-level session normalization.** `AuthBuyerRepoImpl` funnels every provider through the same contract: clear stale user → authenticate remotely → persist locally **only if `emailVerifiedAt != null`**. Unverified users therefore never obtain a cached session and are routed to `SignUpOtpScreen`. `getUser()` adds a **2-minute freshness window** — it returns the cached user immediately and refreshes from the network in the background, avoiding a blocking profile fetch on every entry.

**2 → Interceptor-level proactive refresh.** Rather than reacting to 401s, `AppInterceptorsImpl.onRequest` checks `tokenSavedAt + tokenExpiresIn` before each call and refreshes when expired, re-persisting the updated `Buyer`. The refresh endpoint itself and the OTP-resend endpoint are explicitly **excluded** to prevent infinite recursion. A 401 that still occurs is treated as unrecoverable and triggers global sign-out.

**3 → Navigation-delegate URL interception.** `PaymentWebViewScreen` sets a `NavigationDelegate` whose `onNavigationRequest` matches URLs containing `verify`, **cancels the navigation** (`NavigationDecision.prevent`), and dispatches `GetPaymentStatusEvent` so the *backend* — not the client — is the source of truth for payment status. The WebView clears cache and local storage on both init and dispose to prevent payment session leakage between attempts.

**4 → Locale as a cross-cutting concern.** `LocaleCubit` state drives `MaterialApp.locale`, and the same cubit is read inside the Dio interceptor to set `Accept-Language` — so UI language and API content language can never drift apart. A dedicated `format_date_to_arabic.dart` handles Arabic date rendering.

**5 → `BlocProvider.value` forwarding with typed route arguments.** Routes that continue an existing flow accept the live Bloc as part of their arguments and re-provide it via `.value`, so `CartDetailsScreen`, `UpdateCartAddressScreen`, `OrderMonthsFilterScreen`, and the review flow all mutate the originating instance.

**6 → Commenting-out over deletion.** Seller modules were disabled in place rather than removed, preserving the implementation for reactivation. This is pragmatic for a paused scope, though it leaves substantial dead code (see *Lessons Learned*).

**7 → Include-set construction in the datasource.** `ProductRemoteDataSourceImpl` derives `isGuest` from the presence of cached user data and conditionally omits `isInWishlist` from the include-set for guests, while routing to `products-guest` vs. `products`.

---

## 9. Architecture Decisions

| Decision | Reason | Benefit |
|---|---|---|
| **Clean Architecture with per-feature data/domain/presentation** | Enforce a dependency rule where domain is framework-agnostic; enable a multi-developer team to work on features in parallel | Business rules are testable without Flutter; features are independently navigable and reviewable |
| **One use case per operation (60 total)** | Keep each unit of business logic single-purpose and independently mockable | Blocs receive fine-grained collaborators; use cases are trivially unit-testable |
| **Bloc/Cubit over other state solutions** | Event-driven, explicit, traceable state transitions; `bloc_test` support | `AppBlocObserver` gives a single global hook for state/error tracing; complex flows (cart, orders) are auditable |
| **`CustomCubit<T>` generic for trivial local state** | Avoid writing a bespoke Cubit for a single boolean or index | Reduces boilerplate for toggles, page indices, and step counters |
| **GetIt service locator over compile-time DI** | Simple registration, no codegen build step, permits lazy per-feature module init at route time | Faster startup (lazy singletons); heavy modules deferred until their screen is opened |
| **Extract infrastructure into shared Git packages** | Reuse networking, caching, theming, and locale handling across Intrazero's app portfolio | Fixes propagate across apps; app repos stay feature-focused |
| **Custom JSON localization over ARB/gen-l10n** | Simple key-value editing without codegen; runtime locale switching | Non-developers can edit `ar.json`/`en.json` directly |
| **`onGenerateRoute` with typed args over declarative routing** | Centralize route construction and Bloc provisioning in one place | Every route's dependencies are visible in a single file; no route-level DI scattered across widgets |
| **Platform-adaptive page transitions** | Match each OS's native navigation expectations | Cupertino swipe-back on iOS, fade transitions on Android |
| **Proactive token refresh in the interceptor** | Avoid duplicating refresh logic across ~60 use cases | Single point of session maintenance; no 401-retry storms |
| **Server-driven localization via `Accept-Language`** | Product names, categories, and CMS content are backend-owned | No client-side content translation tables to maintain |

---

## 10. Tech Stack

**Framework**
- Flutter (Dart SDK `^3.5.0`), Material Design

**Architecture**
- Clean Architecture (data / domain / presentation), Repository pattern, Use-case pattern, feature-first modularization

**State Management**
- `flutter_bloc` (Bloc + Cubit), `bloc_test`
- `flutter_riverpod` / `riverpod_annotation` / `riverpod_generator` — *declared and `ProviderScope` is mounted in `main.dart`, but no providers were found in `lib/`; effectively unused. See Needs Confirmation.*
- `rxdart` — *declared; no usage found in `lib/`*

**Networking**
- Dio (via internal `core_package`), custom request interceptor, centralized typed error mapping, offset-based pagination

**Backend & Services**
- REST API (`flowers.intrazero.org/v1/`)
- Firebase Core, Firebase Auth, Firebase Cloud Messaging
- Google Maps Platform

**Local Storage**
- `shared_preferences` via a `CacheConsumer` abstraction; `path_provider`

**Authentication**
- Email/password + OTP, `google_sign_in`, `sign_in_with_apple`, `flutter_facebook_auth`

**UI & UX**
- `flutter_screenutil` (responsive), `cached_network_image`, `shimmer`, `flutter_svg`, `lottie`, `carousel_slider`, `flutter_staggered_animations`, `toastification`, `flutter_rating_bar`, `galleryimage`, `flutter_html`, `syncfusion_flutter_pdfviewer`, `webview_flutter`, `flutter_typeahead`, `country_code_picker`

**Media & Files**
- `image_picker`, `file_picker`, `flutter_image_compress`, `open_filex`, `permission_handler`

**Localization**
- Custom JSON delegate (`ar` / `en`), `flutter_localizations`, `intl`, Cairo + Changa Arabic font families

**Testing**
- `flutter_test`, `bloc_test`, `mockito`, `mocktail`

**Tooling**
- `build_runner`, `custom_lint`, `riverpod_lint`, `flutter_lints`, `flutter_launcher_icons`

**CI/CD**
- **None present in this repository.** No GitLab CI, GitHub Actions, Codemagic, or Fastlane configuration exists. Release signing on Android is still `signingConfig = signingConfigs.debug` with a `TODO`. No build flavors are configured.

---

## 11. Screens

**Onboarding & Auth**
- **Splash** — animated circular-reveal transition; reads cached `userRole` to decide between authenticated entry and the landing screen
- **Landing** — entry point offering login/register paths
- **Buyer Login / Sign Up** — credential and social auth
- **Sign-Up OTP** — email verification code entry with resend
- **Forgot Password** — three-stage flow: request → OTP verify → set new password
- **Buyer Auth Wrapper** — routes an authenticated session into the main layout

**Main Shell**
- **Layout (Buyer)** — `PageView` shell with bottom navigation across Home, Orders, Wishlist, Cart, and Account; initializes FCM permissions and handlers; listens for connectivity loss

**Discovery**
- **Home** — categories, best sellers, top-selling, and For-You feed with infinite scroll
- **For You** — dedicated personalized product feed
- **Search** — query-driven product search
- **Filters** — filter selection surface
- **Product Details** — gallery, description, ratings, add-to-cart, wishlist toggle
- **Reviews** — full review list for a product
- **Seller Details** — seller profile with their filtered catalogue
- **Blog Details / PDF View** — CMS article rendering and in-app PDF viewing

**Commerce**
- **Cart** — line items with quantity controls
- **Cart Details** — order summary before checkout
- **Update Cart Address** — delivery address selection for the cart
- **Map / Map Picker** — Google Maps location selection with autocomplete
- **Schedule Order** — delivery date selection
- **Payment** — payment method presentation
- **Payment WebView** — hosted gateway flow with status interception

**Orders**
- **Buyer Orders** — order history with status grouping
- **Buyer Order Details** — items, status timeline, cancel/complain actions
- **Seller Orders / Seller Order Details** — seller-side order views
- **Order Month / Year Filter** — date-range filtering for seller orders

**Post-Purchase**
- **Order Products** — item selection for review
- **Review Product** — rating and written review submission

**Account**
- **Buyer Account** — account menu hub
- **Profile** — user details
- **Update Field / Update Password / Verify Change Email OTP** — granular profile edits
- **All Saved Addresses / Address Details** — address book CRUD
- **Wishlist** — saved products
- **Notifications** — notification centre

**Informational**
- **Terms & Conditions, Privacy Policy, FAQ, Contact Us** — CMS-driven pages

---

## 12. Lessons Learned

**Architecture scales when the dependency rule is enforced.** With 15+ feature modules and 60 use cases, the data/domain/presentation split is what keeps the codebase navigable — any developer can locate a behaviour by feature and layer without reading unrelated code.

**Cross-cutting concerns belong in interceptors, not call sites.** Token refresh and `Accept-Language` injection are handled once in the Dio interceptor. Had these been per-use-case, ~60 call sites would each be a potential bug. The corollary learned here is subtle: interceptor logic must explicitly exclude the endpoints it depends on (refresh, OTP resend), or it recurses.

**Shared internal packages are a multiplier, but they add coupling.** Extracting `core_package`, `types_package`, and `locale_package` to a shared GitLab group means fixes propagate across the app portfolio — at the cost of unpinned Git dependencies (no version constraints or commit refs in `pubspec.yaml`), which makes builds non-reproducible over time. **Pinning to tags or commit SHAs would be the correction here.**

**Perceived performance is a product decision.** Skeleton shimmer loaders, image caching, per-item cart loading states, and a 2-minute cached-user window all target *felt* latency rather than raw throughput — the right trade for a mobile marketplace on variable connections.

**Descoping should remove code, not comment it out.** Disabling the seller modules in place preserved optionality but left substantial dead weight: commented DI registrations, unreachable route cases, and — most importantly — **a test suite that no longer matches the app**. Roughly half the tests target seller auth, shop creation, and shop repositories for features that are no longer wired up. Deleting to version control (which is what version control is *for*) would have kept the working tree honest.

**Dead code hides in plain sight.** `LookupsRepositoryImpl.getProductCategories()` contains a cache-first read/write strategy that **never executes** — an unconditional `return _lookupsRemoteDatasource.getProductCategories(page)` precedes the entire `try/catch`. The `LookupsLocalDatasourceImpl` methods it would call are themselves mostly `throw UnimplementedError()`. **The app has no working offline caching for lookups**, despite the structure suggesting otherwise. This is a good argument for treating unreachable-code lints as errors.

**Declared dependencies should be pruned.** `riverpod`, `flutter_riverpod`, `riverpod_annotation`, and `rxdart` are all declared, and a `ProviderScope` wraps the app — yet no providers or Rx usage exist in `lib/`. Carrying two state-management systems in the dependency graph increases build size and confuses newcomers about which pattern to follow.

**Security decisions made for convenience must not reach release.** `MyHttpOverrides` in `lib/main.dart` sets `badCertificateCallback => true`, **globally disabling TLS certificate validation** and exposing every request to man-in-the-middle interception. This is almost certainly a workaround for a staging certificate, but it is unconditional — not gated on `kDebugMode`. Combined with release builds still signed by the debug keystore, this is the highest-priority item to fix before any production release.

---

## Needs Confirmation

The following cannot be verified from the codebase and must be supplied before publishing:

**Contribution & team**
- **Specific role and contributions** — no commits in this repository match the local Git identity (see *My Role*). This is the single most important item to resolve.
- Team size and composition — history shows 4 distinct human identities, but their roles are unknown.
- Whether work was done on the shared `core_package` / `types_package` / `locale_package` repositories, which are not part of this checkout.

**Product & business**
- Business goals, KPIs, and the commercial rationale for the app
- Whether the app was ever publicly released; App Store / Play Store listings and statistics
- User numbers, order volume, or any adoption metrics
- The client/brand behind the "Flowers" product
- Why the seller-side scope was disabled — descoped, deferred, or split into a separate app

**Technical unknowns**
- **The `flutter_jank_metrics_01/02.json` profiling artifacts** — what jank was investigated, what was found, and whether it was fixed. No resulting optimization could be inferred from the code.
- The payment gateway provider (the integration is generic WebView-based; no provider is named in code)
- Whether Riverpod was intentionally planned and abandoned, or is vestigial
- Whether the TLS-validation bypass is a known staging workaround with a production fix elsewhere
- Release process — how builds were signed and distributed given no CI/CD or release signing config exists
- Project timeline beyond the commit range visible here (2025-01-21 → 2025-07-15)
- Actual test pass rate — the suite was not executed, and a significant portion targets disabled seller modules
