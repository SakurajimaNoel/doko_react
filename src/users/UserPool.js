import { CognitoUserPool } from "amazon-cognito-identity-js";

const poolData = {
	UserPoolId: "ap-south-1_8FDnHEsKB",
	ClientId: "5kl98seknsnmvdg307nhmip21c",
};

export default new CognitoUserPool(poolData);
