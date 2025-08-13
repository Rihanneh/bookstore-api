import { ApiError } from '@/exceptions/ApiError';
import type { IAdditionalInfo } from '@/interfaces/security/IAdditionalInfo';

/**
 * Erreur spécialisée pour les opérations de mot de passe
 * SOLID: Single Responsibility (erreurs password uniquement)
 * SOLID: Open/Closed (étend ApiError sans modification)
 * KISS: Réutilise ApiError existant
 */

export class PasswordError extends ApiError {
  constructor(message: string, statusCode: number = 400, additionalInfo: IAdditionalInfo = {}) {
    super(message, statusCode, {
      ...additionalInfo,
      category: 'password_operation',
      service: 'PasswordHasher'
    });
  }

  /**
   * Validation error for password field.
   *
   * @param fieldName The name of the field that failed validation.
   * @param details Optional details about the validation error.
   *
   * @returns A PasswordError instance with the validation error details.
   */
  public static validation(fieldName: string, details?: string): PasswordError {
    const message: string = `${fieldName} cannot be empty, null or only whitespaces`;
    const error: PasswordError = new PasswordError(message, 400, {
      fieldName,
      validationType: 'string_validation',
      details: details ?? 'Invalid input format'
    });

    return error;
  }

  /**
   * Error for password hashing failure.
   *
   * @param originalError Optional original error message from the hashing library.
   *
   * @returns A PasswordError instance with the hashing error details.
   */
  public static hashing(originalError?: string): PasswordError {
    const message: string = 'Password hashing failed';
    const error: PasswordError = new PasswordError(message, 500, {
      operation: 'password_hashing',
      originalError: originalError ?? 'Unknown hashing error'
    });

    return error;
  }

  /**
   * Error for password verification failure.
   *
   * @param originalError Optional original error message from the verification process.
   *
   * @returns A PasswordError instance with the verification error details.
   */
  public static verification(originalError?: string): PasswordError {
    const message: string = 'Password verification failed';
    const error: PasswordError = new PasswordError(message, 500, {
      operation: 'password_verification',
      originalError: originalError ?? 'Unknown verification error'
    });

    return error;
  }
}
