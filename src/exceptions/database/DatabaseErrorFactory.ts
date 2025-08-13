import { ApiError } from "@/exceptions/ApiError";
import type { IAdditionalInfo } from "@/interfaces/security/IAdditionalInfo";

/**
 * Factory d'erreurs spécialisée pour les erreurs de base de données
 * SOLID: Single Responsibility (erreurs DB uniquement)
 * RGPD: Pas de données sensibles dans les logs
 */
export class DatabaseErrorFactory extends ApiError {
  constructor(
    message: string,
    statusCode: number = 500,
    additionalInfo: IAdditionalInfo = {}
  ) {
    super(message, statusCode, {
      ...additionalInfo,
      category: "database_error",
      service: "DatabaseService",
    });
  }

  /**
   * Erreur de connexion
   */
  public static connectionFailed(originalError?: Error): DatabaseErrorFactory {
    return new DatabaseErrorFactory(
      "Impossible de se connecter à la base de données",
      500,
      {
        operation: "database_connection",
        errorType: "connection_failed",
        // RGPD: Pas d'infos sensibles de la DB
        originalMessage: originalError?.message?.substring(0, 100) || "unknown",
      }
    );
  }

  /**
   * Timeout de requête
   */
  public static queryTimeout(query?: string): DatabaseErrorFactory {
    return new DatabaseErrorFactory("Timeout de requête base de données", 500, {
      operation: "database_query",
      errorType: "query_timeout",
      // RGPD: Query sans paramètres sensibles
      queryType: query?.split(" ")[0] || "unknown",
    });
  }

  /**
   * Contrainte de clé étrangère
   */
  public static foreignKeyViolation(
    table: string,
    constraint?: string
  ): DatabaseErrorFactory {
    return new DatabaseErrorFactory(
      "Violation de contrainte référentielle",
      400,
      {
        operation: "database_constraint",
        errorType: "foreign_key_violation",
        tableName: table,
        constraintName: constraint || "unknown_fk",
      }
    );
  }

  /**
   * Contrainte unique violée (différent du ConflictError business)
   */
  public static uniqueViolation(
    table: string,
    column: string
  ): DatabaseErrorFactory {
    return new DatabaseErrorFactory("Violation de contrainte unique", 400, {
      operation: "database_constraint",
      errorType: "unique_violation",
      tableName: table,
      columnName: column,
    });
  }

  /**
   * Transaction échouée
   */
  public static transactionFailed(operation: string): DatabaseErrorFactory {
    return new DatabaseErrorFactory("Échec de transaction", 500, {
      operation: "database_transaction",
      errorType: "transaction_failed",
      failedOperation: operation,
    });
  }

  /**
   * Pool de connexions saturé
   */
  public static poolExhausted(): DatabaseErrorFactory {
    return new DatabaseErrorFactory("Pool de connexions saturé", 503, {
      operation: "database_pool",
      errorType: "pool_exhausted",
      retryAfter: "30",
    });
  }

  /**
   * Erreur de migration
   */
  public static migrationFailed(migrationName: string): DatabaseErrorFactory {
    return new DatabaseErrorFactory(
      "Échec de migration de base de données",
      500,
      {
        operation: "database_migration",
        errorType: "migration_failed",
        migrationName,
      }
    );
  }
}
