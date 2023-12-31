<%! import re, random %>
<%namespace name="icons" file="/lib/icons.mc" />
<%namespace name="summary" file="/lib/summary.mc" />


<%def name="nav_sub(nav_item, current_url='')">
<%doc>
  Navigation items, possibly nested.
</%doc>
  % if not nav_item.children:
    <li role="menuitem">
      <a href="${ nav_item.url | url }" class="${ 'active' if nav_item.contains_url(current_url, url, best=True)  else '' }">${ nav_item.title }</a>
    </li>
  % else:
    <li role="menuitem" class="${ 'active' if nav_item.contains_url(current_url, url, best=False) else '' }">
      <span>${ nav_item.title }:</span>
      <ul role="group">
        % for it in nav_item:
          ${ nav_sub(it, current_url) }
        % endfor
      </ul>
    </li>
  % endif
</%def>

<%def name="tags()">
  <%doc>
    Simple list of tags for this page.
  </%doc>
  % if page and page.tags:
    <div class="tagged-with mt-5">
      <p class="m-0">
        % for i, tag in enumerate(page.tags):
          <% taglink = 'flokkar/' + slugify(tag) %>
          <a href="${ taglink | url }" class="tag mr-1">${ tag }</a>
        % endfor
      </p>
    </div>
  % endif
</%def>

<%def name="maybe_auto_title()">
<%doc>
  If there is no <h1> at the start of CONTENT, place the page title above it,
  but only if site.auto_title_h1 is true and page.no_auto_title_h1 is not.
</%doc>
<%
if not site.auto_title_h1 or (page and page.no_auto_title_h1):
    return ''
subtitle = page.subtitle if page and page.subtitle else None
subtitle_date = (page.pubdate or page.date) if page.date_as_subtitle else None
date_comp = LOOKUP.get_template(page.date_comp) if page.date_comp and LOOKUP else None
%>
  % if page and page.title and CONTENT and not CONTENT.startswith('<h1'):
      <% page._added_auto_title = page.title %>
      <h1 id="auto-${ page.title | slugify }">${ page.title }</h1>
      % if subtitle:
        <p class="subtitle">${ subtitle }</p>
      % endif
      % if subtitle_date:
        <p class="subtitle date">${ date_comp.render(subtitle_date) if date_comp else date_short(subtitle_date) }
      % endif
  % endif
</%def>

<%def name="dates()">
  % if page and page.show_dates and (page.date or page.created_date or page.gitdate):
    <%
      # NOTE: sorting is by page.date, but created_date is more accurate if present
      cdate = page.pubdate or page.created_date or page.date
      mdate = page.modified_date or MTIME  # NOTE: perhaps disregard MTIME later
      dfmt = '%-d.%-m. %Y kl. %-H:%M'
    %>
    <div class="pagedate mt-5 text-muted smaller ta-c">
      % if mdate and mdate != cdate:
        <div class="mtime">Síðast breytt <time datetime="${ mdate | date_to_iso }Z" class="relativedate" title="${ mdate | date_to_iso }">${ mdate | date(fmt=dfmt) }</time></div>
      % endif
      <div class="ctime">Síða stofnuð <time datetime="${ cdate | date_to_iso }Z" class="relativedate" title="${ cdate | date_to_iso }">${ cdate | date(fmt=dfmt) }</time></div>
     <div id="pagehits">&nbsp;</div>
   </div>
 % endif
</%def>

<%def name="maybe_bottom_teasers()">
  % if page and page.tags:
    <%
    found = MDCONTENT.has_tag(page.tags) or []
    if found:
        random.shuffle(found)
        found = found[:7]
        found = [_ for _ in found if _['data']['SELF_URL'] != SELF_URL]
        found = found[:6]
    %>
    % if found:
      <div class="bg-contrast full container items-fixed items-max-md pt-3 pb-3">
        <div class="other-pages mt-4">
          <h2 class="fp-section text-muted">Aðrar síður í ${ 'þessum flokkum' if len(page.tags)>1 else 'sama flokki' }</h2>
          ${ summary.body(found, no_intro=True) }
        </div>
      </div>
    % else:
      <div style="height:5rem">&nbsp;</div>
    % endif
  % else:
      <div style="height:5rem">&nbsp;</div>
  % endif
</%def>
