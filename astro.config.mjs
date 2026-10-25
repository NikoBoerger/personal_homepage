import { defineConfig } from 'astro/config';
import sitemap from "@astrojs/sitemap";
import mdx from "@astrojs/mdx";
import icon from "astro-icon";
import lit from "@astrojs/lit";

const noindexPages = [
  'https://niko-boerger.com/apps/madhouse/impressum/',
  'https://niko-boerger.com/apps/dartprotrainingsheet/impressum/',
];

// https://astro.build/config
export default defineConfig({
  site: 'https://niko-boerger.com/', // Your public domain, e.g.: https://my-site.dev/. Used to generate sitemaps and canonical URLs.
  output: 'static', // Für GitHub Pages statisches Export-Format
  integrations: [sitemap({ filter: (page) => !noindexPages.includes(page) }), mdx(), lit(), icon()], // Add renderers to the config
});
