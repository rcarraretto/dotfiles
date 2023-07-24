import * as fs from 'fs';
import * as os from 'os';
import { AppError } from './common';
import { HttpRequest } from './http';
import { Args } from './args';
import { pathExists } from '../common/fs';

interface EnvConfig {
  name: string;
  url: string;
  ca?: string;
  cert?: string;
  key?: string;
  vars?: Record<string, string>;
}

interface AppConfig {
  name: string;
  envs: EnvConfig[];
  headers?: Record<string, string>;
}

interface EndpointConfig {
  method: string;
  endpoint: string;
  request: any;
  headers?: Record<string, string>;
  jqFilter?: string;
}

interface ResolvedEndpointConfig {
  req: HttpRequest;
  jqFilter?: string;
}

const replaceVars = (s: string, vars: Record<string, string>): string => {
  const interpolations = s.match(/\{[A-Za-z]+\}/g);
  if (!interpolations) {
    return s;
  }
  for (const ip of interpolations) {
    const key = ip.slice(1, ip.length - 1);
    const value = vars[key];
    if (!value) {
      throw new AppError(`unresolved variable ${ip} in: ${s}`);
    }
    s = s.replace(ip, value);
  }
  return s;
};

const replaceDataVars = (
  data: any,
  appEnvVars: Record<string, string>,
  argVars: Record<string, string>,
): any => {
  if (!data) {
    return;
  }
  const vars = {
    ...appEnvVars,
    ...argVars,
  };
  for (const [dkey, dvalue] of Object.entries(data)) {
    if (typeof dvalue !== 'string') {
      continue;
    }
    const matches = dvalue.match(/^\{([A-Za-z]+)\}$/);
    if (!matches) {
      continue;
    }
    const varKey = matches[1];
    const varValue = vars[varKey];
    if (!varValue) {
      throw new AppError(`unresolved variable ${dvalue} in: ${dkey}`);
    }
    data[dkey] = varValue;
  }
  return data;
};

const assembleHttpRequest = (
  args: Args,
  appConfig: AppConfig,
  envConfig: EnvConfig,
  endpointConfig: EndpointConfig,
): HttpRequest => {
  const rawUrl = envConfig.url + endpointConfig.endpoint;
  const url = replaceVars(rawUrl, args.vars);
  const data = replaceDataVars(endpointConfig.request, envConfig.vars, args.vars);
  const headers = {
    ...appConfig.headers,
    ...endpointConfig.headers,
  };
  const req: HttpRequest = {
    url,
    method: endpointConfig.method,
    data,
    headers,
  };
  if (envConfig.ca) {
    req.ca = fs.readFileSync(envConfig.ca);
  }
  if (envConfig.cert) {
    req.cert = fs.readFileSync(envConfig.cert);
  }
  if (envConfig.key) {
    req.key = fs.readFileSync(envConfig.key);
  }
  return req;
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

export const resolveEndpointConfig = async (args: Args): Promise<ResolvedEndpointConfig> => {
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
  const req = assembleHttpRequest(args, appConfig, envConfig, endpointConfig);
  return {
    req,
    jqFilter: endpointConfig.jqFilter,
  };
};
