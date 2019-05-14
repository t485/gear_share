import { Elm } from './Main.elm';

const storageKey = 'store';

// delete jwt if it has expired
try {
  const jwt = localStorage.getItem(storageKey);
  const payload = JSON.parse(atob(jwt.split('.')[1]));
  if (new Date(payload.exp * 1000) < new Date())
    localStorage.setItem(storageKey, '');
} catch (e) {}

const flags = localStorage.getItem(storageKey);
const app = Elm.Main.init({ flags: flags });

app.ports.storeCache.subscribe(val => {
  console.log('[js] storing in cache: ' + val);
  if (val === null) {
    localStorage.removeItem(storageKey);
  } else {
    localStorage.setItem(storageKey, JSON.stringify(val));
  }

  // Report that the new session was stored succesfully.
  setTimeout(function() {
    app.ports.onStoreChange.send(val);
  }, 0);
});

// Whenever localStorage changes in another tab, report it if necessary.
window.addEventListener(
  'storage',
  event => {
    if (event.storageArea === localStorage && event.key === storageKey) {
      app.ports.onStoreChange.send(event.newValue);
    }
  },
  false
);
