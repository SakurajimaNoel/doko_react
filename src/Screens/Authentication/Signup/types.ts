import type { NativeStackScreenProps } from "@react-navigation/native-stack";

import { RootStackParamList } from "../../../Navigation/Navigation";

type NavigationProps = NativeStackScreenProps<RootStackParamList, "Signup">;

export interface SignupProps {
	navigation: NavigationProps["navigation"];
}

export interface HandleSignupParams {
	email: string;
	name: string;
	password: string;
	confirmPassword: string;
}

export interface HandleConfirmPasswordParams {
	resetCode: string;
	password: string;
	confirmPassword: string;
}
