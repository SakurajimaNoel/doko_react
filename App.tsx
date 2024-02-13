import React, { useReducer } from "react";
import Navigation from "./src/Navigation/Navigation";

import { UserContext, UserDispatchContext } from "./src/context/userContext";
import { User } from "./src/context/types";
import { initUser, userReducer } from "./src/context/reducer";

function App() {
	const [user, userDispatch] = useReducer(userReducer, initUser);

	return (
		<>
			<UserContext.Provider value={user}>
				<UserDispatchContext.Provider value={userDispatch}>
					<Navigation />
				</UserDispatchContext.Provider>
			</UserContext.Provider>
		</>
	);
}

export default App;
