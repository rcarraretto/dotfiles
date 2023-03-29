import { AppError } from './common';

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
    throw new AppError('not enough args');
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
      const kv = argv[++i].split('=', 2);
      if (kv.length !== 2) {
        throw new AppError(`invalid --var: ${argv[i]}`);
      }
      vars.push({
        key: kv[0],
        value: kv[1],
      });
      continue;
    }
    throw new AppError(`unknown arg: ${argv[i]}`);
  }
  if (positional.length !== 1 && positional.length !== 2) {
    throw new AppError('wrong number of positional args');
  }
  return {
    appName: positional[0],
    endpointName: positional[1],
    vars,
  };
};
