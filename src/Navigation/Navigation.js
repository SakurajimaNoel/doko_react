import { NavigationContainer } from "@react-navigation/native";
import { createNativeStackNavigator } from "@react-navigation/native-stack";

import Intro from "../Screens/Intro";
import Login from "../Screens/Authentication/Login";

const { Navigator, Screen } = createNativeStackNavigator();

const Navigation = () => {
	return (
		<NavigationContainer>
			<Navigator initialRouteName="Login">
				<Screen name="Intro" component={Intro} />

				<Screen name="Login" component={Login} />
			</Navigator>
		</NavigationContainer>
	);
};

export default Navigation;
