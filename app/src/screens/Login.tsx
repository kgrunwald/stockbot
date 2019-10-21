import React from "react";
import { StyleSheet, Text, View, Button } from "react-native";
import { useAuth } from "../context/AuthContext";

const Login = () => {
  const auth = useAuth()
  return (
    <View style={styles.container}>
      {<Button title="Log in with Auth0" onPress={auth.login} />}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#fff",
    alignItems: "center",
    justifyContent: "center"
  },
  title: {
    fontSize: 20,
    textAlign: "center",
    marginTop: 40
  }
});

export default Login;
