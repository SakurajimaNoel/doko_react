import { CognitoUserSession, CognitoUser } from "amazon-cognito-identity-js";

interface AuthState {
	accessToken: string;
	idToken: string;
	refreshToken: string;
	expireAt: number;
	name: string;
	email: string;
	username: string;
}

interface TokenState {
	accessToken: string;
	idToken: string;
	refreshToken: string;
	expireAt: number;
}

export type UserTokenDetails = (payload: CognitoUserSession) => AuthState;

export type UserTokens = (payload: CognitoUserSession) => TokenState;

export type NeedsRefresh = (expAt: number) => boolean;

export type RefreshTokens = (refreshToken: string) => TokenState | {};

export type InitCognitoUser = (userName: string) => void;

export type GetCognitoUser = () => CognitoUser | null;

export type InitAWSCredentials = (idToken: string) => void;

export type GetAWSCredentials = () => null | AWS.CognitoIdentityCredentials;
