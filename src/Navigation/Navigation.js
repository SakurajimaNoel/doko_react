import { NavigationContainer } from "@react-navigation/native";
import { createNativeStackNavigator } from "@react-navigation/native-stack";

import Intro from "../Screens/Intro";
import Login from "../Screens/Authentication/Login";
import Signup from "../Screens/Authentication/Signup";
import ResetPassword from "../Screens/Authentication/ResetPassword";

const { Navigator, Screen } = createNativeStackNavigator();

const Navigation = () => {
	return (
		<NavigationContainer>
			<Navigator initialRouteName="Intro">
				<Screen name="Intro" component={Intro} />

				<Screen name="Login" component={Login} />

				<Screen name="Signup" component={Signup} />

				<Screen name="Reset Password" component={ResetPassword} />
			</Navigator>
		</NavigationContainer>
	);
};

export default Navigation;
