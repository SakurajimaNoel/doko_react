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

export interface SendCodeProps {
	handleForgotPassword: (values: HandleForgotPasswordParams) => void;
	isLoading: boolean;
}

export interface ChangePasswordProps {
	handleConfirmForgotPassword: (values: HandleConfirmPasswordParams) => void;
	isLoading: boolean;
}
