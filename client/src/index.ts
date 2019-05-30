import { WebAuth } from 'auth0-js';
// @ts-ignore
import { Elm } from './Main.elm';

interface Stored {
  cred: { token: string; exp: number };
  profile: { username: string; bio: string };
}

const storageKey = 'store';

// check if storageKey exists
try {
  JSON.parse(localStorage.getItem(storageKey));
} catch (e) {
  // set empty if it doesn't exist
  localStorage.setItem(storageKey, '{}')
}

// delete jwt if it has expired
try {
  const stored = JSON.parse(localStorage.getItem(storageKey));
  if (new Date(stored.cred.exp * 1000) < new Date())
    localStorage.setItem(storageKey, 'null');
} catch (e) {}

const auth = new WebAuth({
  domain: 't485.auth0.com',
  clientID: '0KDLPs5urmZmeE60gwwB93jrjCG6gjCM',
  responseType: 'token id_token',
  scope: 'openid',
  audience: 'https://db-api',
  redirectUri: window.location.origin + '/login',
});

const app = Elm.Main.init({
  flags: JSON.parse(localStorage.getItem(storageKey)),
});

// send to elm and sync with localstorage
function send(payload: Stored | null) {
  app.ports.receiveAuth.send(payload);
  localStorage.setItem(storageKey, JSON.stringify(payload));
}

// handle login token in hash if present
auth.parseHash(function(err, authResult) {
  if (authResult && authResult.accessToken && authResult.idToken) {
    window.location.hash = '';
    console.log(authResult);
    send({
      cred: {
        token: authResult.accessToken,
        exp: authResult.idTokenPayload.exp,
      },
      profile: authResult.idTokenPayload['https://t485.org/metadata'],
    });
  } else if (err) {
    console.error(err);
  }
});

app.ports.requestAuth.subscribe(({ type }) => {
  if (type === 'login_google') {
    console.log('logging in via google...');
    auth.authorize({ connection: 'google-oauth2' });
  } else if (type === 'login_password') {
    console.log('logging in via password...');
    auth.authorize({ connection: 'Username-Password-Authentication' });
  } else if (type === 'logout') {
    console.log('logged out');
    send(null);
  } else {
    console.warn(`Unknown requestAuth message from elm of type "${type}"`);
  }
});

// Whenever localStorage changes in another tab, report it if necessary.
window.addEventListener(
  'storage',
  event => {
    if (event.storageArea === localStorage && event.key === storageKey)
      app.ports.receiveAuth.send(JSON.parse(event.newValue));
  },
  false
);
