/**
 * @format
 */

import {AppRegistry} from 'react-native';
import App from './App';
import {name as appName} from './app.json';
import {RecoilRoot} from 'recoil';

import {Amplify, Auth} from 'aws-amplify';
import awsconfig from './src/aws-exports';

Amplify.configure(awsconfig);

const recoilApp = () => {
  return (
    <RecoilRoot>
      <App />
    </RecoilRoot>
  );
};

AppRegistry.registerComponent(appName, () => recoilApp);
