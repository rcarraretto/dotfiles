export class ArgError extends Error {}

interface ArgOpt {
  name: string;
  kind: 'flag' | 'single' | 'multi';
}

type ArgValue = boolean | string | string[];

interface RawArgs {
  positional: string[];
  named: Record<string, ArgValue>;
}

export const parseRawArgs = (argv: string[], opts: ArgOpt[]): RawArgs => {
  argv = argv.slice(2);
  const positional: string[] = [];
  const named: Record<string, ArgValue> = {};
  for (let i = 0; i < argv.length; i++) {
    if (!argv[i].startsWith('-')) {
      positional.push(argv[i]);
      continue;
    }
    let k: string, v;
    k = argv[i].replace(/^[-]{1,2}/, '');
    if (k.includes('=')) {
      [k, v] = k.split('=', 2);
    } else if (i < argv.length - 1) {
      v = argv[++i];
    }
    const opt = opts.find((o) => o.name === k);
    if (!opt) {
      throw new ArgError(`unknown option: ${k}`);
    }
    if (opt.kind === 'flag') {
      named[k] = true;
      continue;
    }
    if (opt.kind === 'multi') {
      if (v === undefined) {
        throw new ArgError(`missing value for option '${opt.name}'`);
      }
      if (named[k]) {
        (named[k] as string[]).push(v);
      } else {
        named[k] = [v];
      }
      continue;
    }
    named[k] = v;
  }
  return {
    positional,
    named,
  };
};
