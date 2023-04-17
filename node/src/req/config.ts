import * as fs from 'fs';
import * as os from 'os';
import { AppError } from './common';
import { ReqDetails } from './http';
import { Var, Args } from './args';
import { pathExists } from '../common/fs';

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
  headers?: Record<string, string>;
}

const replaceVars = (s: string, vars: Var[]): string => {
  const interpolations = s.match(/\{[A-Za-z]+\}/g);
  if (!interpolations) {
    return s;
  }
  for (const ip of interpolations) {
    const key = ip.slice(1, ip.length - 1);
    const tv = vars.find((v) => v.key === key);
    if (!tv) {
      throw new AppError(`unresolved variable ${ip} in: ${s}`);
    }
    s = s.replace(ip, tv.value);
  }
  return s;
};

const assembleReqDetails = (
  args: Args,
  envConfig: EnvConfig,
  endpointConfig: EndpointConfig,
): ReqDetails => {
  const rawUrl = envConfig.url + endpointConfig.endpoint;
  const url = replaceVars(rawUrl, args.vars);
  return {
    url,
    method: endpointConfig.method,
    data: endpointConfig.request,
    headers: endpointConfig.headers,
  };
};

const listAvailableApps = async (configDir: string): Promise<string[]> => {
  const dirents = await fs.promises.readdir(configDir, { withFileTypes: true });
  const appNames = dirents.filter((d) => d.isDirectory()).map((d) => '- ' + d.name);
  if (!appNames.length) {
    return;
  }
  return ['Available apps:', ...appNames];
};

const listAvailableEndpoints = async (appPath: string): Promise<string[]> => {
  const fnames = await fs.promises.readdir(appPath);
  const endpointNames = fnames.map((fn) => '- ' + fn.replace('.json', ''));
  if (!endpointNames.length) {
    return;
  }
  return ['Available endpoints:', ...endpointNames];
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
    const availableApps = ['Available apps:', ...appConfigs.map((c) => '- ' + c.name)];
    throw new AppError(`app not found in config file: ${args.appName}`, availableApps);
  }
  let envConfig: EnvConfig;
  if (!args.envName) {
    envConfig = appConfig.envs[0];
  } else {
    envConfig = appConfig.envs.find((e) => e.name === args.envName);
  }
  if (!envConfig) {
    const availableEnvs = ['Available envs:', ...appConfig.envs.map((e) => '- ' + e.name)];
    throw new AppError(`no env config found`, availableEnvs);
  }
  const appPath = `${configDir}/${appConfig.name}`;
  exists = await pathExists(appPath);
  if (!exists) {
    const availableApps = await listAvailableApps(configDir);
    throw new AppError(`app config dir not found: ${appPath}`, availableApps);
  }
  if (!args.endpointName) {
    const availableEndpoints = await listAvailableEndpoints(appPath);
    throw new AppError(`no endpoint provided`, availableEndpoints);
  }
  const endpointConfigPath = `${appPath}/${args.endpointName}.json`;
  exists = await pathExists(endpointConfigPath);
  if (!exists) {
    const availableEndpoints = await listAvailableEndpoints(appPath);
    throw new AppError(`endpoint config not found: ${endpointConfigPath}`, availableEndpoints);
  }
  const endpointStr = await fs.promises.readFile(endpointConfigPath, 'utf8');
  const endpointConfig: EndpointConfig = JSON.parse(endpointStr);
  return assembleReqDetails(args, envConfig, endpointConfig);
};
