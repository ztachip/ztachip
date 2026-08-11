# ztachip web documentation

This directory builds a Sphinx/Read-the-Docs-themed site (styled like
https://spinalhdl.github.io/VexiiRiscv-RTD) from the existing docs under
`Documentation/` and `micropython/MicropythonUserGuide.md`. Nothing in those
source files needs to move — the pages under `docs/source/` just `{include}`
them, so editing the original `.md` files is still the way to update content.

Included polish, beyond a bare Sphinx default:

- A generated `ztachip` wordmark/favicon (`docs/source/_static/logo.png`,
  `favicon.ico`) — placeholders, swap in real brand assets whenever you have
  them.
- `custom.css` for a slightly less generic RTD look (accent color, hero
  block and feature cards on the landing page, nicer code blocks).
- Copy-to-clipboard buttons on code blocks (`sphinx-copybutton`).
- `sitemap.xml` generation (`sphinx-sitemap`) and a real 404 page
  (`sphinx-notfound-page`).
- "Edit on GitHub" links on every page (via `html_context`).

## Build locally

```
$ pip install -r docs/requirements.txt
$ sphinx-build -b html docs/source docs/build/html
```

Open `docs/build/html/index.html` in a browser.

## Publishing

`.github/workflows/docs.yml` builds the site on every push to `master` that
touches `docs/`, `Documentation/`, or the MicroPython guide, and publishes
the result to the `ztachip/ztachip.github.io` repository.

To enable it:

1. Create a Personal Access Token (classic, `repo` scope) for an account
   with push access to `ztachip/ztachip.github.io`.
2. Add it as a repository secret named `PAGES_DEPLOY_TOKEN` on
   `ztachip/ztachip` (Settings > Secrets and variables > Actions).
3. Make sure `ztachip.github.io` has a `master` branch (or whichever branch
   Pages is configured to serve) that serves the repo root.

## Still worth doing

- The two PDF-based pages (Programmers Guide, VisionAI Stack Programmers
  Guide) currently just embed/link the existing PDFs — converting those into
  native HTML pages is a natural next step, following the same pattern as
  `overview.md` / `hardware_design.md`.
- Swap the generated placeholder logo/favicon for real brand assets.
- If you want a custom domain, add a `CNAME` file to
  `ztachip.github.io` (peaceiris/actions-gh-pages won't remove it) rather
  than to this repo.
