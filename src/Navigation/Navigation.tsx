import { NavigationContainer } from "@react-navigation/native";
import { createNativeStackNavigator } from "@react-navigation/native-stack";
import { createBottomTabNavigator } from "@react-navigation/bottom-tabs";
import { useAppSelector } from "../hooks/reduxHooks";
import { UserContext } from "../context/userContext";
import { useEffect, useContext } from "react";
import * as AWS from "aws-sdk";

import { initAWSCredentials, getAWSCredentials } from "../Connectors/auth/aws";

import Intro from "../Screens/Intro";
import Login from "../Screens/Authentication/Login";
import Signup from "../Screens/Authentication/Signup";
import ResetPassword from "../Screens/Authentication/ResetPassword";
export type RootStackParamList = {
	Intro: undefined;
	Login: undefined;
	Signup: undefined;
	ResetPassword: undefined;
};
const Stack = createNativeStackNavigator<RootStackParamList>();

import Home from "../Screens/User/Home";
import Nearby from "../Screens/User/Nearby";
import Search from "../Screens/User/Search";
import Profile from "../Screens/User/Profile";
export type RootTabParamList = {
	Home: undefined;
	Nearby: undefined;
	Profile: undefined;
	Search: undefined;
};
const Tab = createBottomTabNavigator<RootTabParamList>();

const Navigation = () => {
	const user = useContext(UserContext);

	// useEffect(() => {
	// 	if (auth.status) {
	// 		initAWSCredentials(auth.idToken);
	// 	}
	// }, [auth.idToken]);

	return (
		<NavigationContainer>
			{user?.user ? (
				<>
					<Tab.Navigator initialRouteName="Home">
						<Tab.Screen name="Home" component={Home} />
						<Tab.Screen name="Nearby" component={Nearby} />
						<Tab.Screen name="Search" component={Search} />
						<Tab.Screen
							name="Profile"
							component={Profile}
							options={{ title: user.user.name }}
						/>
					</Tab.Navigator>
				</>
			) : (
				<>
					<Stack.Navigator initialRouteName="Intro">
						<Stack.Screen name="Intro" component={Intro} />
						<Stack.Screen name="Login" component={Login} />
						<Stack.Screen name="Signup" component={Signup} />
						<Stack.Screen
							name="ResetPassword"
							component={ResetPassword}
						/>
					</Stack.Navigator>
				</>
			)}
		</NavigationContainer>
	);
};

export default Navigation;
