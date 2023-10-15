import type { BottomTabScreenProps } from "@react-navigation/bottom-tabs";
import { RootTabParamList } from "../../../Navigation/Navigation";

type NavigationProps = BottomTabScreenProps<RootTabParamList, "Profile">;

export interface ProfileProps {
	navigation: NavigationProps["navigation"];
}
