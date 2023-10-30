import { CognitoUserSession } from "amazon-cognito-identity-js";

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

export type IamAccess = (idToken: string) => AWS.CognitoIdentityCredentials;
