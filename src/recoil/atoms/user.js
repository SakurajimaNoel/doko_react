import { atom } from "recoil";

export const userState = atom({
	key: "userState",
	value: {
		id: "",
		email: "",
		name: "",
		isAuth: false,
	},
});
