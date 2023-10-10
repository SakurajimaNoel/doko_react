import * as yup from "yup";

export const ResetPasswordSchema = yup.object({
	email: yup.string().email("Invalid email").required("Email is required"),
});

export const ConfirmResetPasswordSchema = yup.object({
	resetCode: yup.number().required("Reset Code is required"),
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
