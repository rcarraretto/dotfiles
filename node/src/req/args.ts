export class ArgError extends Error {}

export const usage = `Usage: req <app_name> <endpoint_name> [options]
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
  argv = argv.slice(2);
  const positional: string[] = [];
  const vars: Var[] = [];
  for (let i = 0; i < argv.length; i++) {
    if (!argv[i].startsWith('-')) {
      positional.push(argv[i]);
      continue;
    }
    if (argv[i] === '--var') {
      if (i === argv.length - 1) {
        throw new ArgError(`invalid --var`);
      }
      const kv = argv[++i].split('=', 2);
      if (kv.length !== 2) {
        throw new ArgError(`invalid --var: ${argv[i]}`);
      }
      vars.push({
        key: kv[0],
        value: kv[1],
      });
      continue;
    }
    throw new ArgError(`unknown arg: ${argv[i]}`);
  }
  if (positional.length !== 1 && positional.length !== 2) {
    throw new ArgError('wrong number of positional args');
  }
  return {
    appName: positional[0],
    endpointName: positional[1],
    vars,
  };
};
