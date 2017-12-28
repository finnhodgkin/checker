const { search } = new URL(window.location.href);
const token =
  (search && search.split('=')[1]) || window.localStorage.getItem('token');

// const failedPosts = window.localStorage.getItem('failed');

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

app.ports.setCheckbox.subscribe(str =>
  window.localStorage.setItem('checkboxes', JSON.stringify(str))
);

app.ports.getCheckboxes.send(
  JSON.parse(window.localStorage.getItem('checkboxes'))
);
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/service-worker.js').then(function() {
    console.log('Service Worker Registered');
  });
}
