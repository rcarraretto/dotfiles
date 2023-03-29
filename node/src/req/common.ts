export class AppError extends Error {}

export interface Args {
  appName: string;
  endpointName: string;
  envName?: string;
}
