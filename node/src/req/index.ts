import { AppError } from './common';
import { getReqDetails } from './config';
import { httpRequest, HttpResponse } from './http';
import { parseArgs } from './args';

const errorMsg = (e: any): string => {
  if (e instanceof AppError) {
    const msg = `Error: ${e.message}`;
    if (!e.info || !e.info.length) {
      return msg;
    }
    return [msg].concat(e.info).join('\n');
  }
  if (e instanceof Error) {
    return e.stack;
  }
  return e.toString();
};

const printRes = (res: HttpResponse): number => {
  const bodyLine = res.body.toString();
  if (res.statusCode < 200 || res.statusCode > 299) {
    console.error(`HTTP status code: ${res.statusCode}`);
    console.log(bodyLine);
    return 1;
  }
  console.log(bodyLine);
  return 0;
};

export const main = async () => {
  try {
    const args = parseArgs(process.argv);
    const reqDetails = await getReqDetails(args);
    console.error(`${reqDetails.method} ${reqDetails.url}`);
    const res = await httpRequest(reqDetails);
    const exitCode = printRes(res);
    process.exit(exitCode);
  } catch (e) {
    console.error(errorMsg(e));
    process.exit(1);
  }
};
