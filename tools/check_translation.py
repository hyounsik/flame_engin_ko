"""Checks translated docs against the upstream English sources.

Usage: python tools/check_translation.py <upstream-doc-dir> [--fix-anchors]

- Code blocks must match upstream, except lines that are comments.
- With --fix-anchors, rewrites the `<a id="..."></a>` alias above each
  translated heading so it carries the slug the English heading had.
"""
import re
import sys
from pathlib import Path

from myst_parser.mdit_to_docutils.base import default_slugify

DOC = Path(__file__).resolve().parent.parent / 'doc'
HEADING = re.compile(r'^(#{1,4})\s+(.*?)\s*#*\s*$')
FENCE = re.compile(r'^\s*(`{3,}|~{3,}|:{3,})')
LABEL = re.compile(r'^\((.+)\)=\s*$')
ALIAS = re.compile(r'^<a id="([^"]+)"></a>\s*$')
COMMENT = re.compile(r'^\s*(//|#|/\*|\*|<!--|--)')
TRAILING_COMMENT = re.compile(r'\s*//[^"\']*$')


def scan(lines):
    """Returns heading line indexes and the lines of real code blocks.

    Directive fences (```{note}, :::{toctree}) hold translatable prose, so only
    fences with a plain language info string count as code. Fences nest.
    """
    headings, code, stack = [], [], []
    for index, line in enumerate(lines):
        match = FENCE.match(line)
        if match:
            marker = match.group(1)
            info = line.strip()[len(marker):].strip()
            top = stack[-1] if stack else None
            if top and not info and marker[0] == top[0][0] and len(marker) >= len(top[0]):
                stack.pop()
                continue
            if not top or not top[1]:
                is_code = marker[0] != ':' and not info.startswith('{')
                stack.append((marker, is_code))
                continue
        if stack and stack[-1][1]:
            code.append(TRAILING_COMMENT.sub('', line))
        elif not stack and HEADING.match(line):
            headings.append(index)
    return headings, code


def plain(title):
    title = re.sub(r'\[([^\]]*)\]\([^)]*\)', r'\1', title)
    return re.sub(r'[`*]', '', title)


def slugs(lines, headings):
    seen, result = {}, []
    for index in headings:
        slug = default_slugify(plain(HEADING.match(lines[index]).group(2)))
        count = seen.get(slug, 0)
        seen[slug] = count + 1
        result.append(slug if count == 0 else f'{slug}-{count}')
    return result


def code_mismatches(original, translated):
    strip = lambda code: [l for l in code if not COMMENT.match(l) and l.strip()]
    a, b = strip(original), strip(translated)
    return [(x, y) for x, y in zip(a, b) if x != y] + (
        [('<length>', f'{len(a)} vs {len(b)}')] if len(a) != len(b) else [])


def fix_anchors(lines, headings, english_slugs, upstream_labels):
    targets = dict(zip(headings, english_slugs))
    translated_slugs = dict(zip(headings, slugs(lines, headings)))
    is_marker = lambda line: ALIAS.match(line) or _is_added_label(line, upstream_labels)
    output = []
    for index, line in enumerate(lines):
        if index in targets:
            while output and (is_marker(output[-1]) or (
                    not output[-1].strip() and len(output) > 1 and is_marker(output[-2]))):
                output.pop()
            if targets[index] != translated_slugs[index]:
                output += [f'<a id="{targets[index]}"></a>', '']
        output.append(line)
    return _retarget_local_links(output, {
        targets[index]: translated_slugs[index] for index in headings})


def _retarget_local_links(lines, english_to_translated):
    """Points same-page `](#english-slug)` links at the translated heading.

    MyST resolves same-page anchors only against the page's own heading slugs,
    so the raw `<a id>` aliases cannot serve them.
    """
    retarget = lambda slug: english_to_translated.get(slug, slug)
    inline = lambda m: f'](#{retarget(m.group(1))})'
    definition = lambda m: f'{m.group(1)}#{retarget(m.group(2))}'
    return [
        re.sub(r'^(\[[^\]]+\]:\s+)#(\S+)$', definition,
               re.sub(r'\]\(#([^)\s]+)\)', inline, line))
        for line in lines
    ]


def _is_added_label(line, upstream_labels):
    match = LABEL.match(line)
    return bool(match) and match.group(1) not in upstream_labels


def check_file(upstream_file, translated_file, fix):
    original = upstream_file.read_text().splitlines()
    translated = translated_file.read_text().splitlines()
    original_headings, original_code = scan(original)
    translated_headings, translated_code = scan(translated)
    problems = [f'code: {a!r} != {b!r}' for a, b in code_mismatches(original_code, translated_code)[:3]]
    if len(original_headings) != len(translated_headings):
        problems.append(f'heading count {len(original_headings)} vs {len(translated_headings)}')
    elif fix:
        labels = {LABEL.match(l).group(1) for l in original if LABEL.match(l)}
        fixed = fix_anchors(translated, translated_headings, slugs(original, original_headings), labels)
        translated_file.write_text('\n'.join(fixed) + '\n')
    return problems


def main():
    upstream = Path(sys.argv[1]).resolve()
    fix = '--fix-anchors' in sys.argv
    failures = 0
    for upstream_file in sorted(upstream.rglob('*.md')):
        relative = upstream_file.relative_to(upstream)
        if relative.parts[0].startswith('_'):
            continue
        problems = check_file(upstream_file, DOC / relative, fix)
        for problem in problems:
            print(f'{relative}: {problem}')
        failures += bool(problems)
    print(f'{failures} file(s) with problems')


if __name__ == '__main__':
    main()
