import { Auth } from "aws-amplify";

export const login = async (email, password) => {
	const user = await Auth.signIn(email, password);

	return user;
};
