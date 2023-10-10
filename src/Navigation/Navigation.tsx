import { NavigationContainer } from "@react-navigation/native";
import {
	createNativeStackNavigator,
	NativeStackScreenProps,
} from "@react-navigation/native-stack";

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

const { Navigator, Screen } = createNativeStackNavigator<RootStackParamList>();

const Navigation = () => {
	return (
		<NavigationContainer>
			<Navigator initialRouteName="Intro">
				<Screen name="Intro" component={Intro} />

				<Screen name="Login" component={Login} />

				<Screen name="Signup" component={Signup} />

				<Screen name="ResetPassword" component={ResetPassword} />
			</Navigator>
		</NavigationContainer>
	);
};

export default Navigation;
