import * as yup from "yup";

export const LoginSchema = yup.object({
	email: yup.string().email("Invalid email").required("Email is required"),
	password: yup
		.string()
		.min(8, "Incorrect Password")
		.required("Password is required"),
});
