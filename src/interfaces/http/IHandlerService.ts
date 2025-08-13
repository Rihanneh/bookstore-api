import type { NextFunction, Request, RequestHandler, Response } from 'express';

/**
 * Interface pour le service de gestion des handlers
 * ISP : Contrat spécifique pour wrapper les controllers
 */
export interface IHandlerService {
  wrap(handler: (req: Request, res: Response, next: NextFunction) => Promise<void>): RequestHandler;
}
