#!/usr/bin/env python3
"""Give an existing Markdown document the same presentation as the converted
programmer guides: numbered headings, a black expandable sidebar, white content
column, light grey code blocks and styled tables.

    mdchrome.py in.md out.md "Title<br>Second line" [code-language]
"""
import os
import re
import sys

SRC = sys.argv[1]
OUT = sys.argv[2]
DOC_TITLE = sys.argv[3] if len(sys.argv) > 3 else 'Guide'
LANG = sys.argv[4] if len(sys.argv) > 4 else ''
# pass '-' as the title for a plain document: numbering and grids, but no
# sidebar and no stylesheet
PANEL = DOC_TITLE != '-'
# relative path back to the documentation index, if the page should carry a
# Home button
HOME = os.environ.get('DOC_HOME', '')

raw = open(SRC, encoding='utf-8').read().split('\n')

# A document whose only level-1 heading is its title: that title belongs in the
# sidebar plate, so everything below it moves up a level and the sections of the
# document become the chapters.
tops = [ln for ln in raw if re.match(r'^#\s+\S', ln)]
first = next((ln for ln in raw if ln.strip()), '')
PROMOTE = PANEL and len(tops) == 1 and first.startswith('# ')

# ------------------------------------------------------------------ body ----
body, headings = [], []
counters = [0] * 6
in_code = False

for line in raw:
    stripped = line.rstrip()

    if stripped.startswith('```'):
        if not in_code and stripped == '```' and LANG:
            stripped = '```' + LANG
        in_code = not in_code
        body.append(stripped)
        continue

    if in_code:
        body.append(line.rstrip())
        continue

    m = re.match(r'^(#{1,6})\s+(.*)$', stripped)
    if m:
        level = len(m.group(1))
        if PROMOTE:
            if level == 1:
                continue          # the title now lives in the sidebar
            level -= 1
        title = m.group(2).strip().rstrip('.: ')
        counters[level - 1] += 1
        for i in range(level, 6):
            counters[i] = 0
        number = '.'.join(str(counters[i]) for i in range(level))
        if level == 1:
            number += '.'
        # with a sidebar the document title lives there, so the body headings
        # move down one; without it they keep their own level
        depth = level + 1 if PANEL else level
        body.append(f'{"#" * depth} {number} {title}')
        headings.append((level, number, title))
        continue

    # a paragraph that is nothing but one inline-code span is a listing
    lone = re.match(r'^`([^`]+)`$', stripped)
    if lone:
        body.append('```' + LANG)
        body.append(lone.group(1))
        body.append('```')
        continue

    body.append(stripped)

# ------------------------------------------------- parameter lists to grids ----
GRID_SECTIONS = re.compile(r'^(parameters?|interfaces?|sub-?components?|components?)$',
                           re.I)


def starts_grid(line):
    """A 'Parameters:' style label, or a heading that introduces a definition list."""
    t = line.strip()
    m = re.match(r'^#{2,6}\s+[\d.]+\s+(.*)$', t)
    if m:
        return bool(GRID_SECTIONS.match(m.group(1).strip()))
    return bool(GRID_SECTIONS.match(t.rstrip(':').strip()))


# a name cell: an identifier, a wildcard like bus_*, or a markdown link
NAME_CELL = re.compile(r'^(\[[^\]]+\]\([^)]+\)|[\w*./-]+(\s+[\w*./-]+)?)$')


def looks_like_name(text):
    t = text.strip()
    return bool(t) and len(t) <= 40 and bool(NAME_CELL.match(t))


def parameters_to_table(lines):
    """Turn a 'name: description' bullet list into a Name/Description grid.

    Used for parameter lists and for the Interfaces / Subcomponents sections.
    Descriptions wrapped over several source lines are joined, and nested
    bullets (a parameter's accepted values) fold into their parent row.
    """
    out, i = [], 0
    while i < len(lines):
        line = lines[i]
        out.append(line)
        if not starts_grid(line):
            i += 1
            continue

        j, rows, ok, prev_blank = i + 1, [], True, True
        while j < len(lines):
            item = lines[j]
            if item.strip() == '':
                prev_blank = True
                j += 1
                continue
            top = re.match(r'^-\s+(.*)$', item)
            sub = re.match(r'^\s+-\s+(.*)$', item)
            if top:
                text = top.group(1)
                name, sep, desc = text.partition(':')
                if not sep or not desc.strip():
                    # some entries have no colon; the link is the name and the
                    # rest of the line is the description
                    m = re.match(r'^(\[[^\]]+\]\([^)]+\))\s+(\S.*)$', text)
                    if not m:
                        ok = False
                        break
                    name, desc = m.group(1), m.group(2)
                rows.append([name.strip(), desc.strip()])
            elif sub and rows:
                rows[-1][1] += '<br>' + sub.group(1).strip()
            else:
                # some sections list their entries as plain paragraphs rather
                # than bullets: "name : description"
                name, sep, desc = item.partition(':')
                if sep and desc.strip() and looks_like_name(name):
                    rows.append([name.strip(), desc.strip()])
                elif rows and not prev_blank:
                    # the description wrapped onto the next source line
                    rows[-1][1] += ' ' + item.strip()
                else:
                    break
            prev_blank = False
            j += 1

        if not ok or not rows:      # a single entry is still a grid
            i += 1
            continue

        out.append('')
        out.append('| Name | Description |')
        out.append('| --- | --- |')
        for name, desc in rows:
            out.append(f'| {name} | {desc} |')
        out.append('')
        i = j
    return out


body = parameters_to_table(body)

# collapse runs of blank lines outside code
clean, blank, in_code = [], False, False
for line in body:
    if line.startswith('```'):
        in_code = not in_code
    if not in_code and line == '':
        if blank:
            continue
        blank = True
    else:
        blank = False
    clean.append(line)


# --------------------------------------------------------------- sidebar ----
def anchor(number, title):
    slug = f'{number} {title}'.lower()
    slug = re.sub(r'[^\w\s-]', '', slug)
    return re.sub(r'\s+', '-', slug.strip())


def esc(s):
    return s.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')


LINK_STYLE = 'color:#e8eaed; text-decoration:none;'


def short(title):
    """Sidebar label: the function name without its parameter list."""
    return re.sub(r'\s*[(\[].*$', '', title).strip() or title


def link(number, title):
    # the anchor still points at the full heading; only the label is shortened
    return (f'<a href="#{anchor(number, title)}" style="{LINK_STYLE}">'
            f'{esc(number)} {esc(short(title))}</a>')


tree = []
for level, number, title in headings:
    if level == 1:
        tree.append((number, title, []))
    elif level == 2 and tree:
        tree[-1][2].append((number, title, []))
    elif level == 3 and tree and tree[-1][2]:
        tree[-1][2][-1][2].append((number, title))

home = [f'[&#8592; Home]({HOME})', ''] if HOME else []

title_line = []
if PANEL:                      # PANEL now means "this document has a title"
    title_line = ['# ' + DOC_TITLE.replace('<br>', ' '), '']

# A collapsed contents block: renders on GitHub, and the html build turns the
# same headings into a side panel.
toc = []
if headings:
    toc = ['<details>', '<summary><b>Contents</b></summary>', '']
    for level, number, title in headings:
        if level > 3:
            continue
        toc.append(f'{"  " * (level - 1)}- [{number} {short(title)}]'
                   f'(#{anchor(number, title)})')
    toc += ['', '</details>', '']

out = home + title_line + toc + clean

open(OUT, 'w', encoding='utf-8').write('\n'.join(out).rstrip() + '\n')
print(f'{OUT}: {len(out)} lines, {len(headings)} headings')
