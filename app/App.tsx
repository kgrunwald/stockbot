import React from 'react';
import AppProviders from "./src/context";
import Main from './src/screens/Main'

const App = () => {
  return (
    <AppProviders>
      <Main/>
    </AppProviders>
  )
}

export default App