export interface User {
	name: string;
	accessToken: string;
	expireAt: number;
	refreshToken: string;
	idToken: string;
	username: string;
	email: string;
	displayUsername?: string;
	completeProfile?: boolean;
	profilePicture?: string;
}

export type SetUser = React.Dispatch<React.SetStateAction<User | null>>;

interface UserType {
	user: User | null;
	setUser: SetUser;
}

export type UserContextType = UserType;
