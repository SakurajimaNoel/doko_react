import * as AWS from "aws-sdk";
import { IamAccess } from "./types";

export const iamAccess: IamAccess = (idToken) => {
	AWS.config.update({ region: "ap-south-1" });

	const credentials = new AWS.CognitoIdentityCredentials({
		IdentityPoolId: "ap-south-1:be985ba0-fa08-4b08-933a-4bdabaa2fcc2", // your identity pool id here
		Logins: {
			// Change the key below according to the specific region your user pool is in.
			"cognito-idp.ap-south-1.amazonaws.com/ap-south-1_7y9RKbI3j":
				idToken,
		},
	});

	return credentials;
};
