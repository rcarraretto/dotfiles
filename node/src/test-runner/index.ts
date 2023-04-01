import { cases, TestFn } from './test-runner';

export const it = (description: string, fn: TestFn): void => {
  cases.push({ description, fn });
};
