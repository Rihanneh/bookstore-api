import { ApiError } from '@/exceptions/ApiError';
import type { IAdditionalInfo } from '@/interfaces/security/IAdditionalInfo';

/**
 * Erreur spécialisée pour les opérations de token JWT
 * SOLID: Single Responsibility (erreurs token uniquement)
 * SOLID: Open/Closed (étend ApiError sans modification)
 * KISS: Réutilise ApiError existant + méthodes statiques simples
 */

export class TokenError extends ApiError {
  constructor(message: string, statusCode: number = 401, additionalInfo: IAdditionalInfo = {}) {
    super(message, statusCode, {
      ...additionalInfo,
      category: 'token_operation',
      service: 'TokenManager'
    });
  }

  /**
   * Error for invalid token format.
   *
   * @returns A TokenError instance with the invalid format error details.
   */
  public static invalidFormat(): TokenError {
    const message: string = 'Token must be a valid string';
    const error: TokenError = new TokenError(message, 400, {
      operation: 'token_validation',
      reason: 'invalid_format'
    });

    return error;
  }

  /**
   * Error for invalid payload in token generation.
   *
   * @returns A TokenError instance with the invalid payload error details.
   */
  public static invalidPayload(): TokenError {
    const message: string = 'Payload must be a valid object';
    const error: TokenError = new TokenError(message, 400, {
      operation: 'token_generation',
      reason: 'invalid_payload'
    });

    return error;
  }

  /**
   * Error for expired token.
   *
   * @returns A TokenError instance with the expired token error details.
   */
  public static expired(): TokenError {
    const message: string = 'Token has expired';
    const error: TokenError = new TokenError(message, 401, {
      operation: 'token_verification',
      reason: 'token_expired'
    });

    return error;
  }

  /**
   * Error for invalid token.
   *
   * @returns A TokenError instance with the details of the invalid token error.
   */
  public static invalid(): TokenError {
    const message: string = 'Invalid token';
    const error: TokenError = new TokenError(message, 401, {
      operation: 'token_verification',
      reason: 'invalid_format'
    });

    return error;
  }

  /**
   * Error for not active token.
   *
   * @returns A TokenError instance with the details of the not active token error.
   */
  public static notActive(): TokenError {
    const message: string = 'Token is not active';
    const error: TokenError = new TokenError(message, 401, {
      operation: 'token_verification',
      reason: 'token_not_active'
    });

    return error;
  }

  /**
   * Error for token generation failure.
   *
   * @param originalError Optional original error message from the token generation process.
   *
   * @returns A TokenError instance with the generation error details.
   */
  public static generation(originalError?: string): TokenError {
    const message: string = 'Token generation failed';
    const error: TokenError = new TokenError(message, 500, {
      operation: 'token_generation',
      originalError: originalError ?? 'Unknown generation error'
    });

    return error;
  }

  /**
   * Error for token verification failure.
   *
   * @param originalError Optional original error message from the token verification process.
   *
   * @returns A TokenError instance with the verification error details.
   */
  public static verification(originalError?: string): TokenError {
    const message: string = 'Token verification failed';
    const error: TokenError = new TokenError(message, 500, {
      operation: 'token_verification',
      originalError: originalError ?? 'Unknown verification error'
    });

    return error;
  }

  /**
   * Error for invalid JWT secret.
   *
   * @returns A TokenError instance with the invalid secret error details.
   */
  public static invalidSecret(): TokenError {
    const message: string = 'JWT secret is invalid';
    const error: TokenError = new TokenError(message, 500, {
      operation: 'token_manager_initialization',
      reason: 'invalid_secret'
    });

    return error;
  }
}
