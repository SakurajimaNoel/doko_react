import type { NativeStackScreenProps } from "@react-navigation/native-stack";

import { RootStackParamList } from "../../../Navigation/Navigation";

type NavigationProps = NativeStackScreenProps<RootStackParamList, "Login">;

export interface LoginProps {
	navigation: NavigationProps["navigation"];
}

export interface HandleLoginParams {
	email: string;
	password: string;
}
