import type { NativeStackScreenProps } from "@react-navigation/native-stack";
import { CognitoUserSession } from "amazon-cognito-identity-js";

import { RootStackParamList } from "../../Navigation/Navigation";

type NavigationProps = NativeStackScreenProps<RootStackParamList, "Intro">;

export interface IntroProps {
	navigation: NavigationProps["navigation"];
}

export type HandleUserSession = (session: CognitoUserSession) => void;
