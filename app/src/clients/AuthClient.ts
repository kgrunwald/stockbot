import { AuthSession } from 'expo';
import { AsyncStorage } from 'react-native';

const localStorageKey = '__auth_token__'

const auth0ClientId = 'qVIw4i0S0Fz8vbW7SFWCwEE0sBRVuX1J';
const auth0Domain = 'https://kgrunwald.auth0.com';

function toQueryString(params) {
  return '?' + Object.entries(params)
      .map(([key, value]) => `${encodeURIComponent(key)}=${encodeURIComponent(value as any)}`)
      .join('&');
  }

const handleUserResponse = async ({id_token}) => {
  const resp = await AsyncStorage.setItem(localStorageKey, id_token)
}

const login = async () => {
  // Retrieve the redirect URL, add this to the callback URL list
  // of your Auth0 application.
  const redirectUrl = AuthSession.getRedirectUrl();
    
  // Structure the auth parameters and URL
  const queryParams = toQueryString({
    client_id: auth0ClientId,
    redirect_uri: redirectUrl,
    response_type: 'id_token', // id_token will return a JWT token
    scope: 'openid profile', // retrieve the user's profile
    nonce: 'nonce', // ideally, this will be a random value
  });
  const authUrl = `${auth0Domain}/authorize` + queryParams;

  // Perform the authentication
  const response = await AuthSession.startAsync({ authUrl });  

  if (response.type === 'success') {
    await handleUserResponse(response.params as any);
    return response.params.id_token
  }
};

const logout = async () => {
  await AsyncStorage.removeItem(localStorageKey)
}

const getToken = async () => {
  return await AsyncStorage.getItem(localStorageKey)
}

export {login, logout, getToken}