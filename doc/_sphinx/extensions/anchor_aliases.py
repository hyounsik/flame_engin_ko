"""Keeps English heading anchors working after headings are translated.

Translated headings get a new MyST slug, which breaks `other.md#english-slug`
links. An `<a id="english-slug"></a>` line above the heading keeps the old
anchor in the HTML; registering it as a MyST slug lets links resolve without
warnings. Raw anchors are used instead of `(label)=` targets because those
are global Sphinx labels and common slugs would clash across pages.
"""
import re
from docutils import nodes
from sphinx.application import Sphinx

_ALIAS = re.compile(r'<a id="([^"]+)">')


def _register(app: Sphinx, doctree: nodes.document) -> None:
    slugs = app.env.metadata[app.env.docname].setdefault('myst_slugs', {})
    for section in doctree.findall(nodes.section):
        title = section[0].astext() if section.children else ''
        for section_id in section['ids']:
            slugs.setdefault(section_id, (0, section_id, title))
    for raw in doctree.findall(nodes.raw):
        for alias in _ALIAS.findall(raw.astext()):
            slugs.setdefault(alias, (0, alias, alias))


def setup(app: Sphinx):
    app.connect('doctree-read', _register)
    return {'parallel_read_safe': True}
