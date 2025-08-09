import { ApiError } from '@/exceptions/ApiError';
import { IAdditionalInfo } from '@/interfaces/security/IAdditionalInfo';

/**
 * Factory d'erreurs spécialisée pour les opérations utilisateur
 * SOLID: Single Responsibility (erreurs user uniquement)
 * SOLID: Open/Closed (étend ApiError sans modification)
 * KISS: Réutilise ApiError existant
 */
export class UserErrorFactory extends ApiError {
  constructor(message: string, statusCode: number = 400, additionalInfo: IAdditionalInfo = {}) {
    super(message, statusCode, {
      ...additionalInfo,
      category: 'user_operation',
      service: 'UserService'
    });
  }

  /**
   * Erreur utilisateur non trouvé
   */
  public static notFound(userId?: string): UserErrorFactory {
    const error = new UserErrorFactory('User not found', 404, {
      operation: 'user_lookup',
      userId: userId ?? 'unknown'
    });
    return error;
  }

  /**
   * Erreur email déjà existant
   */
  public static emailExists(email: string): UserErrorFactory {
    const error = new UserErrorFactory('Email already exists', 409, {
      operation: 'user_creation',
      conflictField: 'email',
      email
    });
    return error;
  }

  /**
   * Erreur validation données utilisateur
   */
  public static validation(fieldName: string, details?: string): UserErrorFactory {
    const error = new UserErrorFactory(
      `${fieldName} cannot be empty, null or only whitespaces`,
      400,
      {
        fieldName,
        validationType: 'user_validation',
        details: details ?? 'Invalid input format'
      }
    );
    return error;
  }

  /**
   * Erreur création utilisateur
   */
  public static creation(originalError?: string): UserErrorFactory {
    const error = new UserErrorFactory('User creation failed', 500, {
      operation: 'user_creation',
      originalError: originalError ?? 'Unknown creation error'
    });
    return error;
  }

  /**
   * Erreur relation Role non chargée
   */
  public static roleNotLoaded(userId?: string | number): UserErrorFactory {
    const error = new UserErrorFactory('Role not loaded', 500, {
      operation: 'user_role_access',
      userId: userId?.toString() ?? 'unknown',
      solution: 'Use findByIdWithRole() or findByEmailWithRole() methods'
    });
    return error;
  }

  /**
   * Erreur relation générale non chargée
   */
  public static relationNotLoaded(relation: string, userId?: string | number): UserErrorFactory {
    const error = new UserErrorFactory(
      `${relation} not loaded. Use repository to load relationship.`,
      500,
      {
        operation: 'user_relation_access',
        relation,
        userId: userId?.toString() ?? 'unknown',
        solution: `Use findByIdWith${relation}() method`
      }
    );
    return error;
  }
}
