const feedback = document.getElementById('results');
const searchfield = document.getElementById('searchfield');

async function do_search (backend) {
  let url = new URL(document.location);
  let query = url.searchParams.get('q');
  if (! query) return;
  form_data = new FormData();
  form_data.append("query", query);
  document.title = 'Leitarniðurstöður: ' + query;
  feedback.innerHTML = 'Augnablik... framkvæmi leit';
  const response = await fetch(backend, {
    method: 'POST',
    cache: "no-cache",
    body: form_data,
  });
  const results = await response.json();
  show_results(query, results);
}

function show_results(query, results) {
  searchfield.value = query;
  if (! results.length) {
    feedback.innerHTML = '<div class="admonition"><p>Ekkert fannst með þessum leitarskilyrðum.</p></div>';
    return;
  }
  let html = results.length > 1 ? `<p class="text-muted">${results.length} síður fundust.</p>` : '<p class="text-muted">Ein síða fannst.</p>';
  html += '<div class="pagelist-summary results grid-sm c2-sm c3-md mb-4">';
  for (const item  of results) {
    const img = item.image ? item.image : '/img/fallback.jpg';
    html += `
     <article>
      <header><a href="${item.url}"><img src="${img}" alt="${item.title}" width="512" height="320"></a></header>
      <h4><a href="${item.url}" class="text">${ item.title }</a></h4>
      <p class="smaller">${ item.summary } <a href="${item.url}">Meira&nbsp;»</a></p>
     </article>
`;
    }
    html += '<div></div><div></div>';
    html += '</div>';
    feedback.innerHTML = html;
}
