<%doc>pagelist handler, called via iki_inline</%doc>
<%page args="pagelist, css_class='pagelist-summary', no_wrap=False" />
<%namespace name="resiz" file="/shortcodes/resize_image.mc" />
<%!
import re
import markdown

def get_main_img(it):
    if it['data']['page'].main_img:
        return it['data']['page'].main_img
    found = re.search(r'([^ "]+\.jpe?g)', it['doc'], flags=re.I)
    if found:
        return found.group(1)
    else:
        return '/img/fallback.jpg'

def get_summary(it):
    if it['data']['page'].summary:
        return it['data']['page'].summary
    found = re.search(r'\*\*(.+?)\*\*', it['doc'], flags=re.S)
    if found:
        summary = markdown.markdown(found.group(1))
    else:
        summary = markdown.markdown(it['doc'])
    summary = re.sub(r'\{\{<.*?>\}\}', '', summary)
    summary = re.sub(r'\[\[.*?\]\]', ' ', summary)
    summary = re.sub(r'<[^>]+>', ' ', summary)
    summary = re.sub(r'\s\s+', ' ', summary)
    summary = summary.strip()
    if len(summary) > 200:
        summary = summary[:200]
        summary = re.sub(r'\s\S+\s*$', '…', summary)
    return summary
%>
<%
if not pagelist:
    return ''
%>
% if not no_wrap:
<div class="${ css_class } grid-sm c2-sm c3-md mb-4">
% endif
  % for it in pagelist:
    ${ _item(it) }
  % endfor
% if not no_wrap:
</div>
% endif

<%def name="_item(it)">
  <%
  orig_img = get_main_img(it)
  if orig_img.startswith('mynd/'):
      orig_img = '/' + orig_img
  img = capture(lambda: resiz.body(orig_img, width=512, height=320, webroot=it['data']['WEBROOT'], self_url=it['url']))
  url = it['url']
  pg = it['data']['page']
  %>
  <article>
    <header>
      <a href="${ url }">
        <img src="${ img }?o=${ orig_img |u }" alt="${ pg.title |h }" width="512" height="320">
      </a>
    </header>
    <h4><a href="${ url }" class="text">${ pg.title }</a></h4>
    <p class="smaller">${ get_summary(it) } <a href="${ url }">Meira&nbsp;»</a></p>
  </article>
</%def>
