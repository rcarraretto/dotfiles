import * as child_process from 'child_process';
import { AppError } from './common';
import { resolveEndpointConfig } from './config';
import { httpRequest, HttpRequest, HttpResponse } from './http';
import { parseArgs, usage } from './args';
import { ArgError } from '../common/args';

const errorMsg = (e: any): string => {
  if (e instanceof ArgError) {
    let msg = '';
    if (e.message) {
      msg = `Error: ${e.message}\n\n`;
    }
    return msg + usage;
  }
  if (e instanceof AppError) {
    const msg = `Error: ${e.message}`;
    if (!e.info || !e.info.length) {
      return msg;
    }
    return [msg].concat(e.info).join('\n');
  }
  if (e instanceof Error) {
    if ((e as any).code === 'ECONNREFUSED') {
      return e.message;
    }
    return e.stack;
  }
  return e.toString();
};

interface PrintOpts {
  jqFilter: string;
  noFilter: boolean;
}

const printReq = (req: HttpRequest, dryRun: boolean): void => {
  if (dryRun) {
    console.error('-- DRY RUN --');
  }
  console.error(`${req.method} ${req.url}`);
  if (dryRun) {
    console.error('headers', req.headers);
    if (req.data) {
      console.error('request', req.data);
    }
  }
};

const printRes = (res: HttpResponse, opts: PrintOpts): number => {
  const bodyLine = res.body.toString();
  if (res.statusCode < 200 || res.statusCode > 299) {
    console.error(`HTTP status code: ${res.statusCode}`);
    console.log(bodyLine);
    return 1;
  }
  if (!opts.jqFilter || opts.noFilter) {
    console.log(bodyLine);
    return 0;
  }
  const jqRes = child_process.spawnSync('jq', ['--compact-output', opts.jqFilter], {
    input: bodyLine,
  });
  if (jqRes.stderr.length) {
    process.stderr.write(jqRes.stderr.toString());
  }
  if (jqRes.stdout.length) {
    process.stdout.write(jqRes.stdout.toString());
  }
  return jqRes.status;
};

export const main = async () => {
  try {
    const args = parseArgs(process.argv);
    const c = await resolveEndpointConfig(args);
    printReq(c.req, args.dryRun);
    if (args.dryRun) {
      process.exit(0);
    }
    const res = await httpRequest(c.req);
    const exitCode = printRes(res, {
      jqFilter: c.jqFilter,
      noFilter: args.noFilter,
    });
    process.exit(exitCode);
  } catch (e) {
    console.error(errorMsg(e));
    process.exit(1);
  }
};
