import { createSlice } from "@reduxjs/toolkit";
import type { PayloadAction } from "@reduxjs/toolkit";

export interface AuthState {
	status: boolean;
	accessToken: string;
	idToken: string;
	refreshToken: string;
	expireAt: number;
	name: string;
	email: string;
	username: string;
	completeProfile: boolean;
}

const initialState: AuthState = {
	status: false,
	accessToken: "",
	idToken: "",
	refreshToken: "",
	expireAt: 0,
	name: "",
	email: "",
	username: "",
	completeProfile: false,
};

const authSlice = createSlice({
	name: "auth",
	initialState,
	reducers: {
		loginUser: (state, action) => {
			const {
				accessToken,
				idToken,
				refreshToken,
				expireAt,
				name,
				email,
				username,
				completeProfile,
			} = action.payload;

			state.status = true;
			state.accessToken = accessToken;
			state.idToken = idToken;
			state.refreshToken = refreshToken;
			state.expireAt = expireAt;
			state.name = name;
			state.email = email;
			state.username = username;
			state.completeProfile = completeProfile;
		},
		logoutUser: (state) => {
			state.status = false;
			state.completeProfile = false;
			state.accessToken = "";
			state.idToken = "";
			state.refreshToken = "";
			state.expireAt = 0;
			state.name = "";
			state.email = "";
			state.username = "";
		},
		updateTokens: (state, action) => {
			const { idToken, accessToken, refreshToken, expireAt } =
				action.payload;

			state.accessToken = accessToken;
			state.idToken = idToken;
			state.refreshToken = refreshToken;
			state.expireAt = expireAt;
		},
		updateName: (state, action) => {
			const { name } = action.payload;

			state.name = name;
		},
		updateEmail: (state, action) => {
			const { email } = action.payload;

			state.email = email;
		},
		updateCompleteProfile: (state, action) => {
			state.completeProfile = action.payload.value;
		},
	},
});

export const {
	loginUser,
	logoutUser,
	updateTokens,
	updateEmail,
	updateName,
	updateCompleteProfile,
} = authSlice.actions;
export default authSlice.reducer;
