import React from "react";

import * as eva from "@eva-design/eva";
import { ApplicationProvider, IconRegistry } from "@ui-kitten/components";
import { default as theme } from "./src/theme/custom-theme.json";
import { EvaIconsPack } from "@ui-kitten/eva-icons";

import Navigation from "./src/Navigation/Navigation";

function App() {
	return (
		<>
			<IconRegistry icons={EvaIconsPack} />
			<ApplicationProvider {...eva} theme={{ ...eva.dark, ...theme }}>
				<Navigation />
			</ApplicationProvider>
		</>
	);
}

export default App;
