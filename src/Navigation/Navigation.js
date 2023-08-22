import { NavigationContainer } from "@react-navigation/native";
import { createNativeStackNavigator } from "@react-navigation/native-stack";

import Home from "../screens/Home";
// import Login from "../screens/Login";
// import Signup from "../screens/Signup";
// import Profile from "../screens/Profile";
// import ConfirmSignup from "../screens/ConfirmSignup";

import CreateUserProfile from "../screens/ApolloClient/Profile/CreateUserProfile";
import SendReq from "../screens/ApolloClient/Connections/Friends/SendReq";
import ViewReq from "../screens/ApolloClient/Connections/Friends/ViewReq";

const { Navigator, Screen } = createNativeStackNavigator();

const Navigation = () => {
	return (
		<NavigationContainer>
			<Navigator initialRouteName="Home">
				<Screen name="Home" component={Home} />

				<Screen
					name="CreateUserProfile"
					component={CreateUserProfile}
				/>

				<Screen name="SendFriendRequest" component={SendReq} />

				<Screen name="ViewFriendRequest" component={ViewReq} />

				{/* <Screen name="Login" component={Login} />

				<Screen name="Profile" component={Profile} />

				<Screen name="Signup" component={Signup} />

				<Screen name="ConfirmSignup" component={ConfirmSignup} />

				<Screen name="CreateProfile" component={CreateProfile} /> */}
			</Navigator>
		</NavigationContainer>
	);
};

export default Navigation;
