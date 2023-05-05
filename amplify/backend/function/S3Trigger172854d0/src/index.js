const sharp = require('sharp');
const AWS = require('aws-sdk');
const S3 = new AWS.S3();


const WIDTH = 100;
const HEIGHT = 100;

exports.handler = async function (event) {
  console.log('Received S3 event:', JSON.stringify(event, null, 2));

  const bucket = event.Records[0].s3.bucket.name;
  const key = event.Records[0].s3.object.key;
  const parts = key.split('/');

  const base_folder = parts[0];
  if(base_folder == 'compressed') return;
  
  let file = parts[parts.length-1];

  try{
    const image = await S3.getObject({Bucket: bucket, Key: key}).promise();
    
    const compressed_image = await sharp(image.Body).resize(WIDTH,HEIGHT).toBuffer();

    await S3.putObject({Bucket: bucket, Body: compressed_image, Key: `compressed/${file}`}).promise();
    
    return;
  }
  catch(error)
  {
    console.log(`Error Compressing Image: ${error}`);
  }

  console.log(`Bucket: ${bucket}`, `Key: ${key}`);
};