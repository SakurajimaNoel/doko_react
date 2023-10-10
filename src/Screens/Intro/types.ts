import type { NativeStackScreenProps } from "@react-navigation/native-stack";

import { RootStackParamList } from "../../Navigation/Navigation";

type NavigationProps = NativeStackScreenProps<RootStackParamList, "Intro">;

export interface IntroProps {
	navigation: NavigationProps["navigation"];
}
