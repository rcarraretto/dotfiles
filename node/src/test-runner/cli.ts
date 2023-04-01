import { runTests } from './test-runner';
import * as path from 'path';

(async () => {
  const scanPath = path.join(process.cwd(), 'dist');
  const ok = await runTests(scanPath);
  process.exit(ok ? 0 : 1);
})();
