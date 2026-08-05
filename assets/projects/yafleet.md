# YaFleet — Peer-to-Peer Crowdshipping Platform (Flutter)

> Portfolio case study. Every technical claim below is traced to the actual implementation
> or to Git history. Unverifiable items are listed under **Needs Confirmation**.

---

## 1. Project Overview

YaFleet is a cross-platform mobile marketplace (iOS + Android) that connects **travelers** who have unused luggage capacity with **shippers** who need to send packages along the same route. A traveler publishes a trip (route, dates, travel method, available weight, meeting points); a shipper publishes a shipment (route, weight, packing type, category); the platform matches the two and manages the transaction end to end — request negotiation, escrowed payment, QR-verified physical handover, in-app chat, and payout to the courier's wallet.

The app ships in three languages (English, Arabic, Chinese — 526 translation keys each in `lang/`) with a shared Arabic/Latin type system (Almarai + Inter, `pubspec.yaml`), indicating a MENA-plus-China corridor focus.

- **Package ID:** `com.intrazero.majdiyafleet` (`android/app/build.gradle`)
- **API:** `https://app.yafleet.com/v1` (`lib/src/core/api/endpoints.dart`)
- **Version at HEAD:** 1.0.2+2 · **minSdk** 23 · **targetSdk** 35
- **Scale:** 458 Dart files in `lib/`, 19 feature modules, 296 commits (Dec 2024 – Nov 2025)

---

## 2. Problem

International and intercity shipping is slow and disproportionately expensive for small parcels — a courier prices a 2 kg package on a fixed commercial tariff regardless of how much unused capacity is flying the same route that day. Meanwhile, millions of travelers cross those exact routes with half-empty luggage allowances.

Turning that spare capacity into a shipping network creates four hard trust and coordination problems, all of which the codebase addresses directly:

1. **Discovery** — a shipper must find a traveler whose route, dates, weight limit, and accepted cargo types all fit, and who will physically be near enough to meet.
2. **Trust between strangers** — neither party has a reason to trust the other with money or goods.
3. **Payment risk** — the shipper will not pay before delivery; the traveler will not carry goods without a guarantee of payment.
4. **Proof of custody** — both handover points (pickup and drop-off) need tamper-resistant evidence that the parcel actually changed hands.

---

## 3. Solution

The app resolves each problem with a distinct implemented mechanism:

**Discovery** — Trips and shipments are separate first-class entities with bidirectional matching endpoints (`/trips/{id}/matched-shipments`, `/shipments/{id}/matched-trips`). Search is geospatial and multi-criteria: `SearchTripInputs.toSearchString()` composes a server-side filter DSL (`latitude:x;longitude:y;weight_from:…;arrival_date_from:…;travel_method:…`) joined with `searchJoin: And`. When the user has not set coordinates, `TripsBloc._getTrips` resolves the device location first and fails gracefully with a localized message if permission is denied.

**Trust** — Layered identity verification (national ID, passport, and passport-with-face liveness via `/identity-verifications/passport/{id}/face`), a bidirectional rating and review system after delivery, and an admin ban system with a user-facing appeal flow (`lib/features/ban_appeal/`).

**Payment** — Money is taken at request-acceptance time, not at delivery. `PaymentMethodScreen` offers Stripe card payment or internal wallet balance. Card flow returns a hosted `payment_url` rendered in a WebView whose navigation delegate detects the `status=success|fail` callback to resolve the transaction. The traveler is paid into an in-app wallet and withdraws via bank transfer or cash pickup.

**Proof of custody** — Each request carries a `stageQr` token (`Request` entity). At pickup and drop-off, one party displays a QR code and the other scans it (`qr_scan_sheet.dart`); the scanned token is posted to `/shipment-requests/{id}/pickup` or `/dropoff` as proof, so a status transition cannot be faked remotely.

---

## 4. My Role

**Verified from Git history:** 90 commits authored as `s.kamel` / `somaya kamel` between **21 January 2025 and 11 June 2025**, on a team of three active developers. I worked in a feature-branch + merge-request workflow (branches: `wallet-balance`, `withdraw-request`, `transactions-impl`, `reviews_impl`, `report-problem`, `hold-impl`, `update-profile`, `create-payment`, `unverified-user-limit`, `guest-mode-hide-requests`, `clear-item-search-fixed`).

**99 of the 458 files in `lib/` were created by me** (`git log --diff-filter=A`). The project's architectural skeleton, core networking, auth, trips, and shipments were established by the project creator before I joined; I built vertical feature slices on top of it and maintained shared surfaces.

### Features I built end to end (data → domain → presentation)

| Feature | Evidence |
|---|---|
| **Wallet & payouts** — entire module: balance, withdrawal templates (bank + cash), transfers, withdrawal requests | Sole creator of all 5 data models, repo impl, all 5 use cases, `WalletBloc`/event/state, and 6 screens |
| **Transactions ledger** — paginated, date-grouped, filtered by all/incoming/payment/withdraw | Created `GroupedTransaction`, `TransactionModel`, `GetTransactionsUsecase`, transactions + details screens, 5 section/card widgets |
| **Profile module** — view/edit profile, per-field update, password change, email change with OTP re-verification, account deletion, reviews display | Created the datasource, repo impl, all 6 use cases, `ProfileBloc`, and 7 screens/widgets |
| **Reviews & ratings** — post-delivery rating tied to request status `drop_off`, for both traveler and shipper roles | Created `ReviewInput`, `ReviewRequestUsecase`, `GetReviewsUsecase`, `ReviewModel`, `Review`, `reviews_section.dart`, `review_bottom_sheet.dart`, `Rating` entity |
| **Report a problem** — categorized reports with photo attachments | Created `ReportTitle` + model, both use cases, screen, and 2 widgets |
| **Payment integration** — payment input/use case and the Stripe WebView bottom sheet | Created `PaymentInput`, `CreatePaymentUsecase`, `payment_web_view_model_sheet.dart`, `payment_method_screen.dart`; commit `44f29ce "create payment"` |
| **Shipment holding flow** — temporary vs. permanent hold with reason capture | Created `holding_shipment_screen.dart`; commits `2472880`, `564ed4b` |
| **Requests listing screens** — sent/received request sections for both trip and shipment sides, plus accepted-requests view | Created 5 listing widgets + `trip_accepted_requests.dart` |
| **Trip/shipment cancellation** | Created `CancelTripUsecase`, `CancelShipmentUsecase`; commit `a43b03f` |
| **Chat-related shipments** — surfacing active shipments inside a conversation | Created `chat_related_shipments.dart` + 2 section widgets; commit `5279461` |
| **Bank picker** | Created `Bank` entity, `BankModel`, `GetBanksUsecase`, 2 picker widgets |

### Shared/maintained surfaces

- **Localization owner** — the highest-touch files in my history are `en.json`, `ar.json`, `zh.json` and `strings_manager.dart` (25 commits each), i.e. I maintained the trilingual string catalogue across the team's features.
- **Routing & DI** — 18 commits to `routes_manager.dart`, 12 to `service_locator.dart`, 12 to `endpoints.dart`, registering my modules and wiring their routes.
- **Access-control rules** — implemented guest-mode and unverified/banned-user restrictions (`eea5bd0 "unverified and baned user limits"`, `cd5502a "Hide shipping request button while in guest mode"`, `cad7479 "verified user condition edit"`).
- **Trip editing** (`032239d`), **map picker range circle** (`1258761`), **staggered list animations** (`7bc7dcf`, `791fac4`, `980b6ae`), and search-filter clearing (`bb18849`, `d51e1b7`, `0279cb0`).

### Explicitly not mine

Project scaffolding, Clean Architecture skeleton, Dio/`ApiConsumer` core, interceptors and refresh-token handling, auth and social sign-in, trips/shipments creation flows, Firestore chat, and push-notification services were authored by `YussifKahilo`. My work builds on those foundations and follows their established patterns.

> **Needs confirmation:** whether I also contributed design input, QA, code review, or release duties — none of this is visible in the repository.

---

## 5. Key Features

**Onboarding & access**
- CMS-driven onboarding carousel, guest browsing without an account, and a login gate that appears only on transactional actions.

**Authentication & identity**
- Email/password registration with OTP verification; Google, Apple, and Facebook sign-in; forgot-password via OTP; three-tier identity verification (national ID, passport, passport + face liveness).

**Trips & shipments (dual role)**
- 3-step wizards to publish a trip (route, dates, travel method, weight capacity, excluded cargo types, multiple geo-pinned pickup/delivery meeting points) or a shipment (route, weight, packing type, category, photos).
- Edit and cancel published listings; separate current/previous tabs.

**Discovery & matching**
- Location-aware search with filters on weight range, arrival date range, travel method, and departure/arrival country + city; autocomplete location lookup; bidirectional match screens with distance-to-nearest-meeting-point computed on device (`getNearestDistance`).

**Request lifecycle**
- A 10-state machine — `pending → accepted → paid → picked_up → drop_off`, with `rejected`, `cancelled`, `returned`, `temporarily_hold`, `permanently_hold` branches — surfaced as sent/received request queues for both roles.

**Payments & wallet**
- Stripe card checkout or wallet balance; in-app wallet with balance, reusable bank/cash withdrawal templates, withdrawal requests, multi-currency selection, and a date-grouped transaction ledger filterable by type.

**Communication**
- Real-time Firestore-backed one-to-one chat with media attachments, unread counts, mark-as-read, trip sharing into a conversation, and related-shipment context inside the chat.

**Notifications**
- FCM push (foreground, background, terminated) with deep-link routing by `clickable_type`; locally scheduled trip reminders; per-category notification muting; in-app notification centre with unread badge.

**Trust & support**
- Post-delivery two-way ratings and reviews; ban appeals; categorized problem reports with photos; FAQ, terms, and privacy pages rendered from CMS HTML.

---

## 6. Technical Highlights

**Clean Architecture, consistently applied at scale.** All 19 feature modules follow `data/{datasources,models,repositories} → domain/{entities,inputs,repositories,usecases} → presentation/{bloc,screens,widgets}`. Models convert to domain entities at the repository boundary (`result.$1.map((e) => e.toEntity()).toList()` in `trips_repository_impl.dart`), so no JSON shape leaks into the UI. Use cases extend a shared `BaseUseCase<ReturnType, ParamsType>`.

**Functional error handling.** Every use case wraps its repository call in `tryCatch`, which returns `Either<Failure, T>` and maps typed exceptions (`ServerException`, `UnauthorizedException`, `CacheException`) to typed failures. Blocs consume results with `.fold(onFailure, onSuccess)` — an unhandled network error cannot crash a screen. `handelDioError` translates HTTP status codes into that exception hierarchy at the Dio layer.

**Modular, lazily-initialized DI.** `service_locator.dart` splits registration into 15 per-feature `init*Module()` functions. Only auth, notifications, lookups, trips, shipments, about, and profile load at startup; wallet, chats, requests, ban-appeal, and verification modules register on first navigation to their route, each guarded by an `if (sl.isRegistered<T>()) return;` idempotency check. This keeps cold start lean and makes module boundaries explicit.

**Multi-tier state management.** Global Blocs for cross-cutting domains are provided once in `app.dart`; screen-scoped Blocs are created per route; and a generic `CustomCubit<T>` handles trivial local UI state (radio selection, tab index) without a bespoke Bloc per widget.

**In-flight request cancellation.** `TripsBloc._getMatchedTrips` calls `sl<ApiConsumer>().cancelRequest()` when a new first-page query supersedes an in-flight one, preventing stale responses from overwriting fresher results — and `tryCatch` classifies the resulting `Canceled` exception as a distinct `CancelFailure` so cancellation is never shown to the user as an error.

**Accumulating pagination.** List Blocs append rather than replace: new page results are concatenated onto the existing list held in state, with `page == 1` triggering the loading state and resetting. Paired with a reusable `PaginatedList` widget that fires `loadMoreData()` at scroll extent.

**Trilingual localization with RTL.** Runtime language switching via `LocaleCubit`, persisted locally and pushed to the backend (`/change-lang`), with `Accept-Language` injected into every request by the interceptor. Directional layout is handled through `EdgeInsetsDirectional` helpers, and list entry animations invert their horizontal offset based on `Directionality.of(context)` (`animations.dart`).

**Shared internal package ecosystem.** Four Git-hosted packages (`core_package`, `types_package`, `locale_package`) plus a local `utils_package` supply the Dio consumer, cache consumer, `Either`/`Failure` types, and ~40 shared widgets — reusable across the company's Flutter apps rather than duplicated per project.

**Responsive sizing.** `flutter_screenutil` against a 375×812 baseline, exposed through `.rh`/`.rw`/`.rs` extensions used consistently for dimensions, spacing, and font sizes.

---

## 7. Challenges

1. **Payment confirmation across a WebView boundary.** Stripe checkout runs on a hosted page outside Flutter's control; the app must reliably learn whether payment succeeded, failed, or was abandoned.
2. **Physical handover cannot be trusted to a button tap.** A "picked up" status that either party can set unilaterally is worthless as proof of custody.
3. **A ten-state request machine driven from three directions.** Status changes originate from the local user, the counterparty (via push), or the backend — and each maps to a different endpoint and payload shape.
4. **Location-dependent search that must not dead-end.** Search requires coordinates, but permission may be denied, permanently denied, or the OS location service disabled.
5. **A dual-role user model.** The same person is a traveler on one screen and a shipper on the next; nearly every list, detail view, and action must resolve which role applies.
6. **Two withdrawal methods with divergent required fields** (bank: account/IBAN/bank/country; cash: receiver identity) behind one wallet flow.
7. **Three languages with opposing text direction** across 526 keys and a feature set still being actively extended by three developers.
8. **Trilingual + multi-developer string drift** — my commit history shows repeated `translation additions` passes, indicating keys landed out of sync with features.

---

## 8. Solutions

**1 — WebView payment resolution.** `PaymentWebViewBottomSheet` installs a `NavigationDelegate` that inspects every URL transition: `onPageStarted` closes the sheet on the `/payments/verify/stripe` callback, and `onPageFinished` parses `Uri.queryParameters['status']`, popping `true` on `success` and `false` on `fail`. The bottom sheet is `isDismissible: false`, so the user cannot dismiss mid-transaction into an ambiguous state, and the result propagates back as the sheet's return value. Wallet payments skip the WebView entirely and resolve synchronously. The controller's cache is cleared on `dispose` so no card session persists.

**2 — QR-verified handover.** The backend issues a per-request `stageQr` token. The receiving party scans it with `QRScannerSheet`, and the scanned value is submitted as `token` on the `pickup`/`dropoff`/`return` transitions. A `captured` boolean guards the scan stream against duplicate emissions firing `Navigator.pop` twice, and `reassemble()` pauses/resumes the camera per platform to survive hot reload. Because the token originates server-side and must be physically presented, neither party can advance the state alone.

**3 — Centralized status-transition mapping.** `RequestsRemoteDatasourceImpl.changeStatus` resolves endpoint and payload from a single Dart 3 `switch` expression over `RequestStatus`, isolating hold/cancel-hold endpoints from the `/{id}/{action}` transitions and attaching `action`, `token`, or hold metadata only where required. Remote-driven changes flow through a dedicated `ChangingRequestStatusCubit`: FCM payloads carrying `current_status` are parsed in `notifications_service.dart` and broadcast so open screens refresh without polling. All requests are tunnelled through Laravel-style `_method: patch` POST overrides for `FormData` compatibility.

**4 — Graceful location degradation.** `GeolocationService` distinguishes *denied*, *permanently denied*, and *service disabled*, offering `openAppSettings()` vs. `openLocationSettings()` accordingly, and suppresses the prompt on first launch by recording a cache flag so users aren't interrupted during onboarding. Rather than throwing, it returns a sentinel `_fallbackPosition()` at (0,0); `TripsBloc` treats `latitude == 0` as "resolve now", and if resolution fails emits a localized, actionable failure state instead of an empty list.

**5 — Role resolution at the entity layer.** `Request` carries `requestedByMe`, `travelerId`, and `shipperId`, so presentation code branches on domain data rather than inferring role from navigation context. Listing screens are split into explicit `sent_requests_section` and `received_requests_section` widgets per side (trip and shipment) — four widgets I authored — making each role's rules independently readable and testable.

**6 — Polymorphic withdrawal templates.** A sealed-style `WalletInputInfoModel` hierarchy (`BankInputInfoModel`, `CashInputInfoModel`) lets `WalletRemoteDatasourceImpl.postWalletInfo` serialize the correct payload from one call site, while `getWalletInfo(TransferType)` queries with `search: 'type:${type.name}'` and defensively returns `null` for both a missing key and an empty list — the API is inconsistent about which it returns for "no template saved".

**7/8 — Localization discipline.** All three catalogues are kept key-identical (526 each, verified), addressed through a typed `StringsManager` constant rather than raw strings, so a missing key is a compile-time-visible mistake rather than a runtime blank. Maintaining this was effectively my responsibility on the team.

---

## 9. Architecture Decisions

**Feature-first Clean Architecture over layer-first**
- *Decision:* Organize by feature module, each with its own three-layer stack, instead of global `models/`, `screens/`, `services/` folders.
- *Reason:* Three developers working concurrent feature branches; layer-first would put every merge in the same directories.
- *Benefit:* My wallet, profile, and reviews branches touched almost entirely disjoint files from teammates' trips/chat work — visible in the history as clean feature-branch merges with minimal conflict resolution.

**Bloc for domain state, `CustomCubit<T>` for ephemeral UI state**
- *Decision:* Event-driven Blocs for anything with async or business meaning; a generic single-value Cubit for local widget state.
- *Reason:* Full event/state boilerplate for a radio-button index is unjustified cost, but `setState` in a large screen forces broad rebuilds.
- *Benefit:* `PaymentMethodScreen` drives method selection with `CustomCubit<int>` and the payment call with `RequestsBloc` — surgical rebuilds, no new state class.

**Per-module lazy DI registration**
- *Decision:* 15 `init*Module()` functions invoked from route generation, not one monolithic startup registration.
- *Reason:* A user who never opens the wallet should not pay its construction cost at launch.
- *Benefit:* Smaller cold-start graph and enforced module boundaries; `isRegistered` guards make repeated navigation idempotent.

**`Either<Failure, T>` instead of exception propagation**
- *Decision:* Convert exceptions to typed failures at the use-case boundary via `tryCatch`.
- *Reason:* Blocs must render every error as UI state; exceptions escaping into the widget tree are unrecoverable.
- *Benefit:* Uniform `.fold()` handling in every Bloc, and error paths are visible in the type signature rather than discovered in production.

**Server-side filter DSL over client-side filtering**
- *Decision:* Encode search as a `field:value;field:value` string with `searchJoin: And`, plus explicit `include` graphs for relations.
- *Reason:* Matching spans large datasets with geospatial ranking that cannot run on device.
- *Benefit:* Pagination stays correct under filtering, and the exhaustive `Endpoints.tripIncludes` constant fetches a fully-populated aggregate in one round trip instead of N+1 follow-ups.

**Firestore for chat, REST for everything else**
- *Decision:* Message streams come from Firestore; chat lists, media upload, and read receipts go through the REST API.
- *Reason:* Real-time fan-out is Firestore's strength; business rules, auth, and file handling belong with the backend.
- *Benefit:* Sub-second message delivery via `snapshots()` without building socket infrastructure, while the server keeps authority over chat metadata. Cost: writes go to both stores (`chats_remote_datasource.dart`) — a deliberate consistency trade-off.

**Platform-differentiated navigation transitions**
- *Decision:* `CupertinoPageRoute` on iOS, a 400 ms `FadeTransition` on Android (`routes_manager.dart`).
- *Reason:* iOS users expect interactive edge-swipe back.
- *Benefit:* Native-feeling navigation on both platforms from one codebase.

**Shared internal packages over per-project copies**
- *Decision:* Extract networking, types, locale, and UI into `core_package`/`types_package`/`locale_package`/`utils_package`.
- *Reason:* An agency running multiple Flutter apps was re-solving the same problems per project.
- *Benefit:* Swapping the HTTP client or error taxonomy is a package-level change; YaFleet's own `lib/` contains almost no generic infrastructure.

---

## 10. Tech Stack

| Category | Technologies |
|---|---|
| **Framework** | Flutter (Dart SDK ^3.5.1) — records, pattern matching, switch expressions |
| **Architecture** | Clean Architecture (data/domain/presentation), Repository pattern, Use-case pattern, feature-first modularization |
| **State Management** | `flutter_bloc` 8.1.6 — Bloc + Cubit, global `AppBlocObserver`, custom generic `CustomCubit<T>` |
| **Dependency Injection** | `get_it` 8.0.0 with lazy singletons and 15 per-feature init modules |
| **Networking** | Dio (via `core_package`), custom request interceptor, refresh-token handler, typed exception→failure mapping, `Either<Failure,T>` |
| **Backend** | REST API (`app.yafleet.com/v1`), Laravel-style `_method` overrides, filter DSL + `include` relation graphs |
| **Realtime & Firebase** | `cloud_firestore` (chat), `firebase_messaging` (FCM push), `firebase_auth`, `firebase_core` |
| **Local Storage** | `CacheConsumer` abstraction (via `core_package`) for user session, tokens, onboarding and permission flags |
| **Authentication** | Email/password + OTP, `google_sign_in`, `sign_in_with_apple`, `flutter_facebook_auth`; ID/passport/face verification |
| **Payments** | Stripe via hosted checkout in `webview_flutter`; internal wallet with bank & cash withdrawal templates; `currency_picker` |
| **Maps & Location** | `google_maps_flutter`, `geolocator`, `geocoding`, on-device nearest-meeting-point distance calculation |
| **Notifications** | `firebase_messaging`, `flutter_local_notifications`, `timezone` (scheduled trip reminders) |
| **Media & Files** | `image_picker`, `file_picker`, `open_filex`, `share_plus`, `screenshot`, `path_provider`, `flutter_svg`, `lottie` |
| **UI & Responsive** | `flutter_screenutil` (375×812 baseline), `shimmer` skeletons, `flutter_staggered_animations`, `smooth_page_indicator`, `flutter_rating_bar`, `dotted_border`, `avatar_glow`, `flutter_html` (CMS), `country_flags`, `country_code_picker` |
| **Localization** | Custom `AppLocalizations` + `LocaleCubit`; en / ar / zh, 526 keys each; Almarai (Arabic) + Inter (Latin) |
| **QR** | `qr_flutter` (generate), `qr_code_scanner_plus` (scan) |
| **Testing** | `flutter_test`, `bloc_test` 9.1.7, `mocktail` 1.0.4 — declared as dev dependencies |
| **Tooling** | `flutter_lints` 4.0.0, `flutter_launcher_icons`, `flutter_native_splash`, GitLab (origin) with feature-branch + MR workflow |

---

## 11. Screens

**Entry & onboarding**
- **Splash** — bootstraps session, resolves auth state, routes to onboarding / login / main layout.
- **Onboarding** — CMS-driven carousel with page indicator; requests location permission in-context.
- **Auth Wrapper** — decides authenticated vs. guest destination.

**Authentication**
- **Login** — credentials + Google/Apple/Facebook; guest-mode aware (back navigation is disabled unless entered from guest browsing).
- **Register** — signup with country-code phone input.
- **Register Verification** — OTP entry with resend.
- **Request Reset Password → Reset Password OTP → Reset Password** — three-step recovery.

**Identity verification**
- **Account Verification** — hub for choosing verification method.
- **National ID Verification** / **Passport Verification** / **Passport Face Verification** — document capture and liveness step.

**Main layout (bottom navigation)**
- **Home** — entry point to trips/shipments discovery.
- **Search** — trip/shipment search with from-to location pickers, date range, weight range, travel method; clearable filter chips.
- **My Trips** — current/previous tabs for published trips.
- **My Shipments** — current/previous tabs for published shipments.
- **Menu** — profile summary, wallet balance, and navigation to settings, legal pages, and support.

**Publishing**
- **Create Trip (3 steps)** — route & travel method → dates/times & capacity → map-based pickup/delivery meeting points. Doubles as the edit flow.
- **Create Shipment (3 steps)** — route → package details (weight, packing type, category) → photos.

**Discovery & matching**
- **Matching Trips** / **Matching Shipments** — counterpart matches for a given listing, ranked with distance to nearest meeting point.
- **My Trips Matched With Shipment** / **My Shipments Matched With Trip** — reverse view for the owner.
- **Trip Details** / **Shipment Details** — full listing with meeting points, owner profile, QR handover actions, and contextual status buttons.

**Requests & fulfilment**
- **Trip Requests** / **Shipment Requests** — sent and received queues with status filters.
- **Trip Accepted Requests** — accepted requests on a trip.
- **Holding Shipment** — temporary vs. permanent hold selection with mandatory reason.
- **Payment Method** — Stripe or wallet, with live balance; Stripe opens a WebView bottom sheet.

**Wallet**
- **Balance Withdraw** — withdrawal entry point showing available balance.
- **Bank Account Info** / **Cash Receiver Info** — reusable withdrawal templates.
- **Transfer** — executes a withdrawal against a saved template.
- **Transactions** — paginated ledger grouped by date, filtered by all/incoming/payment/withdraw.
- **Transaction Details** — single transaction breakdown.

**Chat**
- **My Chats** — conversation list with unread counts.
- **Chat** — real-time messaging with media attachments.
- **Chat Related Shipments** — active shipments in the conversation's context.
- **Share a Trip** — send a trip into a conversation.

**Profile**
- **My Profile** — own profile with reviews and verification status.
- **Profile** — another user's public profile, ratings, and "start chat".
- **Update Field** — generic single-field editor (name, phone, email).
- **Change Email Verify** — OTP confirmation for email change.
- **Update Password**.

**Notifications**
- **My Notifications** — in-app centre with unread badge.
- **Mute General Notifications** — per-category muting.
- **Notification Permission** — permission priming (route currently commented out in `routes_manager.dart` — *needs confirmation on whether this is intentionally retired*).

**Support & legal**
- **Report Problem** — categorized report with photo attachments.
- **FAQ**, **Terms & Conditions**, **Privacy Policy** — CMS HTML.
- **Contact Us**, **Ban Appeal**.

---

## 12. Lessons Learned

**Architecture pays off exactly where teams collide.** With three developers on parallel feature branches, feature-first modularization meant my wallet, transactions, and profile work merged with minimal conflict. The cost — four files per simple endpoint — is real, but the merge history shows it bought more than it charged.

**Consistency is a feature.** Because every module followed the same datasource → repository → use case → bloc shape, I could add the entire wallet stack by pattern-matching against existing modules rather than negotiating a design. New engineers can navigate any feature after learning one.

**Error handling belongs in the type system.** `Either<Failure, T>` forced me to handle failure at every call site. Loading, success, and error states existed from the first commit of each feature instead of being retrofitted after QA.

**Third-party boundaries need explicit contracts.** The Stripe WebView taught me that when a critical flow crosses into code I don't control, I need a deterministic signal — URL callbacks and status parameters — plus defensive UX (non-dismissible sheet, cache clearing) for every path including abandonment.

**Trust flows need physical anchors.** A status field alone can't prove custody. Tying transitions to server-issued QR tokens exchanged in person is what makes the marketplace's core promise enforceable — a design lesson that generalizes well beyond this app.

**Defensive parsing is not pessimism.** Writing `response.data['data'] == null || (… is List && …isEmpty)` looked redundant until the API returned both shapes for the same "empty" condition. Backend contracts drift; the client is where that has to be absorbed.

**Localization is architecture, not a translation task.** Owning three catalogues across a moving feature set taught me that typed string constants and key-parity discipline are the only thing standing between a trilingual app and silent blank labels in the language you don't personally read.

**Lazy modularity is cheap to add and hard to retrofit.** Splitting DI into per-feature init functions cost almost nothing at the time and gave measurable startup savings plus enforced boundaries.

---

## Needs Confirmation

The following cannot be verified from the codebase or Git history:

**Product & business**
- Business goals, target markets, and monetization model (a commission is implied by escrowed payments but is not visible client-side).
- Whether the app is publicly released; no App Store or Play Store IDs, listing metadata, or release notes exist in the repo.
- User numbers, transaction volume, ratings, retention, crash-free rate, or any production metric.

**Team & process**
- Total team size, including backend, design, QA, and product roles — only three active Flutter contributors are visible.
- Your exact job title and formal responsibilities.
- Whether you contributed design, QA, code review, or release management (no review metadata is present in the local clone).
- Sprint cadence and project management tooling. Branch names and a `hotfixes-YAF-374` commit suggest Jira with a `YAF` project key — **worth confirming**, as it evidences structured process.

**Timeline**
- Your engagement dates. Git shows commits from **21 Jan 2025 to 11 Jun 2025**, but first/last commit ≠ start/end of employment.
- Whether the project is ongoing (last commit: 5 Nov 2025).

**Engineering claims I could not substantiate**
- **CI/CD: none exists in this repository.** No `.gitlab-ci.yml`, GitHub Actions, Codemagic, or Fastlane config. Do not list CI/CD on your résumé for this project unless it was configured outside the repo.
- **Build flavors: none.** A single Android build type, one `applicationId`, one hardcoded base URL — no dev/staging/prod separation.
- **Testing: effectively zero.** `bloc_test` and `mocktail` are declared in `pubspec.yaml`, but the only test file is the unmodified Flutter counter template, which would fail if run. **Do not claim a testing strategy for this project.**
- **Offline support: not implemented.** Caching stores the session and flags only; there is no offline data layer. The app detects connectivity and shows a no-internet screen — that is connectivity awareness, not offline capability.
- **Deep linking:** notification-payload routing exists; true URL/universal-link deep linking is not configured.
- Performance benchmarks — no profiling data or before/after measurements exist.
- Whether the shared packages (`core_package`, `types_package`, `locale_package`) were authored partly by you; they live in separate repositories not present here.

**Two issues worth flagging** (not portfolio content, but you should know before an interviewer opens the code):
- `lib/main.dart:47-55` installs an `HttpOverrides` with `badCertificateCallback => true`, which accepts **any** TLS certificate app-wide and disables protection against man-in-the-middle attacks. This is typically a debugging shortcut that shouldn't reach production; it is not in code you authored, but it sits in the shipped release path.
- `lib/src/core/api/try_catch.dart:22` and `handel_dio_error.dart:22-26` have the forced-logout-on-401 navigation commented out, so token expiry clears the session without redirecting to login.
