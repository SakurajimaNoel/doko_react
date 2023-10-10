import UserPool from "../../users/UserPool";

export const SignUp = async (userDetails) => {
	const { name, email, password } = userDetails;

	const userAttributes = [
		{
			Name: "email",
			Value: email,
		},
		{
			Name: "name",
			Value: name,
		},
	];

	//parameters: username, password, attributes = email(necessary), validatindata? keep null, callbacks
	UserPool.signUp(email, password, userAttributes, null, (err, data) => {
		if (err) {
			console.error("cognito error: ", err);
			throw new Error(err);
		}
		console.log("cognito data: ", data);
		return data;
	});
};
