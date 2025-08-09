import { Router } from 'express';
import { IPublicRoutes } from '@/interfaces/http/IPublicRoutes';

/**
 * Interface pour le gestionnaire de routes
 * DIP : Dépendre d'une abstraction, pas d'une implémentation
 */
export interface IRouteManager {
  getRouter(): Router;
  getPublicRoutes(): IPublicRoutes;
  addPublicRoute(route: string): void;
}
