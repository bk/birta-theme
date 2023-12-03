<%doc>pagelist handler, called via iki_inline</%doc>
<%page args="pagelist, css_class='pagelist-summary', no_wrap=False, no_intro=False, with_subtitle=False, grid_css_class='grid-sm c2-sm c3-md'" />
<%namespace name="resiz" file="/shortcodes/resize_image.mc" />
<%! from wmk_theme_autoload import get_main_img, get_summary %>
<%
if not pagelist:
    return ''
%>
% if not no_wrap:
<div class="${ css_class } ${ grid_css_class } mb-4">
% endif
  % for it in pagelist:
    ${ _item(it, with_subtitle=with_subtitle) }
  % endfor
% if not no_wrap:
  ## Prevent horizontal stretching
  % if len(pagelist) == 1:
    <div></div><div></div>
  % elif len(pagelist) == 2:
    <div></div>
  % endif
</div>
% endif

<%def name="_item(it, with_subtitle=False)">
  <%
  orig_img = get_main_img(it)
  if orig_img.startswith('mynd/'):
      orig_img = '/' + orig_img
  img = capture(lambda: resiz.body(orig_img, width=512, height=320, webroot=it['data']['WEBROOT'], self_url=it['url']))
  url = it['url']
  pg = it['data']['page']
  subtitle = None
  if with_subtitle:
      subtitle = pg.subtitle or None
  %>
  <article>
    <header${ ' class="with-subtitle"' if subtitle else '' |n }>
      <a href="${ url }">
        <img src="${ img }?o=${ orig_img |u }" loading="lazy" alt="${ pg.title |h }" width="512" height="320">
      </a>
      % if subtitle:
        <div class="subtitle">${ subtitle }</div>
      % endif
    </header>
    <h4${ ' class="mt-0"' if no_intro else '' }><a href="${ url }" class="text">${ pg.title }</a></h4>
    % if not no_intro:
    <p class="smaller">${ get_summary(it) } <a href="${ url }">Meira&nbsp;»</a></p>
    % endif
  </article>
</%def>
