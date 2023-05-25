import * as child_process from 'child_process';
import { AppError } from './common';
import { resolveEndpointConfig } from './config';
import { httpRequest, HttpResponse } from './http';
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

const printRes = (res: HttpResponse, jqFilter: string): number => {
  const bodyLine = res.body.toString();
  if (res.statusCode < 200 || res.statusCode > 299) {
    console.error(`HTTP status code: ${res.statusCode}`);
    console.log(bodyLine);
    return 1;
  }
  if (!jqFilter) {
    console.log(bodyLine);
    return 0;
  }
  const jqRes = child_process.spawnSync('jq', ['--color-output', jqFilter], {
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
    console.error(`${c.req.method} ${c.req.url}`);
    const res = await httpRequest(c.req);
    const exitCode = printRes(res, c.jqFilter);
    process.exit(exitCode);
  } catch (e) {
    console.error(errorMsg(e));
    process.exit(1);
  }
};
