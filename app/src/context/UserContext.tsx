import React from 'react'
import {useAuth} from './AuthContext'

const UserContext = React.createContext({
  token: undefined
})

const UserProvider = (props) => {
  const {
    token
  } = useAuth()
  return <UserContext.Provider value={{token}} {...props} />
}

const useUser = () => {
  const context = React.useContext(UserContext)
  if (context === undefined) {
    throw new Error(`useUser must be used within a UserProvider`)
  }
  return context
}

export {UserProvider, useUser}