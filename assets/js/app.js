const { search } = new URL(window.location.href);
const token =
  (search && search.split('=')[1]) || window.localStorage.getItem('token');

if (token) {
  window.localStorage.setItem('token', token);
}

window.history.replaceState({}, document.title, '/');

const elmDiv = document.getElementById('elm-container');
const app = Elm.Main.embed(elmDiv, token);

const online = (navigator.onLine && 'online') || 'offline';

app.ports.isOnline.send(online);

const handleConnectionChange = event => app.ports.isOnline.send(event.type);

window.addEventListener('online', handleConnectionChange);
window.addEventListener('offline', handleConnectionChange);

app.ports.logOut.subscribe(() => window.localStorage.removeItem('token'));

app.ports.setLists.subscribe(str =>
  window.localStorage.setItem('checklists', JSON.stringify(str))
);

app.ports.getChecklists.send(
  JSON.parse(window.localStorage.getItem('checklists'))
);

app.ports.setCheckboxes.subscribe(str => {
  const { id } = str;
  const { checkboxes } = str;
  window.localStorage.setItem(`checkbox_${id}`, JSON.stringify(checkboxes));
});

app.ports.getCheckboxes.subscribe(id => {
  app.ports.sendStoredCheckboxes.send(
    JSON.parse(window.localStorage.getItem(`checkbox_${id}`))
  );
});

app.ports.setFailures.subscribe(str => {
  window.localStorage.setItem('failures', JSON.stringify(str));
});

app.ports.getFailures.send(JSON.parse(window.localStorage.getItem('failures')));

app.ports.clearFailures.subscribe(_ =>
  window.localStorage.removeItem('failures')
);

if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/service-worker.js').then(function() {
    console.log('Service Worker Registered');
  });
}
