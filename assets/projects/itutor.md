# i_tutor — Portfolio Case Study

---

## 1. Project Overview

**i_tutor** is a Flutter application for AI-assisted teaching and studying, built for two distinct user roles — **teachers** and **students** — with separate home experiences driven by a `UserRole` enum (`lib/features/auth/domain/entities/user.dart:77-78`).

Users organize their work into **subjects**, upload source **materials** (files or raw text), then converse with an AI tutor grounded in those materials. Beyond chat, the app generates **15 distinct types of learning artifacts** from the same material set — flashcards, mind maps, quizzes, exam simulators, PowerPoint decks, podcast scripts, educational videos, audio files, interactive HTML games, deep-research documents, trainer manuals, forms, surveys, storytelling content, and infographics.

The app ships with **English and Arabic localization** (416 translation keys each, fully in parity), full **RTL support**, and light/dark theming. It is monetized through **subscription packages** with a hosted-checkout payment flow.

**Scale:** ~34,000 lines across `lib/features`, 218 Dart files, 12 feature modules, 31 screens, plus a local `utils_package` design-system package (74 files).

---

## 2. Problem

Teachers and students preparing course content face three compounding problems:

1. **Material is inert.** Uploaded PDFs and notes are static. Turning them into study aids — flashcards, quizzes, practice exams, slide decks — is manual, repetitive work that scales linearly with course size.
2. **Study formats are not interchangeable.** The same chapter needs to become a mind map for one learner, a podcast for a commuter, and a timed practice exam before finals. Producing each format separately multiplies the effort.
3. **AI output is slow and opaque.** Generating a deep-research document or a full video takes tens of seconds. A UI that blocks on a spinner for that long feels broken, and users abandon it.

---

## 3. Solution

i_tutor treats uploaded material as a **single grounded source** that any of 15 generators can consume:

- **Subjects** act as containers. Each subject holds materials and owns a `subject_thread_id` that scopes all AI context.
- **Materials** are uploaded as files or typed text, then explicitly **processed** server-side (`POST /materials/{id}/process`) to become retrievable context.
- **Chat** is grounded per subject thread and streams responses **token-by-token over SSE**, so the first words appear immediately rather than after the full answer completes.
- **Learning-plan generation** reuses the live conversation as context — `currentConversationMessages` is passed to the planner so generated artifacts reflect what was just discussed, not just the raw material.
- **Long-running generation streams too.** Deep research and trainer manuals render incrementally into their chat card via registered stream controllers, so a 60-second generation shows visible progress from second one.

Each generated artifact is rendered by a **purpose-built interactive widget** — the exam simulator tracks attempts and scores; flashcards preserve scroll position across category filters; PowerPoint slides paginate; quizzes and surveys submit answers back to the API.

---

## 4. My Role

> **Needs confirmation.** Git history for this repository attributes all 98 commits to two other identities (`s.kamel@intrazero.net`, 95 commits; `mhosnyessa@gmail.com`, 3 commits). No commits are authored under the email associated with this session, so **I cannot verify your specific contributions from the codebase or Git history.**

Before using this section, confirm which of the following you personally implemented. Each item below is a genuine, verifiable **work stream** in the codebase — described so you can claim only what is yours:

| Work stream | What it involved (verifiable in code) |
|---|---|
| **Chat & streaming engine** | `ChatCubit` (1,270 lines), SSE parsing in both `chat_remote_datasource.dart` and `learning_plans_remote_datasource.dart`, incremental message updates, pagination |
| **Learning-plan artifact system** | 15 `PlanType` variants, per-type metadata builders, and ~10 dedicated renderer widgets (exam simulator, PowerPoint, flashcards, quiz, survey, forms, video, audio, mind map, interactive game) |
| **Subscription & payments** | Package listing, currency switching (USD/EGP), billing capture, `POST /payment/initiate`, WebView checkout with success-URL interception |
| **Auth & security** | Login/register/OTP/reset flows, Cloudflare Turnstile WebView integration, token interception, 401 → forced-logout handling |
| **Architecture & DI foundation** | Clean Architecture layering, `service_locator.dart` (10 feature modules), `tryCatch` error funnel, `RoutesManager` |
| **Design system (`utils_package`)** | 74-file local package: `CustomText`, `CustomContainer`, managers, responsive extensions, theming |
| **Localization & RTL** | 416 keys × 2 languages, `AppLocalizations` delegate, directional layouts |
| **Documentation** | `PROJECT_DESIGN_AND_ARCHITECTURE.md` — a ~700-line architecture guide, notably thorough for an internal project |

**Recommended phrasing once confirmed:** state your role factually (e.g. "Flutter engineer responsible for the chat streaming layer and learning-plan renderers") rather than implying sole ownership of a codebase with multiple contributors.

---

## 5. Key Features

### Authentication & Account
- Email/password login and registration with **Cloudflare Turnstile** bot protection
- Email verification via OTP, forgot/reset password, resend-verification
- Profile management: personal info, email change, phone change, password change
- Social sign-in endpoints defined (Google/Apple/Facebook) — *endpoints exist in `endpoints.dart`; UI wiring needs confirmation*

### Subjects & Materials
- Create, edit, list, and delete subjects
- Upload materials as **files or raw text**; explicit server-side processing step
- Material listing with counts per subject, deletion, and resource browsing
- Speech-to-text input for material entry (`subject_material_bottom_section.dart`)

### AI Chat
- Subject-grounded conversations with **token-by-token SSE streaming**
- Multiple conversations per subject, managed in a drawer: create, rename, delete, switch
- **Reverse pagination** (20 messages/page) with deduplication and scroll-position preservation
- Optional web-search augmentation and voice-chat flags on the query payload

### Learning-Plan Generation (15 types)
- **Study aids:** flashcards (with category filtering), mind maps (graph + card + markdown renderers), interactive HTML games
- **Assessment:** quizzes, surveys, auto-generated forms, and a full **exam simulator** with attempt history, per-question results, and scoring
- **Media:** audio files, educational videos (with progress tracking), podcast scripts, PowerPoint decks (paginated), infographics
- **Long-form:** deep research and trainer manuals, both **streamed live** into the chat card
- Per-type configuration dialogs (duration, day count, hours/day, template selection, difficulty)

### Subscription & Payments
- Current-plan view, plan exploration, full package comparison
- **Dual-currency display (USD/EGP)** with persisted user preference
- Billing-data capture → `POST /payment/initiate` → **WebView checkout** with success-URL interception and redirect

### Cross-cutting
- English/Arabic with full RTL; light/dark/system theming, both persisted
- Pull-to-refresh, shimmer loading states, reusable error/retry screens

---

## 6. Technical Highlights

### SSE streaming implemented twice, deliberately differently

The app parses Server-Sent Events in two places, and the difference is the interesting part.

**Chat streaming** (`chat_remote_datasource.dart:283-375`) uses `LineSplitter` per chunk — adequate because chat tokens are small.

**Plan streaming** (`learning_plans_remote_datasource.dart:242-333`) implements **explicit cross-chunk buffering**:

```dart
buffer += chunk;
final lines = buffer.split('\n');
buffer = lines.removeLast();  // keep incomplete line for next chunk
```

This is the correct handling for large payloads where a JSON object can split across TCP chunk boundaries. It also handles multiple response shapes (`chunk`, `content`, `text`, `delta`), both `[DONE]` and `done` terminators, non-JSON fallback, and flushes the residual buffer on completion — plus graceful `HttpException` recovery when the server closes mid-stream.

Both use a **dedicated Dio instance** rather than the shared `ApiConsumer`, with a comment stating the reason: to avoid interfering with the core client's interceptors. Auth is re-attached manually to compensate.

### Surgical state updates during streaming

Naïve streaming rebuilds the whole message list per token. `_appendToStreamingMessage` replaces exactly one element:

```dart
final updatedList = [...current]..[index] = updated;
```

The class doc makes the invariant explicit: *"In-memory `messagesState` is the source of truth during the session. After streaming completes we do not reload the message list."* This avoids the common bug where a post-stream refetch causes the message to flicker or reorder.

### Concurrency guard on streams

`sendQuestion` returns early if `conversationStatus == streaming`, and `isIdle` is exposed so plan generation can block until chat settles — preventing interleaved token streams writing into the same message buffer.

### Multi-layer in-memory caching

`ChatCubit` maintains **five separate caches** keyed by `planId`: quiz content, interactive-game HTML, exam data, trainer-manual markdown, and video progress. Rationale is documented in-code: *"This avoids repeated `/planner-items/{id}` calls when scrolling chat."* Since plan content is immutable once generated, cache invalidation is a non-issue — a sound trade-off.

### Defensive parsing of variable API shapes

The backend returns inconsistent envelopes, and the client absorbs it. `getPlanById` handles both a bare object and a `plans[]` wrapper. Content extraction unwraps up to three nesting levels with a plain-text fallback:

```dart
try {
  final decoded = jsonDecode(plan.content);
  if (decoded is Map) { /* unwrap nested content */ }
} catch (_) {
  content = plan.content;  // plain HTML/markdown, not JSON
}
```

`PlanType.fromString` normalizes case/whitespace and defaults rather than throwing — the app degrades instead of crashing on an unrecognized type.

### Error handling funneled through one function

Every repository method wraps its datasource call in `tryCatch` (`lib/src/core/api/try_catch.dart`), which converts exceptions to `Either<Failure, T>` and — critically — **centralizes 401 handling**: clear cached auth, null the globals, and `pushNamedAndRemoveUntil` to login. Session expiry is handled in exactly one place instead of in every cubit.

`handelDioError` maps HTTP status codes to typed exceptions and extracts error messages from `detail`, `message`, or `error` fields — `detail` first, correctly reflecting the FastAPI backend.

### Cloudflare Turnstile in a WebView

Bot protection is implemented by hosting the Turnstile JS widget in a `webview_flutter` instance with a `TurnstileDebug` JavaScript channel, polling `localStorage` for the token (60 attempts / 30s), a 4-minute expiry timer, and widget reset on login failure. The token flows UI → Cubit → Repository → `LoginRequestModel.toJson()` as `turnstile_token`.

### Platform-adaptive navigation

`RoutesManager` returns `CupertinoPageRoute` on iOS and a 400ms `FadeTransition` on Android — each platform gets its native-feeling transition from a single routing table.

---

## 7. Challenges

**1. Rendering token-by-token AI output without UI thrash.**
Every SSE delta mutates a message inside a scrollable list. Rebuilding the list per token would drop frames and fight the scroll controller.

**2. Reconciling optimistic local messages with server state.**
Sending a question creates two synthetic messages (`local-user-…`, `local-assistant-…`) before the server knows about them. Plan generation adds a third kind (`local-plan-request-…`). These must merge with server-fetched history without duplicating or reordering.

**3. Paginating a reverse-chronological, actively-mutating list.**
Chat loads newest-first, pages backward while new messages arrive at the front, and must not duplicate or jump the scroll position.

**4. A backend with inconsistent response envelopes.**
The same conceptual field arrives as a bare object, a `plans[]` array, a JSON string, or double-nested `{type, content:{content}}` — varying by plan type.

**5. Two base URLs across one API.**
`baseUrl` (`/v1/public`) and `devBaseUrl` (`/v1`) coexist; chat, exam simulator, and public endpoints are split across them.

**6. Non-fatal WebView exceptions polluting error reporting.**
iOS `WKWebView` emits `PlatformException`s (`PigeonInternalInstanceManager`, `evaluateJavaScript`, `FWFEvaluateJavaScriptError`) during normal lifecycle, surfacing as red-screen errors.

**7. Cloudflare Turnstile script loading inside a mobile WebView.**
Documented in `POSSIBLE_REASONS_SCRIPT_NOT_LOADING.md` and `TURNSTILE_DOMAIN_ERROR_SOLUTION.md` — the script tag was created but `onload` never fired.

**8. Repeated network calls when scrolling a chat full of rich artifacts.**
Each exam/quiz/game card re-fetching `/planner-items/{id}` on rebuild would produce a request storm.

---

## 8. Solutions

**1 → Single-element immutable replacement.** `_appendToStreamingMessage` locates the streaming message by `streamingMessageId` and rebuilds only that index. `ChatState` carries `isStreaming` and `streamingMessageId` so widgets can target rebuilds precisely.

**2 → Prefixed synthetic IDs plus ID-based dedup.** Local messages use recognizable prefixes, enabling targeted cleanup (`removeLocalPlanRequestMessages` filters on `local-plan-request-`). Merges dedupe via a `Set` of existing IDs:

```dart
final currentIds = currentMessages.map((m) => m.id).toSet();
final uniqueNewItems = newItems.where((m) => !currentIds.contains(m.id)).toList();
```

Every merge re-sorts by `createdAt` descending, so ordering is invariant regardless of arrival sequence.

**3 → Derive the page from list length.** Rather than trusting a stored counter that drifts as messages are prepended, the offset is recomputed: `currentPage = (messageCount / pageSize).ceil()`, `offset = currentPage * pageSize`. Page size was **reduced from 100 to 20** (commit `8f8b98e`) explicitly to cut initial load. `hasMoreMessages` latches false on an empty or fully-duplicate page.

**4 → Layered unwrapping with fallbacks at each level.** Every parser tries the structured path, falls back to the next shape, and finally returns raw content — `try/catch` around `jsonDecode` treats a parse failure as "this is plain HTML/markdown," which is the correct interpretation for game and manual content.

**5 → Explicit per-call URL construction.** Datasources prefix `Endpoints.devBaseUrl` or `Endpoints.baseUrl` per call site, with doc comments recording which base each endpoint requires (e.g. *"use devBaseUrl"* on the exam-simulator methods). Pragmatic given a backend mid-migration, though it leaves URL knowledge scattered.

**6 → Targeted global error filters.** `main.dart` installs both `FlutterError.onError` and `PlatformDispatcher.instance.onError`, matching on the specific exception codes and message substrings and suppressing only those — all other errors pass through to `FlutterError.presentError`. The filter is narrow rather than a blanket swallow.

**7 → Instrumentation-first debugging.** A `TurnstileDebug` JS channel pipes browser console output to Dart, a `fetch`-based network test verifies reachability from inside the WebView, `checkWidgetStatus()` and `getTurnstileDebugInfo()` expose state, and iOS `Info.plist` was configured with `NSAppTransportSecurity` exceptions for `challenges.cloudflare.com`. The findings were written up in dedicated markdown docs.

> **Needs confirmation:** `TURNSTILE_INTEGRATION_CHECKLIST.md` still lists the script-loading issue as **CRITICAL / unresolved** and device testing as pending. Confirm the final status before presenting this as solved.

**8 → Per-type in-memory caches.** Five `Map<String, …>` caches in `ChatCubit`, checked before any fetch, with cache hits/misses logged. Safe because generated plan content is immutable.

---

## 9. Architecture Decisions

### Clean Architecture, feature-first
- **Decision:** Each of 12 features owns `data/` (datasources, models, repository impls), `domain/` (entities, abstract repositories), `presentation/` (cubit, screens, widgets).
- **Reason:** Multiple contributors working on distinct features simultaneously; feature-first keeps changes local to one directory.
- **Benefit:** Cubits depend on abstract repositories, so data sources are swappable and mockable. Adding a feature is a mechanical, documented 4-step process.

### Cubit over Bloc
- **Decision:** `flutter_bloc` used exclusively via `Cubit` (through a shared `CustomCubit` base). No event classes anywhere.
- **Reason:** These are CRUD-and-stream flows, not complex event-sourced state machines; events would be ceremony.
- **Benefit:** Roughly half the boilerplate. `ChatCubit`'s streaming methods are direct calls rather than event round-trips.

### `CustomState<T>` instead of sealed state classes
- **Decision:** One generic wrapper (`initial`/`loading`/`success`/`failure`) held as *multiple fields* on a single state object — e.g. `ChatState` holds `conversationsState` and `messagesState` independently.
- **Reason:** Screens often run several concurrent async operations; a single sealed state forces them into one status.
- **Benefit:** A conversation list can be loading while messages are already displayed. Trade-off: `Status` is an enum, so no exhaustive compile-time matching.

### `Either<Failure, T>` at every repository boundary
- **Decision:** No repository method throws; all return `Either`.
- **Reason:** Makes the failure path part of the type signature so it cannot be silently ignored.
- **Benefit:** Uniform `result.fold(onFailure, onSuccess)` in every cubit; exception handling lives only in `tryCatch`.

### GetIt with deliberate lifetime choices
- **Decision:** Datasources/repositories as `lazySingleton`; feature cubits as `factory`; `ThemeCubit`/`LookupsCubit`/`ProfileCubit` as `lazySingleton`.
- **Reason:** Feature cubits must reset per screen; global cubits must persist preferences across the app.
- **Benefit:** No stale state leaking between screen visits. The code is candid where it isn't ideal — `ProfileCubit` is commented *"global, used as a temporary workaround."*

### Named routes with a central `onGenerateRoute`
- **Decision:** `RoutesManager` switch over static `route` constants; arguments cast from `settings.arguments`.
- **Reason:** Keeps every route and its `BlocProvider` wiring in one auditable file.
- **Benefit:** Routes can conditionally branch — `CreateSubjectScreen` inspects the argument type to choose create vs. edit vs. provided-cubit mode. Trade-off: argument casts are unchecked at compile time.

### Local `utils_package` as the design system
- **Decision:** Three shared packages consumed from GitLab (`core_package`, `types_package`, `locale_package`); `utils_package` kept **local, by path**.
- **Reason:** Shared infrastructure is stable and reusable across company apps; UI tokens need per-project iteration.
- **Benefit:** Colors, strings, and widgets can be edited without a package release cycle, while HTTP/error/locale infrastructure stays consistent org-wide.

### Dedicated Dio client for SSE
- **Decision:** Bypass the shared `ApiConsumer` for streaming; construct a separate `Dio` with `ResponseType.stream`.
- **Reason:** Stated in-code — avoid interfering with the core client's interceptors and response transformers, which assume buffered JSON.
- **Benefit:** Streaming and standard requests can't destabilize each other. Cost: auth headers must be re-attached manually in both streaming datasources.

---

## 10. Tech Stack

**Framework & Language**
Flutter (Dart SDK ^3.9.2) · Material Design

**Architecture**
Clean Architecture (feature-first) · Repository pattern · `Either<Failure, T>` functional error handling

**State Management**
`flutter_bloc` ^8.1.6 (Cubit-only) · `equatable` · custom `CustomCubit` / `CustomState<T>` · `AppBlocObserver` for debug lifecycle logging

**Dependency Injection**
`get_it` ^8.2.0 — 10 feature modules registered in `service_locator.dart`

**Networking**
Dio (via `core_package`'s `ApiConsumer`) · **SSE streaming** via dedicated Dio clients · custom `AppInterceptors` (bearer injection, 307-redirect following) · centralized `handelDioError`

**Backend**
REST API at `api.itutor.study` — FastAPI (inferred from `detail` error fields and documented `/subjects` → `/subjects/` 307 behavior)
*Firebase: not integrated.* Messaging code exists but is commented out in `main.dart`; no `google-services.json` or `GoogleService-Info.plist` present.

**Local Storage**
`CacheConsumer` (from `core_package`) — auth tokens, onboarding flag, theme mode, currency preference (`CacheKeys`)

**Authentication**
Bearer-token OAuth-style flow · **Cloudflare Turnstile** bot protection · 401-triggered forced logout

**Payments**
Custom `POST /payment/initiate` → hosted checkout in `webview_flutter` ^4.4.2 · `currency_converter` ^3.0.0 for USD/EGP display

**Localization**
Custom `AppLocalizations` with JSON assets (`lang/en.json`, `lang/ar.json` — 416 keys each) · `locale_package` `LocaleCubit` · `intl` ^0.20.2 · full RTL

**UI & Media**
`flutter_screenutil` ^5.9.3 (440×956 design baseline) · `flutter_svg` · `lottie` ^3.1.2 · `graphview` ^1.2.0 (mind maps) · `audioplayers` ^6.1.0 · `video_player` + `chewie` · `cached_network_image` · `shimmer` · `toastification` · `smooth_page_indicator`

**Device & Files**
`speech_to_text` ^7.0.0 · `file_picker` · `image_picker` · `flutter_image_compress` · `open_filex` ^4.7.0 · `url_launcher` ^6.3.2 · `path_provider` · `connectivity_plus` + `internet_connection_checker`

**Internal Packages**
`core_package` (GitLab) — HTTP/cache/auth · `types_package` (GitLab) — Either/Failure/exceptions · `locale_package` (GitLab) — LocaleCubit · `utils_package` (local, 74 files) — design system

**Tooling**
`flutter_lints` ^5.0.0 · `device_preview` ^1.3.1 · `AppBlocObserver`

**Testing**
⚠️ **One placeholder smoke test only** (`test/widget_test.dart`) — renders a bare `SizedBox`. No unit, widget, or integration coverage.

**CI/CD**
⚠️ **None present.** No GitLab CI, GitHub Actions, Fastlane, or Codemagic configuration. No build flavors.

---

## 11. Screens

### Onboarding & Entry
- **Splash** — reads cache to route to onboarding, login, or home
- **Onboarding** — paged intro with CMS-sourced content; completion persisted

### Authentication
- **Login** — credentials + embedded Turnstile widget
- **Register** — registration with optional billing information
- **Verify Email** — OTP entry with resend
- **Forgot Password / OTP / Reset Password** — three-step recovery

### Home
- **Home** — role dispatcher; also surfaces post-payment success
- **Teacher Home** — subject/class management entry points
- **Student Home** — study-oriented entry points

### Subjects & Materials
- **Subjects List** — grid/list with shimmer loading, pull-to-refresh, error/retry
- **Create/Edit Subject** — form with paginated reasoning-template dropdown; one screen serves both modes
- **Subject Material** — materials for a subject; upload via file or text, with speech-to-text
- **Resources** — browse and open uploaded materials

### Classes
- **Classes List** / **Create Class** — class CRUD

### Chat & Generation
- **Subjects Chats** — pick a subject to start a conversation
- **Subject Chat** — the core screen (1,036 lines): streaming messages, chat-history drawer, plan-tools row, reverse pagination, and inline rendering of all 15 artifact types
- **Generate Plan** — plan configuration entry point
- **Exam Simulator Full Screen** — dedicated timed exam-taking view with attempt tracking

### Subscription
- **My Plan** — current subscription and entitlements
- **Explore Plans** / **All Plans** — package comparison with USD/EGP toggle
- **Payment Summary** — pre-checkout confirmation
- **Complete Billing for Payment** — billing-data capture
- **Payment WebView** — hosted checkout with success interception

### Profile
- **Profile** — account hub
- **Update Personal Info / Update Email / Update Phone / Change Password**

---

## 12. Lessons Learned

**Streaming UIs demand state discipline.** The naïve approach — refetch after the stream completes — causes flicker and reordering. The codebase converged on a documented invariant: in-memory state is authoritative during a session, and only the single streaming message mutates. Writing that invariant as a class-level doc comment is what keeps it from eroding.

**Buffer across chunk boundaries, always.** The chat parser splits lines per chunk; the plan parser buffers across them. The second is correct in general — the first works only because chat tokens happen to be small. Network chunk boundaries respect no protocol framing.

**Defensive parsing is a feature when the backend is in flux.** Every parser in this codebase tries the structured path and falls back to raw content. The result is an app that renders *something* rather than crashing on an unexpected envelope — the right trade-off while a backend stabilizes.

**Centralize the auth failure path.** Handling 401 inside `tryCatch` means session expiry is correct in all ~40 repository methods by construction. Distributing it would guarantee inconsistency.

**Suppress errors narrowly or not at all.** The WebView filters match specific codes and message substrings, then re-raise everything else. A blanket `try/catch` would have hidden real bugs.

**Immutable data makes caching trivial.** Five caches with no invalidation logic are safe *only* because generated plan content never changes. Recognizing that property up front removed an entire class of bugs.

**Document architecture while building it.** `PROJECT_DESIGN_AND_ARCHITECTURE.md` (~700 lines) covers layering, DI registration rules, widget conventions, and a new-feature checklist. On a multi-contributor project this is what makes conventions actually hold.

**Untested code is a liability that compounds.** With ~34,000 lines of feature code and one placeholder test, every refactor is manual-verification work. The architecture is *built* for testability — abstract repositories, injected dependencies, `Either` returns — but that investment goes unrealized without tests. This is the clearest improvement the project would benefit from.

---

## Needs Confirmation

The following cannot be verified from the codebase and must not be presented as fact:

### Your contribution (highest priority)
- Which features, layers, or files you personally authored. Git history shows **no commits under your email** — 95 by `s.kamel@intrazero.net`, 3 by `mhosnyessa@gmail.com`. Confirm your role before publishing Section 4.
- Whether you contributed to the shared GitLab packages (`core_package`, `types_package`, `locale_package`), which are external to this repo and unreadable here.
- Whether you authored `PROJECT_DESIGN_AND_ARCHITECTURE.md`.

### Project context
- Business goals, target market, and commercial outcome
- Team size and composition; your reporting structure
- Project timeline and duration
- Whether the app was released (no CI/CD, flavors, signing config, or store metadata present)

### Product & metrics
- User numbers, retention, subscription conversion
- App Store / Play Store presence, ratings, download counts
- Any measured performance improvements (the page-size reduction from 100→20 is visible in commit `8f8b98e`, but no before/after benchmarks exist)

### Technical status
- **Turnstile script loading** — `TURNSTILE_INTEGRATION_CHECKLIST.md` still marks this **CRITICAL/unresolved**; device testing listed as pending
- Whether social sign-in (Google/Apple/Facebook) is wired to UI — endpoints are defined but no implementation was found
- Whether Firebase was intentionally dropped or is planned (code is commented out; config files absent)
- Payment provider identity — the integration is generic (`/payment/initiate` → `checkout_url`); the processor is not named in the client
- Whether `MyHttpOverrides` (which accepts **all** bad TLS certificates in `lib/main.dart`) is dev-only or shipped to production. **If shipped, this is a genuine security vulnerability and should be removed before release — do not highlight this code in a portfolio.**
- Whether the `loginCredentials` cache key (commented *"Testing only"*) is disabled in production builds

---

*Generated from static analysis of the i_tutor codebase (branch: `develop`, 218 Dart files, 98 commits). Every technical claim above is traceable to a specific file or commit; unverifiable items are marked "Needs confirmation."*
