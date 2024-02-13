import { User, UserActionKind, UserAction } from "./types";

export function userReducer(user: User | null, action: UserAction) {
	let { type, payload } = action;

	switch (type) {
		case UserActionKind.INIT:
			return { ...user, ...payload };

		case UserActionKind.COMPLETE:
			return { ...user, ...payload };

		case UserActionKind.UPDATE:
			return { ...user, ...payload };

		case UserActionKind.ERASE:
			return payload;
		default:
			return user;
	}
}

export const initUser = null;
