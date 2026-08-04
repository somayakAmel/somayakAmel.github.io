# Portfolio — Project Specification

> **Status:** Awaiting approval. No implementation code exists yet.
>
> **Engineering reference:** `ARCHITECTURE_GUIDE.md` (the `gharemeen` standard). This document adapts that standard to a local-data portfolio application. Where this spec deviates from the guide, Section 19 states why.
>
> **Audience for this document:** the developer implementing the app (human or AI). Every section is written to be actionable without further clarification.

---

## Table of Contents

1. [Project Vision](#1-project-vision)
2. [Target Audience](#2-target-audience)
3. [User Journeys](#3-user-journeys)
4. [Information Architecture](#4-information-architecture)
5. [Navigation Map](#5-navigation-map)
6. [Screen List](#6-screen-list)
7. [Section Breakdown](#7-section-breakdown)
8. [Data Models](#8-data-models)
9. [JSON Schema Proposals](#9-json-schema-proposals)
10. [Reusable UI Components](#10-reusable-ui-components)
11. [Asset Organization](#11-asset-organization)
12. [Responsive Behavior](#12-responsive-behavior)
13. [Animation Guidelines](#13-animation-guidelines)
14. [Accessibility Guidelines](#14-accessibility-guidelines)
15. [Design Principles](#15-design-principles)
16. [Folder Ownership](#16-folder-ownership)
17. [Feature Priorities](#17-feature-priorities)
18. [Risks & Implementation Considerations](#18-risks--implementation-considerations)
19. [Consistency Review Against ARCHITECTURE_GUIDE.md](#19-consistency-review-against-architecture_guidemd)

---

## 1. Project Vision

**A portfolio that is itself the strongest project in the portfolio.**

Most developer portfolios are a styled résumé. This one is a working demonstration of the engineering standard described in `ARCHITECTURE_GUIDE.md` — Clean Architecture, feature-first organization, dependency injection, a real design system, full localization, and responsive layout — applied to a problem small enough that the architecture stays visible rather than buried.

### What success looks like

| Goal | Measured by |
|---|---|
| A recruiter understands the candidate within 30 seconds | Hero + first project card visible without scrolling on a 1440×900 laptop |
| A senior engineer reviewing the repo sees deliberate architecture | Every feature has the same predictable `data/domain/presentation` shape; no logic in widgets |
| The app feels premium, not templated | Consistent type scale, restrained motion, no layout shift, no jank at 60fps |
| Content changes require no Dart edits | Adding a project = adding one JSON file + one asset folder |
| It runs everywhere | One codebase, three platforms, no platform-specific screens |

### Explicit non-goals for v1

- No CMS, admin panel, or content editing in-app.
- No backend, analytics, or telemetry.
- No blog.
- No light theme (architecture supports it; v1 ships dark only).
- No SEO/SSR strategy beyond what Flutter Web provides out of the box (see [Section 18](#18-risks--implementation-considerations), R-1).

### Design tension to hold

The brief asks for "production-quality architecture" *and* "lightweight, appropriate for a portfolio." These pull against each other. The resolution used throughout this spec: **keep every architectural boundary, remove every piece of infrastructure that exists only to serve a network or database.** Repositories, use cases, and DI stay — because they are the boundaries. Interceptors, retry policies, and cache layers go — because they are infrastructure for a problem this app doesn't have.

---

## 2. Target Audience

Four readers, in priority order. Every design decision below is traceable to one of them.

### A1 — Technical recruiter / hiring manager *(primary)*

- **Context:** desktop browser, 20–90 seconds, scanning many candidates.
- **Wants:** years of experience, company names, tech stack, "can they ship?"
- **Implication:** Hero states role + years immediately. Projects appear before Skills. Resume is reachable from three places without scrolling.

### A2 — Senior engineer / tech lead reviewing code *(primary)*

- **Context:** arrives from the GitHub repo link, or opens the repo alongside the live site.
- **Wants:** Is the architecture real or cargo-culted? Are boundaries respected?
- **Implication:** The repo is part of the deliverable. `README.md` links to `ARCHITECTURE_GUIDE.md` and this spec. Code must survive a `git clone` and a skeptical read.

### A3 — Potential client / freelance lead *(secondary)*

- **Context:** mobile browser, often from a LinkedIn or WhatsApp link.
- **Wants:** proof of similar work, then a way to make contact.
- **Implication:** Mobile layout is not an afterthought. Contact actions are one tap. Project cards communicate domain, not just tech.

### A4 — Peer developer / student *(tertiary)*

- **Context:** browsing for reference or inspiration.
- **Wants:** how it's built.
- **Implication:** Costs nothing extra — served by the same repo transparency A2 needs.

### Language audience

Arabic and English are both first-class ([Section 9](#9-json-schema-proposals) makes every user-facing content string bilingual in the JSON). Default locale follows the device; Arabic renders full RTL.

---

## 3. User Journeys

### J1 — The 30-second recruiter scan *(A1, most common desktop path)*

```
Land on /home (from LinkedIn or CV link)
  → Hero: name, role, years, primary stack, [View Work] [Resume]
  → scroll → About: 2–3 sentences + highlight stats
  → scroll → Featured Projects: 3 cards, each showing domain + stack
  → hover a card: subtle lift, "View details" affordance appears
  → EITHER  tap [Resume]  → PDF opens in a new tab  → journey ends satisfied
  → OR     tap a card    → /project_details        → continues into J2
```

**Failure mode to design against:** the recruiter scrolls past Projects because the cards look like generic placeholders. Mitigation — every card shows a real cover image, the domain ("Fleet management", "Legal services"), and 3 stack chips.

### J2 — The deep evaluation *(A1 + A2)*

```
/home → Featured Projects → tap card → /project_details
  → cover image + title + role + duration
  → problem → responsibilities → challenges → solutions
  → screenshot gallery (tap → full-screen zoom, swipe between shots)
  → tech stack chips
  → [GitHub] and/or [Live Demo]
  → back → /home, restored to the exact scroll offset  ← non-negotiable, see R-4
  → OR [View all projects] → /projects → filter by type → another detail page
```

### J3 — The mobile referral *(A3)*

```
Open link on phone
  → Hero (single column, condensed)
  → swipe through Featured Projects (horizontal carousel on mobile)
  → jump via bottom-anchored [Contact] CTA
  → Contact: tap email → mail app opens with address prefilled
             tap WhatsApp/LinkedIn → external app opens
```

### J4 — The architecture reviewer *(A2)*

```
Arrives at the GitHub repo (linked in Footer + Contact + Project Details)
  → README → ARCHITECTURE_GUIDE.md + PROJECT_SPEC.md
  → clones, runs `flutter run -d chrome` with zero setup steps
  → reads lib/features/projects/ as the reference slice
```

**Implication:** the app must run from a fresh clone with no environment variables, no secrets, no `--dart-define`. Local JSON makes this true by construction.

### J5 — The Arabic-speaking visitor

```
Device locale is ar → app opens in Arabic, RTL, Arabic font
  → all content (titles, descriptions, responsibilities) renders in Arabic
  → toggles to English from the app bar → layout mirrors, fonts swap, no reload
```

### J6 — The returning visitor

```
Reopens → language preference restored from the previous session
  → lands on /home (no splash re-run beyond the asset preload)
```

---

## 4. Information Architecture

### Content domains

Content splits into six domains, each owned by exactly one feature slice, each backed by its own JSON:

| Domain | Source | Cardinality | Volatility |
|---|---|---|---|
| Identity & narrative | `about.json` | 1 object | Low — edited a few times a year |
| Capability | `skills.json` | ~25–40 items, grouped | Medium |
| Work history | `experience.json` | 3–8 items | Low |
| Portfolio pieces | `projects/index.json` + `projects/<slug>.json` | 5–15 files | High — the file you touch most |
| Credentials | `certificates.json` | 5–20 items | Medium |
| Reachability | `social_links.json` | 4–8 items | Very low |

### The projects index pattern

You asked for one JSON file per project. That is the right call for editing ergonomics, but it creates a discovery problem: Flutter cannot list an asset directory at runtime. Two options exist, and the choice matters:

| Option | How | Verdict |
|---|---|---|
| Read `AssetManifest.json` | Flutter's built-in manifest lists every bundled asset; filter for `assets/data/projects/*.json` | **Rejected** — manifest format is an implementation detail that has changed between Flutter versions, and it forces loading every project file just to build the list screen |
| **Explicit index file** | `projects/index.json` holds an ordered array of lightweight summaries; each entry names its detail file | **Chosen** |

**Why the index wins on architecture, not just safety:** it gives the list screen a genuinely different, smaller model than the detail screen. `ProjectSummary` (card data: title, tagline, cover, 3 chips) versus `ProjectDetail` (everything). That is a real domain distinction — the list never loads challenge/solution prose it won't render — and it mirrors the list/detail split any real API would have. It also makes ordering explicit and editorial rather than alphabetical-by-filename.

**Cost:** adding a project means editing two files (`index.json` + the new detail file). Accepted, and documented in the README.

### Content hierarchy on Home

```
Home
├── Hero               ← identity            (about.json)
├── About              ← narrative + stats   (about.json)
├── Featured Projects  ← proof               (projects/index.json, isFeatured)
├── Skills             ← capability          (skills.json)
├── Tech Stack         ← capability, visual  (skills.json, different grouping)
├── Experience         ← track record        (experience.json)
├── Certifications     ← credentials         (certificates.json)
├── Contact            ← the ask             (social_links.json)
└── Footer             ← links + resume      (social_links.json)
```

**Note on Skills vs. Tech Stack.** In my earlier structural review I recommended merging these. Your specification lists both, so this spec keeps both — but they must not be two renderings of the same list, or the page reads as padding. The distinction that makes both earn their place:

- **Skills** — *competencies*, grouped by category, with a proficiency signal. "State Management", "Clean Architecture", "CI/CD". Answers *what can this person do*.
- **Tech Stack** — *named technologies*, rendered as a dense logo/chip grid, no proficiency. Flutter, Dart, Firebase, Git, Figma. Answers *what tools do they use*.

Both read `skills.json`; the `kind` field (`"competency"` vs `"technology"`) partitions them. One file, one repository, one cubit, two section widgets with different groupings. If in implementation the two sections still feel redundant on screen, collapse Tech Stack into a footer strip of Skills — that decision can be made from the rendered page.

---

## 5. Navigation Map

**Mechanism:** imperative named routing via `onGenerateRoute` (guide §9.1). No `go_router`, no nested navigators — with one addition for Web, see below.

```
                        ┌───────────────┐
                        │   /splash     │  preload JSON + locale, min 1 frame
                        └───────┬───────┘
                                │ pushNamedAndRemoveUntil
                                ▼
        ┌───────────────────────────────────────────────┐
        │                  /home                        │
        │  ┌─────────────────────────────────────────┐  │
        │  │ Hero                                    │  │
        │  │ About                                   │  │
        │  │ Featured Projects ──[View all]──────────┼──┼──▶ /projects
        │  │ Skills                                  │  │        │
        │  │ Tech Stack                              │  │    [tap card]
        │  │ Experience                              │  │        │
        │  │ Certifications ──[View all]─────────────┼──┼──▶ /certificates
        │  │ Contact                                 │  │        │
        │  │ Footer                                  │  │        ▼
        │  └────────────────┬────────────────────────┘  │  /project_details
        │        [tap project card]────────────────────────────▶ │
        └───────────────────┬───────────────────────────┘        │
                            │                                    │
                   app bar [lang toggle]              [gallery tap]
                            │                                    ▼
                            ▼                            /image_viewer
                       (no route —                    (fullscreenDialog)
                     LocaleCubit only)
```

### Route table

| Route constant | Path | Arguments | Notes |
|---|---|---|---|
| `SplashScreen.route` | `/splash` | — | `initialRoute`. Not re-enterable. |
| `HomeScreen.route` | `/home` | — | Scroll position preserved across push/pop (R-4). |
| `ProjectsScreen.route` | `/projects` | `ProjectsArguments?` | Optional initial `type` filter. |
| `ProjectDetailsScreen.route` | `/project_details` | `ProjectDetailsArguments` **(required)** | Carries `slug` + the already-loaded `ProjectSummary` for an instant header render. |
| `CertificatesScreen.route` | `/certificates` | — | |
| `ImageViewerScreen.route` | `/image_viewer` | `ImageViewerArguments` | `fullscreenDialog: true`. Gallery zoom. |

Six routes. **No `/settings`** — the open question from the structural review is resolved: with dark-mode-only in v1, language is the single setting, so it lives as an app-bar toggle. A Settings screen would be one screen holding one switch.

### In-page navigation (Home)

Home sections are reached by scroll, not by route. The app bar hosts anchor links on desktop:

- Each section widget holds a `GlobalKey`; the app bar calls `Scrollable.ensureVisible` with a 400ms curve.
- **Desktop/tablet:** horizontal nav row — About · Work · Skills · Experience · Contact.
- **Mobile:** nav row collapses to a hamburger opening a bottom sheet with the same anchors.
- The active section highlights as it scrolls into view (scroll-offset listener, throttled).

### Web URL strategy

Named routes map to browser URLs automatically via `MaterialApp`'s route name. Additional requirements:

- **Path URL strategy** (no `/#/` fragment) — one call in `main.dart` under a `kIsWeb` guard.
- **Deep-linkable detail pages.** `/project_details` alone cannot be deep-linked because it needs a `ProjectSummary` argument. Handled by `RouteInformationParser`-free means: `onGenerateRoute` checks whether `settings.arguments` is null; if so (direct URL entry / page refresh), it reads the `slug` from the route name query and re-fetches. **Route format:** `/project_details?slug=motary`. This makes every project shareable — important for A3, who will be sent a specific project link.
- **Browser back must work** at every level. Verified in the QA checklist ([Section 17](#17-feature-priorities)).

---

## 6. Screen List

| # | Screen | Route | Stateful? | Cubits provided | Purpose |
|---|---|---|---|---|---|
| S1 | `SplashScreen` | `/splash` | ✅ | — (reads `sl` directly) | Preload all JSON into repositories; resolve saved locale; navigate to Home. |
| S2 | `HomeScreen` | `/home` | ✅ (scroll ctrl, section keys) | Per-section, provided by each section widget | The scrolling composite. Owns nothing but layout + scroll. |
| S3 | `ProjectsScreen` | `/projects` | ✅ (filter state) | `ProjectsCubit` | All projects, filterable by `type`. |
| S4 | `ProjectDetailsScreen` | `/project_details` | ✅ | `ProjectDetailsCubit` | One project, full depth. |
| S5 | `CertificatesScreen` | `/certificates` | ❌ | `CertificatesCubit` | Full credential list. |
| S6 | `ImageViewerScreen` | `/image_viewer` | ✅ (PageController) | — | Full-screen zoomable gallery. |
| S7 | `UndefinedRouteScreen` | *(fallback)* | ❌ | — | 404. Reachable on Web via a bad URL, so it must look intentional — not the guide's red danger screen. |

Seven screens. S7 is a real screen here (unlike in the guide, where it was a debug affordance) because Flutter Web exposes URLs to the public.

---

## 7. Section Breakdown

Each Home section is a self-sufficient widget: it provides its own cubit, fetches on mount, and renders its own loading/success/failure states. `HomeScreen` composes them in order and knows nothing of their internals.

### 7.1 Hero

| | |
|---|---|
| **Data** | `about.json` → `About` entity |
| **Renders** | Name, role title, years-of-experience line, 1-sentence positioning statement, primary CTA `[View My Work]`, secondary CTA `[Download Resume]`, optional avatar/illustration, scroll-down affordance |
| **Layout** | Desktop: two columns (text 60% / visual 40%). Mobile: single column, visual above text, centered |
| **Height** | Desktop `min(100vh, 720px)`; mobile: content-driven, never forced to full height (a full-height mobile hero hides the proof below it) |
| **Motion** | Staggered fade+slide-up of name → role → statement → CTAs, 80ms apart, on first paint only |
| **States** | Loading → skeleton matching final layout (no spinner — this is above the fold). Failure → static fallback with name from `StringsManager`, never a broken hero |

### 7.2 About

| | |
|---|---|
| **Data** | `about.json` → `About` entity |
| **Renders** | Section header, 2–4 sentence bio, a row of 3–4 highlight stats (e.g. "5+ Years", "20+ Apps Shipped", "3 Platforms"), optional "What I'm good at" bullet trio |
| **Layout** | Desktop: bio left (2/3), stats right (1/3) as a vertical card stack. Mobile: bio then stats as a 2×2 grid |
| **Motion** | Section entrance fade+slide; stat numbers count up from 0 once, when ≥50% visible |

### 7.3 Featured Projects

| | |
|---|---|
| **Data** | `projects/index.json` → `List<ProjectSummary>`, filtered `isFeatured == true`, limit 3 (desktop) / all featured (mobile carousel) |
| **Renders** | Section header + `[View all →]`, project cards, each with cover image, title, tagline, domain label, ≤3 tech chips, `[Details]` affordance |
| **Layout** | Desktop: 3-column grid. Tablet: 2-column. Mobile: horizontal `PageView` carousel with page dots — swipeable, which reads better than a tall vertical stack on phones |
| **Motion** | Cards stagger in 100ms apart. Hover (desktop): lift 4px + shadow deepen + cover image scale 1.03, 200ms |
| **Empty** | Never legitimately empty; if the index is empty, show `SectionEmptyState` rather than an empty grid |

### 7.4 Skills

| | |
|---|---|
| **Data** | `skills.json`, entries where `kind == "competency"`, grouped by `category` |
| **Renders** | Section header, category groups (Mobile · Architecture · State Management · Backend & Tools · Practices), each a labeled cluster of skill items with an optional proficiency indicator |
| **Proficiency** | A 3-step scale (`familiar` / `proficient` / `expert`) rendered as a subtle 3-segment bar — **not** a percentage. Self-assessed percentages ("Flutter 95%") read as unserious to A2 and are unfalsifiable; a coarse scale is honest |
| **Layout** | Desktop: 2-column category grid. Mobile: single column, categories stacked |
| **Motion** | Groups stagger; proficiency bars fill left-to-right (start-to-end in RTL) on entry |

### 7.5 Tech Stack

| | |
|---|---|
| **Data** | `skills.json`, entries where `kind == "technology"` |
| **Renders** | A dense, flowing grid of technology tiles — logo + name. No proficiency, no grouping headers |
| **Layout** | `Wrap` of fixed-size tiles, centered; 6–8 per row desktop, 3–4 mobile |
| **Motion** | Whole-grid fade-in; individual tile hover: background tint + slight scale |
| **Asset note** | Each technology needs a logo SVG in `assets/logos/`. A missing logo falls back to a monogram tile (first letter) — the grid must never show a broken-image box |

### 7.6 Experience

| | |
|---|---|
| **Data** | `experience.json` → `List<Experience>`, sorted by `startDate` descending |
| **Renders** | Vertical timeline: company, role, employment type, date range, computed duration, location, 2–4 achievement bullets, optional company logo, optional tech chips |
| **Layout** | Desktop: centered spine with alternating left/right cards. Tablet/Mobile: left-anchored spine (start-anchored in RTL), all cards on one side |
| **Current role** | `endDate: null` renders as "Present" with an accent dot on the timeline |
| **Motion** | The spine line draws top-to-bottom as the section enters; entries fade+slide in sequence |

### 7.7 Certifications

| | |
|---|---|
| **Data** | `certificates.json` → `List<Certificate>`, sorted by `issueDate` descending, limit 4 on Home |
| **Renders** | Section header + `[View all →]`, certificate cards: title, issuer, issuer logo, issue date, optional credential ID, `[Verify]` link when `credentialUrl` is present |
| **Layout** | Desktop 4-col / tablet 2-col / mobile 1-col grid |
| **Motion** | Standard staggered card entrance; hover lift |

### 7.8 Contact

| | |
|---|---|
| **Data** | `social_links.json` → `List<SocialLink>`, plus email/phone from `about.json` |
| **Renders** | Section header, short availability line, primary email CTA, secondary action row (LinkedIn, GitHub, WhatsApp, phone), `[Download Resume]` |
| **Actions** | `mailto:` / `tel:` / `https:` / `whatsapp:` via `url_launcher`. Every launch failure shows a toast **and** copies the raw value to the clipboard — the fallback matters most on Web, where `mailto:` frequently does nothing |
| **No contact form** | Deliberate. A form requires a backend; the brief forbids one. A form that silently does nothing is worse than no form |
| **Motion** | Action tiles stagger; hover lift + platform-color tint |

### 7.9 Footer

| | |
|---|---|
| **Data** | `social_links.json` |
| **Renders** | Compact logo/name, social icon row, `[Resume]`, copyright with current year, "Built with Flutter — source on GitHub" link |
| **Reach** | Home + `/projects` + `/certificates`. Not on `/project_details` (which ends with its own CTA row) |
| **Motion** | None. Footers should not animate |

### 7.10 Project Details *(page, not a Home section)*

Content order, top to bottom:

1. Back button + project title + tagline
2. Cover image (full-bleed on desktop, 16:9)
3. Meta row: role · duration · platforms · status
4. **Overview** — the problem and context
5. **My Responsibilities** — bulleted
6. **Challenges** — bulleted or paired with solutions
7. **Solutions** — how each challenge was addressed
8. **Tech Stack** — chip grid
9. **Gallery** — horizontally scrollable screenshots → tap opens `/image_viewer`
10. **Links** — `[GitHub]` `[Live Demo]` `[App Store]` `[Play Store]`, each rendered only when present
11. **Next project →** — keeps A1/A2 moving instead of dead-ending

Challenges and Solutions are modeled as **paired** items (`ChallengeSolution`), not two independent lists — a challenge with no matching solution is the most common way this section reads badly.

---

## 8. Data Models

Following your approved decision: **full entity separation** (guide §22.11 option (a)). Domain entities are pure Dart with no JSON knowledge; data models own serialization and expose `toEntity()`.

### 8.1 The pattern, stated once

```
assets/data/x.json
      │ rootBundle.loadString + jsonDecode
      ▼
XModel            ← data/models/     factory fromJson, toJson, toEntity()
      │ .toEntity()
      ▼
X                 ← domain/entities/ pure, immutable, Equatable, no JSON
      │
      ▼
XRepository       ← domain/repositories/  returns entities, never models
```

Repository contracts reference **entities only**. This is the guide's §22.11(a) and it fixes the defect the guide flags in the original (domain depending on data types).

### 8.2 Localized text

Every user-facing string in the JSON is bilingual. Rather than duplicating every field (`titleEn`/`titleAr`), a single value object carries both:

```dart
// domain/entities/localized_text.dart
class LocalizedText extends Equatable {
  final String en;
  final String ar;
  const LocalizedText({required this.en, required this.ar});

  String resolve(Locale locale) => locale.languageCode == 'ar' ? ar : en;
}
```

**Why a value object rather than two fields:** resolution happens in exactly one place, the type makes it impossible to forget a translation, and a future third language is one field plus one branch. Widgets call `entity.title.resolve(context.locale)`.

**Distinction from `StringsManager`:** `StringsManager` + `.tr(context)` handles **UI chrome** (button labels, section headers, error messages) via `lang/*.json`. `LocalizedText` handles **content** (project titles, bios, achievements) via `assets/data/*.json`. Two mechanisms because they have different owners and different edit cadences. This is stated explicitly so no one "unifies" them later.

### 8.3 Entity catalogue

| Entity | Fields | Owner |
|---|---|---|
| `LocalizedText` | `en`, `ar` | `core/domain` (shared) |
| `About` | `name: LocalizedText`, `roleTitle: LocalizedText`, `tagline: LocalizedText`, `bio: LocalizedText`, `yearsOfExperience: int`, `location: LocalizedText`, `email: String`, `phone: String?`, `avatarPath: String?`, `highlights: List<Highlight>` | `about` |
| `Highlight` | `value: String`, `label: LocalizedText`, `iconKey: String?` | `about` |
| `Skill` | `id`, `name: String`, `kind: SkillKind`, `category: SkillCategory`, `level: SkillLevel?`, `logoPath: String?` | `skills` |
| `ProjectSummary` | `slug`, `title: LocalizedText`, `tagline: LocalizedText`, `domain: LocalizedText`, `coverPath`, `type: ProjectType`, `primaryTech: List<String>`, `isFeatured: bool`, `order: int` | `projects` |
| `ProjectDetail` | `summary: ProjectSummary`, `overview: LocalizedText`, `role: LocalizedText`, `duration: LocalizedText`, `platforms: List<PlatformKind>`, `status: ProjectStatus`, `responsibilities: List<LocalizedText>`, `challenges: List<ChallengeSolution>`, `techStack: List<String>`, `gallery: List<GalleryImage>`, `links: ProjectLinks` | `projects` |
| `ChallengeSolution` | `challenge: LocalizedText`, `solution: LocalizedText` | `projects` |
| `GalleryImage` | `path: String`, `caption: LocalizedText?` | `projects` |
| `ProjectLinks` | `github: String?`, `liveDemo: String?`, `appStore: String?`, `playStore: String?` | `projects` |
| `Experience` | `id`, `company: LocalizedText`, `role: LocalizedText`, `employmentType: EmploymentType`, `startDate: DateTime`, `endDate: DateTime?`, `location: LocalizedText`, `achievements: List<LocalizedText>`, `technologies: List<String>`, `logoPath: String?` | `experience` |
| `Certificate` | `id`, `title: LocalizedText`, `issuer: LocalizedText`, `issueDate: DateTime`, `expiryDate: DateTime?`, `credentialId: String?`, `credentialUrl: String?`, `imagePath: String?`, `issuerLogoPath: String?` | `certificates` |
| `SocialLink` | `id`, `platform: SocialPlatform`, `label: LocalizedText`, `url: String`, `iconKey: String`, `showInFooter: bool`, `order: int` | `contact` |

### 8.4 Enums

```dart
enum SkillKind        { competency, technology }
enum SkillCategory    { mobile, architecture, stateManagement, backend, tools, practices }
enum SkillLevel       { familiar, proficient, expert }
enum ProjectType      { product, client, openSource, personal }
enum ProjectStatus    { live, inDevelopment, archived }
enum PlatformKind     { android, ios, web, desktop }
enum EmploymentType   { fullTime, partTime, freelance, contract, internship }
enum SocialPlatform   { github, linkedin, email, whatsapp, phone, twitter, medium, other }
```

**[RULE] Every enum parsed from JSON has an explicit `fromValue(String)` with a documented default.** An unrecognized value must never throw — a typo in a JSON file should degrade one card, not white-screen the app. Parsing lives in the model, never the entity.

### 8.5 Computed properties (entity-owned)

Derivations belong on the entity, not in widgets:

- `Experience.isCurrent` → `endDate == null`
- `Experience.durationMonths` → months between `startDate` and `endDate ?? now`
- `Certificate.isExpired` → `expiryDate != null && expiryDate!.isBefore(now)`
- `ProjectDetail.hasLinks` → any of `links.*` non-null
- `ProjectLinks.asList` → ordered non-null entries, for uniform rendering

Presentation-shaped derivations that need `BuildContext` (formatted date ranges, localized duration strings) go in **mapper extensions** under `data/mappers/`, per guide §7.3.

---

## 9. JSON Schema Proposals

### File layout

```
assets/data/
├── about.json
├── skills.json
├── experience.json
├── certificates.json
├── social_links.json
└── projects/
    ├── index.json
    ├── motary.json
    ├── qanony.json
    ├── gharemeen.json
    └── portfolio.json
```

**Conventions applying to every file:**
- `snake_case` keys (matches the guide's API convention; keeps a future backend swap seamless).
- Every content string is an object `{ "en": "...", "ar": "..." }`.
- Dates are ISO-8601 `YYYY-MM-DD` strings; `null` means "present"/"no expiry".
- Asset paths are full paths from the project root (`assets/projects/motary/cover.webp`) — no path assembly in Dart, so a missing asset is greppable.
- Every file's root is an **object**, never a bare array — leaves room for a future `version` or `meta` key without breaking the parser.

---

### `about.json`

```json
{
  "name":       { "en": "Mariam Fawzy", "ar": "مريم فوزي" },
  "role_title": { "en": "Flutter & Mobile Developer", "ar": "مطورة تطبيقات فلاتر" },
  "tagline":    { "en": "I build production Flutter apps with architecture that lasts.",
                  "ar": "أبني تطبيقات فلاتر بمعمارية قابلة للتوسع." },
  "bio":        { "en": "Two to four sentences...", "ar": "..." },
  "years_of_experience": 5,
  "location":   { "en": "Cairo, Egypt", "ar": "القاهرة، مصر" },
  "email": "mariamfawzy110@gmail.com",
  "phone": null,
  "avatar_path": "assets/images/avatar.webp",
  "resume_path": "assets/documents/resume.pdf",
  "highlights": [
    { "value": "5+",  "label": { "en": "Years Experience", "ar": "سنوات خبرة" }, "icon_key": "calendar" },
    { "value": "20+", "label": { "en": "Apps Shipped",     "ar": "تطبيق منشور" }, "icon_key": "rocket" },
    { "value": "3",   "label": { "en": "Platforms",        "ar": "منصات" },      "icon_key": "devices" }
  ]
}
```

> `resume_path` lives here rather than in `AssetsManager` so the resume can be swapped by replacing a file and editing one JSON line.

---

### `skills.json`

```json
{
  "skills": [
    { "id": "flutter",       "name": "Flutter",          "kind": "technology", "category": "mobile",          "logo_path": "assets/logos/flutter.svg" },
    { "id": "dart",          "name": "Dart",             "kind": "technology", "category": "mobile",          "logo_path": "assets/logos/dart.svg" },
    { "id": "clean_arch",    "name": "Clean Architecture","kind": "competency", "category": "architecture",    "level": "expert" },
    { "id": "bloc",          "name": "Bloc / Cubit",     "kind": "competency", "category": "stateManagement", "level": "expert" },
    { "id": "di_getit",      "name": "Dependency Injection","kind": "competency","category": "architecture",  "level": "proficient" },
    { "id": "firebase",      "name": "Firebase",         "kind": "technology", "category": "backend",         "logo_path": "assets/logos/firebase.svg" },
    { "id": "git",           "name": "Git",              "kind": "technology", "category": "tools",           "logo_path": "assets/logos/git.svg" }
  ]
}
```

`name` is intentionally **not** localized — technology names are proper nouns and are not translated in either language.

---

### `experience.json`

```json
{
  "experience": [
    {
      "id": "company-slug-2024",
      "company":  { "en": "Company Name", "ar": "اسم الشركة" },
      "role":     { "en": "Senior Flutter Developer", "ar": "مطورة فلاتر أولى" },
      "employment_type": "fullTime",
      "start_date": "2024-03-01",
      "end_date": null,
      "location": { "en": "Cairo, Egypt · Hybrid", "ar": "القاهرة، مصر · هجين" },
      "logo_path": "assets/logos/company.svg",
      "achievements": [
        { "en": "Led architecture for a fleet-management app serving 10k+ daily users.",
          "ar": "قدت تصميم معمارية تطبيق إدارة أساطيل يخدم أكثر من ١٠ آلاف مستخدم يوميًا." }
      ],
      "technologies": ["Flutter", "Bloc", "GetIt", "Firebase"]
    }
  ]
}
```

**[RULE] Achievements are outcome statements, not duty lists.** "Reduced cold start 40%" over "Responsible for app performance." This is a content rule, but it belongs in the spec because it's the difference between an Experience section that persuades A1 and one that doesn't.

---

### `certificates.json`

```json
{
  "certificates": [
    {
      "id": "gdg-flutter-2023",
      "title":  { "en": "Flutter Development", "ar": "تطوير تطبيقات فلاتر" },
      "issuer": { "en": "Google Developers", "ar": "مطوري جوجل" },
      "issue_date": "2023-06-15",
      "expiry_date": null,
      "credential_id": "ABC-123-XYZ",
      "credential_url": "https://example.com/verify/ABC-123-XYZ",
      "image_path": "assets/certificates/gdg_flutter.webp",
      "issuer_logo_path": "assets/logos/google.svg"
    }
  ]
}
```

---

### `social_links.json`

```json
{
  "social_links": [
    { "id": "github",   "platform": "github",   "label": { "en": "GitHub",   "ar": "جيت هب" },
      "url": "https://github.com/Meroothman", "icon_key": "github",   "show_in_footer": true,  "order": 1 },
    { "id": "linkedin", "platform": "linkedin", "label": { "en": "LinkedIn", "ar": "لينكد إن" },
      "url": "https://linkedin.com/in/...",   "icon_key": "linkedin", "show_in_footer": true,  "order": 2 },
    { "id": "email",    "platform": "email",    "label": { "en": "Email",    "ar": "البريد" },
      "url": "mailto:mariamfawzy110@gmail.com", "icon_key": "mail",   "show_in_footer": true,  "order": 3 },
    { "id": "whatsapp", "platform": "whatsapp", "label": { "en": "WhatsApp", "ar": "واتساب" },
      "url": "https://wa.me/20XXXXXXXXXX",     "icon_key": "whatsapp","show_in_footer": false, "order": 4 }
  ]
}
```

The full URL (including `mailto:` / `https://wa.me/`) is stored in JSON rather than assembled in Dart, so adding a platform requires no code change.

---

### `projects/index.json`

```json
{
  "projects": [
    {
      "slug": "motary",
      "title":   { "en": "Motary", "ar": "موتري" },
      "tagline": { "en": "Vehicle services marketplace", "ar": "سوق خدمات المركبات" },
      "domain":  { "en": "Automotive", "ar": "السيارات" },
      "cover_path": "assets/projects/motary/cover.webp",
      "type": "client",
      "primary_tech": ["Flutter", "Bloc", "Firebase"],
      "is_featured": true,
      "order": 1,
      "detail_file": "assets/data/projects/motary.json"
    }
  ]
}
```

`detail_file` is an explicit path rather than a `slug`-derived convention — it keeps the mapping visible and lets a file be renamed without a silent 404.

---

### `projects/<slug>.json`

```json
{
  "slug": "motary",
  "overview": { "en": "Two to four sentences on the problem and context.", "ar": "..." },
  "role":     { "en": "Lead Flutter Developer", "ar": "مطورة فلاتر رئيسية" },
  "duration": { "en": "Jan 2024 – Aug 2024 · 8 months", "ar": "يناير ٢٠٢٤ – أغسطس ٢٠٢٤ · ٨ أشهر" },
  "platforms": ["android", "ios"],
  "status": "live",
  "responsibilities": [
    { "en": "Designed the Clean Architecture foundation and DI composition root.", "ar": "..." },
    { "en": "Built the offline-first sync layer for field agents.", "ar": "..." }
  ],
  "challenges": [
    {
      "challenge": { "en": "Field agents worked in areas with no connectivity.", "ar": "..." },
      "solution":  { "en": "Write-through cache plus a de-duplicated offline queue replayed on reconnect.", "ar": "..." }
    }
  ],
  "tech_stack": ["Flutter", "Dart", "Bloc", "GetIt", "Dio", "SQLite", "Firebase"],
  "gallery": [
    { "path": "assets/projects/motary/01_home.webp",    "caption": { "en": "Home dashboard", "ar": "الرئيسية" } },
    { "path": "assets/projects/motary/02_details.webp", "caption": null }
  ],
  "links": {
    "github": "https://github.com/...",
    "live_demo": null,
    "app_store": "https://apps.apple.com/...",
    "play_store": "https://play.google.com/..."
  }
}
```

> `slug` is duplicated between index and detail file **on purpose** — the datasource asserts they match on load, catching a mis-wired `detail_file` immediately rather than rendering the wrong project.

### Schema validation

**[RULE] Every model's `fromJson` is defensive** (guide §6.3): coerce types, default nullable-but-required strings to `""`, default unknown enum values, and default missing lists to `[]`. A malformed JSON file must degrade one card, never crash the app.

**Recommended dev tooling (P2):** a `tool/validate_data.dart` script, runnable via `dart run tool/validate_data.dart`, that parses every JSON file against the models and reports missing keys, unmatched slugs, unknown enum values, and asset paths that don't exist on disk. This is the highest-value 100 lines in the project — it converts an entire class of runtime content bugs into a pre-commit failure.

---

## 10. Reusable UI Components

Two tiers, split by reach (guide §1.4). Since this is a single-package build, both live under `lib/core/design_system/widgets/` and `lib/src/widgets/` respectively.

### 10.1 Design system — `lib/core/design_system/widgets/`

Ported from the guide's catalogue, minus everything serving networking, file upload, or forms this app doesn't have.

| Widget | Purpose | Notes vs. guide |
|---|---|---|
| `CustomText` | All text rendering | Kept as-is. Positional first arg |
| `CustomTextSpan` | Multi-style rich text | Kept |
| `CustomContainer` | Container / button / card / loading button | Kept. **Extended** with `onHover` support for Web |
| `CustomImage` | Asset / network / SVG with placeholder + error fallback | **Simplified** — no `CachedNetworkImage` (all assets are local), no file variant |
| `CustomSvg` | SVG with responsive sizing + optional tint | Kept. Uses `colorFilter`, not deprecated `.color` (guide §22.19) |
| `CustomAppBar` | App bar, `PreferredSizeWidget` | **Extended** — hosts desktop anchor nav + language toggle |
| `CustomLoading` | Adaptive progress indicator | Kept |
| `CustomErrorWidget` | Section-level error + retry | Kept |
| `CustomShimmer` | Skeleton loading | Kept as `.shimmerLoading` extension |
| `CustomTooltip` | Hover tooltip | **New** — Web/desktop affordance the guide had no need for |
| `CustomDivider` | Consistent separator | New, trivial |
| `showToastNotification()` | Toasts | Kept — used for link-launch failures |

**Deliberately omitted:** `CustomTextField`, `CustomOtpField`, all dropdowns, `CustomCountryCodePicker`, `CustomVideoPlayer`, all attachment pickers, `PaginatedList`/`PaginationGrid`, all selection dialogs, `NetworkBanner`/`NoInternetConnection`, `BackAgainScreenHolder`. **Reason:** no forms, no pagination (every dataset is ≤20 items and fully in memory), no network, no uploads. Each would be dead code.

> **Note on the guide's §22.18 defect:** `PaginatedList`'s `ScrollController` leak doesn't carry forward, because the widget isn't ported. Any new scroll-listening widget here (the Home scroll-spy) must still create its controller in `initState` and dispose it in `dispose`.

### 10.2 Shared app widgets — `lib/src/widgets/`

Used by ≥2 features, too app-specific for the design system.

| Widget | Purpose |
|---|---|
| `SectionContainer` | Vertical rhythm + max-width clamp + screen padding + entrance animation for every Home section. **One place to retune the whole page's spacing** |
| `SectionHeader` | Eyebrow label + title + optional subtitle + optional trailing `[View all]` |
| `SectionStateBuilder<T>` | Wraps `BlocBuilder`, branches loading → success → failure → `SizedBox` in the guide's mandated order (§3.7, Rule 22), with built-in retry. **The single most valuable shared widget** — without it, eight sections each hand-roll the same ladder |
| `SectionEmptyState` | Icon + localized title + subtitle |
| `AppFooter` | Social row + resume + copyright |
| `TagChip` | One pill. Used by Skills, Tech Stack, project cards, detail stack, filters |
| `LinkButton` | External-link action; owns the `url_launcher` call, failure toast, and clipboard fallback |
| `HoverScale` | Wraps a child with a hover lift/scale on desktop, no-op on touch. Single place where the Web/mobile interaction split lives |
| `AnimatedCounter` | Count-up number for About highlights |
| `ResponsiveBuilder` | Builds per breakpoint (see §12) |
| `MaxWidthWrapper` | Clamps content width and centers on large screens |
| `AppScaffold` | Standard page chrome: `CustomAppBar` + body + optional footer. Used by every screen except Splash/ImageViewer |

### 10.3 Feature-local widgets

Each feature owns a **card** (item rendering) and a **section** (the Home block):

```
about/        AboutSection · HighlightStatsRow · HighlightStatTile
skills/       SkillsSection · SkillCategoryGroup · SkillLevelBar
              TechStackSection · TechTile
projects/     FeaturedProjectsSection · ProjectCard · ProjectsGrid
              ProjectTypeFilter · ProjectGallery · ProjectLinksRow
              ChallengeSolutionTile · ProjectMetaRow
experience/   ExperienceSection · ExperienceTimeline · ExperienceTile · TimelineSpine
certificates/ CertificatesSection · CertificateCard
contact/      ContactSection · ContactActionTile · SocialLinksRow
home/         HeroSection · HeroCtaRow · ScrollDownIndicator · SectionNavBar
```

**Composition contract:** `HomeScreen` is an ordered list of `<Feature>Section` widgets inside a scroll view. Reordering Home is a matter of moving one line.

---

## 11. Asset Organization

```
assets/
├── data/                    # JSON content (see §9)
│   ├── about.json
│   ├── skills.json
│   ├── experience.json
│   ├── certificates.json
│   ├── social_links.json
│   └── projects/
│       ├── index.json
│       └── <slug>.json
├── images/                  # App imagery: avatar, hero art, placeholders, og_image
├── icons/                   # UI icons — SVG only
├── logos/                   # Tech + company + issuer logos — SVG preferred
├── certificates/            # Certificate images — WebP
├── projects/                # Per-project media, one folder per slug
│   └── <slug>/
│       ├── cover.webp
│       └── 01_*.webp …
├── animations/              # Lottie JSON (used sparingly — see §13)
├── documents/
│   └── resume.pdf
└── fonts/
    ├── english/
    └── arabic/

lang/
├── en.json                  # UI chrome strings
└── ar.json
```

### Rules

**[RULE] Declare folders, not files, in `pubspec.yaml`** (guide §13.1) — with one exception: `assets/projects/` needs each `<slug>/` subfolder declared, because Flutter's folder declaration is not recursive. This is a real footgun; the README must state it, and the `validate_data.dart` script should check it.

**[RULE] No asset path string appears outside `AssetsManager`** — except paths that come from JSON content (`cover_path`, `logo_path`), which are data, not code. `AssetsManager` holds only structural assets: placeholders, the app logo, UI icons.

**[RULE] Raster assets are WebP.** Materially smaller than PNG/JPG, and Web payload is the binding constraint (R-1). Cover images ≤1600px wide, gallery ≤1200px, certificates ≤1000px.

**[RULE] Every logo is SVG where obtainable**, with a monogram fallback tile when absent.

**Image budget:** total `assets/` ≤ 8MB. A portfolio that takes six seconds to load on Web has failed its primary audience regardless of its architecture.

---

## 12. Responsive Behavior

### Breakpoints

```dart
class Breakpoints {
  static const double mobile  = 600;   // < 600
  static const double tablet  = 900;   // 600–899
  static const double desktop = 1240;  // 900–1239
  // >= 1240 → large desktop
}
```

Four bands: `mobile` · `tablet` · `desktop` · `largeDesktop`, exposed as a `DeviceType` enum resolved by `ResponsiveBuilder` from `MediaQuery.sizeOf(context).width`.

### The `flutter_screenutil` problem

The guide makes every dimension responsive via `flutter_screenutil` against a 440×956 design size (§15.1). **That approach must not be carried to Web unchanged.** ScreenUtil scales linearly from a phone-sized design; on a 2560px monitor it produces 40pt body text and comically large spacing.

**Resolution — a hybrid, and this is the single most important responsive decision:**

| Concern | Mobile/tablet | Desktop/Web |
|---|---|---|
| Dimensions (`.rh` `.rw` `.rs` `.rb`) | ScreenUtil scaling, as the guide specifies | **Clamped** — scale factor capped at 1.0 above the tablet breakpoint |
| Layout | Single column | Multi-column grids + `MaxWidthWrapper` (content clamped to 1200px) |
| Type scale | ScreenUtil-scaled | Fixed ladder, no scaling |

The extension keeps the guide's exact call sites (`AppSize.s16.spaceH`) — only the internal implementation clamps. **Nothing in feature code changes**, which is precisely the payoff of the guide's extension-based DSL.

### Per-section layout matrix

| Section | Mobile (<600) | Tablet (600–899) | Desktop (≥900) |
|---|---|---|---|
| Hero | 1 col, visual above text | 1 col, centered | 2 col (60/40) |
| About | Bio then 2×2 stats | Bio then stat row | Bio 2/3, stats 1/3 |
| Featured Projects | Horizontal carousel | 2-col grid | 3-col grid |
| Skills | 1 col categories | 2 col | 2 col, wider |
| Tech Stack | 3–4 tiles/row | 5–6 | 7–8 |
| Experience | Start-anchored timeline | Start-anchored | Centered alternating spine |
| Certifications | 1 col | 2 col | 4 col |
| Contact | Stacked full-width | 2 col | Row of tiles |
| Nav | Hamburger → bottom sheet | Hamburger | Inline anchor row |

### Cross-cutting rules

- **[RULE] No horizontal scroll at any width ≥320px.** The most common portfolio bug.
- **[RULE] Every tappable target ≥44×44 logical px** on touch platforms.
- **[RULE] Test at 320 / 375 / 768 / 1024 / 1440 / 2560.** Part of the QA checklist.
- **[RULE] Hover effects are gated on pointer type**, never on `kIsWeb` — a touchscreen Windows laptop is Web with no hover.
- Text scales with the OS accessibility setting up to 1.3× without clipping (§14).

---

## 13. Animation Guidelines

**Governing principle:** motion clarifies structure and confirms interaction. Motion that merely decorates is removed. Your brief says "moderate," which this spec reads as: *every animation must survive the question "what would break if this were instant?"*

### Duration & curve tokens

Added to `DurationValues` (guide §14.3 naming):

| Token | ms | Use |
|---|---|---|
| `dm150` | 150 | Hover, tap feedback, color transitions |
| `dm250` | 250 | Card lift, chip states |
| `dm400` | 400 | Section entrance, page transitions, scroll-to-anchor |
| `dm600` | 600 | Hero stagger total, counter count-up |

| Curve | Use |
|---|---|
| `Curves.easeOutCubic` | Entrances (default) |
| `Curves.easeInOut` | Reversible states (hover, toggles) |
| `Curves.easeOut` | Exits |

**No springs, no bounce, no elastic.** They read as playful; the brief asks for premium and minimal.

### The five sanctioned animation types

1. **Section entrance** — fade (0→1) + slide-up (24px→0) over `dm400`, triggered once when ≥20% visible. Children stagger 60–100ms. **Fires once per session**, never on scroll-back — re-animating on every scroll is the fastest way to make a page feel cheap.

2. **Page transitions** — guide §9.3 pattern, extended for Web: `CupertinoPageRoute` on iOS; `dm400` fade on Android **and Web** (a slide on Web fights browser back). `/image_viewer` uses a Hero transition from the tapped thumbnail.

3. **Hover (desktop/Web only)** — cards lift 4px + shadow deepen + cover scale 1.03; buttons brighten + scale 1.02; chips tint; links underline-in from start edge. All `dm150`–`dm250`. Gated on pointer type.

4. **Press feedback** — scale 0.98 on tap-down, restore on release, `dm150`. Applies to every interactive surface. This is what makes a Flutter app feel native rather than like a web page.

5. **Content-specific, one each** —
   - About highlight numbers count up once on first visibility.
   - Skill proficiency bars fill start→end on entry.
   - Experience timeline spine draws top→bottom as the section enters.
   - Scroll-down indicator in Hero: gentle 8px vertical loop — **the only looping animation in the app**.

### Prohibited

- Parallax scrolling (jank risk on Web, no informational value).
- Any looping animation besides the Hero indicator.
- Animated page backgrounds, particles, gradient meshes.
- Lottie in any always-visible position. `assets/animations/` exists for the 404 screen and possibly an empty state — nowhere else.
- Text character-by-character typewriter effects.
- Animations exceeding 600ms.

### Accessibility & performance

- **[RULE] Honor `MediaQuery.disableAnimations`** (set by OS "reduce motion"). When true: entrances become instant opacity, counters jump to final value, the Hero indicator stops looping. One `AnimationConfig.effectiveDuration(context)` helper consulted by every animated widget.
- **[RULE] Animate only `Opacity`, `Transform`, and color.** Never animate layout properties on Web — they force reflow.
- **[RULE] 60fps floor on a mid-range Android device and on Chrome desktop.** Profiled before release.

---

## 14. Accessibility Guidelines

Not a checkbox. A1 may be using a screen reader; A2 will notice if the DOM semantics are broken.

### Color & contrast

- **[RULE] Body text ≥4.5:1 against its background; large text (≥18pt or 14pt bold) ≥3:1.** WCAG AA. Verified for every `ColorsManager` role alias against the dark surface tokens, documented in a contrast table when the palette is finalized.
- **[RULE] Color is never the sole carrier of meaning.** Project status uses icon + label, not just a colored dot. Skill level uses filled segments + a text label on hover/focus.
- Dark theme specifically: **avoid pure black (#000) surfaces and pure white (#FFF) text.** Use `#0D0D0F`-ish and `#F2F2F5`-ish — the reduced contrast ratio lowers halation for astigmatic readers, and looks more premium.

### Semantics

- **[RULE] Every image has a semantic label or is explicitly marked decorative.** Project covers and certificate images take labels from their JSON `title`. Logo/ornamental images get `ExcludeSemantics`.
- **[RULE] Every icon-only button has a `tooltip` and a semantic label.** Applies to social icons, the language toggle, and the back button.
- Section headers use `Semantics(header: true)` so screen readers can jump between them.
- Decorative dividers and spacers are excluded from the semantic tree.

### Keyboard & focus *(Web/desktop — non-optional there)*

- **[RULE] Every interactive element is reachable by Tab in visual order and activatable by Enter/Space.**
- **[RULE] A visible focus indicator on every focusable element** — a 2px accent outline. Flutter Web's default focus styling is inadequate; this needs an explicit `FocusableActionDetector` in `CustomContainer`.
- `Esc` closes the image viewer and the mobile nav sheet.
- Arrow keys navigate the gallery in `/image_viewer`.
- Focus is trapped inside the image viewer while open, and restored to the originating thumbnail on close.

### Text & motion

- **[RULE] Layout survives OS text scaling to 1.3×** without clipping or overflow. Enforced by using `maxLines` + `TextOverflow.ellipsis` deliberately rather than fixed heights on text containers.
- **[RULE] `MediaQuery.disableAnimations` is honored** (§13).

### Language & direction

- **[RULE] All geometry is directional** — `EdgeInsetsDirectional`, `BorderRadiusDirectional`, `start`/`end` (guide §12.4). The extension library produces only directional types, so following the DSL keeps this correct for free.
- `Directionality` flips wholesale with the locale; icons that imply direction (back arrow, "view all →") mirror; logos and numerals do not.
- `lang/en.json` and `lang/ar.json` must both be **complete** — the guide flags (§22.16) that the original shipped 2 English keys against 80 Arabic. A CI check comparing key sets between the two files prevents a recurrence.

---

## 15. Design Principles

No fixed design exists yet, so these are the constraints the implementation designs within.

### Visual direction

**Modern · premium · minimal · dark.** Reference points: Linear, Vercel, Stripe docs — restraint, strong typography, generous negative space, one accent color used sparingly.

### 1. Typography carries the hierarchy

With minimal ornament, type does the work. A fixed ladder, defined once in `FontSize`:

| Role | Desktop | Mobile | Weight |
|---|---|---|---|
| Display (Hero name) | 56 | 34 | 700 |
| H1 (section titles) | 40 | 28 | 700 |
| H2 (card titles) | 24 | 20 | 600 |
| H3 (subsections) | 20 | 18 | 600 |
| Body large | 18 | 16 | 400 |
| Body | 16 | 15 | 400 |
| Caption / meta | 14 | 13 | 400 |
| Label / chip | 13 | 12 | 500 |

- **[RULE] Exactly two font families:** one Latin, one Arabic, swapped by `FontConstants.changeFontFamily` (guide §14.2). Recommended: **Inter** (Latin) + **IBM Plex Sans Arabic** or **Cairo** (Arabic) — both have real weight ranges and read well at small sizes.
- **[RULE] Four weights maximum:** 400 / 500 / 600 / 700.
- Line height 1.5 for body, 1.2 for headings. Measure (line length) capped at ~70 characters — enforced by `MaxWidthWrapper` on prose blocks.

### 2. Spacing is a system, not a decision

- **[RULE] All spacing comes from an 8px scale** (4 permitted for tight pairs): 4 · 8 · 12 · 16 · 24 · 32 · 48 · 64 · 96. Already how `PaddingValues`/`AppSize` are structured.
- Vertical rhythm between Home sections: 96 desktop / 64 mobile, owned by `SectionContainer`.
- **[RULE] No magic numbers in feature code.** Every dimension resolves to a token.

### 3. Color: one accent, many neutrals

Three tiers, per guide §14.1 (raw palette → semantic → role alias):

- **Surfaces** — 4–5 dark neutrals forming an elevation ladder (page → section → card → raised card). Elevation is expressed by *surface lightness*, not shadow — shadows are nearly invisible on dark backgrounds.
- **Text** — primary / secondary / tertiary / disabled, all contrast-verified.
- **Accent** — exactly one, used for CTAs, links, active states, and the timeline "present" marker. Nothing else.
- **Semantic** — success / warning / danger, reserved for status indicators.

**[RULE] Widgets reference role aliases only** (`ColorsManager.surfaceCard`, `ColorsManager.textPrimary`), never raw hex, never raw palette names. This is what makes a future light theme a token-swap rather than a refactor — see §17 and the theme note below.

### 4. Depth through surface, not shadow

On dark UI, layer by lightening the surface. Borders are 1px at low opacity. Reserve real shadows for genuinely floating elements (hover-lifted cards, the app bar once scrolled).

### 5. Consistency over novelty

Every card has the same radius, padding, and hover behavior. Every section has the same header treatment and rhythm. **The page should feel like one system, not nine designs.** This is also the strongest signal to A2.

### 6. Content-first

Design serves the content. Where the two conflict — a beautiful layout that truncates an achievement — the content wins.

### Theme architecture (light-mode readiness)

Dark-only ships in v1, but the structure must not preclude light. The mechanism:

```dart
class ThemeManager {
  static ThemeData get dark => _build(AppColorScheme.dark);
  // static ThemeData get light => _build(AppColorScheme.light);   ← v2, no other change
  static ThemeData _build(AppColorScheme scheme) { … }
}
```

**[RULE] Widgets read role aliases resolved from the active `AppColorScheme`, never `ColorsManager.<rawColor>` directly.** With that discipline, adding light mode in v2 is: define a second `AppColorScheme`, add a `ThemeCubit`, add a toggle. No widget changes.

This is a **deviation from the guide**, which uses flat `static const` color access (§10, §14.1). Justification: the guide's app was single-theme forever; this one has a stated future requirement for a second theme. Flat statics cannot support that without touching every widget. Everything else about the token layer — naming, tiering, the manager classes — is preserved.

---

## 16. Folder Ownership

Single-package layout (your approved decision), with layering enforced by structure, barrels, and lint.

```
lib/
├── main.dart                          # bindings, URL strategy, DI init, runApp
│
├── core/                              # app-agnostic foundation — no feature imports it downward
│   ├── domain/
│   │   ├── entities/localized_text.dart
│   │   ├── errors/failures.dart       # Failure · DataFailure · NotFoundFailure
│   │   ├── errors/exceptions.dart     # AssetLoadException · DataParseException
│   │   └── usecases/base_usecase.dart # BaseUseCase · BaseUseCaseNoParam
│   ├── data/
│   │   ├── local_json_datasource.dart # THE single asset-reading primitive
│   │   └── try_catch.dart             # Exception → Either<Failure, T>
│   ├── state/custom_state.dart        # CustomState<T> — guide §22.9, correctly placed
│   ├── managers/
│   │   ├── assets_manager.dart
│   │   ├── colors_manager.dart
│   │   ├── strings_manager.dart
│   │   ├── fonts_manager.dart
│   │   ├── values_manager.dart        # AppSize · PaddingValues · BorderValues · DurationValues · AppShadow
│   │   ├── icons_manager.dart
│   │   ├── breakpoints_manager.dart
│   │   └── managers.dart              # barrel
│   ├── design_system/
│   │   ├── theme/theme_manager.dart
│   │   ├── theme/app_color_scheme.dart
│   │   ├── widgets/                   # Custom* — see §10.1
│   │   └── design_system.dart         # barrel
│   ├── extensions/                    # responsive · spacer · padding · border · duration · debug · color · string · context
│   ├── localization/
│   │   ├── app_localizations.dart
│   │   ├── app_localizations_setup.dart
│   │   └── locale_extension.dart      # .tr(context)
│   ├── utils/                         # url_launcher_helper · resume_service · scroll_helper
│   └── core.dart                      # barrel
│
├── features/                          # one folder per slice — all identical in shape
│   ├── about/        { data · domain · presentation }
│   ├── skills/       { data · domain · presentation }
│   ├── projects/     { data · domain · presentation }
│   ├── experience/   { data · domain · presentation }
│   ├── certificates/ { data · domain · presentation }
│   ├── contact/      { data · domain · presentation }
│   ├── home/         { presentation only }          ← composition slice, owns no data
│   └── splash/       { presentation only }          ← orchestration slice
│
└── src/                               # app-level infrastructure, not a feature
    ├── app.dart                       # PortfolioApp: MultiBlocProvider + MaterialApp
    ├── service_locator.dart           # GetIt composition root
    ├── routes_manager.dart            # onGenerateRoute
    ├── bloc_observer.dart
    └── widgets/                       # shared app widgets — see §10.2
```

### Canonical feature slice

```
features/projects/
├── data/
│   ├── datasources/projects_local_datasource.dart   # abstract + Impl, same file (guide §2.8)
│   ├── models/
│   │   ├── project_summary_model.dart
│   │   ├── project_detail_model.dart
│   │   ├── challenge_solution_model.dart
│   │   ├── gallery_image_model.dart
│   │   └── project_links_model.dart
│   ├── mappers/project_display_mapper.dart          # presentation-shaped derivations
│   └── repositories/projects_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── project_summary.dart
│   │   ├── project_detail.dart
│   │   ├── challenge_solution.dart
│   │   ├── gallery_image.dart
│   │   └── project_links.dart
│   ├── repositories/projects_repository.dart        # abstract; returns ENTITIES
│   └── usecases/
│       ├── get_projects_usecase.dart
│       ├── get_featured_projects_usecase.dart
│       └── get_project_detail_usecase.dart
└── presentation/
    ├── cubit/
    │   ├── projects_cubit.dart + projects_state.dart          # part of
    │   └── project_details_cubit.dart + project_details_state.dart
    ├── screens/
    │   ├── projects_screen.dart
    │   ├── project_details_screen.dart
    │   └── project_details_arguments.dart
    └── widgets/                                     # see §10.3
```

**Naming standardized** on `<Feature>Repository` / `<Feature>RepositoryImpl` and folder `repositories/` — resolving the guide's own inconsistency (§22.8).

### Ownership table

| Path | Owns | Must never |
|---|---|---|
| `core/` | Foundation, tokens, design system, base contracts | Import any `features/` file |
| `core/data/local_json_datasource.dart` | The **only** `rootBundle` call in the app | Know about any specific feature |
| `features/<f>/data/` | JSON→model parsing, repository impl | Import `presentation/` |
| `features/<f>/domain/` | Entities, contracts, use cases | Import Flutter, `rootBundle`, or any model |
| `features/<f>/presentation/` | Screens, widgets, cubits | Import `data/` internals or call `rootBundle` |
| `features/home/` | Home layout + Hero | Own data or import another feature's `data/`/`domain/` |
| `src/` | App wiring: DI, routes, app widget | Contain feature logic |

**[RULE] Features never import each other's `data/` or `domain/`.** Home composes other features' **section widgets** (a `presentation` export) and nothing else. `LocalizedText` is shared via `core/`, not via a feature.

### The `LocalJsonDataSource` primitive

One class every feature datasource depends on:

```dart
abstract class LocalJsonDataSource {
  Future<Map<String, dynamic>> readJson(String assetPath);
}
```

`LocalJsonDataSourceImpl` wraps `rootBundle.loadString` + `jsonDecode`, throws `AssetLoadException` / `DataParseException`, and **memoizes by path** — so Home's eight sections reading five files hit the bundle five times, not eight, and a return visit to `/projects` re-reads nothing.

**Why memoize here rather than build a cache layer:** the brief forbids a cache layer, correctly. This is not one — it's a `Map<String, Map<String,dynamic>>` field on a lazy singleton, ~10 lines, no eviction, no persistence, no invalidation. It exists because assets are immutable for the process lifetime, which makes re-parsing strictly wasted work.

---

## 17. Feature Priorities

### MVP — v1.0 (ship this)

| P | Item | Why |
|---|---|---|
| P0 | Project skeleton: folders, barrels, `pubspec`, lints, `analysis_options` | Everything depends on it |
| P0 | `core/` foundation: managers, tokens, extensions, `CustomState`, `tryCatch`, `LocalJsonDataSource` | Every feature depends on it |
| P0 | Design system: `CustomText` · `CustomContainer` · `CustomImage` · `CustomSvg` · `CustomAppBar` · `CustomLoading` · `CustomErrorWidget` | Every screen depends on it |
| P0 | Dark theme + `AppColorScheme` + typography ladder | Every widget depends on it |
| P0 | DI composition root + `RoutesManager` + `app.dart` + `main.dart` | Wiring |
| P0 | `about` slice + Hero + About sections | Above the fold |
| P0 | `projects` slice + Featured + `/projects` + `/project_details` | **The core value of the portfolio** |
| P0 | `HomeScreen` composition + scroll | The product |
| P1 | `skills` slice + Skills + Tech Stack sections | Expected content |
| P1 | `experience` slice + timeline | Expected content |
| P1 | `contact` slice + Footer + link launching + resume open | The conversion point |
| P1 | Responsive layouts across all four breakpoints | A1 is on desktop, A3 on mobile |
| P1 | EN/AR localization, both files complete, RTL verified | Stated requirement |
| P1 | Section entrance + hover + press animations | Stated requirement |
| P2 | `certificates` slice + `/certificates` | Supporting evidence |
| P2 | `/image_viewer` gallery | Enhances J2 |
| P2 | Accessibility pass: semantics, focus order, contrast audit, reduce-motion | Quality bar |
| P2 | `UndefinedRouteScreen` + Web deep links + path URL strategy | Web correctness |
| P2 | `tool/validate_data.dart` | Prevents a whole bug class |
| P2 | Tests (see below) | Guide §22.1 — the original's biggest gap |
| P2 | README with architecture overview + "how to add a project" | A2 reads this first |

### Tests — MVP scope

The guide names zero tests as the original's single biggest gap (§22.1). Not repeating it. Realistic scope for v1, using `mocktail` + `bloc_test`:

```
test/
├── features/<feature>/
│   ├── data/  <feature>_repository_impl_test.dart   # fake datasource, assert entity mapping
│   ├── data/  <model>_test.dart                      # fromJson incl. malformed input
│   └── presentation/ <feature>_cubit_test.dart       # assert emission order
├── core/  local_json_datasource_test.dart
└── helpers/ mocks.dart · fixtures/*.json
```

**Coverage target: every model's `fromJson` (including malformed input) and every cubit's emission order.** Widget/golden tests are explicitly out of scope for v1 — high maintenance cost against a design still being iterated.

### Future — v2+

| Item | Trigger |
|---|---|
| Light theme + `ThemeCubit` + toggle | Architecture already ready (§15) |
| Open Source section | When there are ≥3 real contributions worth showing |
| Testimonials | **Only** with real, attributable, permitted quotes |
| Blog / writing | If writing actually happens |
| Project case-study long form | If a project deserves more than the detail page |
| Analytics | Only with a privacy-respecting, cookieless provider |
| PWA / offline | Once Web is the dominant traffic source |
| SEO/SSR strategy | See R-1 |

### Definition of done (v1)

- [ ] All P0 + P1 shipped; P2 shipped or explicitly deferred with a note
- [ ] `flutter analyze` clean, zero warnings
- [ ] Runs on Chrome, a physical Android device, and iOS simulator
- [ ] No horizontal scroll at 320 · 375 · 768 · 1024 · 1440 · 2560
- [ ] Browser back works from every page; every project URL is shareable
- [ ] EN and AR key sets identical; RTL visually verified on every screen
- [ ] Reduce-motion honored; keyboard navigation complete on Web
- [ ] Contrast audit passes AA for all text roles
- [ ] Total `assets/` ≤ 8MB; Web first paint < 3s on a mid-tier connection
- [ ] 60fps scroll on a mid-range Android and Chrome desktop
- [ ] Fresh `git clone` → `flutter run -d chrome` works with zero setup

---

## 18. Risks & Implementation Considerations

### R-1 — Flutter Web load time and SEO *(highest risk)*

**Problem.** A Flutter Web app ships a multi-MB engine before rendering anything, and its content lives in a canvas that search engines and LinkedIn/WhatsApp preview crawlers do not read. For a portfolio whose primary audience arrives via a shared link, this is the most consequential technical risk in the project — and it is a risk inherent to the platform choice, not to anything in this spec.

**Mitigations (in scope for v1):**
- WebP everywhere, ≤8MB asset budget, `--release --wasm` if the target Flutter version supports it.
- `flutter build web --release` with tree-shaken icons.
- A styled loading state in `web/index.html` — a dark background matching the app's surface plus the name, so the pre-engine gap doesn't look broken.
- Full static `<meta>` tags in `index.html`: title, description, and Open Graph / Twitter Card tags with a pre-rendered `og_image.png`. **This alone fixes link previews**, which matters more than search ranking for A1/A3, who arrive from LinkedIn and WhatsApp, not Google.
- `<noscript>` fallback with plain-text name, role, and contact email.

**Accepted limitation:** genuine SEO indexing of section content is not achievable without SSR or a parallel static site. Deferred to v2, and honestly out of scope for v1.

### R-2 — Content is the actual bottleneck

The architecture will be finished long before the content is. Empty or placeholder content makes an excellent app look like an unfinished one, and A1 cannot distinguish "great architecture, no content yet" from "abandoned."

**Mitigation:** treat content as a deliverable with its own deadline. Write `about.json` and two full project files **before** building the sections that render them — real content immediately exposes layout assumptions (a 3-line tagline, a 12-item tech stack) that lorem ipsum hides. `SectionEmptyState` exists so a partially-filled portfolio degrades gracefully.

### R-3 — Over-engineering the small slices

`about` and `contact` each read one file and render one block. Full Clean Architecture means ~8 files each for what a `FutureBuilder` could do in 20 lines. A skeptical reviewer (A2) may read this as cargo-culting.

**Decision: keep the full chain, uniformly.** Consistency *is* the demonstration — a codebase where every slice has the same shape is the point, and the guide explicitly names the original's shortcut slices (`dashboard`, `profile`, `lookups`) as a defect (§22.7). Mitigate the perception in the README: state that uniformity is deliberate and name the alternative that was rejected. An architecture you can explain is worth more than one that is merely minimal.

### R-4 — Home scroll position on back navigation

Returning from `/project_details` to a Home scrolled back to the top would badly damage J2 — the recruiter loses their place in the middle of evaluating you.

**Mitigation:** `HomeScreen` owns a `ScrollController` created in `initState`; its offset is preserved via `PageStorageKey` on the scroll view. **Explicitly verified on all three platforms**, since Web adds browser-level scroll restoration that can conflict. This is a named QA item, not an assumption.

### R-5 — Section animations firing on every scroll

Entrance animations re-triggering when a section scrolls back into view makes a page feel cheap and fights the reader.

**Mitigation:** each `SectionContainer` holds a `_hasAnimated` flag; the visibility trigger is one-shot per session.

### R-6 — RTL correctness is not automatic

Directional geometry handles most of it, but not all: timeline spines, "next project →" arrows, gallery swipe direction, and the scroll-spy's active-section math all have handedness that `Directionality` won't fix.

**Mitigation:** RTL review is a per-screen QA item, not a final pass. Anything that encodes direction (arrows, timelines, carousels) gets an explicit `Directionality.of(context)` branch.

### R-7 — Asset folder declaration is not recursive

`assets/projects/` in `pubspec.yaml` does **not** include `assets/projects/motary/`. Adding a project and forgetting the pubspec line produces a broken image with no analyzer warning.

**Mitigation:** documented in the README's "adding a project" checklist, and checked by `tool/validate_data.dart`.

### R-8 — `flutter_screenutil` on large screens

Covered in §12. Flagged here because it is the most likely thing to be implemented per the guide and look wrong on a monitor. **The clamping must be in the extension from day one**, not retrofitted after the desktop layout looks off.

### R-9 — Splash preload vs. perceived speed

Blocking on all JSON before Home renders is clean but adds latency on Web, where the engine has already cost seconds.

**Mitigation:** Splash awaits only `about.json` and `projects/index.json` (everything above the fold). The rest load per-section, each with a skeleton. **Splash has a hard 1200ms timeout** — if anything hangs, navigate anyway and let sections show their own error state. Never let a data problem trap the user on a splash screen.

### R-10 — Localized content doubles the authoring burden

Every project needs its prose written twice. Half-translated content is worse than monolingual.

**Mitigation:** `LocalizedText.resolve` falls back to `en` when `ar` is empty, so partial translation degrades rather than showing blanks. `validate_data.dart` reports every empty `ar` value as a warning. If Arabic content can't be completed, the honest move is to ship English-only in v1 and remove `Locale('ar')` from `supportedLocales` — exactly the choice the guide's §22.16 says the original got wrong by leaving both half-done.

### R-11 — Web hover on touch devices

Gating hover on `kIsWeb` gives touchscreen laptops sticky hover states and phantom effects.

**Mitigation:** `HoverScale` keys off `MediaQuery.of(context).navigationMode` / pointer kind, not platform. One widget owns the decision.

---

## 19. Consistency Review Against `ARCHITECTURE_GUIDE.md`

### Preserved

| Guide § | Convention | How it appears here |
|---|---|---|
| §2 | Clean Architecture, three layers, dependency direction | Every feature slice; §16 ownership table |
| §2.5 | Repository pattern; repos return raw values / throw, never `Either` | §8.1, §16 |
| §2.6 | Use cases: callable `BaseUseCase`, body is only `tryCatch` | `core/domain/usecases/base_usecase.dart` |
| §2.8 | Datasource abstract + `Impl` in one file | Every feature datasource |
| §3 | Cubits only, `CustomState<T>`, one field per async op, `part of` state, `Equatable`, `static get(context)` | Every cubit |
| §3.7 | `BlocBuilder` order loading → success → failure → `SizedBox`; failure always has retry | `SectionStateBuilder` enforces it |
| §4 | GetIt, single `sl`, per-feature `_init<Feature>Module()`, factories for cubits, lazy singletons for the rest, register against abstractions | §16, service_locator |
| §9 | Named routes via `onGenerateRoute`; `static const String route` on each screen; typed `<Screen>Arguments`; platform-adaptive transitions | §5, §6 |
| §11 | `Custom*` design system; never raw `Text`/`Container`/`Image` | §10.1 |
| §12 | `StringsManager` keys + runtime JSON `lang/*.json` + `.tr(context)`; loud debug miss, silent release fallback | §14, `core/localization/` |
| §12.4 | Directional geometry everywhere; font swap by language | §14, §12 |
| §13 | `AssetsManager` registry, folder declarations, no codegen | §11 |
| §14 | `*Manager`/`*Values` token classes; naming encodes value (`p16`, `s24`, `b12`, `dm300`); three color tiers | §11, §13, §15 |
| §15 | Extension DSL: `.spaceH` · `.pSymmetricH` · `.withPadding()` · `.borderAll` · `.rh`/`.rw`/`.rs`/`.rb` · `.dLog()` | `core/extensions/` |
| §17 | Full naming conventions, files and classes | Throughout |
| §18 | Code style, import order, member order, `const` constructors, `StatelessWidget` default | Throughout |
| §6.3 | Hand-written `fromJson`/`toJson`/`copyWith`, defensive parsing, **no codegen** | §8, §9 |

### Adopted from the guide's own "Missing Improvements" (§22)

| Guide § | Gap in the original | Fixed here |
|---|---|---|
| §22.1 | Zero tests | Test suite is P2 MVP scope, structure defined (§17) |
| §22.5 | Loose linter | Full rule set adopted from day one |
| §22.6 | `BuildContext` across async gaps | `use_build_context_synchronously` enabled; `mounted` checks required |
| §22.7 | Some features skip layers | **Every** slice has the full chain, uniformly (§16, R-3) |
| §22.8 | Mixed `Repo`/`Repository` naming | Standardized on `<Feature>Repository` + `repositories/` |
| §22.9 | `CustomState` in the wrong layer, not `Equatable` | Lives in `core/state/`, extends `Equatable` |
| §22.11 | Domain depends on data models | **Full entity separation** (your approved decision) |
| §22.15 | Shadows declared inline | `AppShadow` in `values_manager.dart` |
| §22.16 | `en.json` had 2 keys vs 80 in `ar.json` | Both complete; CI key-set check (§14, R-10) |
| §22.18 | `PaginatedList` controller leak | Widget not ported; controller discipline required for the scroll-spy (§10.1) |
| §22.19 | Deprecated APIs (`withOpacity`, `SvgPicture.color`) | Current APIs from the start |
| §22.21 | Thin/stale architecture docs | This spec + `ARCHITECTURE_GUIDE.md` + README |

### Removed, with justification

| Removed | Guide § | Why |
|---|---|---|
| Monorepo, 4 local packages | §1.1–1.3 | Your approved decision. The split exists to share infrastructure across apps; there is no second app. Layering is preserved by folder structure + barrels + lint |
| Networking, Dio, `ApiConsumer`, `DioConsumer` | §5.1–5.2 | No network. Removing it deletes the layer's entire reason to exist |
| Interceptors, auth headers, 401 handling, token refresh | §5.3, §22.13 | No auth, no server |
| `handelDioError`, `StatusCode` | §5.4 | No HTTP statuses to translate |
| Retry policy / backoff | §22.12 | Asset reads don't fail transiently |
| Request timeouts | §22.14 | No requests |
| Offline-first: write-through cache, offline queue, sync service | §5.6 | The app is 100% local — it is always "offline." The mechanism has no counterpart |
| `NetworkInfo`, `NetworkConnectivityCubit`, network banners | §5.7 | Connectivity is irrelevant |
| SQLite, DAOs, `local_service` feature | §1.4 | Prohibited by the brief; JSON assets replace it |
| `CacheConsumer` / `SharedPreferences` as a data store | §4.2 | **Except** one key: the saved locale. Kept for that alone |
| Full exception hierarchy (7 classes) | §8.1 | Two exceptions and two failures cover every real case: asset-missing and parse-failure |
| Pagination: `PaginatedList`, `(List<T>, int)` records, page counters | §3.3, §3.5 | Every dataset is ≤20 items, fully in memory. Pagination for 12 projects is ceremony |
| Pull-to-refresh | §3.6 | Bundled assets cannot change at runtime |
| Form widgets, validation, `CustomTextField`, dropdowns, OTP | §8.4, §11.3 | No forms — no contact form (§7.8), no auth, no filters requiring input |
| Attachment pickers, image picker, multipart | §11.4 | No uploads |
| `flutter_launcher_icons` for the guide's exact config | §13.4 | Kept, but extended to Web favicon |
| `MyApp.navigatorKey` for interceptor-driven logout | §9.5 | Kept for toasts/dialogs from non-widget code; the logout rationale is gone |
| TLS certificate bypass (`MyHttpOverrides`) | §22.3 | Was a **security defect** in the original. Never carried forward |
| Unconditional `print` in error paths | §22.4 | `.dLog()` only |
| `role`-based access branching | §9.5 | No users, no roles |

### Deliberate deviations

Three, each with a stated reason:

1. **Theme resolves through `AppColorScheme` rather than flat `static const` color access** (§15). The guide's flat statics cannot support a second theme without touching every widget, and light mode is a stated v2 requirement. Token naming, tiering, and the manager-class structure are otherwise unchanged.

2. **Responsive extensions clamp above the tablet breakpoint** (§12). The guide's unclamped `flutter_screenutil` scaling produces broken layouts on desktop monitors. Call sites are identical; only the extension internals change.

3. **A single JSON-parse memo in `LocalJsonDataSource`** (§16). Not the prohibited "cache layer" — a ~10-line `Map` on a lazy singleton with no eviction, invalidation, or persistence, justified because bundled assets are immutable for the process lifetime.

---

## Approval

This specification is complete and ready for review. Once approved, implementation begins with the P0 items in [Section 17](#17-feature-priorities), in order.

**Open items needing your input before implementation:**

1. **Fonts** — confirm Inter + IBM Plex Sans Arabic (or name your preference). Needed before the typography ladder is built.
2. **Accent color** — one accent drives the entire palette. Do you have a preference, or should I propose 2–3 options against the dark surface ladder?
3. **Project list** — which projects go in v1, and do you have cover images and screenshots for them? This gates the `projects` slice, which is the portfolio's core value.
4. **Arabic content** — will full Arabic translations exist for all content? If not, R-10's honest fallback is English-only in v1.
