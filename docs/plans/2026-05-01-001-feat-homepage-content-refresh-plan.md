---
title: "feat: Refresh homepage and contact-page content to match current profile"
type: feat
status: completed
date: 2026-05-01
origin: docs/brainstorms/2026-05-01-homepage-content-refresh-requirements.md
---

# feat: Refresh homepage and contact-page content to match current profile

## Summary

Land six content/structural changes across `src/pages/index.astro` and `src/pages/contact.astro`: refresh the hero badges and subtitle, replace the Clean Code quote with an auto-rotating four-testimonial carousel built as a new Astro component, regroup the sticky-image section into three pillars (Fullstack / Cloud & DevOps / KI), rewrite the Was/Warum/Wie + CTA copy in the PDF voice, and refresh the contact-page subtitle. No visual redesign; all text changes ship with the existing client-side i18n pattern.

---

## Problem Frame

The site's positioning has drifted from Niko's current professional profile (see origin: [`docs/brainstorms/2026-05-01-homepage-content-refresh-requirements.md`](../brainstorms/2026-05-01-homepage-content-refresh-requirements.md)). Implementation is bounded to copy edits in two pages plus one new presentational component (testimonial carousel).

---

## Requirements

- R1. Refresh hero tech-badges row (drop Clean Code, TDD; add Golang, Kubernetes, AI-tooling badge; keep core stack).
- R2. Surface Tech-Lead and 11+ years signals in hero subtitle.
- R3. Replace Clean Code quote with auto-rotating carousel of four testimonials with dot indicators.
- R4. Sticky-image section regrouped into three pillars: Fullstack-Entwicklung / Cloud & DevOps / KI-getriebenes Arbeiten.
- R5. Rewrite homepage Was/Warum/Wie + CTA copy in full PDF voice.
- R6. Rewrite contact-page subtitle paragraph in PDF voice.
- R7. KI pillar copy is affirmative; does not call out a "Clean Code matters less" thesis.
- R8. Carousel respects `prefers-reduced-motion`, supports keyboard navigation, and has German + English versions of every testimonial.
- R9. All new copy uses the existing `data-i18n-en` / `data-i18n-html-en` pattern.

---

## Scope Boundaries

- No theme / visual redesign (no new colors, fonts, or layout system).
- No Impressum copy changes.
- No new page types (case studies page, blog, project portfolio).
- No certifications, project highlight cards, header/footer/nav changes.
- No SEO meta-description language toggling — current build-time `seo` props are not language-toggled and stay German (per `CLAUDE.md`).

---

## Context & Research

### Relevant Code and Patterns

- `src/pages/index.astro` — homepage; carries hero, ThreeColumnTextSection (Was/Warum/Wie), TranslatableCustomerQuoteSection (Clean Code quote), StickyTextImageSection (Backend/Frontend/Cloud), CtaCardSection. Inline `<script>` blocks at the bottom assemble the contact info and recompute the availability badge color. Single source-of-truth date `availabilityDateStr` is unchanged by this work.
- `src/pages/contact.astro` — contact page; carries subtitle paragraph and contact info script. Build-time `seo` block is effectively dead code per `CLAUDE.md`.
- `src/components/sections/TranslatableCustomerQuoteSection.astro` — single-quote pattern using `blockquote` plus a customer name with `data-i18n-en`. Keep as-is (still present, currently the only callsite is the Clean Code quote which we are removing). New `TestimonialCarousel` component will replace this callsite without modifying the existing component.
- `src/components/sections/StickyTextImageSection.astro` — current 3-heading structure inside one slot; AI is straightforward to add as a fourth `<h3>` block. We will reorganize to three pillars rather than add a fourth.
- `src/components/sections/heros/TextAndImageHero.astro` — hero shell.
- `src/components/language-toggle/LanguageToggle.astro` — owns `data-i18n-en` / `data-i18n-html-en` translation contract; dispatches `languagechange` CustomEvent on the document. Carousel can subscribe to this if it needs to react to language switches at runtime (see U2 approach).
- `src/styles/badge.css` — defines existing badge classes (`badge`, `badge--primary`, `badge--green/yellow/red`).
- `src/styles/index.css` — aggregates all stylesheet imports; new component styles added via Astro scoped `<style>` blocks (matching existing component pattern).
- `src/components/odyssey-theme.js` — barrel export. New `TestimonialCarousel` does not need to be exported here unless we want to consume it via the `@components/odyssey-theme` alias for symmetry with other section imports. Recommendation: export it for consistency.

### Institutional Learnings

- No `docs/solutions/` directory exists in this repo; no prior learnings to apply.

### External References

- None required. Plain Astro + plain CSS + plain JS for the carousel; no new dependencies.

---

## Key Technical Decisions

- **New component, don't extend existing one.** Build `TestimonialCarousel.astro` as a new section component rather than overloading `TranslatableCustomerQuoteSection` with multi-quote behavior. Rationale: the existing component is shaped for one quote and one source line; bolting on rotation logic, an array prop, and a dot strip would make both shapes worse. The new component takes a `testimonials` array prop. Existing single-quote component stays untouched.
- **Carousel as a single Astro component with a small inline `<script>` block.** Matches the project's existing pattern (availability badge, contact info obfuscation, language toggle). No client-side framework adoption (no React/Vue/Svelte islands), no CSS-in-JS, no carousel library. Plain CSS `transition` for the slide/fade animation; plain JS `setInterval` (or `requestAnimationFrame`-driven timer) for auto-advance.
- **Reduced-motion handling skips auto-advance entirely** (does not just shorten or remove the transition). Users with `prefers-reduced-motion: reduce` see a static first testimonial and can manually switch via dot click or keyboard.
- **Language toggle integration: cache English testimonial bodies as `data-i18n-html-en` on each slide's content node** so the existing `LanguageToggle` script handles translation automatically without the carousel needing to know about language. This keeps translation logic centralized.
- **Auto-advance interval: 7 seconds.** Long enough for a reader to finish a multi-line German testimonial without rushing. Pause on hover/focus.
- **Hero subtitle pattern: two-line subtitle.** Line 1 carries the role + Tech Lead. Line 2 carries location + experience. Matches the existing two-line layout (currently "Freiberuflicher Senior Fullstack Developer" + "Hamburg, Germany").
- **Tech-badge count stays at 10** to preserve the existing wrap behavior and visual rhythm. Drops two ("Clean Code", "TDD"); adds three ("Golang", "Kubernetes", "Claude Code"); upgrades one ("Spring" → "Spring Boot").
- **Sticky-image section heading shifts** from "Technische Exzellenz von Backend bis Cloud" to "Technische Exzellenz von Backend bis KI" / "Technical Excellence from Backend to AI" — signals the new pillar inclusion in the heading itself.

---

## Open Questions

### Resolved During Planning

- Auto-advance interval: 7 seconds (decided above).
- Whether to upgrade or replace the existing single-quote component: replace at the callsite, leave the component file in place (decided above).
- Tech-badge count: 10 (decided above).
- AI badge wording: "Claude Code" rather than "Compound Engineering" or generic "AI-Tooling" — most concrete and immediately legible to visitors. Compound Engineering is mentioned in prose inside the KI pillar.

### Deferred to Implementation

- Exact CSS transition style for slide change (fade vs horizontal slide). Either is acceptable; pick during implementation based on what looks best with the existing theme.
- Exact pixel sizing of dot indicators — design-system spacing variables in `src/styles/theme.css` should drive this; choose during implementation.

---

## Implementation Units

- U1. **Refresh hero badges and subtitle**

**Goal:** Update the hero badge row and subtitle to reflect Niko's current stack and Tech-Lead positioning.

**Requirements:** R1, R2, R9.

**Dependencies:** None.

**Files:**
- Modify: `src/pages/index.astro`

**Approach:**
- Update subtitle from one role line to two-line block:
  - Line 1 (DE): `Freiberuflicher Senior Fullstack Developer & Tech Lead` (EN: `Freelance Senior Fullstack Developer & Tech Lead`).
  - Line 2 (DE): `Hamburg, Germany · 11+ Jahre Erfahrung` (EN: `Hamburg, Germany · 11+ years of experience`).
- Replace the 10 existing tech badges with the new 10:
  1. `Java / Kotlin`
  2. `TypeScript`
  3. `Golang`
  4. `Spring Boot`
  5. `Node.js`
  6. `AWS Cloud`
  7. `Kubernetes`
  8. `Microservices`
  9. `DevOps`
  10. `Claude Code`
- Use the existing `<span class="badge badge--primary">…</span>` pattern; no badge CSS changes.

**Patterns to follow:**
- Existing `<span class="badge badge--primary">` pattern in `src/pages/index.astro`.
- `data-i18n-en` translation pattern documented in `CLAUDE.md`.

**Test scenarios:**
- Happy path: load homepage in browser; the new 10 badges render in order, role line shows "& Tech Lead", second subtitle line shows "11+ Jahre Erfahrung".
- Happy path: toggle language to EN; role and experience strings switch to English versions; badges (which are language-neutral) stay unchanged.
- Edge case: at narrow viewport widths, the badge row still wraps cleanly (visual check).

**Verification:**
- Visiting the homepage shows updated badges and subtitle in both DE and EN.

---

- U2. **Build and integrate the testimonial carousel**

**Goal:** Create a new auto-rotating testimonial carousel component, populate it with all four PDF testimonials (DE + EN), and wire it into `index.astro` in place of the Clean Code quote.

**Requirements:** R3, R8, R9.

**Dependencies:** None.

**Files:**
- Create: `src/components/sections/TestimonialCarousel.astro`
- Modify: `src/components/odyssey-theme.js` (add export so the carousel is consumable via the existing barrel pattern; non-blocking, optional but recommended)
- Modify: `src/pages/index.astro` (replace the `<TranslatableCustomerQuoteSection ... quoteText="One difference between..." ... />` element with `<TestimonialCarousel testimonials={...} />`)

**Approach:**
- The component takes a `testimonials` prop: an array of `{ quoteDe: string, quoteEn: string, nameDe: string, nameEn: string, roleDe: string, roleEn: string }`.
- Render the array as a stack of slide nodes, all in the DOM, with one slide visible (`.is-active`) and the rest hidden via CSS (visibility/opacity, not display:none, so transitions can run).
- Render a row of dot buttons (one per testimonial) below the slide stack. Active dot has a different style (`.is-active`).
- Inline `<script>` block within the component handles:
  - Reading the slides and dots from the DOM.
  - Applying `is-active` to slide index 0 on load.
  - Setting up an auto-advance interval (7000 ms) that increments the active index, wrapping modulo array length.
  - Clearing/restarting the interval on dot click and on keyboard interaction (pause-and-reset, so manual nav doesn't immediately get auto-advanced).
  - Pausing the interval when the carousel is hovered or any inner element has focus, resuming on mouseleave/blur.
  - Checking `window.matchMedia('(prefers-reduced-motion: reduce)').matches` at startup; if true, skip starting the auto-advance interval (manual nav still works).
- Translation: each testimonial slide carries quote text in the German DOM and the English equivalent on `data-i18n-html-en` (use `-html-` variant because the source quote may contain typographic punctuation or `<em>` if we choose to render the role inline). The customer name and role line use `data-i18n-en`. The existing `LanguageToggle` runtime script picks these up automatically.
- Keyboard support: dots are real `<button>` elements (so they're tab-focusable and Enter/Space activate naturally). Add `aria-label` per dot ("Show testimonial 1 of 4", etc.). Add `aria-live="polite"` on the slide container so screen readers announce when content changes.
- Use `prefers-reduced-motion` media query in CSS to disable transition animations as well, in addition to the auto-advance opt-out in JS.

**Technical design:** *(directional guidance, not implementation specification)*

```
TestimonialCarousel.astro
  Container (section.testimonial-carousel)
    SlideStack (div.testimonial-carousel__slides, aria-live=polite)
      For each testimonial:
        Slide (div.testimonial-carousel__slide, .is-active on the current one)
          Blockquote (with quote text, data-i18n-html-en for English)
          Attribution (— Name, Role; data-i18n-en for both)
    DotRow (div.testimonial-carousel__dots, role=tablist optional)
      For each testimonial:
        DotButton (button.testimonial-carousel__dot, .is-active on the current one)
  <script>
    on DOMContentLoaded:
      cache slides/dots
      setActive(0)
      respect prefers-reduced-motion → maybe skip auto-advance
      start interval; pause on hover/focus; reset on dot click
  </script>
```

**Testimonials data (German source + English translation):**

1. **Markus Klußmann** — *Technical Lead bei OTTO*
   - DE: "Niko gehört fachlich wie menschlich zu den starken Entwicklern, mit denen ich zusammenarbeiten durfte. Er hat regelmäßig Verantwortung übernommen, Themen strukturiert vorangetrieben und dabei andere mitgenommen. Ich konnte mich jederzeit auf ihn verlassen. Durch seine hilfsbereite, angenehme Art war er im gesamten Team überaus geschätzt."
   - EN: "Niko is one of the strongest developers I've worked with, both technically and as a person. He consistently took ownership, drove topics forward in a structured way, and brought others along with him. I could rely on him at any time. His helpful, friendly manner made him highly valued across the whole team."
2. **Jan Wittern** — *Senior Manager Solutions bei Opitz Consulting*
   - DE: "Niko überzeugt nicht nur durch technische Exzellenz und einen hohen Qualitätsanspruch, sondern auch durch seine professionelle, positive Ausstrahlung im Kundenkontakt. Jeder unserer Kunden ist durchweg begeistert von seiner Arbeit und der Zusammenarbeit. Er agiert zuverlässig, lösungsorientiert und mit einem feinen Gespür für die Bedürfnisse unterschiedlicher Stakeholder."
   - EN: "Niko stands out not only through technical excellence and a high quality bar, but also through his professional, positive presence in client interactions. Every one of our clients has been consistently impressed with his work and the collaboration. He's reliable, solutions-oriented, and has a fine sense for the needs of different stakeholders."
3. **Martin Wepner** — *Freelance Senior Fullstack Dev · Projekt OTTO (2023–2025)*
   - DE: "In meinem Folgeprojekt merke ich gerade nochmal besonders, wie wichtig es war, jemanden wie dich im Team gehabt zu haben, der für hohe Coding-Qualität gesorgt hat. Wir verlieren hier unglaublich viel Zeit, Nerven und Geld durch schlechte Codequalität. Ich bin froh, dass ich so viel von dir lernen konnte."
   - EN: "In my follow-up project, I'm noticing again how important it was to have someone like you on the team — someone who took care of high coding quality. Here we're losing an incredible amount of time, nerves, and money to poor code quality. I'm glad I got to learn so much from you."
4. **Zeinab Labaf** — *Junior Entwicklerin*
   - DE: "Ich habe Niko als mein Mentor erlebt, der komplexe Themen mit Geduld und hoher fachlicher Qualität vermittelt. Seine positive, wertschätzende Art hat jede Session bereichert. Besonders beeindruckt haben mich seine Klarheit in der Kommunikation und sein konsequenter Anspruch an gute Lösungen."
   - EN: "I experienced Niko as my mentor, someone who teaches complex topics with patience and deep technical quality. His positive, appreciative manner enriched every session. What impressed me most was his clarity in communication and his consistent commitment to good solutions."

**Patterns to follow:**
- Inline `<script>` pattern from `src/pages/index.astro` (availability badge, contact info obfuscation) — direct DOM access, no framework, runs at end of component.
- Existing `data-i18n-html-en` / `data-i18n-en` pattern for translation.
- `LanguageToggle` `languagechange` CustomEvent on `document` — listen if anything inside the carousel needs to react at runtime (likely not needed; relying on the toggle's existing DOM-mutation pass is sufficient).
- Astro scoped `<style>` blocks at the bottom of the component file.
- Theme tokens from `src/styles/theme.css` (`--theme-surface-1`, `--theme-on-surface-2`, `--theme-primary`) for all colors.

**Test scenarios:**
- Happy path: load homepage; the first testimonial (Markus Klußmann) is visible immediately with active dot 1.
- Happy path: wait 7 seconds without interacting; the second testimonial fades in and dot 2 becomes active.
- Happy path: click dot 3; the third testimonial appears immediately and the auto-advance timer resets (next auto-advance happens 7 s after the click, not immediately).
- Happy path: toggle language to EN; all four testimonials display the English versions; the active slide stays the same; auto-advance behavior is unaffected.
- Edge case: hover the carousel for 15 seconds; the slide does not auto-advance during hover; on mouseleave the auto-advance resumes from the current slide.
- Edge case: keyboard-tab into a dot button, press Enter; that slide becomes active and the timer resets.
- Edge case: enable `prefers-reduced-motion` in the OS; load the homepage; the first testimonial is shown statically with no auto-advance and no transition animations; manual dot clicks still work and switch slides without animation.
- Edge case: at narrow viewport widths, the carousel layout (slide content, dot row) remains readable and dots don't overflow horizontally.
- Integration: navigation between dots and slides survives a language toggle mid-rotation (toggle EN → DE → click dot 4 → wait 7 s → slide 1 appears).

**Verification:**
- Component renders on the homepage in place of the Clean Code quote section.
- Auto-advance, hover-pause, dot navigation, keyboard navigation, language toggle, and reduced-motion behavior all work as enumerated above on a local dev server (`npm start`).

---

- U3. **Restructure sticky-image section into three pillars**

**Goal:** Replace the existing Backend / Frontend / Cloud-Infrastruktur subsections with Fullstack-Entwicklung / Cloud & DevOps / KI-getriebenes Arbeiten, each with new prose, and update the parent H2 heading.

**Requirements:** R4, R7, R9.

**Dependencies:** None.

**Files:**
- Modify: `src/pages/index.astro`

**Approach:**
- Update parent H2:
  - DE: `Technische Exzellenz von Backend bis KI`
  - EN: `Technical Excellence from Backend to AI`
- Pillar 1 — Fullstack-Entwicklung:
  - DE: "Mein Schwerpunkt liegt auf robusten, skalierbaren Backends mit klarer Architektur. In cross-funktionalen DevOps-Teams entwickle ich APIs, Microservices und eventgetriebene Systeme, die stabil laufen, sauber getestet sind und langfristig wartbar bleiben. Auf der Frontend-Seite habe ich unter anderem verschiedene Seiten auf [OTTO.de](https://www.otto.de) mit aufgebaut und komplexe UIs umgesetzt, die technisch sauber und robust in Produktion laufen."
  - EN: "My focus is on robust, scalable backends with a clear architecture. In cross-functional DevOps teams, I build APIs, microservices, and event-driven systems that run reliably, are thoroughly tested, and stay maintainable over the long term. On the frontend side, I&apos;ve helped build various pages on [OTTO.de](https://www.otto.de) and shipped complex UIs that run cleanly and robustly in production."
- Pillar 2 — Cloud & DevOps:
  - DE: "Infrastruktur ist für mich Teil der Software, nicht Beiwerk. In DevOps-Setups automatisiere ich Build-, Test- und Deployment-Prozesse, etabliere Trunk-Based-Development und CI/CD und baue Cloud- und Kubernetes-Umgebungen, die zuverlässig, sicher und beherrschbar sind."
  - EN: "Infrastructure is part of the software for me, not a side concern. In DevOps setups, I automate build, test, and deployment processes, establish trunk-based development and CI/CD, and build cloud and Kubernetes environments that are reliable, secure, and manageable."
- Pillar 3 — KI-getriebenes Arbeiten:
  - DE: "KI ist für mich kein Buzzword, sondern Arbeitsweise. Mit Claude Code, GitHub Copilot und Compound Engineering komme ich schneller von der Idee zum produktiven System – mit schärferer Architektur und engeren Feedback-Schleifen. Ich bringe diese Arbeitsweise ins Team und sorge dafür, dass KI nicht nur als Tool, sondern als Hebel für bessere Software wirkt."
  - EN: "AI isn&apos;t a buzzword for me, it&apos;s a way of working. With Claude Code, GitHub Copilot, and Compound Engineering, I get from idea to production faster — with sharper architecture and tighter feedback loops. I bring that way of working into the team and make sure AI acts not just as a tool but as a lever for better software."
- Use `data-i18n-html-en` for paragraphs containing inline links (Pillar 1 OTTO link); `data-i18n-en` for plain-text paragraphs (Pillar 2 and 3).
- Image (`/assets/images/devops.png`) stays — it still reads as "engineering / DevOps" and works as the visual anchor for all three pillars.

**Patterns to follow:**
- Existing `StickyTextImageSection` slot structure in `src/pages/index.astro:111-144`.
- `data-i18n-html-en` escaping rules from `CLAUDE.md` (English HTML must escape `'` as `&apos;`, etc.).

**Test scenarios:**
- Happy path: load homepage in DE; sticky section shows three pillars with H2 "Technische Exzellenz von Backend bis KI" and the OTTO link inside Pillar 1 is clickable.
- Happy path: toggle to EN; H2, all three pillar headings, and all three pillar paragraphs switch to English; OTTO link still works.
- Edge case: confirm the OTTO `<a>` link opens in a new tab (`target="_blank" rel="noopener noreferrer"`) in both languages.
- Edge case: scrolling the page exhibits the existing sticky-image behavior (image follows the heading stack).

**Verification:**
- All three pillars render in both languages; OTTO link is functional; sticky behavior is preserved.

---

- U4. **Rewrite Was/Warum/Wie + CTA copy in PDF voice**

**Goal:** Replace the existing Was/Warum/Wie three-column copy and the homepage CTA paragraph with the PDF-voice rewrite.

**Requirements:** R5, R7, R9.

**Dependencies:** None.

**Files:**
- Modify: `src/pages/index.astro`

**Approach:**
- Was?
  - DE: "Ich verbinde höchste Qualität mit echter Teamkultur. Ich bin nicht nur Entwickler, ich bin **Entstresser**. Ob Legacy-Monster, chaotisches MVP oder Grüne-Wiese-Projekt: Ich sorge mit Struktur dafür, dass nicht nur das Produkt überzeugt, sondern auch das Team, das dahintersteht."
  - EN: "I combine the highest quality with genuine team culture. I&apos;m not just a developer — I&apos;m a **de-stresser**. Whether it&apos;s a legacy monster, a chaotic MVP, or a greenfield project: I bring the structure that makes both the product convince and the team behind it."
- Warum?
  - DE (heading-area framing): keep `Warum?` heading. Body: "Wann Sie mich holen sollten:<br>Wenn Ihre Architektur Sie nachts wach hält. Wenn Ihr Team nicht liefert, sondern stöhnt. Wenn Sie jemanden suchen, der technische Exzellenz lebt und trotzdem auch mal ein GIF postet."
  - EN: "When to bring me in:<br>When your architecture keeps you up at night. When your team isn&apos;t shipping but groaning. When you&apos;re looking for someone who lives technical excellence and still posts a GIF every now and then."
- Wie?
  - DE: "Meine Mission: **Weniger Chaos, weniger Bugs, weniger Drama.** Dafür moderne Arbeitsweisen, saubere Architektur, Trunk-Based-Development und mehr entspannte Gesichter im Daily."
  - EN: "My mission: **Less chaos, fewer bugs, less drama.** In return: modern ways of working, clean architecture, trunk-based development, and more relaxed faces in the daily standup."
- CTA section (CtaCardSection):
  - DE heading: keep `Ihr Partner für Softwareprojekte`.
  - DE body: "Sie suchen jemanden, der Ihr Projekt nicht nur baut, sondern es zum Laufen bringt? Ich freue mich auf Ihre Nachricht."
  - EN body: "Looking for someone who doesn&apos;t just build your project but actually makes it run? I&apos;d love to hear from you."
- Use `data-i18n-html-en` for paragraphs containing `<strong>` or `<br>`; `data-i18n-en` for plain-text paragraphs.

**Patterns to follow:**
- Existing `ThreeColumnTextSection` slot structure in `src/pages/index.astro:83-109`.
- Existing `CtaCardSection` structure in `src/pages/index.astro:146-163`.
- `data-i18n-html-en` apostrophe escaping pattern (see `index.astro:124`).

**Test scenarios:**
- Happy path: load homepage in DE; Was/Warum/Wie show the new copy with bolded "Entstresser" and "Weniger Chaos, weniger Bugs, weniger Drama"; the `<br>` inside Warum? produces a line break.
- Happy path: toggle to EN; all three columns and the CTA body switch to English with bolded "de-stresser" and "Less chaos…"; line break preserved.
- Edge case: language toggle round-trip (DE → EN → DE) restores the original German DOM exactly (via the existing toggle cache mechanism).
- Edge case: confirm visually that none of the apostrophe entities (`&apos;`) leak as literal text in EN view.

**Verification:**
- All three columns and the CTA carry the new copy in both languages; bold and `<br>` formatting render correctly.

---

- U5. **Refresh contact-page subtitle paragraph**

**Goal:** Replace the contact-page subtitle paragraph with PDF-voice copy that opens with a "starker Partner" framing and weaves in the mission line.

**Requirements:** R6, R9.

**Dependencies:** None.

**Files:**
- Modify: `src/pages/contact.astro`

**Approach:**
- Subtitle heading: keep `Ihr Partner für Softwareprojekte` (already in PDF voice).
- Subtitle body:
  - DE: "Sie suchen einen starken Partner für Ihr Projekt? **Weniger Chaos, weniger Bugs, weniger Drama** — moderne Arbeitsweisen, saubere Architektur und mehr entspannte Gesichter im Daily.<br><br>Ich freue mich auf Ihre Nachricht."
  - EN: "Looking for a strong partner for your project? **Less chaos, fewer bugs, less drama** — modern ways of working, clean architecture, and more relaxed faces in the daily standup.<br><br>I&apos;d love to hear from you."
- Use `data-i18n-html-en` (paragraph contains `<strong>` and `<br>` tags).
- Leave the existing build-time `seo` block untouched — per `CLAUDE.md`, that code is dead at runtime.

**Patterns to follow:**
- Existing `<p data-i18n-html-en="...">` pattern in `src/pages/contact.astro:29-34`.

**Test scenarios:**
- Happy path: load `/contact` in DE; the new subtitle shows with bolded "Weniger Chaos, weniger Bugs, weniger Drama" and a paragraph break before "Ich freue mich auf Ihre Nachricht."
- Happy path: toggle language to EN; the subtitle switches to the English version with bolded "Less chaos…".
- Edge case: language toggle round-trip; original German content is restored exactly.

**Verification:**
- Visiting `/contact` in both languages shows the rewritten subtitle.

---

## System-Wide Impact

- **Interaction graph:** New `TestimonialCarousel` component listens for nothing global; it's self-contained. The existing `LanguageToggle` runtime script will pick up the carousel's `data-i18n-*` attributes automatically — no toggle change needed.
- **Error propagation:** None. All changes are presentational. If the carousel's inline script errors, it should fail closed (first slide remains visible, dots are inert) rather than break the page; explicit try/catch around the auto-advance setup is recommended but not strictly required for an isolated component.
- **State lifecycle risks:** The carousel's interval handle must be set up after `DOMContentLoaded` (Astro inline scripts default to module behavior; verify the load order during implementation).
- **API surface parity:** None. No public-facing JS API or URL change.
- **Integration coverage:** The language-toggle integration (carousel + i18n) is the only cross-cutting behavior. U2 test scenarios explicitly cover this.
- **Unchanged invariants:** Availability badge logic (`availabilityDateStr`, color computation), contact info obfuscation pattern, build-time `seo` props, GitHub Pages deployment workflow, custom-domain config (CNAME), client-side i18n contract — all unchanged.

---

## Risks & Dependencies

| Risk | Mitigation |
|------|------------|
| Carousel auto-advance feels too fast or too slow once content is in place | Picked 7 s as a reasonable default; adjustable in one place during execution if needed. |
| Language toggle does not pick up dynamically-changed slides correctly (e.g., active slide changes after language flip) | Each slide carries its own `data-i18n-*` attributes; `LanguageToggle` mutates all matching nodes regardless of active state. Covered by U2 integration test scenario. |
| `prefers-reduced-motion` skip path leaves a visually broken initial state (e.g., all slides stacked) | CSS sets the inactive slides to hidden by default (visibility/opacity); reduced-motion path simply skips the rotation, not the initial active-slide setup. |
| 10-badge row wraps awkwardly on a specific viewport width | No automated visual testing in this repo; rely on manual check during implementation. The badge-row count is unchanged from current (still 10), so layout risk is low. |
| Apostrophe escaping in `data-i18n-html-en` strings causes literal `&apos;` to leak in EN view | `CLAUDE.md` flags this explicitly; tests scenarios in U3, U4, U5 include a visual check. |
| OTTO frontend reference becomes stale-looking once it's the only frontend signal | Mitigation deferred — surfacing this as scope creep is intentional. The site preserves the link as a credibility signal; refreshing the project list itself is out of scope per Scope Boundaries. |

---

## Documentation / Operational Notes

- `CLAUDE.md` already documents the i18n contract, availability-badge mechanism, and contact-info obfuscation pattern — no doc updates required.
- Deployment is automatic via the existing GitHub Pages workflow (`.github/workflows/astro-gh-pages.yml`) on push to `main`.
- No monitoring, rollout flag, or migration concerns — this is a static-site copy update.

---

## Sources & References

- **Origin document:** [`docs/brainstorms/2026-05-01-homepage-content-refresh-requirements.md`](../brainstorms/2026-05-01-homepage-content-refresh-requirements.md)
- Niko's profile PDF: `docs/Profil Niko Börger.pdf` (testimonials, project history, voice samples)
- Project guidance: `CLAUDE.md` (i18n pattern, availability badge, deployment, scaffolding map)
- Relevant code:
  - `src/pages/index.astro` (homepage)
  - `src/pages/contact.astro` (contact page)
  - `src/components/sections/TranslatableCustomerQuoteSection.astro` (existing single-quote pattern, kept untouched)
  - `src/components/sections/StickyTextImageSection.astro` (sticky shell)
  - `src/components/language-toggle/LanguageToggle.astro` (i18n runtime)
  - `src/components/odyssey-theme.js` (component barrel)
  - `src/styles/badge.css`, `src/styles/theme.css` (existing tokens)
