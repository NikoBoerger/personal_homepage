---
title: Homepage and contact-page content refresh
type: feature
status: ready-to-plan
date: 2026-05-01
---

# Homepage and contact-page content refresh

## Summary

Refresh the marketing content on `niko-boerger.com` so it matches Niko's current professional profile: AI-aware, Tech-Lead-credible, written in the direct PDF voice. Structural change: replace the static Clean Code quote with an auto-rotating testimonial carousel, regroup the sticky-image section into three pillars (Fullstack / Cloud & DevOps / KI), and rewrite the homepage and contact-page copy in the PDF voice. Tech badges refreshed to match the current stack.

---

## Problem Frame

The site copy is anchored to a positioning that has drifted from Niko's current profile:

- Tech badges show only Java/Kotlin, TypeScript, AWS, Spring, Node.js, DevOps, Microservices, RESTful, TDD, Clean Code — no Golang, no Kubernetes, no AI tooling, even though Golang is the primary language of Niko's current Babbel engagement and AI tooling (Claude Code, Compound Engineering) is now a named competency in the profile.
- Tech-Lead experience is invisible — site role is "Senior Fullstack Developer" while Niko is currently Tech Lead at Babbel and was Tech Lead during the OTTO Article Detail Page engagement (team of 11 devs).
- AI does not appear anywhere on the page despite being a core current differentiator.
- The quote slot uses a Robert C. Martin Clean Code aphorism, which both feels generic and reflects a positioning that has shifted — Niko now treats AI tooling, architecture, and team enablement as the headline value, not hand-crafted clean code.
- Voice on the site is more buttoned-up than Niko's PDF profile, which is more direct and playful ("Wenn Ihre Architektur Sie nachts wach hält", "auch mal ein GIF postet").
- The site has no testimonials, even though the profile carries four named client/colleague references (Jan Wittern, Markus Klußmann, Martin Wepner, Zeinab Labaf).
- The contact page subtitle paragraph ("Mit meinem Spezialwissen in der Umsetzung maßgeschneiderter Softwarelösungen…") is generic and does not match the rest of the refreshed voice.

---

## Requirements

- R1. Refresh the hero tech-badge row to match the current stack: keep core (Java/Kotlin, TypeScript, AWS Cloud, Spring Boot, Node.js, Microservices, DevOps), add Golang, Kubernetes, and an AI-tooling badge ("Claude Code" or "Compound Engineering"), and drop "Clean Code" and "TDD" as standalone badges.
- R2. Surface Tech-Lead credibility and 11+ years of experience in the hero (subtitle area).
- R3. Replace the static Clean Code quote section with an auto-rotating testimonial carousel that cycles through all four PDF references (Jan Wittern, Markus Klußmann, Martin Wepner, Zeinab Labaf), with dot indicators that allow manual navigation.
- R4. Add KI-getriebenes Arbeiten as a peer pillar in the sticky-image section, alongside Fullstack-Entwicklung and Cloud & DevOps. Total pillar count remains three (Fullstack folds Backend + Frontend; Cloud & DevOps absorbs DevOps content).
- R5. Rewrite the Was/Warum/Wie copy and the CTA section copy on the homepage in the full PDF voice, including the playful asides ("auch mal ein GIF postet", "Wenn Ihre Architektur Sie nachts wach hält"), and weave in "Weniger Chaos, weniger Bugs, weniger Drama".
- R6. Rewrite the contact-page subtitle paragraph in the same PDF voice.
- R7. The page does not call out the "Clean Code matters less now with AI" thesis explicitly. The KI-getriebenes Arbeiten pillar is written affirmatively (what AI tooling enables), without commentary on what now matters less.
- R8. The testimonial carousel respects `prefers-reduced-motion`, supports keyboard navigation, and integrates with the project's existing client-side i18n pattern so each testimonial has a German source and an English translation.
- R9. All new copy follows the existing `data-i18n-en` / `data-i18n-html-en` translation pattern documented in `CLAUDE.md`.

---

## Scope Boundaries

- No visual / theme redesign — no new layout, colors, fonts, or component visual style beyond what the testimonial carousel needs.
- No Impressum copy changes.
- No new page types (case studies page, blog, project portfolio).
- No certifications shown on the page (A-CSD, CSD/CSM, ISTQB CTFL).
- No dedicated project highlight cards (Babbel Streaks, OTTO Reviews) as a new section.
- No header / footer / navigation changes.
- No SEO meta-description rewriting beyond what naturally falls out of the role-line update (the build-time `seo` props are not language-toggled, per `CLAUDE.md`).

---

## Key Decisions

- Replace, don't redirect: the existing `TranslatableCustomerQuoteSection` is single-quote-shaped. Build a new `TestimonialCarousel` component rather than overloading the existing component with multi-quote behavior. Rationale: simpler component contracts, no risk of breaking the existing single-quote callsite if it gets reused elsewhere later.
- 3-pillar split is **Fullstack-Entwicklung / Cloud & DevOps / KI-getriebenes Arbeiten**, not Backend/Frontend/Cloud. Rationale: matches the "Senior Fullstack" headline, keeps Cloud & DevOps as a peer pillar (a real strength, listed across every recent project), and elevates AI to peer status.
- Voice level is full PDF voice including "auch mal ein GIF postet". Rationale: filters for modern/startup clients; user explicitly chose the full level.
- Hero subtitle picks up both signals: "& Tech Lead" in the role line and "11+ Jahre Erfahrung" near the location. Both are present in the PDF.
- "Clean Code" and "TDD" come down from the headline-tier badges but the underlying values are not denied — they live on inside the prose where useful.

---

## Outstanding Questions

None blocking — open implementation questions (carousel timing, exact label wording for the AI badge, exact phrasing of the Was/Warum/Wie rewrite) are deferred to the plan and execution.
