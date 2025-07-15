import { LoggerSingleton } from '../LoggerSingleton';

describe('LoggerSingleton', () => {
  it('should always return same instance (singleton pattern)', () => {
    // GIVEN
    const logger1 = LoggerSingleton.getInstance();
    const logger2 = LoggerSingleton.getInstance();

    // THEN
    expect(logger1).toBe(logger2);
  });

  it('should always return same instance (singleton pattern)', () => {
    // GIVEN
    const logger = LoggerSingleton.getInstance();

    // THEN
    expect(logger.transports).toHaveLength(3);
    expect(logger.level).toBeDefined();
  });
});
