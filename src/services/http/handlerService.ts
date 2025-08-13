import type { NextFunction, Request, RequestHandler, Response } from 'express';
import type { IHandlerService } from '@/interfaces/http/IHandlerService';

/**
 * Service de gestion des handlers asynchrones
 * SRP : Une seule responsabilité - wrapper les erreurs async
 * Singleton pattern pour éviter les instances multiples
 */
export default class HandlerService implements IHandlerService {
  static #instance: HandlerService;

  /**
   * Constructeur privé pour Singleton
   */
  private constructor() {}

  /**
   * getInstance pour Singleton
   */
  public static getInstance(): HandlerService {
    if (!HandlerService.#instance) {
      HandlerService.#instance = new HandlerService();
    }
    return HandlerService.#instance;
  }

  /**
   * Méthode statique pour simplicité d'usage
   * Wrapper automatique des erreurs async/await
   */
  public static wrap(
    handler: (req: Request, res: Response, next: NextFunction) => Promise<void>
  ): RequestHandler {
    return HandlerService.getInstance().wrap(handler);
  }

  /**
   * Implémentation de l'interface
   * Capture automatiquement les erreurs des controllers async
   */
  public wrap(
    handler: (req: Request, res: Response, next: NextFunction) => Promise<void>
  ): RequestHandler {
    return (req: Request, res: Response, next: NextFunction): void => {
      Promise.resolve(handler(req, res, next)).catch(next); // Passe automatiquement l'erreur au middleware d'erreur
    };
  }

  /**
   * Reset pour les tests
   */
  public static resetInstance(): void {
    HandlerService.#instance = null as unknown as HandlerService;
  }
}
