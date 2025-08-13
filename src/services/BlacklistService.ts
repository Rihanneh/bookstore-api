import type { IBlacklistService } from '@/interfaces/security/IBlacklistService';

export class BlacklistService implements IBlacklistService {
  static #instance: BlacklistService;
  private readonly blacklistedTokens: Set<string> = new Set<string>();

  private constructor() {}

  public static getInstance(): BlacklistService {
    if (!BlacklistService.#instance) {
      BlacklistService.#instance = new BlacklistService();
    }
    return BlacklistService.#instance;
  }
  public async addToken(jti: string): Promise<void> {
    this.blacklistedTokens.add(jti);
  }
  public async isTokenBlacklisted(jti: string): Promise<boolean> {
    return this.blacklistedTokens.has(jti);
  }
}
