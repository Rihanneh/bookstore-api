import type { ITokenPayload } from '@/interfaces/security/ITokenPayload';

export interface ITokenManager {
  generateAccessToken(payload: ITokenPayload): Promise<string>;
  generateRefreshToken(payload: ITokenPayload): Promise<string>;
  verifyToken(token: string): Promise<ITokenPayload>;
}
