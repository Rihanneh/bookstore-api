export interface IBlacklistService {
  addToken(jti: string): Promise<void>;
  isTokenBlacklisted(jti: string): Promise<boolean>;
}
