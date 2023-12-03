<%page args="pagelist, with_subtitle=False" />
<%namespace name="summary" file="summary.mc" />
${ summary.body(pagelist, css_class='pagelist-tagsummary', with_subtitle=with_subtitle) }
