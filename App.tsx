import React, { useState } from "react";
import Navigation from "./src/Navigation/Navigation";

import { UserContext } from "./src/context/userContext";
import { User } from "./src/context/types";

function App() {
	const [user, setUser] = useState<User | null>(null);

	return (
		<>
			<UserContext.Provider value={{ user, setUser }}>
				<Navigation />
			</UserContext.Provider>
		</>
	);
}

export default App;
