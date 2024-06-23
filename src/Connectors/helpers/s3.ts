import { getS3Obj } from "../auth/aws";
import { GetS3PresignedUrl } from "./types";

export const getS3PresignedUrl: GetS3PresignedUrl = async (key: string) => {
	const s3 = getS3Obj();
	if (!s3) {
		return Promise.reject("error now s3 client found");
	}

	let bucketName = "dokiuserprofile";

	const params = {
		Bucket: bucketName,
		Key: key,
		Expires: 180,
	};

	// s3.getSignedUrl("getObject", params, (err, url) => {
	// 	if (err) {
	// 		console.error("Error generating signed URL:", err);
	// 		return Promise.reject("error getting presigned url");
	// 	}

	// 	return Promise.resolve(url);
	// });
	try {
		const url = await s3.getSignedUrlPromise("getObject", params);
		return url;
	} catch (err) {
		console.error("Error generating signed URL:", err);
		return Promise.reject(err);
	}
};
