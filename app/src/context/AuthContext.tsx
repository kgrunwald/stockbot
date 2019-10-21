import React, { useState } from "react";
import * as authClient from "../clients/AuthClient";

const AuthContext = React.createContext({
  token: undefined,
  login: undefined,
  logout: undefined
});

const AuthProvider = props => {
  const [token, setToken] = useState(undefined);
  const login = async () => {
    const token = await authClient.login();
    setToken(token)
  }
  const logout = async () => {
    authClient.logout();
    setToken(undefined)
  }
  authClient.getToken(setToken);
  return <AuthContext.Provider value={{ token, login, logout }} {...props} />;
};
const useAuth = () => {
  const context = React.useContext(AuthContext);
  if (context === undefined) {
    throw new Error(`useAuth must be used within a AuthProvider`);
  }
  return context;
};
export { AuthProvider, useAuth };
