import type { BottomTabScreenProps } from "@react-navigation/bottom-tabs";
import { RootTabParamList } from "../../../Navigation/Navigation";

type NavigationProps = BottomTabScreenProps<RootTabParamList, "Search">;

export interface SearchProps {
	navigation: NavigationProps["navigation"];
}
