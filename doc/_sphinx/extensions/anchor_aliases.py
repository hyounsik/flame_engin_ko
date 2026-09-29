"""Keeps English heading anchors working after headings are translated.

Translated headings get a new MyST slug, which breaks `other.md#english-slug`
links. Translators put an explicit `(english-slug)=` target above the heading;
this extension registers such targets as MyST slugs so links resolve cleanly.
"""
from docutils import nodes
from sphinx.application import Sphinx


def _register_section_ids(app: Sphinx, doctree: nodes.document) -> None:
    slugs = app.env.metadata[app.env.docname].setdefault('myst_slugs', {})
    for section in doctree.findall(nodes.section):
        title = section[0].astext() if section.children else ''
        for section_id in section['ids']:
            slugs.setdefault(section_id, (0, section_id, title))


def setup(app: Sphinx):
    app.connect('doctree-read', _register_section_ids)
    return {'parallel_read_safe': True}
