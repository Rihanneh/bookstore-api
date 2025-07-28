import { BlacklistService } from '@/services/BlacklistService';

describe('BlacklistService', () => {
  let service: BlacklistService;
  beforeEach(() => {
    service = BlacklistService.getInstance();
  });

  it('should blacklist token', async () => {
    await service.addToken('test-jti');
    expect(await service.isTokenBlacklisted('test-jti')).toBe(true);
  });

  it('should return false for non-blacklisted token', async () => {
    expect(await service.isTokenBlacklisted('unknown-jti')).toBe(false);
  });
});
