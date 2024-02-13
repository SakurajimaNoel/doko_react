import { createContext } from "react";
import { User, UserAction } from "./types";

export const UserContext = createContext<User | null>(null);
export const UserDispatchContext =
	createContext<React.Dispatch<UserAction> | null>(null);
