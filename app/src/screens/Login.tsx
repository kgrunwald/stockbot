import React from "react";
import { StyleSheet, Text, View, Button } from "react-native";
import { Feather } from "@expo/vector-icons";
import { Image } from "react-native";
import { useAuth } from "../context/AuthContext";

const Login = () => {
  const auth = useAuth();
  return (
    <View style={styles.mainContainer}>
      <View style={styles.titleContainer}>
        <Image
          source={require("../../assets/money-bot.png")}
          style={{ width: 100, height: 100 }}
        />
        <Text style={styles.title}>StockBot</Text>
      </View>
      <Button color="#EB5424" title="Log in with Auth0" onPress={auth.login} />
      <View />
    </View>
  );
};

const styles = StyleSheet.create({
  mainContainer: {
    flex: 1,
    backgroundColor: "#fff",
    alignItems: "center",
    justifyContent: "space-around"
  },
  titleContainer: {
    backgroundColor: "#fff",
    alignItems: "center",
    justifyContent: "center"
  },
  title: {
    fontSize: 40,
    textAlign: "center",
    marginTop: 20,
    fontFamily: "Courier-Bold",
    fontWeight: "400"
  }
});

export default Login;
