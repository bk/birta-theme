<%page args="pagelist" />
<%namespace name="tagsummary" file="tagsummary.mc" />
${ tagsummary.body(pagelist, with_subtitle=True) }
