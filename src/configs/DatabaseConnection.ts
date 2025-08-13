import { DatabaseErrorFactory } from "@/exceptions/database/DatabaseErrorFactory";
import { IDatabaseConnection } from "@/interfaces/database/IDatabaseConnection";
import { config } from "dotenv";
import pgPromise, { IDatabase, ITask } from "pg-promise";


config({
  path:
    process.env.NODE_ENV === "production"
      ? ".env.production"
      : ".env.development",
});

/**
 * Singleton for PostgreSQL database connection with connection pooling
 * SOLID: Single Responsibility (gestion connexion DB uniquement)
 * RGPD: Pas de données sensibles loggées
 */
export class DatabaseConnection implements IDatabaseConnection {
  static #instance: DatabaseConnection;
  readonly #db: IDatabase<{}>;
  readonly #pgp: pgPromise.IMain;

  private constructor() {
    try {
      // Configuration production-ready avec pool
      this.#pgp = pgPromise({
        error: (err: Error) => {
          // RGPD: Log sans données sensibles
          console.error('Database error:', err.message.substring(0, 100));
        }
      });

      this.#db = this.#pgp({
        connectionString: process.env.DATABASE_URL!,
        max: 20, // Pool size
        idleTimeoutMillis: 30000, // Auto cleanup
        connectionTimeoutMillis: 10000
      });
    } catch (error) {
      throw DatabaseErrorFactory.connectionFailed(error as Error);
    }
  }

  public static getInstance(): DatabaseConnection {
    if (!DatabaseConnection.#instance) {
      DatabaseConnection.#instance = new DatabaseConnection();
    }
    return DatabaseConnection.#instance;
  }

  public getDatabase(): IDatabase<{}> {
    return this.#db;
  }

  public async testConnection(): Promise<void> {
    try {
      await this.#db.oneOrNone('SELECT 1');
    } catch (error) {
      throw DatabaseErrorFactory.connectionFailed(error as Error);
    }
  }

  /**
   * Graceful shutdown - Essential for production
   * RGPD: Audit de fermeture des connexions
   */
  public async disconnect(): Promise<void> {
    try {
      await this.#pgp.end();
    } catch (error) {
      throw DatabaseErrorFactory.connectionFailed(error as Error);
    }
  }

  /**
   * Méthode utilitaire pour transactions avec gestion d'erreurs
   *
   * POURQUOI ce wrapper ?
   * - pg-promise gère le rollback automatiquement si erreur
   * - MAIS renvoie des erreurs PostgreSQL brutes comme :
   *   "duplicate key value violates unique constraint user_email_key"
   * - Ce wrapper TRADUIT ces erreurs en ApiError typées pour ton frontend
   *
   * ALTERNATIVE sans wrapper :
   * - Tu peux utiliser directement this.#db.tx() partout
   * - Mais tu devras gérer les erreurs PostgreSQL dans chaque repository
   *
   * Pattern: Centralisé vs Distribué
   * KISS: Un seul endroit pour traduire les erreurs DB
   */
  public async withTransaction<T>(operation: (tx: ITask<{}>) => Promise<T>): Promise<T> {
    try {
      // pg-promise s'occupe du rollback si erreur
      return await this.#db.tx(async tx => {
        return await operation(tx);
      });
    } catch (error) {
      const err = error as Error;

      // TON AJOUT : Translation des erreurs PostgreSQL → ApiError
      if (err.message.includes('foreign key')) {
        throw DatabaseErrorFactory.foreignKeyViolation('unknown', 'unknown_fk');
      }
      if (err.message.includes('unique')) {
        throw DatabaseErrorFactory.uniqueViolation('unknown', 'unknown');
      }

      throw DatabaseErrorFactory.transactionFailed('user_operation');
    }
  }
}
