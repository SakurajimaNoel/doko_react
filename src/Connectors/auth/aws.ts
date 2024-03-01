import * as AWS from "aws-sdk";
import {
	InitAWSCredentials,
	GetAWSCredentials,
	GetS3Obj,
	InitS3,
} from "./types";

let awsCredentials: null | AWS.CognitoIdentityCredentials = null;
let prevIdToken: string = "";
let s3: null | AWS.S3 = null;

const initAWSCredentials: InitAWSCredentials = (idToken) => {
	if (idToken !== prevIdToken) {
		prevIdToken = idToken;
		AWS.config.update({ region: "ap-south-1" });

		const credentials = new AWS.CognitoIdentityCredentials({
			IdentityPoolId: "ap-south-1:be985ba0-fa08-4b08-933a-4bdabaa2fcc2", // your identity pool id here
			Logins: {
				// Change the key below according to the specific region your user pool is in.
				"cognito-idp.ap-south-1.amazonaws.com/ap-south-1_8FDnHEsKB":
					idToken,
			},
		});

		awsCredentials = credentials;

		initS3();
	}
};

const getAWSCredentials: GetAWSCredentials = () => {
	return awsCredentials;
};

// global s3 object init
const initS3: InitS3 = () => {
	const credentials = getAWSCredentials();

	credentials?.get(async (error) => {
		if (error) {
			console.error("Error fetching AWS credentials: ", error);
			s3 = null;
		} else {
			let accessKeyId = credentials.accessKeyId;
			let secretAccessKey = credentials.secretAccessKey;
			let sessionToken = credentials.sessionToken;

			const s3Obj = new AWS.S3({
				accessKeyId,
				secretAccessKey,
				sessionToken,
				region: "ap-south-1",
			});

			s3 = s3Obj;
		}
	});
};

export const getS3Obj: GetS3Obj = () => {
	return s3;
};

export { initAWSCredentials, getAWSCredentials };
