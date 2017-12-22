const { search } = new URL(window.location.href);
const token =
  (search && search.split('=')[1]) ||
  window.localStorage.getItem('token') ||
  null;

const failedPosts = window.localStorage.getItem('failed') || null;

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
