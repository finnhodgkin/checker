const { search } = new URL(window.location.href);
const token = search ? search.split('=')[1] : null;

window.history.replaceState({}, document.title, '/');

const elmDiv = document.getElementById('elm-container');
Elm.Main.embed(elmDiv, token);
