import type { BottomTabScreenProps } from "@react-navigation/bottom-tabs";
import { RootTabParamList } from "../../../Navigation/Navigation";

type NavigationProps = BottomTabScreenProps<RootTabParamList, "Nearby">;

export interface NearbyProps {
	navigation: NavigationProps["navigation"];
}
