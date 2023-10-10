import type { NativeStackScreenProps } from "@react-navigation/native-stack";

import { RootStackParamList } from "../../../Navigation/Navigation";

type NavigationProps = NativeStackScreenProps<
	RootStackParamList,
	"ResetPassword"
>;

export interface ResetPasswordProps {
	navigation: NavigationProps["navigation"];
}

export interface HandleForgotPasswordParams {
	email: string;
}

export interface HandleConfirmPasswordParams {
	resetCode: string;
	password: string;
	confirmPassword: string;
}
