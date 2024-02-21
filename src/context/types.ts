export interface User {
	name: string;
	username: string;
	email: string;
	displayUsername?: string;
	completeProfile?: boolean;
	profilePicture?: string;
	accessToken: string;
	expireAt: number;
	refreshToken: string;
	idToken: string;
}

export interface Payload {
	name?: string;
	username?: string;
	email?: string;
	displayUsername?: string;
	completeProfile?: boolean;
	profilePicture?: string;
	accessToken?: string;
	expireAt?: number;
	refreshToken?: string;
	idToken?: string;
}

export enum UserActionKind {
	INIT = "init",
	COMPLETE = "complete",
	UPDATE = "update",
	ERASE = "erase",
	TOKEN = "token",
}

export interface UserAction {
	type: UserActionKind;
	payload: Payload | null;
}
