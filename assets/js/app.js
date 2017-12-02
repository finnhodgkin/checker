const { search } = new URL(window.location.href);
const token =
  (search && search.split('=')[1]) ||
  window.localStorage.getItem('token') ||
  null;

if (token) {
  window.localStorage.setItem('token', token);
}

window.history.replaceState({}, document.title, '/');

const elmDiv = document.getElementById('elm-container');
Elm.Main.embed(elmDiv, token);
