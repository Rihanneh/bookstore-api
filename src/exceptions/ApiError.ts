import { LoggerSingleton } from '@/singletons/LoggerSingleton';
import { IAdditionalInfo } from '@/interfaces/IAdditionalInfo';

/**
 * Classe d'erreur API avec winston logging via singleton
 * SOLID: Single Responsibility (gestion erreurs uniquement)
 * SOLID: Dependency Inversion (dépend du singleton, pas de winston directement)
 * KISS: Simple, essentiel
 */

export class ApiError extends Error {
  public readonly statusCode: number;
  public readonly additionalInfo: IAdditionalInfo;
  public readonly timestamp: string;
  public readonly logger = LoggerSingleton.getInstance();

  constructor(message: string, statusCode: number, additionalInfo: IAdditionalInfo = {}) {
    super(message);
    this.name = this.constructor.name;
    this.statusCode = statusCode;
    this.additionalInfo = additionalInfo;
    this.timestamp = new Date().toISOString();

    if (Error.captureStackTrace) {
      Error.captureStackTrace(this, this.constructor);
    }
  }

  /**
   * Log the error with the winston logger.
   * Method chaining pattern support
   *
   * @returns The ApiError instance itself for chaining.
   */
  public log(): this {
    const message: object = {
      name: this.name,
      message: this.message,
      statusCode: this.statusCode,
      additionalInfo: this.additionalInfo,
      timestamp: this.timestamp,
      stack: this.stack
    };
    this.logger.error(message);
    return this;
  }

  /**
   * Converts the error to a JSON-serializable object
   * @returns a JSON-serializable object containing the error details
   */
  public toJSON(): Record<string, unknown> {
    return {
      name: this.name,
      message: this.message,
      statusCode: this.statusCode,
      timestamp: this.timestamp
    };
  }
}
