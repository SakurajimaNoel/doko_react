import {
	NavigationContainer,
	NavigatorScreenParams,
} from "@react-navigation/native";
import { createNativeStackNavigator } from "@react-navigation/native-stack";
import { createBottomTabNavigator } from "@react-navigation/bottom-tabs";
import { UserContext } from "../context/userContext";
import { useContext } from "react";

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
	Friends: undefined;
	CreatePost: undefined;
};
const ProfileStack = createNativeStackNavigator<ProfileStackParamList>();

import Home from "../Screens/User/Home";
import Nearby from "../Screens/User/Nearby";
import Search from "../Screens/User/Search";
import Profile from "../Screens/User/Profile";
import EditProfile from "../Screens/User/Profile/Screen/EditProfile";
import Friends from "../Screens/User/Profile/Screen/Friends";
import Post from "../Screens/User/Profile/Screen/Post";

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
			<ProfileStack.Screen
				name="Friends"
				component={Friends}
				options={{ title: "Friends" }}
			/>
			<ProfileStack.Screen
				name="CreatePost"
				component={Post}
				options={{ title: "Create New Post" }}
			/>
		</ProfileStack.Navigator>
	);
}

const Navigation = () => {
	const user = useContext(UserContext);

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
