import { NeedsRefresh, UserTokenDetails, UserTokens } from "./types";

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
	let username = decodedId.preferred_username;
	let email = decodedId.email;
	let awsUsername = decodedAccess.username;
	let completeProfile = awsUsername !== username;

	let userDetails = {
		accessToken,
		idToken,
		refreshToken,
		expireAt,
		name,
		username,
		email,
		completeProfile,
		awsUsername,
	};

	return userDetails;
};

export const userTokens: UserTokens = (payload) => {
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

	return tokens;
};

export const needsRefresh: NeedsRefresh = (expAt) => {
	let curr: number = Math.round(Date.now() / 1000);

	return expAt - curr <= 300;
};
