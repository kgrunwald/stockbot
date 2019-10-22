import React from "react";
import { useAuth } from "./AuthContext";
import jwtDecode from "jwt-decode";

const UserContext = React.createContext({
  user: undefined
});

const UserProvider = props => {
  const { token } = useAuth();

  const user = token ? jwtDecode(token) : undefined;

  return <UserContext.Provider value={{ user }} {...props} />;
};

const useUser = () => {
  const context = React.useContext(UserContext);
  if (context === undefined) {
    throw new Error(`useUser must be used within a UserProvider`);
  }
  return context;
};

export { UserProvider, useUser };
