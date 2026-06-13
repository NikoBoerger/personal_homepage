---
title: "feat: Migrate DartProTrainingSheet and Madhouse homepages into the Astro site under /apps"
type: feat
date: 2026-06-12
status: ready
origin: none (solo planning; no upstream brainstorm)
depth: standard
---

# feat: Migrate app homepages into the Astro site under `/apps`

## Summary

Bring the two standalone app marketing/support pages — **DartProTrainingSheet** and **Madhouse** — into this Astro site as self-contained micro-sites served at `/apps/dartprotrainingsheet/` and `/apps/madhouse/`. Each app page set looks and feels like its own site: its own brand color, its own header/footer, its own in-app navigation, and **no links, nav, or branding from the personal `niko-boerger.com` site**. The pages are rebuilt fresh as Astro components (the DartPro original is a Nicepage export carrying ~1.8 MB of jQuery + `nicepage.css`/`.js` that we drop entirely). Content is ported faithfully — a modern visual refresh, not a copy rewrite.

Confirmed scope decisions:
- **English only** — both source homepages are English today; no `data-i18n` wiring on app pages.
- **DartPro keeps its Google Play badge**; Madhouse gets **no download button yet** (it ships on iOS + Android but has no public store link in hand).
- **Modern refresh, same content** — clean styling + per-app brand color, existing copy and sections preserved.

---

## Problem Frame

Two apps currently have homepages that live as loose artifacts in their app repos and are not deployed through any maintained pipeline:

- **DartProTrainingSheet** — `dart_pro_training_sheet_android/homepage/nicepage/` — a Nicepage (visual builder) export: `index.html`/`Home.html` (hero), `Privacy-Policy.html`, `Delete-Account.html`, plus 1.4 MB `nicepage.css`, 360 KB `nicepage.js`, and `jquery.js`. Android-only app; Google Play id `de.nikoboerger.darttraining`.
- **Madhouse** — `madhouse_darts/homepage/` — hand-written `home.html` (About / Upcoming Features / Contact) and `privacy_policy.html`. Flutter app on iOS + Android (`de.nikoboerger.madhouse_darts`), launched Sept 2025. The home header still shows a leftover placeholder title `MyApp Support`.

The personal site is a maintained, auto-deployed Astro static site (push to `main` → GitHub Pages → `niko-boerger.com`). Folding the app pages in gives them the same build, hosting, and HTTPS for free — but only if they are presented as **their own sites under their own path**, not as sub-pages of the freelancer homepage.

The challenge: the site's normal page layer (`Page.astro`) injects the personal `Header` (Home/Kontakt nav, language toggle) and `Footer` (Niko Börger branding, socials, "showPlug"). App pages must bypass that entirely and supply their own chrome.

---

## Requirements

- **R1** — App pages reachable at `/apps/dartprotrainingsheet/` and `/apps/madhouse/` (trailing-slash directory URLs from Astro static output).
- **R2** — No links, nav entries, footer items, logo, or copy referencing the personal `niko-boerger.com` site appear *in the rendered app pages*. Each app subtree links only within itself. Two hosting-level exceptions are inherent to serving under one domain on GitHub Pages and are documented in Risks rather than solved here: the shared global `404.html` (a mistyped `/apps/...` URL shows the personal 404) and sitemap co-listing. Canonical URLs legitimately resolve on `niko-boerger.com` because the pages genuinely live there (see KTD1a).
- **R3** — Each app reads as its own site: own brand color, own header (app logo + name + in-app nav), own footer, own favicon and `<title>`/meta.
- **R4** — Content ported faithfully from the source homepages, English only:
  - DartPro: Home (hero with Google Play badge + screenshot), Privacy Policy, Delete Account.
  - Madhouse: Home (About, Upcoming Features, Contact), Privacy Policy.
- **R5** — The DartPro `Delete Account` page is preserved (Google Play account-deletion requirement).
- **R6** — Email (`apps.nikoboerger@gmail.com`) assembled client-side via the existing obfuscation pattern; server-rendered placeholder reads `[Please enable Javascript]`.
- **R7** — The Nicepage runtime (jQuery, `nicepage.css`, `nicepage.js`) is **not** carried over.
- **R8** — Existing personal pages (`index.astro`, `contact.astro`, `impressum.astro`, `404.astro`) and the deploy workflow (CNAME, `gh-pages`) are unchanged.
- **R9** — `npm run build` succeeds and emits the five new pages into `dist/apps/...`.

Success criteria: visiting each app URL after build shows the ported content, brand-colored and standalone, with working in-app nav and a JS-assembled contact email, and zero personal-site references.

---

## Key Technical Decisions

### KTD1 — A dedicated standalone `AppLayout.astro`, not `Page.astro`/`Base.astro`

`Page.astro` hard-wires the personal `Header` + `Footer`; `Base.astro` → `BaseHead.astro` hard-codes `<link rel="icon" href="/favicon.png">` and imports `styles/index.css` (which pulls `theme.css` setting the personal brand tokens). Reusing either would leak personal branding and the wrong favicon. Decision: a **new, self-contained `src/layouts/AppLayout.astro`** that renders its own `<html><head>` and brand-colored header/footer, parameterized per app. It imports only baseline `reset.css` + `typography.css` (fonts/reset, no brand tokens) and sets an `--app-primary` custom property per app. Rationale: cleanest path to genuine standalone feel, per-app favicon/`theme-color`/SEO, and zero risk of personal-site bleed. Trade-off: a small amount of head boilerplate duplicated from `BaseHead.astro`, accepted because the app pages intentionally diverge.

### KTD2 — Centralize per-app metadata in `src/config/apps.js`

Brand color, app display name, contact email, favicon path, Google Play URL, and the in-app nav link list are identical-shape data for both apps. Put them in one `src/config/apps.js` map (mirroring the existing `src/config/nav.js`/`footer.js` convention) so `AppLayout` and the pages read from a single source. Two apps is enough repetition to justify it and it keeps nav/footer consistent within each subtree.

### KTD1a — App pages own their head metadata; `og:image` never falls back to the personal headshot

`AppLayout` writes its own `<head>` and must **not** reuse `BaseHead.astro`'s defaults, which set `og:image` to `/assets/images/profile_pic.jpg` and build canonical/OG URLs from `Astro.site` (`https://niko-boerger.com/`). Decision: each app page sets `og:image`/`twitter:image` to its own app icon/logo (never `profile_pic.jpg`); `<title>`, description, `theme-color`, and favicon are app-specific. Canonical and `og:url` are allowed to resolve on `niko-boerger.com/apps/...` because the pages truly live there — that is accurate, not a branding leak. The R2 grep guard (Verification Strategy) is extended to also assert no `profile_pic` appears in app-page `<head>` output.

### KTD3 — Rebuild content as semantic Astro markup; drop Nicepage entirely

The DartPro `u-*` class soup and `nicepage.css` are not portable or maintainable. Re-author the hero, privacy, and delete-account content as plain semantic HTML in `.astro` files styled by a small scoped CSS block / shared `app.css`. Madhouse is already simple hand-written HTML and ports almost directly. This satisfies R7 and the "design can change, stays modern" intent.

### KTD4 — Assets copied into `public/assets/apps/<app>/`

Static images (DartPro `app_logo.png`, screenshot `11.png`, `google-play-badge.png`; Madhouse `app_icon.png`) go under `public/` so they are served verbatim and referenced by absolute path (`/assets/apps/...`), matching how the personal site references `/assets/images/...`. The DartPro screenshot `11.png` is 566 KB; copied as-is (optimization deferred — see Scope Boundaries).

### KTD5 — Fix the Madhouse placeholder title during migration

The Madhouse `home.html` header reads `MyApp Support` (a builder leftover). Migrate it as `Madhouse`. This is a faithful-intent fix, not new content.

### KTD6 — Sitemap inclusion accepted

`@astrojs/sitemap` will auto-include the new pages in `niko-boerger.com`'s sitemap. Accepted as-is (the pages are public anyway). No exclusion config added.

---

## High-Level Technical Design

Routing and layout relationships (new files in **bold**):

```
src/pages/apps/
  dartprotrainingsheet/
    index.astro            → /apps/dartprotrainingsheet/          (hero + Google Play badge + screenshot)
    privacy.astro          → /apps/dartprotrainingsheet/privacy/
    delete-account.astro   → /apps/dartprotrainingsheet/delete-account/
  madhouse/
    index.astro            → /apps/madhouse/                      (About / Upcoming Features / Contact)
    privacy.astro          → /apps/madhouse/privacy/

      every *.astro page above
              │ imports
              ▼
   src/layouts/AppLayout.astro   ── reads ──▶  src/config/apps.js  (brand, name, navLinks, faviconPath, ogImagePath, playUrl)
       │ renders                                    
       ├─ <head> (own charset/viewport/title/desc/favicon/theme-color; og:image = app icon)
       ├─ skip-link + <header> brand-colored: logo + app name + in-app nav 
       ├─ <main id="content"><slot/></main>  (page content)                              
       └─ <footer> "© <year> <app>" + obfuscated email (parts inlined in script)
       imports: styles/reset.css + styles/app.css (self-contained fonts; NOT typography.css/theme.css)
```

Each app subtree is a closed graph: nav links resolve only to sibling pages within the same `/apps/<app>/` path. `AppLayout` never imports `odyssey-theme` `Header`/`Footer`, `Page.astro`, or `BaseHead.astro`, which is what structurally guarantees R2.

---

## Output Structure

```
src/
  layouts/
    AppLayout.astro          (new)
  config/
    apps.js                  (new)
  styles/
    app.css                  (new — shared app chrome + self-contained typography/fonts)
  pages/
    apps/                    (new dir)
      dartprotrainingsheet/
        index.astro
        privacy.astro
        delete-account.astro
      madhouse/
        index.astro
        privacy.astro
public/
  assets/
    apps/                    (new dir)
      dartprotrainingsheet/
        app_logo.png
        screenshot.png       (from nicepage/images/11.png)
        google-play-badge.png
        favicon.png          (fallback to app_logo.png if none exists)
      madhouse/
        app_icon.png
```

The per-unit **Files** lists below are authoritative; this tree is the scope-shape overview.

---

## Implementation Units

### U1. App layout, config, and shared styles

**Goal:** Establish the standalone chrome every app page renders through.

**Requirements:** R2, R3, R6, R7 (foundation), KTD1, KTD2.

**Dependencies:** none.

**Files:**
- `src/layouts/AppLayout.astro` (new)
- `src/config/apps.js` (new)
- `src/styles/app.css` (new)

**Approach:**
- `apps.js` exports a map keyed by app slug, each entry: `{ name, brandColor, brandColorDark, faviconPath, ogImagePath, playUrl?, navLinks: [{ title, href }] }`. `navLinks` hrefs are absolute in-subtree paths (e.g. `/apps/dartprotrainingsheet/privacy/`). DartPro `playUrl` = `https://play.google.com/store/apps/details?id=de.nikoboerger.darttraining`; Madhouse omits `playUrl`. **No `email` field** — see the obfuscation note below.
- `AppLayout.astro` props: `app` (slug) and `seo` (`{ title, description }`). It looks up the app entry and renders a full `<html lang="en">` document. The `<head>` must explicitly include: `<meta charset="utf-8">`, `<meta name="viewport" content="width=device-width">` (the mobile stacked layouts depend on it), `<title>` + description, `<link rel="icon">` from `faviconPath`, `<meta name="theme-color">` = brandColor, canonical/`og:url` on the real `niko-boerger.com/apps/...` URL, and `og:image`/`twitter:image` = `ogImagePath` (the app icon/logo — **never** `profile_pic.jpg`; see KTD1a). It does **not** route through `BaseHead.astro`. Body: a skip-link to `#content` (mirroring `Base.astro`, which `AppLayout` replaces), a brand-colored `<header>` (app logo + name + `navLinks`), `<main id="content"><slot/></main>`, and a `<footer>` with `© <currentYear> <name>` + an obfuscated-email placeholder span.
- **Responsive header nav:** no JavaScript hamburger needed. The 2-3 short nav links sit in a flex row that wraps (or centers below the app name) on narrow viewports. Specify this in `app.css` so both apps behave consistently; document that this intentionally replaces the source Nicepage off-canvas menu.
- Brand color is exposed as `--app-primary` / `--app-primary-dark` on a wrapper element so page-level scoped CSS and `app.css` can consume it. Verify brand colors used as foreground (links, headings on white) meet WCAG AA — `#137177` is ~4.6:1 on white (AA for large text, borderline for body); use `#0A2F51` navy for body-weight text/links where contrast is tight, and reserve the lighter brand tone for large headings and accents.
- Email obfuscation: render `<span id="app-mail-placeholder">[Please enable Javascript]</span>` and an inline `<script>` that assembles `apps.nikoboerger@gmail.com` from split parts into a `mailto:` link (mirror `impressum.astro:39-51`). The split parts live **only inside the inline script** (not as a plain string in `apps.js` or in server-rendered markup), preserving scraper deterrence. The email is identical for both apps, so it is intentionally not data-driven.
- **Styling / fonts (do not import `typography.css`):** `typography.css` is not self-contained — its `html`/`body` and heading rules consume `--theme-font-family-sans`, `--theme-font-family-serif`, and `--theme-on-bg`, which are defined only in `theme.css`. Importing `typography.css` without `theme.css` leaves those `var()` calls unresolved and renders app pages in the browser default font, the opposite of the intended refresh. Therefore `AppLayout` imports `reset.css` only, and `app.css` carries its own self-contained typography: the needed `@font-face` declarations (or a reused subset pointing at the existing `/assets/fonts/` woff2 files) plus `font-family`/heading/link rules written against literal values or `--app-*` tokens. Do **not** import `theme.css` or `index.css` (personal brand tokens).
- Page copy must contain no em dash characters (project rule).

**Patterns to follow:**
- Layout slots + props: `src/layouts/Base.astro`, `src/layouts/Page.astro`.
- Head/SEO/OG construction: `src/components/head/BaseHead.astro`.
- Config-as-data: `src/config/nav.js`, `src/config/footer.js`.
- Email obfuscation: `src/pages/impressum.astro:39-51`.

**Test scenarios:** Test expectation: none for unit tests — repo has no test/lint/typecheck harness (per CLAUDE.md). Verify by:
- `npm run build` compiles `AppLayout.astro` with no Astro errors.
- A throwaway smoke page (or U3/U4) rendering through `AppLayout` shows the brand-colored header/footer and contains zero `odyssey-theme`/personal-nav markup in the built HTML (`grep -L "Kontakt\|odyssey\|profile_pic" dist/apps/...`).

**Verification:** `AppLayout` builds; output `<head>` carries the app favicon/theme-color and no personal-site nav/footer markup is present in pages that use it.

---

### U2. Copy and organize app assets

**Goal:** Make app images available as static assets under `public/`.

**Requirements:** R4 (assets), KTD4.

**Dependencies:** none (can run parallel to U1).

**Files:**
- `public/assets/apps/dartprotrainingsheet/app_logo.png` (from `dart_pro_training_sheet_android/homepage/nicepage/images/app_logo.png`)
- `public/assets/apps/dartprotrainingsheet/screenshot.png` (from `nicepage/images/11.png`)
- `public/assets/apps/dartprotrainingsheet/google-play-badge.png` (from `nicepage/images/google-play-badge.png`)
- `public/assets/apps/dartprotrainingsheet/favicon.png` (use `app_logo.png` if no dedicated favicon exists in source — the source `favicon.png` is referenced but absent)
- `public/assets/apps/madhouse/app_icon.png` (from `madhouse_darts/homepage/images/app_icon.png`)

**Approach:** Copy files into the new `public/assets/apps/<slug>/` directories. Rename `11.png` → `screenshot.png` for clarity. Confirm the DartPro favicon source: the nicepage HTML references `images/favicon.png` but the images dir contains only `11.png`, `app_logo.png`, `google-play-badge.png` — fall back to `app_logo.png` as the favicon and note it. Confirm `madhouse_darts/homepage/images/app_icon.png` exists before U4 references it.

**Alt text (decide here, used by U3/U4):** app logo / icon → the app name (e.g. `"Dart Pro Training Sheet"`, `"Madhouse"`); DartPro screenshot → a short descriptive string (e.g. `"Dart Pro Training Sheet app screenshot"`); Google Play badge → the Google-mandated `"Get it on Google Play"`.

**Patterns to follow:** existing `public/assets/images/` layout and absolute `/assets/...` references.

**Test scenarios:** Test expectation: none (static files). Verify all referenced asset paths resolve in `dist/` after build (no 404s in `npm run preview`).

**Verification:** Each image referenced by U3/U4 exists at its `/assets/apps/...` path in `dist/`.

---

### U3. DartProTrainingSheet pages

**Goal:** Build the three DartPro pages through `AppLayout`.

**Requirements:** R1, R2, R3, R4, R5, R6, R9.

**Dependencies:** U1, U2.

**Files:**
- `src/pages/apps/dartprotrainingsheet/index.astro` (new)
- `src/pages/apps/dartprotrainingsheet/privacy.astro` (new)
- `src/pages/apps/dartprotrainingsheet/delete-account.astro` (new)

**Approach:**
- **index** — hero ported from `nicepage/index.html`: H1 "Practice Routine Darts", subtitle "Dart Pro Training Sheet", lead "Improve your skills with this extensive Darts Pro Training Sheet", the app screenshot, and the Google Play badge linking to `playUrl` (from `apps.js`, `target="_blank" rel="noopener"`). Two-column on wide screens, stacked on mobile, brand blue `#478ac9`.
- **privacy** — port the full privacy text verbatim from `nicepage/Privacy-Policy.html` (Information Collection and Use, third-party links to Google Play Services / AdMob / Firebase Analytics / Crashlytics, Log Data, Cookies, Service Providers, Security, Links to Other Sites, Children's Privacy, Changes, Contact). Preserve effective date `2020-10-25`. External third-party links keep `target="_blank" rel="noopener"`. **Assumption (owner's call):** verbatim porting assumes the source text still accurately describes the current app's data practices and that the 2020 effective date need not be refreshed. Confirming accuracy and whether to re-date the policy is the app owner's decision, outside this migration's scope.
- **delete-account** — port `nicepage/Delete-Account.html`: "Request Data Deletion" heading + instructions to email (obfuscated) + "name the Google account used to sign in" note.
- All three set `seo` title/description and pass `app="dartprotrainingsheet"` to `AppLayout`. In-app nav (Home / Privacy Policy / Delete Account) comes from `apps.js`.
- No em dashes in copy.

**Patterns to follow:** `AppLayout` usage per U1; legal-text section structure similar to `impressum.astro`.

**Test scenarios:** Test expectation: none (unit). Manual/build verification:
- Build emits `/apps/dartprotrainingsheet/`, `/apps/dartprotrainingsheet/privacy/`, `/apps/dartprotrainingsheet/delete-account/`.
- Hero Google Play badge href = `https://play.google.com/store/apps/details?id=de.nikoboerger.darttraining`.
- With JS disabled, contact/delete email shows `[Please enable Javascript]`; with JS enabled it renders a `mailto:apps.nikoboerger@gmail.com` link.
- In-app nav links stay within `/apps/dartprotrainingsheet/`; no link points to `/`, `/contact`, or `/impressum`.
- Built HTML contains no `nicepage`, `jquery`, or `u-` class references.

**Verification:** All three URLs render branded, standalone, with working badge + obfuscated email and self-contained nav.

---

### U4. Madhouse pages

**Goal:** Build the two Madhouse pages through `AppLayout`.

**Requirements:** R1, R2, R3, R4, R6, R9.

**Dependencies:** U1, U2.

**Files:**
- `src/pages/apps/madhouse/index.astro` (new)
- `src/pages/apps/madhouse/privacy.astro` (new)

**Approach:**
- **index** — port `madhouse_darts/homepage/home.html`: app icon, "About Madhouse" paragraph, "Upcoming Features" list (Dart Bot, Improved 2-Player View, Individual Player Settings, Improved Match Summary, Deletion of Matches, Statistic Filters, Cricket), "Contact Support" with obfuscated email. Header title is **Madhouse** (fixes the `MyApp Support` placeholder, KTD5). Brand teal `#137177`, headings navy `#0A2F51`. **No download button** (confirmed decision). **Responsive layout:** centered single-column content with a max-width container (mirror the source's centered card layout); the app icon sits centered above the About section. No two-column hero (it has no screenshot or store badge to pair).
- **privacy** — port `madhouse_darts/homepage/privacy_policy.html` verbatim: Information We Collect (Firebase Analytics), How We Use It, Third-Party Services, Data Retention, Your Choices, Contact. Preserve effective date `06.09.2025`. External links keep `target="_blank" rel="noopener"`. **Assumption (owner's call):** same verbatim-accuracy caveat as DartPro privacy above.
- Both pass `app="madhouse"` to `AppLayout`; in-app nav (Home / Privacy Policy) from `apps.js`. No em dashes in copy.

**Patterns to follow:** same as U3.

**Test scenarios:** Test expectation: none (unit). Manual/build verification:
- Build emits `/apps/madhouse/` and `/apps/madhouse/privacy/`.
- Header shows "Madhouse", not "MyApp Support".
- No download/store badge present on the Madhouse pages.
- Obfuscated email behaves as in U3.
- In-app nav stays within `/apps/madhouse/`; no personal-site links.

**Verification:** Both URLs render branded, standalone, content-faithful, no store button, self-contained nav.

---

## Scope Boundaries

**In scope:** the five app pages, `AppLayout`, `apps.js`, `app.css`, asset copy, and the placeholder-title fix.

**Out of scope / non-goals:**
- Changing any personal page (`index`, `contact`, `impressum`, `404`) or adding links between the personal site and the app pages (neither direction was requested).
- Deploy-workflow changes (CNAME, `gh-pages`, custom domains/subdomains for the apps — they live under the existing domain path).
- Bilingual DE/EN on app pages (decided English-only).
- A Madhouse download button / store-badge wiring (deferred until store URLs are in hand).

### Deferred to Follow-Up Work
- **Madhouse store badges** — add Play + App Store CTAs once the public store URLs are available; `apps.js` already has a `playUrl` slot to extend.
- **Image optimization** — DartPro `screenshot.png` is ~566 KB; consider compressing or moving to Astro's `<Image>`/assets pipeline later.
- **Per-app OG/share images** — currently reuse app icon/logo; dedicated social cards could be added.
- **Removing the source homepages** from the app repos once these are live (separate repos, owner's call).

---

## Risks & Dependencies

- **Personal-branding bleed (primary risk).** Mitigated structurally by KTD1: `AppLayout` imports none of `odyssey-theme`, `Page.astro`, or `BaseHead.astro`. Verify with a grep over built `dist/apps/**` for `Kontakt`, `odyssey`, `profile_pic`, and personal footer text.
- **Typography token coupling (resolved in U1).** `typography.css` depends on `--theme-*` tokens defined only in `theme.css`; importing it without `theme.css` would render app pages in the browser default font. U1 resolves this by importing `reset.css` only and giving `app.css` self-contained fonts/typography. Verify app pages render in the intended fonts during preview, not just that the build passes.
- **404 boundary (accepted limitation).** GitHub Pages serves a single global `404.html`. A mistyped `/apps/<app>/...` URL therefore shows the personal, German `404.astro` (personal Header/Footer, "Zur Startseite" → `/`), which breaks the standalone illusion for that error path. Accepted as a known limit of path-based hosting under one domain; a neutral/app-aware 404 is out of scope (would require changing the shared 404). Mitigate by keeping in-app links correct so the 404 is only hit on external typos.
- **`og:image` / canonical bleed.** Without explicit head values, `BaseHead`'s defaults would point `og:image` at the personal headshot and canonical at the personal domain. Resolved by KTD1a + the U1 head checklist; enforced by the extended grep in Verification.
- **Sitemap leak of intent** — app pages appear in the personal sitemap (KTD6, accepted).
- **Missing DartPro favicon source** — handled in U2 (fall back to `app_logo.png`).
- No runtime/back-end dependencies; pure static additions. Existing deploy pipeline carries them automatically on push to `main`.

---

## Verification Strategy

1. `npm run build` succeeds and `dist/apps/{dartprotrainingsheet,madhouse}/...` contains all five pages.
2. `npm run preview` — manually load each URL: brand color correct, header/footer standalone, in-app nav works, no personal-site links, all images load.
3. JS-off vs JS-on check on the email obfuscation.
4. `grep -ri "nicepage\|jquery\|odyssey\|Kontakt\|profile_pic" dist/apps` returns nothing (the `profile_pic` check covers `<head>` `og:image`, catching a personal-headshot leak).
5. Confirm personal pages still build and render unchanged.

(There is no automated test/lint/typecheck harness in this repo; verification is build + manual preview, consistent with how the rest of the site is maintained.)
