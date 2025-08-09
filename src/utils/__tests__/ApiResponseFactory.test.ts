import { ApiResponseFactory } from '@/utils/ApiResponseFactory';

describe('ApiResponseFactory', () => {
  describe('success()', () => {
    it('should create success response with data', () => {
      // Act
      const response = ApiResponseFactory.success('Success', { id: 1 });

      // Assert
      expect(response.success).toBe(true);
      expect(response.message).toBe('Success');
      expect(response.data).toEqual({ id: 1 });
      expect(response.meta.timestamp).toBeTruthy();
    });

    it('should create success response without data', () => {
      // Act
      const response = ApiResponseFactory.success('Success');

      // Assert
      expect(response.success).toBe(true);
      expect(response).not.toHaveProperty('data');
    });
  });

  describe('error()', () => {
    it('should create error response', () => {
      // Act
      const response = ApiResponseFactory.error('Error', 'CODE');

      // Assert
      expect(response.success).toBe(false);
      expect(response.message).toBe('Error');
      expect(response.error?.code).toBe('CODE');
    });
  });

  describe('paginated()', () => {
    it('should create paginated response', () => {
      // Act
      const response = ApiResponseFactory.paginated('Data', [{ id: 1 }], 1, 10, 15);

      // Assert
      expect(response.success).toBe(true);
      expect(response.data).toEqual([{ id: 1 }]);
      expect(response.meta.pagination?.totalPages).toBe(2);
    });
  });
});
