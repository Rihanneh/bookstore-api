export interface ITokenPayload {
  [key: string]: unknown;
  userId: string;
  username?: string;
  role: string;
}
