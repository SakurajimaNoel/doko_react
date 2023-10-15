import { createSlice } from "@reduxjs/toolkit";
import type { PayloadAction } from "@reduxjs/toolkit";

interface AuthState {
	value: boolean;
}

const initialState: AuthState = {
	value: false,
};

export const authSlice = createSlice({
	name: "text",
	initialState,
	reducers: {
		toggle: (state) => {
			state.value = !state.value;
		},
	},
});

export const { toggle } = authSlice.actions;
export default authSlice.reducer;
