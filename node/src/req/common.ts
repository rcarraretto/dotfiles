export class AppError extends Error {
  constructor(message: string, public info?: string[]) {
    super(message);
  }
}
