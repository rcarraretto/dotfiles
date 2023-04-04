import { ArgError, parseRawArgs } from '../common/args';

export const usage = `Usage: req <app_name> <endpoint_name> [options]
 --env <env_name>
 --var <key=value>`;

export interface Var {
  key: string;
  value: string;
}

export interface Args {
  appName: string;
  endpointName: string;
  envName?: string;
  vars: Var[];
}

export const parseArgs = (argv: string[]): Args => {
  if (argv.length <= 2) {
    throw new ArgError();
  }
  const { positional, named } = parseRawArgs(argv, [
    { name: 'env', kind: 'single' },
    { name: 'var', kind: 'multi' },
  ]);
  if (positional.length !== 1 && positional.length !== 2) {
    throw new ArgError('wrong number of positional args');
  }
  const vars: Var[] = [];
  if (named['var']) {
    for (const varArg of named['var']) {
      const kv = varArg.split('=', 2);
      if (kv.length !== 2) {
        throw new ArgError(`invalid --var: ${varArg}`);
      }
      vars.push({
        key: kv[0],
        value: kv[1],
      });
    }
  }
  return {
    appName: positional[0],
    endpointName: positional[1],
    envName: named['env'] as string,
    vars,
  };
};
