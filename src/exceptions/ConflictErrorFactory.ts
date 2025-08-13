// src/exceptions/ConflictErrorFactory.ts
import { ApiError } from '@/exceptions/ApiError';
import type { IAdditionalInfo } from '@/interfaces/security/IAdditionalInfo';

/**
 * Factory d'erreurs spécialisée pour les conflits de données
 * SOLID: Single Responsibility (erreurs conflits uniquement)
 * SOLID: Open/Closed (étend ApiError sans modification)
 * KISS: Réutilise ApiError existant
 * RGPD: Pas de données sensibles dans les messages d'erreur
 */
export class ConflictErrorFactory extends ApiError {
  constructor(message: string, statusCode: number = 409, additionalInfo: IAdditionalInfo = {}) {
    super(message, statusCode, {
      ...additionalInfo,
      category: 'conflict_error',
      service: 'ConflictService'
    });
  }

  /**
   * Erreur email déjà existant
   * RGPD: Ne pas exposer l'email existant
   */
  public static emailExists(email?: string): ConflictErrorFactory {
    return new ConflictErrorFactory('Un utilisateur avec cet email existe déjà', 409, {
      operation: 'user_registration',
      conflictField: 'email',
      conflictType: 'duplicate_email',
      // RGPD: email hashé pour les logs, pas stocké en clair
      emailHash: email ? `${email.substring(0, 3)}***` : 'unknown'
    });
  }

  /**
   * Erreur username déjà existant
   * RGPD: Ne pas exposer le username existant
   */
  public static usernameExists(username?: string): ConflictErrorFactory {
    return new ConflictErrorFactory('"Ce nom d\'utilisateur est déjà pris"', 409, {
      operation: 'user_registration',
      conflictField: 'username',
      conflictType: 'duplicate_username',
      // RGPD: username partiel pour les logs
      usernameHash: username ? `${username.substring(0, 2)}***` : 'unknown'
    });
  }

  /**
   * Erreur ressource déjà existante (générique)
   */
  public static resourceExists(
    resourceType: string,
    fieldName: string,
    value?: string
  ): ConflictErrorFactory {
    return new ConflictErrorFactory(`${resourceType} avec ce ${fieldName} existe déjà`, 409, {
      operation: 'resource_creation',
      conflictField: fieldName,
      conflictType: 'duplicate_resource',
      resourceType,
      // RGPD: Valeur partielle pour les logs
      partialValue: value ? `${value.substring(0, 3)}***` : 'unknown'
    });
  }

  /**
   * Erreur données en conflit (modification simultanée)
   */
  public static dataConflict(resourceType: string, resourceId?: string): ConflictErrorFactory {
    return new ConflictErrorFactory('Conflit de données détecté, veuillez réessayer', 409, {
      operation: 'data_update',
      conflictField: 'version',
      conflictType: 'concurrent_modification',
      resourceType,
      resourceId: resourceId ?? 'unknown'
    });
  }

  /**
   * Erreur contrainte unique violée
   */
  public static uniqueConstraint(fieldName: string, constraintName?: string): ConflictErrorFactory {
    return new ConflictErrorFactory(`Contrainte d'unicité violée pour ${fieldName}`, 409, {
      operation: 'constraint_violation',
      conflictField: fieldName,
      conflictType: 'unique_constraint',
      constraintName: constraintName ?? 'unknown_constraint'
    });
  }

  /**
   * Erreur relation déjà existante
   */
  public static relationExists(
    parentType: string,
    childType: string,
    relationName: string
  ): ConflictErrorFactory {
    return new ConflictErrorFactory(
      `Relation ${relationName} entre ${parentType} et ${childType} existe déjà`,
      409,
      {
        operation: 'relation_creation',
        conflictField: relationName,
        conflictType: 'duplicate_relation',
        parentType,
        childType
      }
    );
  }

  /**
   * Erreur statut incompatible
   */
  public static statusConflict(
    currentStatus: string,
    targetStatus: string,
    resourceType: string
  ): ConflictErrorFactory {
    return new ConflictErrorFactory(
      `Impossible de passer de ${currentStatus} à ${targetStatus}`,
      409,
      {
        operation: 'status_change',
        conflictField: 'status',
        conflictType: 'invalid_status_transition',
        currentStatus,
        targetStatus,
        resourceType
      }
    );
  }

  /**
   * Erreur limite de quota atteinte
   */
  public static quotaExceeded(
    quotaType: string,
    currentValue: number,
    maxValue: number
  ): ConflictErrorFactory {
    return new ConflictErrorFactory(
      `Quota ${quotaType} dépassé (${currentValue}/${maxValue})`,
      409,
      {
        operation: 'quota_check',
        conflictField: quotaType,
        conflictType: 'quota_exceeded',
        currentValue,
        maxValue
      }
    );
  }
}
