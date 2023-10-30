import { CognitoUserSession, CognitoUser } from "amazon-cognito-identity-js";

export interface TokenState {
	token: string;
	expTime: string;
	issuedAt: string;
}

interface AuthState {
	accessToken: TokenState;
	idToken: TokenState;
	refreshToken: string;
	name: string;
	email: string;
	username: string;
	completeProfile: boolean;
	awsUsername: string;
}

export type UserTokenDetails = (payload: CognitoUserSession) => AuthState;

export type InitCognitoUser = (userName: string) => void;

export type GetCognitoUser = () => CognitoUser | null;

export type InitAWSCredentials = (idToken: string) => void;

export type GetAWSCredentials = () => null | AWS.CognitoIdentityCredentials;
