import { PasswordError } from '@/exceptions/security/PasswordError';
import { PasswordHasher } from '@/utils/PasswordHasher';

describe('PasswordHasher', () => {
  const passwordHasher = new PasswordHasher();

  it('should hash and verify password correctly', async () => {
    // GIVEN
    const password = 'password123';

    // WHEN
    const hash = await passwordHasher.hash(password);
    const isValid = await passwordHasher.verify(hash, password);

    // THEN
    expect(hash).not.toBe(password);
    expect(isValid).toBe(true);
  });

  it('should reject wrong password', async () => {
    // GIVEN
    const hash = await passwordHasher.hash('correct123');

    // WHEN
    const isValid = await passwordHasher.verify(hash, 'wrong123');

    // THEN
    expect(isValid).toBe(false);
  });

  it('should validate inputs', async () => {
    // GIVEN + WHEN + THEN
    await expect(passwordHasher.hash('')).rejects.toThrow(PasswordError);
    await expect(passwordHasher.verify('', 'hash')).rejects.toThrow(PasswordError);
  });
});
