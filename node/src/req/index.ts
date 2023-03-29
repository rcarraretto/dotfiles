import { AppError, Args } from './common';
import { getReqDetails } from './config';
import { httpRequest, HttpResponse } from './http';

const parseArgs = (argv: string[]): Args => {
  if (argv.length <= 3) {
    throw new AppError('not enough args');
  }
  return {
    appName: argv[2],
    endpointName: argv[3],
  };
};

const errorMsg = (e: any): string => {
  if (e instanceof AppError) {
    return `Error: ${e.message}`;
  }
  if (e instanceof Error) {
    return e.stack;
  }
  return e.toString();
};

const printRes = (res: HttpResponse): number => {
  const bodyLine = `${res.body.toString()}\n`;
  if (res.statusCode < 200 || res.statusCode > 299) {
    process.stderr.write(`HTTP status code ${res.statusCode}\n`);
    process.stdout.write(bodyLine);
    return 1;
  }
  process.stdout.write(bodyLine);
  return 0;
};

export const main = async () => {
  try {
    const args = parseArgs(process.argv);
    const reqDetails = await getReqDetails(args);
    const res = await httpRequest(reqDetails);
    const exitCode = printRes(res);
    process.exit(exitCode);
  } catch (e) {
    process.stderr.write(`${errorMsg(e)}\n`);
    process.exit(1);
  }
};
