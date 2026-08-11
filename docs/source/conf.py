# Configuration file for the Sphinx documentation builder.
# https://www.sphinx-doc.org/en/master/usage/configuration.html
import datetime

project = "ztachip"
copyright = f"2021 - {datetime.date.today().year}, ztachip"
author = "ztachip"

# Site is published to the root of ztachip/ztachip.github.io.
html_baseurl = "https://ztachip.github.io/"

extensions = [
    "myst_parser",
    "sphinx.ext.autosectionlabel",
    "sphinx_copybutton",
    "sphinx_sitemap",
    "notfound.extension",
]

# Allow both restructured text and markdown (myst) sources.
source_suffix = {
    ".rst": "restructuredtext",
    ".md": "markdown",
}

myst_enable_extensions = [
    "colon_fence",
]
myst_heading_anchors = 3

master_doc = "index"

templates_path = ["_templates"]
exclude_patterns = ["_build", "Thumbs.db", ".DS_Store"]

# -- Copy-button (skip the leading '$ ' shell prompt when users copy) -----
copybutton_prompt_text = r"\$ "
copybutton_prompt_is_regexp = True

# -- 404 page ---------------------------------------------------------
notfound_urls_prefix = "/"
notfound_context = {
    "title": "Page not found",
    "body": (
        "<h1>Page not found</h1>"
        "<p>The page you were looking for doesn't exist, or moved. "
        "Head back to the <a href='/'>docs home</a>.</p>"
    ),
}

# -- HTML output -------------------------------------------------------
html_theme = "sphinx_rtd_theme"
html_static_path = ["_static"]
html_css_files = ["custom.css"]
html_logo = "_static/logo.png"
html_favicon = "_static/favicon.ico"
html_title = "ztachip documentation"
html_theme_options = {
    "logo_only": True,
    "navigation_depth": 4,
    "collapse_navigation": False,
    "sticky_navigation": True,
    "style_external_links": True,
}
html_show_sourcelink = True
html_show_sphinx = True

# Keep this in sync with the GitHub repo so "Edit on GitHub" style links work.
html_context = {
    "display_github": True,
    "github_user": "ztachip",
    "github_repo": "ztachip",
    "github_version": "master",
    "conf_py_path": "/docs/source/",
}
