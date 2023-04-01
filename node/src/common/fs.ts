import * as fs from 'fs';
import * as path from 'path';

export const pathExists = async (path: string): Promise<boolean> => {
  return fs.promises
    .access(path, fs.constants.F_OK)
    .then(() => true)
    .catch(() => false);
};

export const findFilesRecursive = async (
  dir: string,
  fn: (fpath: string) => boolean,
): Promise<string[]> => {
  const dirents = await fs.promises.readdir(dir, { withFileTypes: true });
  const fpaths = await Promise.all(
    dirents.map((dirent) => {
      const res = path.resolve(dir, dirent.name);
      return dirent.isDirectory() ? findFilesRecursive(res, fn) : res;
    }),
  );
  return fpaths.flat().filter(fn);
};
