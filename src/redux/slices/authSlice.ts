import { createSlice } from "@reduxjs/toolkit";
import type { PayloadAction } from "@reduxjs/toolkit";

interface TokenState {
	token: string;
	expTime: string;
	issuedAt: string;
}

export interface AuthState {
	status: boolean;
	accessToken: TokenState;
	idToken: TokenState;
	refreshToken: string;
	name: string;
	email: string;
	username: string;
	completeProfile: boolean;
	awsUsername: string;
}

const initialState: AuthState = {
	status: false,
	accessToken: {
		token: "",
		expTime: "",
		issuedAt: "",
	},
	idToken: {
		token: "",
		expTime: "",
		issuedAt: "",
	},
	refreshToken: "",
	name: "",
	email: "",
	username: "",
	completeProfile: false,
	awsUsername: "",
};

export const authSlice = createSlice({
	name: "text",
	initialState,
	reducers: {
		loginUser: (state, action) => {
			const {
				accessToken,
				refreshToken,
				idToken,
				name,
				email,
				username,
				completeProfile,
				awsUsername,
			} = action.payload;

			state.status = true;
			state.accessToken = accessToken;
			state.refreshToken = refreshToken;
			state.idToken = idToken;
			state.name = name;
			state.email = email;
			state.username = username;
			state.completeProfile = completeProfile;
			state.awsUsername = username;
		},
		logoutUser: (state) => {
			state.status = false;
			state.completeProfile = false;
			state.accessToken = {
				token: "",
				expTime: "",
				issuedAt: "",
			};
			state.refreshToken = "";
			state.idToken = {
				token: "",
				expTime: "",
				issuedAt: "",
			};
			state.name = "";
			state.email = "";
			state.username = "";
			state.awsUsername = "";
		},
	},
});

export const { loginUser, logoutUser } = authSlice.actions;
export default authSlice.reducer;
