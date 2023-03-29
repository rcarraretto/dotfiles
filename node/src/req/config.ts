import * as fs from 'fs';
import * as os from 'os';
import { AppError, Args } from './common';
import { ReqDetails } from './http';

interface EnvConfig {
  name: string;
  url: string;
}

interface AppConfig {
  name: string;
  envs: EnvConfig[];
}

interface EndpointConfig {
  method: string;
  endpoint: string;
  request: any;
}

const pathExists = async (path: string): Promise<boolean> => {
  return fs.promises
    .access(path, fs.constants.F_OK)
    .then(() => true)
    .catch(() => false);
};

export const getReqDetails = async (args: Args): Promise<ReqDetails> => {
  const configDir = `${os.homedir()}/.config/req`;
  const configPath = `${configDir}/apps.json`;
  let exists = await pathExists(configPath);
  if (!exists) {
    throw new AppError(`config not found: ${configPath}`);
  }
  const configStr = await fs.promises.readFile(configPath, 'utf8');
  const appConfigs: AppConfig[] = JSON.parse(configStr);
  const appConfig = appConfigs.find((c) => c.name === args.appName);
  if (!appConfig) {
    throw new AppError(`app not found: ${args.appName}`);
  }
  let envConfig: EnvConfig;
  if (!args.envName && appConfig.envs.length === 1) {
    envConfig = appConfig.envs[0];
  } else {
    envConfig = appConfig.envs.find((e) => e.name === args.envName);
  }
  if (!envConfig) {
    throw new AppError(`no env config found`);
  }
  const endpointConfigPath = `${configDir}/${appConfig.name}/${args.endpointName}.json`;
  exists = await pathExists(endpointConfigPath);
  if (!exists) {
    throw new AppError(`endpoint config not found: ${endpointConfigPath}`);
  }
  const endpointStr = await fs.promises.readFile(endpointConfigPath, 'utf8');
  const endpointConfig: EndpointConfig = JSON.parse(endpointStr);
  const url = `${envConfig.url}${endpointConfig.endpoint}`;
  return {
    url,
    method: endpointConfig.method,
    data: endpointConfig.request,
  };
};
