import { findFilesRecursive, pathExists } from '../common/fs';

export type TestFn = () => Promise<void>;

export interface TestCase {
  description: string;
  fn: TestFn;
}

export const cases: TestCase[] = [];

const runTestCase = async (c: TestCase): Promise<string> => {
  try {
    await c.fn();
  } catch (e) {
    return e.message;
  }
};

const logTestCaseResult = (c: TestCase, i: number, errMsg: string) => {
  if (!errMsg) {
    console.log(`ok ${i} ${c.description}`);
  } else {
    console.log(`not ok ${i} ${c.description}`);
    console.log(errMsg);
  }
};

const requireTestFiles = async (scanPath: string): Promise<void> => {
  const specFiles = await findFilesRecursive(scanPath, (fpath: string) => {
    return fpath.endsWith('.spec.js');
  });
  specFiles.forEach(require);
};

const runTestCases = async (cases: TestCase[]): Promise<boolean> => {
  console.log(`1..${cases.length}`);
  for (let i = 0; i < cases.length; i++) {
    const errMsg = await runTestCase(cases[i]);
    logTestCaseResult(cases[i], i + 1, errMsg);
    if (errMsg) {
      return false;
    }
  }
  return true;
};

export const runTests = async (scanPath: string): Promise<boolean> => {
  const exists = await pathExists(scanPath);
  if (!exists) {
    console.log(`Error: path not found: ${scanPath}`);
    return false;
  }
  await requireTestFiles(scanPath);
  if (!cases.length) {
    console.log('Error: no test files found');
    return false;
  }
  return runTestCases(cases);
};
