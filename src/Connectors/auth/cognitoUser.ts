import { CognitoUser } from "amazon-cognito-identity-js";
import UserPool from "../../users/UserPool";
import { InitCognitoUser, GetCognitoUser } from "./types";

let cognitoUser: null | CognitoUser = null;

const initCognitoUser: InitCognitoUser = (userName) => {
	if (userName) {
		cognitoUser = new CognitoUser({
			Username: userName,
			Pool: UserPool,
		});
	}
};

const getCognitoUser: GetCognitoUser = () => {
	return cognitoUser;
};

const resetCognitoUser = () => {
	cognitoUser = null;
};

export { initCognitoUser, getCognitoUser, resetCognitoUser };
