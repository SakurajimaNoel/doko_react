import type { BottomTabScreenProps } from "@react-navigation/bottom-tabs";
import { RootTabParamList } from "../../../Navigation/Navigation";

type NavigationProps = BottomTabScreenProps<RootTabParamList, "Profile">;

export interface ProfileProps {
	navigation: NavigationProps["navigation"];
}

export type Steps = 1 | 2 | 3;

export interface UserInfo {
	username: string;
	dob: Date;
	bio?: string;
	profilePicture?: string;
	imageExtension?: string;
	imageType?: string;
}

export interface UsernameProps {
	handleNext: () => void;
	accessToken: string;
	setUserInfo: React.Dispatch<React.SetStateAction<UserInfo>>;
	userName: string;
}

export interface UserDetailsProps {
	handleNext: () => void;
	handlePrev: () => void;
	setUserInfo: React.Dispatch<React.SetStateAction<UserInfo>>;
	userInfo: UserInfo;
}

export interface ProfilePictureProps {
	handlePrev: () => void;
	setUserInfo: React.Dispatch<React.SetStateAction<UserInfo>>;
	userInfo: UserInfo;
	handleProfileCreate: () => void;
}

export interface ProfileModalProps {
	openModal: boolean;
	setOpenModal: React.Dispatch<React.SetStateAction<boolean>>;
	handleCamera: () => void;
	handleGallery: () => void;
}

export type HandleSteps = (prev?: boolean) => void;

export interface UserProfileProps {
	navigation: NavigationProps["navigation"];
}

export interface CompleteUser {
	bio: string;
	dob: string;
	email: string;
	name: string;
	username: string;
	profilePicture: string;
	friends: {
		id: string;
		name: string;
		username: string;
		profilePicture: string;
	}[];
	posts:
		| {
				id: string;
				content: string;
				caption: string;
				likes: string;
		  }[];
}
