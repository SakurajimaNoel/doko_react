export enum UserActionKind {
	INIT = "init",
	COMPLETE = "complete",
	UPDATE = "update",
	ERASE = "erase",
	TOKEN = "token",
}

export enum ProfileStatusKind {
	PENDING = "pending",
	INCOMPLETE = "incomplete",
	COMPLETE = "complete",
}

export interface User {
	name: string;
	username: string;
	email: string;
	displayUsername?: string;
	profileStatus: ProfileStatusKind;
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
	profileStatus?: ProfileStatusKind;
	profilePicture?: string;
	accessToken?: string;
	expireAt?: number;
	refreshToken?: string;
	idToken?: string;
}

export interface UserAction {
	type: UserActionKind;
	payload: Payload | null;
}
