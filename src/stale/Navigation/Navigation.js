import { NavigationContainer } from "@react-navigation/native";
import { createNativeStackNavigator } from "@react-navigation/native-stack";

import Home from "../screens/Home";

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
			</Navigator>
		</NavigationContainer>
	);
};

export default Navigation;
