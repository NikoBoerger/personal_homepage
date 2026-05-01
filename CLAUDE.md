# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Personal/freelancer marketing site for Niko Börger, deployed at https://niko-boerger.com. Originally based on the "
Odyssey Theme" (Astro starter); much of the upstream theme scaffolding (`src/components/odyssey-theme.js`, blog/form
components, theme switcher) is still present but unused by the live pages. The actual site is just
`src/pages/index.astro`, `src/pages/contact.astro`, and `src/pages/impressum.astro`.

## Commands

```bash
npm install
npm start          # = astro dev (local dev server)
npm run build      # static build into ./dist
npm run preview    # serve the built site
npm run format     # prettier -w .
```

There is no test suite, no linter, and no typechecker wired into npm scripts. `tsconfig.json` defines path aliases (
`@components/*`, `@layouts/*`, `@config`, `@styles/*`, etc.) used throughout.

## Deployment

Pushing to `main` triggers `.github/workflows/astro-gh-pages.yml`, which runs `npm ci && npm run build` and publishes
`./dist` to the `gh-pages` branch via `peaceiris/actions-gh-pages`. The `cname: niko-boerger.com` line in that
workflow (and `public/CNAME`) configures the custom domain — don't drop them.

`astro.config.mjs` sets `output: 'static'` and `site: 'https://niko-boerger.com/'` (used for sitemap/canonical URLs).

## Development
- Work with trunk-based-development directly on the main
- Do not commit yourself or create branches or push!! Leave that to the developer.
- Benutze niemals diese Striche: — (em dash) in Text.

## Architecture

### Client-side i18n (the most load-bearing pattern)

The site has no per-locale routes. German is the source of truth in the markup; English is provided as data attributes
and swapped in the browser by `src/components/language-toggle/LanguageToggle.astro`.

- `data-i18n-en="..."` — replaces `textContent` when language flips to EN.
- `data-i18n-html-en="..."` — replaces `innerHTML` (use this when the German source contains tags like `<strong>` or
  `<a>`; the English HTML must escape quotes/apostrophes as `&apos;` etc. — see `index.astro:124`).
- `data-i18n-de` / `data-i18n-html-de` — optional explicit DE override; otherwise the original DOM content is cached on
  first switch and restored on switch back.
- The toggle persists choice in `localStorage` under `preferred-language` (default `de`), updates `<html lang>`, and
  dispatches a `languagechange` CustomEvent.

When adding new copy, default to writing the German in the markup and providing English via `data-i18n-en` /
`data-i18n-html-en`. Nav and footer entries instead carry `titleEn` in `src/config/nav.js` / `src/config/footer.js` and
the `Header`/`Footer` components apply `data-i18n-en` themselves.

Page `<title>` and `<meta description>` are passed via the `seo` prop to `Page.astro` and are **not** translated — the
`if (typeof window !== 'undefined')` block in `contact.astro` runs at build time on the server and is effectively dead
code.

### Availability badge

`src/pages/index.astro` has a single source-of-truth date:

```ts
const availabilityDateStr = '2026-07-01';
```

An inline script at the bottom of that file recomputes the badge color on page load from the difference (in months)
between that date and `new Date()`:

- `< 2 months out` → `badge--green`
- `2–6 months out` → `badge--yellow`
- `>= 6 months out` → `badge--red`

To update availability, change `availabilityDateStr` only — both the German and English formatted dates are derived from
it via `toLocaleDateString`. Color classes live in `src/styles/badge.css`.

### Contact info obfuscation

Email and phone are assembled in inline `<script>` blocks in `index.astro` and `contact.astro` to deter scrapers —
placeholders read `[Please enable Javascript]` server-side. Keep this pattern when adding new contact surfaces.

### Layout chain

`Base.astro` (head + skip link + slots) → `Page.astro` (adds `Header` with `LanguageToggle` slot + `Footer`) →
individual `*.astro` pages. Use `Page.astro` for normal pages; `Post.astro` exists for blog posts but the blog isn't
currently published.

### Styling

Plain CSS in `src/styles/` (`reset.css`, `theme.css`, `typography.css`, `badge.css`, `global.css`, aggregated by
`index.css`). No Tailwind, no CSS-in-JS. Theme tokens are CSS custom properties (`--theme-primary`, `--theme-surface-1`,
`--theme-on-surface-2`, etc.); prefer those over hard-coded colors when adding components.

### Unused upstream scaffolding

`src/components/{blog,buttons,cards,forms,form-fields,theme-switcher}` and most `sections/*` are leftover from the
Odyssey theme. Empty dirs (`src/locales`, `src/pages/en`, `docs`) are not load-bearing. Don't assume something is wired
up just because the file exists — check whether it's actually imported by `index.astro` / `contact.astro` /
`impressum.astro` before editing.

## Personal Information

- See [Profil Niko Börger.pdf](docs/Profil%20Niko%20Bo%CC%88rger.pdf) for a detailed overview of Niko's background,
  skills, and experience.
- How Niko wants to come across:
    - Not just a normal Senior Fullstack Developer, but also a strategic partner for clients, helping them navigate
      complex technical decisions and align them with their business goals.
    - Actively improves team processes and communication.
    - Strong focus on quality
    - Modern ways of working (trunk-based-development, CI/CD, Cloud, etc..)
    - Working with AI