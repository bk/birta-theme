<%page args="pages, show='title', **kwargs" />\
<%! import re %>\
<%doc>
"""
help.mdwn:[[!map pages="help/* and ! help/*/*" show="title"]]
help.mdwn:[[!map pages="leikur_ad_bokum/*" show="title"]]
leikur_ad_bokum.mdwn:[[!map pages="leikur_ad_bokum/* and ! leikur_ad_bokum/*/*"]]
mynd.mdwn:[[!map  pages="mynd/*"]]
tag.mdwn:[[!map pages="tag/* and ! tag/*/*"]]
user.mdwn:[[!map pages="user/* and ! user/*/*"]]
"""
</%doc>\
<%namespace name="pagelist" file="pagelist.mc" />\
<%
  pages = re.sub(r' and.*', '', pages)
  pages = pages.replace('*', '')
  match = {'url': pages}
%>
${ pagelist.body(match, **kwargs) }
