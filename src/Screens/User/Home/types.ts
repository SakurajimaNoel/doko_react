import type { BottomTabScreenProps } from "@react-navigation/bottom-tabs";
import { RootTabParamList } from "../../../Navigation/Navigation";

type NavigationProps = BottomTabScreenProps<RootTabParamList, "Home">;

export interface HomeProps {
	navigation: NavigationProps["navigation"];
}
