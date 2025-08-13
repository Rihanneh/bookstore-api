import { ApiError } from '@/exceptions/ApiError';

describe('ApiError', () => {
  it('should create error with message and status code', () => {
    // GIVEN
    const error = new ApiError('Test error', 400);

    // THEN
    expect(error.message).toBe('Test error');
    expect(error.statusCode).toBe(400);
    expect(error.name).toBe('ApiError');
  });

  it('should create error with additional info', () => {
    // GIVEN
    const error = new ApiError('Test error', 401, { userId: '98' });

    // THEN
    expect(error.additionalInfo).toStrictEqual({ userId: '98' });
  });

  it('should support method chaining', () => {
    // GIVEN
    const error = new ApiError('Test error', 500);

    const result = error.log();

    // THEN
    expect(result).toBe(error);
  });

  it('should return clean JSON without additionalInfo', () => {
    // GIVEN
    const error = new ApiError('Test error', 400, { password: 'secretPanda' });

    const json = error.toJSON();

    // THEN
    expect(json.message).toBe('Test error');
    expect(json.statusCode).toBe(400);
    expect(json).not.toHaveProperty('additionalInfo');
  });
});
