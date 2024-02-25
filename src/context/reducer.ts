import { User, UserActionKind, UserAction } from "./types";

export function userReducer(user: User | null, action: UserAction) {
	let { type, payload } = action;

	switch (type) {
		case UserActionKind.INIT:
			console.log("init");
			return { ...user, ...payload };

		case UserActionKind.COMPLETE:
			console.log("complete");
			return { ...user, ...payload };

		case UserActionKind.UPDATE:
			let updatedUser = {
				...user,
				...payload,
			};

			console.log("update");

			return updatedUser;

		case UserActionKind.TOKEN:
			console.log("token");
			return {
				...user,
				...payload,
			};

		case UserActionKind.ERASE:
			console.log("Erase");
			return null;
		default:
			console.log("default");
			return user;
	}
}

export const initUser = null;
