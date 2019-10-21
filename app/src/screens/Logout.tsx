import React from 'react';
import { StyleSheet, Text, View, Button } from 'react-native';
import {useAuth} from '../context/AuthContext'

const Logout = () => {
  const auth = useAuth()
  return (
      <View style={styles.container}>
          <Text style={styles.title}>You are logged in!</Text>
          <Button title={"Log Out"} onPress={auth.logout} />
      </View>
  )
}

const styles = StyleSheet.create({
  container: {
      flex: 1,
      backgroundColor: '#fff',
      alignItems: 'center',
      justifyContent: 'center',
  },
  title: {
      fontSize: 20,
      textAlign: 'center',
      marginTop: 40,
  },
  });

  export default Logout