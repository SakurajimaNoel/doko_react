import type { BottomTabScreenProps } from "@react-navigation/bottom-tabs";
import {
	ProfileStackParamList,
	RootTabParamList,
} from "../../../Navigation/Navigation";
import { NativeStackScreenProps } from "@react-navigation/native-stack";

type NavigationProps = BottomTabScreenProps<RootTabParamList, "Profile">;

type EditProfileNavigationProps = NativeStackScreenProps<
	ProfileStackParamList,
	"EditProfile"
>;

type PostNavigatioProps = NativeStackScreenProps<
	ProfileStackParamList,
	"CreatePost"
>;

type PostItemNavigationProps = NativeStackScreenProps<
	ProfileStackParamList,
	"PostItem"
>;

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
	creating: boolean;
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

export interface Post {
	id: string;
	content: string[];
	caption: string;
	likes: string;
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
	posts: Post[];
}

export interface EditProfileProps {
	route: EditProfileNavigationProps["route"];
	navigation: EditProfileNavigationProps["navigation"];
}

export interface CreatePostProps {
	navigation: PostNavigatioProps["navigation"];
}

export interface PostItemProps {
	navigation: PostItemNavigationProps["navigation"];
	route: PostItemNavigationProps["route"];
}

export interface UpdateProfileImageProps {
	profileImage: string;
	navigation: EditProfileNavigationProps["navigation"];
}

export interface ProfileImageDetails {
	profilePicture: string;
	imageExtension: string;
	imageType: string;
}

export interface ProfileImageModalProps {
	toggleModal: () => void;
	openModal: boolean;
	handleDelete: (show: boolean) => void;
	setError: React.Dispatch<React.SetStateAction<string | null>>;
	setMessage: React.Dispatch<React.SetStateAction<string | null>>;
	navigation: EditProfileNavigationProps["navigation"];
}

export interface PostsProps {
	posts: Post[];
	navigation: NavigationProps["navigation"];
	allow: boolean;
}
