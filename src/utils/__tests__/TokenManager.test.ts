import { TokenManager } from '@/utils/TokenManager';

describe('TokenManager', () => {
  const tokenManager = new TokenManager();
  const payload = { userId: '123', role: 'admin' };

  it('should generate and verify access token', async () => {
    // GIVEN + WHEN
    const token = await tokenManager.generateAccessToken(payload);
    const decoded = await tokenManager.verifyToken(token);

    // THEN
    expect(token).toBeDefined();
    expect(decoded.userId).toBe('123');
  });

  it('should generate and verify refresh token', async () => {
    // GIVEN + WHEN
    const token = await tokenManager.generateRefreshToken(payload);
    const decoded = await tokenManager.verifyToken(token);

    // THEN
    expect(token).toBeDefined();
    expect(decoded.userId).toBe('123');
  });

  it('should validate inputs', async () => {
    // GIVEN + WHEN + THEN
    await expect(tokenManager.verifyToken('invalid.token')).rejects.toThrow();
  });
});
