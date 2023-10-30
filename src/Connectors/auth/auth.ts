import { UserTokenDetails, TokenState } from "./types";

export const userTokenDetails: UserTokenDetails = (payload) => {
	let decodedAccess = payload.getAccessToken().decodePayload();
	let decodedId = payload.getIdToken().decodePayload();

	// accesstoken
	let accessToken: TokenState = {
		token: payload.getAccessToken().getJwtToken(),
		expTime: String(payload.getAccessToken().getExpiration()),
		issuedAt: String(payload.getAccessToken().getIssuedAt()),
	};
	console.log(accessToken.token);

	// idToken
	let idToken: TokenState = {
		token: payload.getIdToken().getJwtToken(),
		expTime: String(payload.getIdToken().getExpiration()),
		issuedAt: String(payload.getIdToken().getIssuedAt()),
	};

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
		name,
		username,
		email,
		completeProfile,
		awsUsername,
	};

	return userDetails;
};
