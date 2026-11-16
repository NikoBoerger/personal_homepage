---
name: pre-push-dev-check
description: Before pushing anything to main in the personal_homepage repo, start the Astro dev server once and confirm the changed page renders. Use whenever Niko asks to push, deploy, "ship it", or "commit and push" in this repo, even for a one-line change like an availability date. Pushing to main deploys the live site, so the check runs first, every time.
---

# Pre-push dev server check

Pushing to `main` deploys https://niko-boerger.com via GitHub Actions. Before every push, run the dev server quickly to build the new version and prove it renders.

Only push when Niko explicitly asks for it in the moment. This skill does not authorize pushing on its own.

## Steps

1. Start the dev server in the background, fetch the homepage once it is up, then stop it:

   ```bash
   (npx astro dev --port 4399 > "$TMPDIR/astro-dev.log" 2>&1 &)
   curl -s --retry 40 --retry-connrefused --retry-delay 1 \
     -o "$TMPDIR/index.html" -w "HTTP %{http_code}\n" http://localhost:4399/
   pkill -f "astro dev --port 4399"
   grep -iE "error|warn" "$TMPDIR/astro-dev.log"
   ```

2. Check the result:
   - The response must be `HTTP 200`.
   - The log must have no errors. Node deprecation warnings are fine.
   - Grep the fetched HTML for the content you changed (for example `data-availability-date="..."`) and confirm the new value is there. If you changed `contact.astro` or `impressum.astro`, fetch `/contact` or `/impressum` too.

3. If any check fails, stop. Do not push. Report the error to Niko.

4. If everything passes, tell Niko what you verified, then commit and push to `main` as he asked. Afterwards, confirm the GitHub Actions deploy (`gh run list --limit 1`) succeeded.
