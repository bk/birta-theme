<%page args="title, url, img, intro=None, css_class='', lazy=True" />
<%doc>
Simpler verison of big_round_teaser, to be used from templates directly,
and not necessarily with page content.
</%doc>
<div class="${ css_class } round-teaser round-teaser-small">
  <a href="${url}">
    <img src="${ img }" ${ ' loading="lazy"' if lazy else '' |n} alt="${ title |h}" width="150" height="150" class="borad-round">
  </a>
  <div class="intro">
    <h3 class="mt-0${ ' mb-0' if not intro else '' }"><a href="${url}" class="plain">${ title }</a></h3>
    % if intro:
      <p class="m-0">${ intro } <a href="${ url }">Meira&nbsp;»</a>
    % endif
  </div>
</div>
