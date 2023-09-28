import * as yup from "yup";

export const SignupSchema = yup.object({
	email: yup.string().email("Invalid email").required("Email is required"),
	name: yup.string().required("Name is required"),
	password: yup
		.string()
		.matches(/\w*[a-z]\w*/, "Password must have a small letter")
		.matches(/\w*[A-Z]\w*/, "Password must have a capital letter")
		.matches(/\d/, "Password must have a number")
		.matches(
			/[!@#$%^&*()\-_"=+{}; :,<.>]/,
			"Password must have a special character",
		)
		.min(8, ({ min }) => `Password must be at least ${min} characters`)
		.required("Password is required"),
	confirmPassword: yup
		.string()
		.oneOf([yup.ref("password")], "Passwords do not match")
		.required("Confirm password is required"),
});
