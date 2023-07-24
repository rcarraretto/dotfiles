import { ArgError, parseRawArgs } from '../common/args';

export const usage = `Usage: req <app_name> <endpoint_name> [options]
 --env <env_name>
 --var <key=value>
 --dry-run             Displays HTTP request without sending it
 --no-filter           Skips a jqFilter`;

export interface Args {
  appName: string;
  endpointName: string;
  envName?: string;
  dryRun?: boolean;
  noFilter?: boolean;
  vars: Record<string, string>;
}

export const parseArgs = (argv: string[]): Args => {
  if (argv.length <= 2) {
    throw new ArgError();
  }
  const { positional, named } = parseRawArgs(argv, [
    { name: 'env', kind: 'single' },
    { name: 'var', kind: 'multi' },
    { name: 'no-filter', kind: 'flag' },
    { name: 'dry-run', kind: 'flag' },
  ]);
  if (positional.length !== 1 && positional.length !== 2) {
    throw new ArgError('wrong number of positional args');
  }
  const vars: Record<string, string> = {};
  if (named['var']) {
    for (const varArg of named['var'] as string[]) {
      const kv = varArg.split('=', 2);
      if (kv.length !== 2) {
        throw new ArgError(`invalid --var: ${varArg}`);
      }
      vars[kv[0]] = kv[1];
    }
  }
  return {
    appName: positional[0],
    endpointName: positional[1],
    envName: named['env'] as string,
    dryRun: named['dry-run'] as boolean,
    noFilter: named['no-filter'] as boolean,
    vars,
  };
};
