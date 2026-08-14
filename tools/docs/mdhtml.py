#!/usr/bin/env python3
"""Build styled HTML pages from the documentation Markdown.

The output directory is self-contained: images are copied in beside the pages
and links to repository files are rewritten to github.com, so the same build
works opened from disk and published to GitHub Pages.

The Markdown files carry their layout as inline HTML (sidebar, buttons, content
column) but cannot carry a stylesheet: GitHub strips <style> and prints its text.
Here the same content is wrapped in a real HTML document, so the code blocks,
tables and syntax colours that GitHub cannot show are available locally.

    mdhtml.py out_dir file.md ...
"""
import html
import os
import shutil
import re
import sys
from urllib.parse import quote

# ------------------------------------------------------------------- style ----
CSS = """
:root { color-scheme: light; }
body { margin:0; background:#ffffff; color:#24292f;
       font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Helvetica,Arial,sans-serif;
       font-size:17px; line-height:1.65; }
h1,h2,h3,h4,h5,h6 { line-height:1.3; margin:26px 0 10px 0; }
h1 { font-size:30px; } h2 { font-size:25px; border-bottom:1px solid #d8dce0;
     padding-bottom:6px; } h3 { font-size:20px; } h4 { font-size:18px; }
h5,h6 { font-size:17px; }
a { color:#0a58ca; }
img { max-width:100%; }
p { margin:10px 0; }
ul { margin:8px 0 8px 0; padding-left:26px; }
li { margin:3px 0; }
hr { border:0; border-top:1px solid #d8dce0; margin:24px 0; }

pre { background:#e4e6e8; padding:12px 14px; border:1px solid #d8dce0;
      border-radius:6px; overflow-x:auto; }
pre code { background:transparent; color:#1f2328; padding:0;
           font-size:14px; line-height:1.55; }
code { background:#e4e6e8; color:#1f2328; padding:1px 4px; border-radius:4px;
       font-family:'Cascadia Code',Consolas,'Liberation Mono',monospace;
       font-size:14px; }


table { border-collapse:collapse; margin:8px 0 16px 0; }
th, td { border:1px solid #c9ced4; padding:6px 10px; vertical-align:top; }
th { background:#eef1f4; text-align:left; }

details > summary { cursor:pointer; }
"""

def highlight(code, lang):
    """Code is rendered as plain text: no token colouring."""
    return html.escape(code)


# ------------------------------------------------------------ inline markup ----
def inline(text):
    text = html.escape(text)
    text = re.sub(r'!\[([^\]]*)\]\(([^)]+)\)',
                  lambda m: f'<img src="{m.group(2)}" alt="{m.group(1)}">', text)
    text = re.sub(r'\[([^\]]+)\]\(([^)]+)\)',
                  lambda m: f'<a href="{m.group(2)}">{m.group(1)}</a>', text)
    text = re.sub(r'`([^`]+)`', lambda m: f'<code>{m.group(1)}</code>', text)
    text = re.sub(r'\*\*([^*]+)\*\*', r'<strong>\1</strong>', text)
    text = re.sub(r'(?<![*\w])\*([^*]+)\*(?!\*)', r'<em>\1</em>', text)
    text = text.replace('&lt;br&gt;', '<br>')
    return text


def slug(title):
    title = re.sub(r'\[([^\]]+)\]\([^)]+\)', r'\1', title)   # [text](link) -> text
    s = re.sub(r'[^\w\s-]', '', title.lower())
    return re.sub(r'\s+', '-', s.strip())


# ------------------------------------------------------------------ blocks ----
def render(md):
    out, i, lines = [], 0, md.split('\n')
    while i < len(lines):
        line = lines[i]

        # fenced code
        m = re.match(r'^```(\w*)\s*$', line)
        if m:
            lang, body, i = m.group(1), [], i + 1
            while i < len(lines) and not lines[i].startswith('```'):
                body.append(lines[i])
                i += 1
            i += 1
            code = '\n'.join(body)
            out.append(f'<pre><code>{highlight(code, lang)}</code></pre>')
            continue

        # raw html passes straight through
        if line.lstrip().startswith(('<div', '</div', '<a ', '</a', '<details',
                                     '</details', '<summary', '</summary', '<ul',
                                     '</ul', '<li', '</li', '<b>', '<p ', '</p',
                                     '<table', '</table', '<tr', '<td', '<th',
                                     '<span', '<img')):
            out.append(line)
            i += 1
            continue

        # heading
        m = re.match(r'^(#{1,6})\s+(.*)$', line)
        if m:
            level, title = len(m.group(1)), m.group(2).strip()
            out.append(f'<h{level} id="{slug(title)}">{inline(title)}</h{level}>')
            i += 1
            continue

        # table
        if line.startswith('|') and i + 1 < len(lines) and \
                re.match(r'^\|[\s:|-]+\|\s*$', lines[i + 1]):
            head = [c.strip() for c in line.strip('|').split('|')]
            rows, i = [], i + 2
            while i < len(lines) and lines[i].startswith('|'):
                rows.append([c.strip() for c in lines[i].strip('|').split('|')])
                i += 1
            out.append('<table>')
            out.append('<tr>' + ''.join(f'<th>{inline(c)}</th>' for c in head) + '</tr>')
            for r in rows:
                out.append('<tr>' + ''.join(f'<td>{inline(c)}</td>' for c in r) + '</tr>')
            out.append('</table>')
            continue

        # list
        if re.match(r'^\s*-\s+', line):
            depth_stack = []
            while i < len(lines) and (re.match(r'^\s*-\s+', lines[i]) or
                                      (lines[i].strip() == '' and i + 1 < len(lines)
                                       and re.match(r'^\s*-\s+', lines[i + 1]))):
                if lines[i].strip() == '':
                    i += 1
                    continue
                indent = len(lines[i]) - len(lines[i].lstrip())
                text = re.sub(r'^\s*-\s+', '', lines[i])
                while depth_stack and indent < depth_stack[-1]:
                    out.append('</ul>')
                    depth_stack.pop()
                if not depth_stack or indent > depth_stack[-1]:
                    out.append('<ul>')
                    depth_stack.append(indent)
                out.append(f'<li>{inline(text)}</li>')
                i += 1
            for _ in depth_stack:
                out.append('</ul>')
            continue

        if line.strip() == '':
            i += 1
            continue

        if line.strip() == '---':
            out.append('<hr>')
            i += 1
            continue

        # paragraph
        para = [line]
        i += 1
        while i < len(lines) and lines[i].strip() and \
                not re.match(r'^(\s*-\s+|#{1,6}\s|```|\||<)', lines[i]):
            para.append(lines[i])
            i += 1
        out.append(f'<p>{inline(" ".join(para))}</p>')
    return '\n'.join(out)


SIDE = """
.layout { display:flex; align-items:flex-start; gap:0; }
.side { flex:0 0 auto; width:290px; min-width:150px; max-width:70%;
        resize:horizontal; overflow:auto; height:100vh; box-sizing:border-box;
        position:sticky; top:0; background:#000000; color:#e8eaed;
        padding:56px 16px 26px 16px; font-size:14px; line-height:1.7; }
.side a { color:#e8eaed; text-decoration:none; }
.side a:hover { text-decoration:underline; }
.side ul { list-style:none; margin:4px 0 4px 4px; padding-left:12px; }
.side .plate { background:#d6e8ff; color:#0b2545; padding:9px 10px;
        border-radius:6px; text-align:center; font-weight:bold;
        margin:0 0 14px 0; line-height:1.35; }
.main { flex:1 1 auto; min-width:0; padding:0 30px; max-width:940px; }
.page { padding:0 40px; max-width:960px; margin:0 auto; }

/* landing page */
.hero { text-align:center; padding:38px 24px 30px 24px; margin:0 0 6px 0;
        background:#0b2545; color:#ffffff; border-radius:12px; }
.hero .mark { width:66px; height:66px; display:block; margin:0 auto 16px auto; }
.hero h1 { margin:0 0 12px 0; font-size:36px; color:#ffffff;
        border:0; letter-spacing:-0.5px; }
.hero p { margin:0 auto; max-width:640px; font-size:17px; color:#c8d6e8;
        line-height:1.55; }
.cards { display:grid; grid-template-columns:repeat(auto-fit,minmax(300px,1fr));
        gap:16px; margin:26px 0 40px 0; }
.card { display:block; text-decoration:none; background:#f6f8fa;
        border:1px solid #d0d7de; border-radius:10px; padding:18px 20px;
        transition:border-color .15s, box-shadow .15s, transform .15s; }
.card:hover { border-color:#0a6abf; box-shadow:0 4px 14px rgba(10,37,69,.10);
        transform:translateY(-2px); }
.card .t { display:block; color:#0a4a8f; font-weight:700; font-size:17px;
        margin-bottom:7px; }
.card .d { display:block; color:#41484f; font-size:14px; line-height:1.55; }

/* toolbar: show / hide the navigation panel, and return home */
.navbar { position:fixed; top:10px; left:10px; z-index:40;
        display:flex; align-items:flex-start; gap:8px; }
.navbtn { display:inline-flex; align-items:center; justify-content:center;
        width:36px; height:31px; padding:0; cursor:pointer;
        background:#1f2937; color:#e8eaed; border:1px solid #3a4553;
        border-radius:6px;
        box-shadow:0 2px 0 #080d13, inset 0 1px 0 rgba(255,255,255,.10); }
.navbtn:hover { background:#2b3a4d; }
.navbtn .ico { width:17px; height:17px; fill:currentColor; display:block; }
/* the contents button sits pressed in while the panel is open */
body:not(.nav-hidden) .navtoggle { background:#0c131b; border-color:#26313f;
        box-shadow:inset 0 2px 5px rgba(0,0,0,.7); transform:translateY(2px); }
body.nav-hidden .side { display:none; }
/* step to the previous or next section; dimmed at the ends of the document */
.navbar .gap { width:10px; }
.navbtn.off { opacity:.38; cursor:default; box-shadow:none; }
.navbtn.off:hover { background:#1f2937; }

/* one section at a time, with a pager below it */
.sec { display:none; }
.sec.on { display:block; }
.pagerbar { display:flex; align-items:center; justify-content:space-between;
        gap:12px; margin:38px 0 44px 0; padding-top:16px;
        border-top:1px solid #d8dee4; }
.pbtn { display:inline-flex; align-items:center; gap:8px; max-width:42%;
        padding:9px 14px; cursor:pointer; font-family:inherit; font-size:14px;
        color:#0a4a8f; background:#f6f8fa; border:1px solid #d0d7de;
        border-radius:7px; text-align:left; }
.pbtn:hover { background:#eaf2fb; border-color:#0a6abf; }
.pbtn.off { opacity:.4; cursor:default; }
.pbtn.off:hover { background:#f6f8fa; border-color:#d0d7de; }
.pbtn .lbl { overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
.pbtn .arrow { flex:0 0 auto; color:#57606a; }
.pgcount { flex:0 0 auto; color:#57606a; font-size:13px; white-space:nowrap; }
/* the section being read, marked in the contents panel */
.side a.here { color:#7fc4ff; font-weight:bold; }

/* phones: the panel covers the screen, and closes once a section is chosen */
@media (max-width:820px) {
  .layout { display:block; }
  .side { position:fixed; inset:0; width:100% !important; max-width:none;
          height:100vh; resize:none; padding:60px 20px 30px 20px;
          font-size:16px; z-index:30; }
  .main { padding:52px 18px 0 18px; max-width:none; }
  .page { padding:52px 18px 0 18px; }
  /* the arrows would act on the document behind the contents overlay */
  body:not(.nav-hidden) .navbar .gap,
  body:not(.nav-hidden) #secprev,
  body:not(.nav-hidden) #secnext { display:none; }
  .pgcount { display:none; }
  .pbtn { max-width:48%; }
}
"""

NAV_JS = """
<script>
function navToggle() { document.body.classList.toggle('nav-hidden'); }
// on a phone the panel starts hidden, so the document is what you see first
if (window.matchMedia('(max-width:820px)').matches) {
    document.body.classList.add('nav-hidden');
}
// choosing a section on a phone closes the panel again
document.addEventListener('click', function (e) {
    var link = e.target.closest && e.target.closest('.side a');
    if (link && window.matchMedia('(max-width:820px)').matches) {
        document.body.classList.add('nav-hidden');
    }
});
</script>
"""

# Stepping through the sections with the two arrow buttons. Set PAGER to False
# and rebuild to take the buttons out again.
PAGER = True
# One chapter or section on screen at a time, with a pager below it. Set PAGED
# to False and rebuild for a single scrolling document, arrows still stepping
# from heading to heading.
PAGED = True

PAGED_JS = """
<script>
(function () {
    var secs = [].slice.call(document.querySelectorAll('.main .sec')),
        up = document.getElementById('secprev'),
        down = document.getElementById('secnext'),
        bprev = document.getElementById('pgprev'),
        bnext = document.getElementById('pgnext'),
        plabel = document.getElementById('pgprevlbl'),
        nlabel = document.getElementById('pgnextlbl'),
        count = document.getElementById('pgcount'),
        page = {},                       // heading id -> page holding it
        cur = 0;
    if (secs.length < 2) { return; }
    secs.forEach(function (s, i) {
        [].slice.call(s.querySelectorAll('[id]')).forEach(function (el) {
            page[el.id] = i;
        });
    });

    function heading(s) {
        return s.querySelector('h2, h3') || s.querySelector('h1, h4');
    }
    function label(s) {
        var h = heading(s);
        return h ? h.textContent.replace(/\\s+/g, ' ').trim() : '';
    }
    function show(i, hash) {
        if (i < 0 || i >= secs.length) { return; }
        secs[cur].classList.remove('on');
        cur = i;
        secs[cur].classList.add('on');
        window.scrollTo(0, 0);
        if (hash !== false) { stamp(heading(secs[cur])); }
        mark();
    }
    function stamp(el) {
        if (el && el.id) {
            try { history.replaceState(null, '', '#' + el.id); } catch (e) { }
        }
    }
    // label the pager with its destinations, and dim it at either end
    function mark() {
        var back = cur > 0, on = cur < secs.length - 1;
        [up, bprev].forEach(function (b) { b.classList.toggle('off', !back); });
        [down, bnext].forEach(function (b) { b.classList.toggle('off', !on); });
        up.title = back ? 'Previous: ' + label(secs[cur - 1]) : 'Previous section';
        down.title = on ? 'Next: ' + label(secs[cur + 1]) : 'Next section';
        plabel.textContent = back ? label(secs[cur - 1]) : 'Previous';
        nlabel.textContent = on ? label(secs[cur + 1]) : 'Next';
        count.textContent = (cur + 1) + ' of ' + secs.length;
        var was = document.querySelectorAll('.side a.here');
        for (var k = 0; k < was.length; k++) { was[k].classList.remove('here'); }
        var h = heading(secs[cur]),
            link = h && document.querySelector('.side a[href="#' + h.id + '"]');
        if (link) {
            link.classList.add('here');
            if (link.scrollIntoView) { link.scrollIntoView({block: 'nearest'}); }
        }
    }
    window.secStep = function (d) { show(cur + d); };

    // a link to a heading opens the page holding it, then scrolls to it
    document.addEventListener('click', function (e) {
        var a = e.target.closest && e.target.closest('a[href^="#"]');
        if (!a) { return; }
        var id = a.getAttribute('href').slice(1), i = page[id];
        if (i === undefined) { return; }
        e.preventDefault();
        if (i !== cur) { show(i, false); }
        var el = document.getElementById(id);
        if (el && el !== heading(secs[i])) { el.scrollIntoView(); }
        stamp(el);
    });
    // arriving with #section in the address bar opens that page
    function fromHash() {
        var id = decodeURIComponent(location.hash.slice(1)), i = page[id];
        if (i === undefined) { mark(); return; }
        show(i, false);
        var el = document.getElementById(id);
        if (el && el !== heading(secs[i])) { el.scrollIntoView(); }
    }
    window.addEventListener('hashchange', fromHash);
    fromHash();
})();
</script>
"""

PAGER_JS = """
<script>
(function () {
    var heads = [].slice.call(document.querySelectorAll(
                    '.main h2[id], .main h3[id], .main h4[id]')),
        prev = document.getElementById('secprev'),
        next = document.getElementById('secnext'),
        OFF = 12,      // gap left above a heading once it has been jumped to
        CUR = 40;      // a heading this near the top counts as the one being read
    if (!heads.length || !prev || !next) { return; }

    function top(el) {
        return el.getBoundingClientRect().top + window.pageYOffset;
    }
    // index of the section being read, or -1 while above the first heading
    function here() {
        var y = window.pageYOffset + CUR, at = -1;
        for (var i = 0; i < heads.length; i++) {
            if (top(heads[i]) <= y) { at = i; }
        }
        return at;
    }
    function label(el) {
        return el.textContent.replace(/\\s+/g, ' ').trim();
    }
    function go(y, hash) {
        window.scrollTo(0, y);
        if (hash) {
            try { history.replaceState(null, '', hash); } catch (e) { /* file:// */ }
        }
        mark();
    }
    function step(dir) {
        var i = here(), j;
        if (i < 0) {                       // above the first heading
            if (dir > 0) { go(top(heads[0]) - OFF, '#' + heads[0].id); }
            return;
        }
        // part-way down a section, Previous returns to that section's heading
        if (dir < 0 && window.pageYOffset + OFF - top(heads[i]) > CUR - OFF) {
            go(top(heads[i]) - OFF, '#' + heads[i].id);
            return;
        }
        j = i + dir;
        if (j < 0) { go(0, ''); return; }   // back past the first: page top
        if (j >= heads.length) { return; }
        go(top(heads[j]) - OFF, '#' + heads[j].id);
    }
    // dim an arrow when there is nowhere to go, and name the target section
    function mark() {
        var i = here();
        prev.classList.toggle('off', window.pageYOffset < 8);
        next.classList.toggle('off', i >= heads.length - 1);
        prev.title = i > 0 ? 'Previous section: ' + label(heads[i - 1])
                           : 'Back to the top';
        next.title = i < heads.length - 1
                     ? 'Next section: ' + label(heads[i + 1]) : 'Next section';
    }
    window.secStep = step;
    var pending = false;
    window.addEventListener('scroll', function () {
        if (pending) { return; }
        pending = true;
        window.requestAnimationFrame(function () { pending = false; mark(); });
    });
    mark();
})();
</script>
"""

# Four bars for the contents button, a house for the home button.
ICON_BARS = ('<svg class="ico" viewBox="0 0 16 16" aria-hidden="true">'
             '<rect x="1" y="1" width="14" height="2" rx="1"/>'
             '<rect x="1" y="5" width="14" height="2" rx="1"/>'
             '<rect x="1" y="9" width="14" height="2" rx="1"/>'
             '<rect x="1" y="13" width="14" height="2" rx="1"/></svg>')
ICON_HOME = ('<svg class="ico" viewBox="0 0 16 16" aria-hidden="true">'
             '<path d="M8 1.2 0.7 7.6h1.9V14.6h4V10.4h2.8v4.2h4V7.6h1.9z"/></svg>')
ICON_UP = ('<svg class="ico" viewBox="0 0 16 16" aria-hidden="true">'
           '<path d="M8 3.4 14.1 9.5 12.7 10.9 8 6.2 3.3 10.9 1.9 9.5z"/></svg>')
ICON_DOWN = ('<svg class="ico" viewBox="0 0 16 16" aria-hidden="true">'
             '<path d="M8 12.6 1.9 6.5 3.3 5.1 8 9.8 12.7 5.1 14.1 6.5z"/></svg>')


def nav_bar(home):
    """The floating toolbar: contents toggle, home, then the section arrows."""
    out = ['<div class="navbar">',
           '<button class="navbtn navtoggle" onclick="navToggle()"'
           ' title="Show or hide the contents" aria-label="Contents">'
           f'{ICON_BARS}</button>']
    if home:
        out.append(f'<a class="navbtn" href="{home}" title="Home"'
                   f' aria-label="Home">{ICON_HOME}</a>')
    if PAGER:
        out.append('<span class="gap"></span>'
                   '<button class="navbtn" id="secprev" onclick="secStep(-1)"'
                   ' title="Previous section" aria-label="Previous section">'
                   f'{ICON_UP}</button>'
                   '<button class="navbtn" id="secnext" onclick="secStep(1)"'
                   ' title="Next section" aria-label="Next section">'
                   f'{ICON_DOWN}</button>')
    out.append('</div>')
    return ''.join(out)


PAGER_BAR = (
    '<nav class="pagerbar">'
    '<button class="pbtn" id="pgprev" onclick="secStep(-1)">'
    '<span class="arrow">&#9664;</span>'
    '<span class="lbl" id="pgprevlbl">Previous</span></button>'
    '<span class="pgcount" id="pgcount"></span>'
    '<button class="pbtn" id="pgnext" onclick="secStep(1)">'
    '<span class="lbl" id="pgnextlbl">Next</span>'
    '<span class="arrow">&#9654;</span></button>'
    '</nav>')


def paginate(body):
    """Split the document into pages: one per chapter and per section.

    Sub-subsections stay with the section they belong to. A chapter heading
    with no text of its own shares a page with the section that follows it,
    so paging never lands on a page holding nothing but a title.
    """
    parts = re.split(r'(<h[23] id="[^"]+">)', body)
    if len(parts) < 4:                            # one section: nothing to page
        return body
    pages = []
    for i in range(1, len(parts), 2):
        chunk = parts[i] + parts[i + 1]
        own = re.sub(r'^<h[23][^>]*>.*?</h[23]>', '', chunk, flags=re.S)
        own = re.sub(r'<[^>]+>', '', own).strip()
        if pages and not pages[-1][1]:            # previous page was title-only
            pages[-1] = (pages[-1][0] + chunk, own)
        else:
            pages.append((chunk, own))
    # whatever precedes the first heading — the title and its lead-in
    html = [parts[0] + pages[0][0]] + [p[0] for p in pages[1:]]
    return '\n'.join(
        f'<section class="sec{" on" if n == 0 else ""}">{p}</section>'
        for n, p in enumerate(html)) + PAGER_BAR


# The project mark: a tile grid with one live cell, as on the old site.
LOGO_TILES = [(2, 2), (22, 2), (42, 2),
              (2, 22), (22, 22), (42, 22),
              (2, 42), (22, 42), (42, 42)]


def logo(tile, live):
    cells = ''.join(
        f'<rect x="{x}" y="{y}" width="16" height="16" rx="4" fill="'
        f'{live if (x, y) == (22, 22) else tile}"/>' for x, y in LOGO_TILES)
    return f'<svg viewBox="0 0 60 60" xmlns="http://www.w3.org/2000/svg">{cells}</svg>'


HERO_LOGO = logo('#ffffff', '#2fd3c0').replace(
    '<svg ', '<svg class="mark" aria-hidden="true" ')
FAVICON = 'data:image/svg+xml,' + quote(logo('#454f5f', '#2fd3c0'))


def build_landing(body):
    """Lay the landing page out as a hero panel above a grid of cards."""
    hero = re.search(r'(<h1[^>]*>.*?</h1>)\s*(<p>.*?</p>)', body, re.S)
    cards = re.findall(
        r'<h3[^>]*><a href="([^"]+)">(.*?)</a></h3>\s*<p>(.*?)</p>', body, re.S)
    if not (hero and cards):
        return body
    out = [f'<div class="hero">{HERO_LOGO}{hero.group(1)}{hero.group(2)}</div>',
           '<div class="cards">']
    for href, title, desc in cards:
        out.append(f'<a class="card" href="{href}">'
                   f'<span class="t">{title} &#8594;</span>'
                   f'<span class="d">{desc}</span></a>')
    out.append('</div>')
    return '\n'.join(out)


def sidebar(body, title):
    """Build the navigation panel from the headings of the rendered page."""
    heads = re.findall(r'<h([2-4]) id="([^"]+)">(.*?)</h\1>', body)
    if not heads:
        return ''
    out = ['<div class="side">']
    out.append(f'<div class="plate">{title}</div>')
    out.append('<b>Contents</b>')
    depth = 0
    for lvl, hid, text in heads:
        lvl = int(lvl) - 1
        text = re.sub(r'<[^>]+>', '', text)
        text = re.sub(r'\s*[(\[].*$', '', text).strip() or text
        while depth < lvl:
            out.append('<ul>'); depth += 1
        while depth > lvl:
            out.append('</ul>'); depth -= 1
        out.append(f'<li><a href="#{hid}">{text}</a></li>')
    out += ['</ul>'] * depth
    out.append('</div>')
    return '\n'.join(out)


PAGE = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title}</title>
<link rel="icon" href="{favicon}">
<style>{css}{side}</style>
</head>
<body>
{body}
</body>
</html>
"""

# ------------------------------------------------------------------- build ----
GITHUB = 'https://github.com/ztachip/ztachip/blob/master/'
MEDIA = 'media'

# Page names used by the previous documentation site. Links to them are still
# out in the wild, so the build leaves a redirect at each old name.
REDIRECTS = {
    'overview.html': 'Overview.html',
    'hardware_design.html': 'HardwareDesign.html',
    'programmer_guide.html': 'ztachip_programmer_guide.html',
    'visionai_guide.html': 'visionai_programmer_guide.html',
    'micropython_guide.html': 'MicropythonUserGuide.html',
    'genindex.html': 'index.html',
    'search.html': 'index.html',
}

REDIRECT_PAGE = '''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta http-equiv="refresh" content="0; url={target}">
<link rel="canonical" href="{target}">
<title>Moved</title>
</head>
<body>
<p>This page has moved to <a href="{target}">{target}</a>.</p>
</body>
</html>
'''

out_dir = sys.argv[1]
os.makedirs(os.path.join(out_dir, MEDIA), exist_ok=True)
sources = sys.argv[2:]
doc_names = {os.path.basename(s): os.path.basename(s)[:-3] + '.html' for s in sources}

for src in sources:
    doc_dir = os.path.dirname(src)
    md = open(src, encoding='utf-8').read()
    copied = {}

    def repo_path(path):
        return os.path.normpath(os.path.join(doc_dir, path))

    def fix(path, is_image=False):
        if path.startswith(('http', '#', 'mailto:')):
            return path
        base = os.path.basename(path)
        if base in doc_names:                    # another document
            return doc_names[base]
        target = repo_path(path)
        if is_image:                             # copy it in beside the pages
            name = target.replace(os.sep, '_')
            if target not in copied and os.path.exists(target):
                shutil.copyfile(target, os.path.join(out_dir, MEDIA, name))
                copied[target] = True
            return f'{MEDIA}/{name}'
        return GITHUB + target.replace(os.sep, '/')

    md = re.sub(r'(!\[[^\]]*\]\()([^)]+)(\))',
                lambda m: m.group(1) + fix(m.group(2), True) + m.group(3), md)
    md = re.sub(r'(?<!!)(\[[^\]]*\]\()([^)]+)(\))',
                lambda m: m.group(1) + fix(m.group(2)) + m.group(3), md)
    md = re.sub(r'(<a href=")([^"]+)(")',
                lambda m: m.group(1) + fix(m.group(2)) + m.group(3), md)
    md = re.sub(r'(<img src=")([^"]+)(")',
                lambda m: m.group(1) + fix(m.group(2), True) + m.group(3), md)

    m = re.search(r'^#\s+(.*)$', md, re.M)
    title = m.group(1).strip() if m else os.path.basename(src)
    # the link rewrite above already points this at the html build
    home = re.search(r'\[&#8592; Home\]\(([^)]+)\)', md)
    home = home.group(1) if home else ''

    # the panel replaces the in-page contents block and the home link
    md = re.sub(r'\[&#8592; Home\]\([^)]+\)\n', '', md)
    md = re.sub(r'<details>\s*\n<summary><b>Contents</b></summary>.*?</details>',
                '', md, flags=re.S)

    body = render(md)
    # the launcher is the navigation; it needs no panel of its own
    panel = ('' if os.path.basename(src) == 'index.md'
             else sidebar(body, html.escape(title)))
    if os.path.basename(src) == 'index.md':
        body = build_landing(body)

    if panel:
        if PAGED:
            body, step = paginate(body), PAGED_JS
        else:
            step = PAGER_JS if PAGER else ''
        body = (f'<div class="layout">{panel}'
                f'<div class="main">{nav_bar(home)}{body}</div></div>'
                f'{NAV_JS}{step}')
    else:
        body = f'<div class="page">{body}</div>'
    dest = os.path.join(out_dir, doc_names[os.path.basename(src)])
    open(dest, 'w', encoding='utf-8').write(
        PAGE.format(title=html.escape(title), css=CSS, side=SIDE,
                    favicon=FAVICON, body=body))
    print(f'  {dest}')

# redirects from the old site's page names
for old, new in REDIRECTS.items():
    if old in doc_names.values():          # never shadow a real page
        continue
    with open(os.path.join(out_dir, old), 'w', encoding='utf-8') as fh:
        fh.write(REDIRECT_PAGE.format(target=new))
    print(f'  {os.path.join(out_dir, old)} -> {new}')
