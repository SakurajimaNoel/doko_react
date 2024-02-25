import {
	NavigationContainer,
	NavigatorScreenParams,
} from "@react-navigation/native";
import { createNativeStackNavigator } from "@react-navigation/native-stack";
import { createBottomTabNavigator } from "@react-navigation/bottom-tabs";
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

export type ProfileStackParamList = {
	ProfileInfo: undefined;
	EditProfile: {
		name: string;
		bio: string;
		username: string;
		profilePicture: string;
	};
};
const ProfileStack = createNativeStackNavigator<ProfileStackParamList>();

import Home from "../Screens/User/Home";
import Nearby from "../Screens/User/Nearby";
import Search from "../Screens/User/Search";
import Profile from "../Screens/User/Profile";
import EditProfile from "../Screens/User/Profile/components/EditProfile";
export type RootTabParamList = {
	Home: undefined;
	Nearby: undefined;
	Profile: NavigatorScreenParams<ProfileStackParamList>;
	Search: undefined;
};
const Tab = createBottomTabNavigator<RootTabParamList>();

function ProfileStackScreen() {
	const user = useContext(UserContext);

	return (
		<ProfileStack.Navigator initialRouteName="ProfileInfo">
			<ProfileStack.Screen
				name="ProfileInfo"
				component={Profile}
				options={{ title: user?.name }}
			/>
			<ProfileStack.Screen
				name="EditProfile"
				component={EditProfile}
				options={{ title: "Edit" }}
			/>
		</ProfileStack.Navigator>
	);
}

const Navigation = () => {
	const user = useContext(UserContext);

	// useEffect(() => {
	// 	if (auth.status) {
	// 		initAWSCredentials(auth.idToken);
	// 	}
	// }, [auth.idToken]);

	return (
		<NavigationContainer>
			{user ? (
				<>
					<Tab.Navigator initialRouteName="Home">
						<Tab.Screen name="Home" component={Home} />
						<Tab.Screen name="Nearby" component={Nearby} />
						<Tab.Screen name="Search" component={Search} />
						<Tab.Screen
							name="Profile"
							component={ProfileStackScreen}
							options={{
								headerShown: false,
								title: user.name,
							}}
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
