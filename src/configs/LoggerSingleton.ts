import winston from 'winston';
import DailyRotateFile from 'winston-daily-rotate-file';

/**
 * Singleton pour winston logger
 */

export class LoggerSingleton {
  // Propriété (private, protected, public)
  static #instance: winston.Logger;

  private constructor() {
    // Empêche l'instanciation directe
  }

  /**
   * Returns the singleton instance of the winston logger.
   *
   * This method ensures that only one instance of the logger is created
   * throughout the application. The logger is configured with specified
   * log levels, formats, and transports, including console and
   * daily rotating file transports for errors and audits.
   *
   * @returns {winston.Logger} The singleton logger instance.
   */

  public static getInstance(): winston.Logger {
    if (!LoggerSingleton.#instance) {
      LoggerSingleton.#instance = winston.createLogger({
        level: process.env.LOG_LEVEL ?? 'info',
        format: winston.format.combine(
          winston.format.timestamp({ format: 'DD-MM-YYYY HH:mm:ss' }),
          winston.format.errors({ stack: true }),
          winston.format.printf(({ timestamp, level, message, stack }) => {
            const stackInfo: string = typeof stack === 'string' ? `\n${stack}` : '';
            return `[${timestamp}] ${level.toUpperCase()}: ${message} ${stackInfo}`;
          })
        ),
        transports: [
          new winston.transports.Console({
            format: winston.format.combine(
              winston.format.colorize(),
              winston.format.timestamp({ format: 'DD-MM-YYYY HH:mm:ss' }),
              winston.format.errors({ stack: true }),
              winston.format.printf(({ timestamp, level, message, stack }) => {
                const stackInfo: string = typeof stack === 'string' ? `\n${stack}` : '';
                return `[${timestamp}] ${level.toUpperCase()}: ${message} ${stackInfo}`;
              })
            )
          }),

          // ERREURS (30 jours, max 10MB par fichier)
          new DailyRotateFile({
            filename: 'logs/error-%DATE%.log',
            datePattern: 'YYYY-MM-DD',
            level: 'error',
            maxSize: '10m',
            zippedArchive: true,
            maxFiles: '30d'
          }),
          // AUDIT RGPD (1 an, max 20MB par fichier)
          new DailyRotateFile({
            filename: 'logs/audit-%DATE%.log',
            datePattern: 'YYYY-MM-DD',
            level: 'info',
            maxSize: '20m',
            zippedArchive: true,
            maxFiles: '365d'
          })
        ]
      });
    }
    return LoggerSingleton.#instance;
  }
}
