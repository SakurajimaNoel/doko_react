import { NavigationContainer } from "@react-navigation/native";
import { createNativeStackNavigator } from "@react-navigation/native-stack";
import { useRecoilValue } from "recoil";
import { userState } from "../recoil/atoms/user";

import Home from "../screens/Home";
import Login from "../screens/Login";
import Signup from "../screens/Signup";
import Profile from "../screens/Profile";
import ConfirmSignup from "../screens/ConfirmSignup";
import CreateProfile from "../screens/CreateProfile";

const { Navigator, Screen } = createNativeStackNavigator();

const Navigation = () => {
	return (
		<NavigationContainer>
			<Navigator initialRouteName="CreateProfile">
				<Screen name="Home" component={Home} />

				<Screen name="Login" component={Login} />

				<Screen name="Profile" component={Profile} />

				<Screen name="Signup" component={Signup} />

				<Screen name="ConfirmSignup" component={ConfirmSignup} />

				<Screen name="CreateProfile" component={CreateProfile} />
			</Navigator>
		</NavigationContainer>
	);
};

export default Navigation;
