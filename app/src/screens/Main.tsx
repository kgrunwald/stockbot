import React from "react";
import { createAppContainer } from "react-navigation";
import { createStackNavigator } from "react-navigation-stack";
import routeConfig from "../routeConfig";
import { useUser } from "../context/UserContext";
import Login from "./Login";

const RootStack = createStackNavigator(routeConfig);
const AppContainer = createAppContainer(RootStack);

const Main = () => {
  const { user } = useUser();
  return user ? <AppContainer /> : <Login />;
};

export default Main;
