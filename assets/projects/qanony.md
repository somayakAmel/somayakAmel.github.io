# Qanony — Portfolio Case Study

> **Authorship note (read first):** Git records four committers — `s.kamel` (66 commits, ~59k lines added), `Mahmoud Ghonemi` (9 commits, ~33k added, initial UI + architecture migration), `mhosny` (2 commits), `somaya kamel` (2 merges). The local git identity is `Meroothman <01119923095a@gmail.com>`, which matches **none** of them. I therefore could not verify which work is yours, and **Section 4 (My Role) is left as a template for you to fill in.** Everything else below is verified against the code.

---

## 1. Project Overview

Qanony is a bilingual (Arabic/English) Flutter client for a legal-services marketplace operated by Intrazero, targeting the Egyptian market (pricing in EGP, 15% VAT). It lets individuals and businesses browse legal services — contract drafting, contract review, company formation, trademark registration, wills and inheritance, legal consultations — submit a structured request with supporting documents, pay, then track the request through to delivery of the finished legal document.

The codebase is ~52,700 lines across 287 Dart files in 15 feature modules, at version `1.0.0+5`, backed by a REST API at `qanony.intrazero.org/v1`.

## 2. Problem

Engaging a lawyer for routine legal work is opaque: clients don't know what a service costs, what documents are required, how long it will take, or where their matter stands after handing it over. Each service also demands a different set of facts — a sale contract needs buyer/seller/item/price details, an NDA needs parties and a term, an employment contract needs a contract type — so a single generic intake form either omits critical information or overwhelms the user with irrelevant fields.

## 3. Solution

The app converts legal engagement into a tracked transaction. Services are published with description, deliverables, delivery estimate and price; intake is driven by a per-subtype form specification so users answer only the questions their chosen service requires; payment (subtotal + 15% VAT) is taken up front; and the request then moves through an explicit lifecycle — New → In Progress → Under Review → Completed, with `Needs Editing` and `Failed` branches — surfaced as a status timeline, backed by push notifications, and ending in downloadable deliverables. A `Needs Editing` state gives the assigned lawyer a structured channel to request corrections without leaving the app.

## 4. My Role

**Needs confirmation.** The repository cannot attribute this. Fill from the verified work areas below, which map to distinct commit clusters:

| Work area | Evidence in history |
|---|---|
| Clean Architecture migration + dark mode + localization | Feb 2026, `Ghonemi` |
| Mock API layer (Dio interceptor) for offline development | Feb 2026, `Ghonemi` |
| Full feature build-out: services, requests, payment, documents, CMS, FAQ, config | Mar–Jun 2026, `s.kamel` |
| Firebase: phone auth, Google Sign-In, FCM + APNs, local notifications | Mar–Apr 2026, `s.kamel` |
| Biometric (Face ID / Touch ID) authentication | Jun 3 2026, `s.kamel` |
| Error sanitization for release builds | Jun 30 2026, `s.kamel` |
| RTL bidi/directional-icon correctness pass | Jun 30 2026, `s.kamel` |
| Tablet responsive foundation + tablet-native layouts | Jun 30–Jul 5 2026, `s.kamel` |
| iOS Podfile platform fix | Aug 2 2026, `mhosny` |

## 5. Key Features

**Authentication** — Email/password registration and login; phone login via Firebase SMS OTP (including reCAPTCHA deep-link callback handling at `/link`); Google Sign-In; email OTP password recovery with reset; biometric (Face ID / Touch ID / Face Unlock) re-login.

**Service discovery** — Categorized catalogue with search, subtype selection, and detail pages showing scope, deliverables, delivery time and price.

**Request intake** — A multi-step wizard (personal info → details → service-specific questions → document upload → review → payment) with per-subtype dynamic fields, attachment picking from device or from previously uploaded documents, and locally persisted drafts.

**Consultation booking** — A separate reservation wizard with calendar date selection and selectable time slots.

**Payment** — Method selection, transparent subtotal/VAT/total breakdown, cancellation-policy acknowledgement gate, success confirmation with reference number, and payment history.

**Request tracking** — List with search and status filters, detail view with status timeline and assigned-lawyer info, cancellation, `Needs Editing` response flow with re-upload, deliverables download, and an appointments/calendar view.

**Documents** — A personal document library separating user-uploaded files from issued deliverables, with attach-to-request reuse.

**Notifications** — FCM push with foreground display, deduplication by `notification_id`, deep navigation into the relevant request from foreground, background, and terminated states; plus an in-app notifications inbox.

**Content & settings** — Remote-driven FAQ (categories, search, accordion), About/company credentials, Terms, Privacy, Help Center; language switching (AR/EN), dark mode, notification preferences.

## 6. Technical Highlights

**Clean Architecture, consistently applied.** Twelve features (`auth`, `services`, `requests`, `notifications`, `profile`, `payment`, `documents`, `cms`, `faq`, `config`, `about`) each carry `data/{datasources,models,repositories}`, `domain/{entities,repositories}`, and `presentation/{cubit,screens,widgets}`. Repository interfaces live in `domain` and return `Either<Failure, T>` from `types_package`, so failures are values rather than exceptions crossing layer boundaries.

**Two-tier secret handling.** `lib/core/services/secure_storage_service.dart` is the single owner of all auth secrets — access token, refresh token, biometric flag, cached credentials — stored exclusively in iOS Keychain / Android Keystore. The Dio interceptor at `lib/src/core/api/app_interceptor.dart:38-41` deliberately reads the bearer token straight from secure storage rather than the plaintext cache, with an explicit comment saying so.

**Biometric login that doesn't trust the device alone.** `lib/features/auth/data/repositories/auth_repository_impl.dart:261-310` implements what the code calls "CIB-style" biometric login: a successful Face ID prompt does not itself grant a session — it unlocks securely cached credentials which are then replayed against the real login API. The method gates on network first, nulls the plaintext password immediately after the request, and distinguishes the two failure modes precisely: `UnauthorizedException` wipes credentials and forces manual login, while a server/network error *keeps* them so the user can retry.

**Release-build error sanitization.** `lib/src/core/api/handle_dio_error.dart` runs backend error text through regex heuristics detecting SQL, stack traces, ORM punctuation, file:line markers, and constraint violations. In debug the raw message passes through untouched; in release anything flagged technical — or longer than 120 characters — is replaced by a status-code-appropriate friendly message, while the raw text is preserved in the developer log.

**Declarative dynamic forms.** `lib/features/standard_request/presentation/request_form_spec.dart` (1,468 lines) declares backend-compatible subtype constants, a `PayloadFieldKind` enum (text/number/boolean/dropdown/date/dateTime/time), and `PayloadFieldVisibility` for conditional fields that appear based on another field's value. Adding a legal-service variant is a spec change, not new UI code.

**Orientation policy by physical device class.** `lib/main.dart:38-58` computes shortest side in dp from `platformDispatcher.views.first` *before* `runApp`, locking phones to portrait while allowing tablets to rotate. `lib/config/responsive.dart` keys every breakpoint off shortest side so rotation never reclassifies a device — a phone in landscape is still a phone.

**FCM lifecycle sequencing.** FCM initialization is deliberately deferred to `addPostFrameCallback` because `flutter_local_notifications` needs the UI isolate running before its method channel registers (`lib/main.dart:74-77`). The debug APNs token logger polls with backoff because iOS delivers the APNs token asynchronously with no callback or stream.

**Full RTL correctness.** 921 Arabic and 925 English ARB keys, `Accept-Language` injected per request by the interceptor, `initializeDateFormatting()` for locale-aware month/weekday names, and a dedicated `QDirectional` widget layer for icon mirroring — covered by a widget test asserting arrows mirror under RTL and *don't* under LTR.

## 7. Challenges

1. **Heterogeneous intake across a dozen legal service subtypes** — each needs a different, sometimes conditional, field set.
2. **Firebase phone auth's reCAPTCHA flow destroys the calling screen.** When the deep-link callback returns, `PhoneLoginScreen` no longer exists, and OTP-sent success may be emitted before the callback handler mounts.
3. **Backend error messages leak internal detail** — a real risk in TestFlight/production builds.
4. **Long multi-step forms lose user work** if the app is backgrounded or killed mid-flow.
5. **Biometric auth is a device-side check, not an authorization** — treating a Face ID success as a session is a security error.
6. **Two parallel networking stacks exist** (`Api` singleton in `lib/services/api.dart` and `ApiConsumer`/`DioConsumer` from `core_package`), with duplicated endpoint constants across `Api` and `lib/src/core/api/endpoints.dart` — technical debt from the architecture migration.
7. **Tablet support added to a phone-first codebase** without regressing phone layouts.

## 8. Solutions

1. **A form-spec layer.** Field kinds, dropdown option sets, and `PayloadFieldVisibility` dependencies are declared as data; the wizard renders from the spec via shared builders in `lib/src/widgets/form_builders/`.
2. **A dedicated `/link` route with dual-path recovery.** `_LinkCallbackHandler` in `lib/config/router.dart:466-510` runs *both* a post-frame check of current `AuthCubit` state (for the case where success already fired) and a `BlocListener` (for the normal post-mount path), closing the race in both directions.
3. **Pattern-based sanitization with a debug escape hatch** (see Technical Highlights). Recognizable safe cases like duplicate-account get specific friendly copy in every build.
4. **`RequestDraftLocalDataSource`** persists in-progress form state to `SharedPreferences` via `CacheConsumer`. Every operation is wrapped in try/catch with reads returning `null`/`false` — the code's stated rule is that a storage failure must never break the form.
5. **Credential replay over a real login call**, with the failure-mode split described above.
6. **Partially addressed.** The repository/datasource layer uses `ApiConsumer`; the legacy `Api` singleton is retained for token storage and `isAuthenticated()` checks in the router. The dead `refresh_token_handler.dart` is fully commented out. **This convergence is incomplete** — a fair thing to name in an interview rather than hide.
7. **A `QResponsive` extension over `BuildContext`** exposing `isTablet`, `isTabletLandscape`, `responsive<T>()`, and gap/gutter scalers, so widgets never scatter raw width checks. Two dedicated widget tests (`test/tablet_auth_layout_test.dart`, `test/tablet_content_layout_test.dart`) guard the layouts.

## 9. Architecture Decisions

| Decision | Reason | Benefit |
|---|---|---|
| **Clean Architecture per feature** | 15 features with distinct backends; a shared-layer structure would couple them | Features are independently readable and testable; `domain` has no Flutter dependency |
| **Cubit over Bloc** | Screens are request/response-shaped; event classes add ceremony without payoff | Less boilerplate; `AppBlocObserver` still gives centralized transition logging |
| **`Either<Failure, T>` at repository boundaries** | Network failure is expected, not exceptional | Presentation handles failure explicitly; no exceptions cross layers |
| **`get_it` service locator, mostly lazy singletons** | Cubits must be shared across routes (e.g. `RequestsCubit` spans wizard → payment → tracking) | Shared state without global widget-tree providers; `FaqCubit` is a `registerFactory` where fresh per-screen state is wanted |
| **`go_router` with a global async `redirect` auth guard** | Auth state must gate every route, including cold-start deep links | One `publicRoutes` allowlist protects all routes; a try/catch fail-open prevents redirect errors from bricking navigation |
| **`ShellRoute` for bottom-nav tabs** | Tabs must share a persistent scaffold | Tab state survives navigation; custom directional slide transitions follow swipe direction |
| **Secure storage as the sole token source** | Tokens in SharedPreferences are readable on rooted/jailbroken devices | Keychain/Keystore-backed; the interceptor never touches plaintext cache |
| **Server-driven CMS/config/FAQ** | Legal copy, support contacts and FAQs change without engineering | Content updates ship without an app release |
| **Mock interceptor layer** | Enables UI work before backend readiness | `lib/services/mock/` with 7 handlers; disabled in production, re-enablable by one call |
| **Git-hosted shared internal packages** | `core_package`, `locale_package`, `types_package` reused across Intrazero apps | Consistent networking/error/locale primitives across the org's portfolio |

## 10. Tech Stack

**Framework** — Flutter (Dart SDK ≥ 3.9.0), Material Design

**State Management** — `flutter_bloc` 8.1.6 (Cubit), `equatable`; `provider` 6.1.2 retained transitionally

**Architecture** — Clean Architecture, Repository pattern, `get_it` 7.6.7 service locator, `Either`-based functional error handling

**Networking** — `dio` 5.4.0, custom request/error interceptors, `internet_connection_checker`

**Navigation** — `go_router` 14.2.0 with `ShellRoute` and async auth redirect

**Backend** — REST API (`qanony.intrazero.org/v1`); Firebase Core, Firebase Auth (phone), Firebase Messaging

**Local Storage** — `flutter_secure_storage` 9.2.2 (Keychain/Keystore), `shared_preferences` (drafts, theme, locale)

**Authentication** — Email/password, Firebase phone OTP, `google_sign_in` 7.2.0, `local_auth` 2.3.0 biometrics

**Payments** — Custom create/verify endpoints; `webview_flutter` present for Paymob iframe *(declared in pubspec; end-to-end Paymob flow — **needs confirmation**)*

**Files & Media** — `file_picker`, `image_picker`, `open_filex`, `path_provider`, `cached_network_image`

**UI** — `flutter_screenutil`, `flutter_svg`, `shimmer`, `pin_code_fields`, `flutter_staggered_grid_view`; Graphik + Inter variable fonts

**i18n** — `flutter_localizations`, `intl` 0.20.2, ARB-based codegen, full RTL

**Testing** — `flutter_test` widget tests, `integration_test` + `flutter_drive` screenshot automation

**Internal Packages** — `core_package`, `locale_package`, `types_package` (GitLab), `utils_package` (local path)

**Tooling** — `flutter_lints` 5.0.0, `flutter_launcher_icons`, Gradle Kotlin DSL with keystore-property release signing

## 11. Screens

**Entry** — `Splash` (auth check + connectivity probe), `Onboarding` (2-page intro).

**Auth** — `Welcome`, `Login` (supports `?biometric=1` to auto-trigger the native prompt), `Signup`, `PhoneLogin`, `PhoneOtp`, `ForgotPassword`, `Otp`, `ResetPassword`.

**Main tabs** — `Home` (greeting, featured categories, latest request, upcoming appointments, "how it works", unread badge), `Documents`, `MyRequests`, `Profile`.

**Services** — `ServicesList` (search + categories), `ChooseServiceSubtype`, `ServiceDetail`.

**Request flows** — `StandardRequestWizard` (3,018 lines — the full multi-step intake), `ReservationWizard` (date/slot booking).

**Payment** — `Payment` (method, VAT breakdown, policy gate), `PaymentSuccess`, `PaymentHistory`.

**Tracking** — `RequestDetail` (1,529 lines — status timeline, lawyer info, attachments), `Deliverables`, `NeedsEdit`, `Calendar`, `AllAppointments`.

**Account & content** — `EditProfile`, `Settings` (language/theme/notifications), `Notifications`, `HelpCenter`, `About`, `CompanyCredentials`, `Terms`, `Privacy`.

## 12. Lessons Learned

**Layer boundaries are worth their cost at this scale.** Twelve features with identical internal shape means any one is navigable without re-learning conventions — the payoff arrives around feature five, not feature one.

**Security posture is about failure paths, not the happy path.** The biometric implementation is interesting precisely because of what it does on `UnauthorizedException` versus `ServerException` — one wipes, one preserves. Getting that split wrong produces either a lockout bug or a security hole.

**Debug and release need different truth.** Sanitizing errors globally would have blinded developers; leaving raw messages would have leaked internals to users. The build-mode split resolves the conflict rather than compromising on it.

**Platform SDK ordering constraints must be encoded, not remembered.** FCM after first frame, `GoogleSignIn.initialize()` before any sign-in, orientation from `platformDispatcher` before `runApp` — each is a hard sequencing rule, and each carries a comment explaining why.

**Retrofitting responsiveness works when device class is a first-class concept.** Deriving everything from shortest side — so orientation can never reclassify a device — let tablet layouts land without touching phone behavior.

**Architecture migrations leave residue.** Two networking stacks and duplicated endpoint constants still coexist. Recognizing that honestly is more useful than claiming the migration finished.

**Automated screenshots pay for themselves.** Driving store screenshots through `integration_test` with a `FLUTTER_TEST` auth bypass keeps them reproducible across both languages and both platforms — no manual capture, no browser tooling.

---

## Needs Confirmation

- **Your specific role and contributions** — no commits match the local git identity. **Highest priority to resolve.**
- **Team size and composition** — history shows four committers; whether that reflects the full team is unknown.
- **Business goals and success metrics** — no analytics or KPI instrumentation in the codebase.
- **Release status and store presence** — version is `1.0.0+5`; no Play Store/App Store listing, release notes, or Fastlane config in the repo.
- **User numbers, ratings, download counts** — not derivable.
- **Performance measurements** — no benchmarks or profiling artifacts. Shimmer loaders and `cached_network_image` are present, but no before/after data exists.
- **CI/CD pipeline** — **no `.github/workflows`, `.gitlab-ci.yml`, `codemagic.yaml`, or Fastlane found.** Releases appear to be manual. Do not claim CI/CD without evidence.
- **Build flavors** — none configured; a single `com.qanony.qanony` applicationId with debug/release build types only.
- **Paymob payment integration status** — `webview_flutter` is a declared dependency and the docs reference a Paymob iframe, but the payment screen calls generic `/payments/create` and `/payments/verify` endpoints. Whether the Paymob iframe is live needs confirmation.
- **Project timeline as *your* engagement** — repo activity spans Feb 10 – Aug 2, 2026, but your start/end dates are unknown.
- **Test coverage** — 498 test lines against ~52,700 source lines, with `test/widget_test.dart` being a placeholder asserting `1 + 1 == 2`. The three real tests cover RTL icons and tablet layouts only. **Do not describe this project as well-tested.**
- **Offline support scope** — `NetworkInfo` is used only in splash, login, welcome, and biometric login. Request drafts persist locally, but there is no offline read cache or write queue. Describe as *connectivity-aware*, not *offline-first*.
