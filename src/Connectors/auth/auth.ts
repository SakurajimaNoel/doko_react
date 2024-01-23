import {
	CognitoRefreshToken,
	CognitoUserSession,
} from "amazon-cognito-identity-js";
import { getCognitoUser } from "./cognitoUser";
import { initAWSCredentials } from "./aws";
import {
	NeedsRefresh,
	RefreshTokens,
	UserTokenDetails,
	UserTokens,
} from "./types";

export const userTokenDetails: UserTokenDetails = (payload) => {
	let decodedAccess = payload.getAccessToken().decodePayload();
	let decodedId = payload.getIdToken().decodePayload();

	// accesstoken
	let accessToken = payload.getAccessToken().getJwtToken();
	let expireAt = payload.getAccessToken().getExpiration();
	console.log(accessToken);

	//idtoken
	let idToken = payload.getIdToken().getJwtToken();
	let refreshToken = payload.getRefreshToken().getToken();

	let name = decodedId.name ? decodedId.name : "dokiii";
	let email = decodedId.email;
	let username = decodedAccess.username;

	let userDetails = {
		accessToken,
		idToken,
		refreshToken,
		expireAt,
		name,
		username,
		email,
	};
	initAWSCredentials(idToken);

	return userDetails;
};

const userTokens: UserTokens = (payload) => {
	let accessToken = payload.getAccessToken().getJwtToken();
	console.log(accessToken);

	let idToken = payload.getIdToken().getJwtToken();
	let refreshToken = payload.getRefreshToken().getToken();
	let expireAt = payload.getAccessToken().getExpiration();

	let tokens = {
		accessToken,
		idToken,
		refreshToken,
		expireAt,
	};
	initAWSCredentials(idToken);

	return tokens;
};

export const needsRefresh: NeedsRefresh = (expAt) => {
	let curr: number = Math.round(Date.now() / 1000);

	return expAt - curr <= 300;
};

export const refreshTokens: RefreshTokens = async (refreshToken) => {
	const cognitoUser = getCognitoUser();
	const refreshDetails = new CognitoRefreshToken({
		RefreshToken: refreshToken,
	});

	try {
		const session: CognitoUserSession = await new Promise(
			(resolve, reject) => {
				cognitoUser?.refreshSession(refreshDetails, (error, result) => {
					console.info("3");
					if (error) {
						reject(error);
					} else {
						resolve(result);
					}
				});
			},
		);

		let userDetails = userTokens(session);
		return userDetails;
	} catch (err) {
		console.error("my error", err);
		return {};
	}
};

export const logout = () => {
	const cognitoUser = getCognitoUser();
	cognitoUser?.signOut();
};
