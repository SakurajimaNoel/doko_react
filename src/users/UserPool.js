import { CognitoUserPool } from "amazon-cognito-identity-js";

const poolData = {
    UserPoolId: "ap-south-1_7y9RKbI3j",
    ClientId: "275p2pfrvqhdndqan686n9mvva"
}

export default new CognitoUserPool(poolData);