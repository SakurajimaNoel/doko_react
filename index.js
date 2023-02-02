/**
 * @format
 */

import {AppRegistry} from 'react-native';
import App from './App';
import {name as appName} from './app.json';

import {Amplify} from "aws-amplify";
//import awsconfig from './src/aws-exports.js';
const awsmobile = {
    "aws_project_region": "ap-south-1"
};
Amplify.configure(awsmobile);

AppRegistry.registerComponent(appName, () => App);
