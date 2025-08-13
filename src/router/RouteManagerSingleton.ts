import { AuthController } from '@/controllers/AuthController';
import { IPublicRoutes, IRouteManager } from '@/interfaces/http';
import { IUserRepository } from '@/interfaces/repositories/IUserRepository';
import { IPasswordHasher } from '@/interfaces/security/IPasswordHasher';
import { IAuthService } from '@/interfaces/services/IAuthService';
import { Router } from 'express';
import { PublicRoutes } from './PublicRoutes';
import { AuthService } from '@/services/AuthService';
import { MockUserRepository as UserRepository } from '@/repositories/MockUserRepository';
import { PasswordHasher } from '@/utils/PasswordHasher';
import HandlerService from '@/services/http/handlerService';

/**
 * Gestionnaire de routes
 * Singleton + DIP + Routes directes
 */
export class RouteManagerSingleton implements IRouteManager {
  static #instance: RouteManagerSingleton;
  private readonly router: Router;
  private readonly publicRoutes: IPublicRoutes;
  private readonly authController: AuthController; // Instance du controller

  /**
   * Constructeur avec injection de dépendances
   * DIP : Accepte des interfaces en paramètres
   */
  private constructor(
    publicRoutes?: IPublicRoutes,
    authController?: AuthController,
    authService?: IAuthService,
    userRepository?: IUserRepository,
    passwordHasher?: IPasswordHasher
  ) {
    this.router = Router();
    this.publicRoutes = publicRoutes || new PublicRoutes();

    // Injection en cascade avec interfaces
    this.authController =
      authController ||
      new AuthController(
        authService ||
          new AuthService(
            userRepository || new UserRepository(),
            passwordHasher || new PasswordHasher()
          )
      );

    this.setupRoutes();
  }

  /**
   * getInstance avec injection optionnelle de dépendances
   */
  public static getInstance(
    publicRoutes?: IPublicRoutes,
    authController?: AuthController
  ): RouteManagerSingleton {
    if (!RouteManagerSingleton.#instance) {
      RouteManagerSingleton.#instance = new RouteManagerSingleton(publicRoutes, authController);
    }
    return RouteManagerSingleton.#instance;
  }

  /**
   * Reset pour les tests
   */
  public static resetInstance(): void {
    RouteManagerSingleton.#instance = null as unknown as RouteManagerSingleton;
  }

  /**
   * Configuration principale des routes
   */
  private setupRoutes(): void {
    this.setupAuthRoutes();
    // this.setupUserRoutes();
    // this.setupAdminRoutes();
  }

  /**
   * Configuration des routes d'authentification
   */
  private setupAuthRoutes(): void {
    const handlerService = HandlerService.getInstance(); // ✅ Instance du service

    // Routes publiques
    this.router.post(
      '/auth/register',

      handlerService.wrap((req, res, next) => this.authController.register(req, res, next))
    );

    // this.router.post(
    //   '/auth/login',
    //   handlerService.wrap((req, res, next) => this.authController.login(req, res, next))
    // );

    // this.router.post(
    //   '/auth/forgot-password',
    //   handlerService.wrap((req, res, next) => this.authController.forgotPassword(req, res, next))
    // );

    // Routes d'authentification
    // this.router.post(
    //   '/auth/logout',
    //   handlerService.wrap((req, res, next) => this.authController.logout(req, res, next))
    // );

    // this.router.post(
    //   '/auth/refresh',
    //   handlerService.wrap((req, res, next) => this.authController.refresh(req, res, next))
    // );
  }

  /**
   * Implémentation de l'interface IRouteManager
   */
  public getRouter(): Router {
    return this.router;
  }

  public getPublicRoutes(): IPublicRoutes {
    return this.publicRoutes;
  }

  public addPublicRoute(route: string): void {
    this.publicRoutes.add(route);
  }
}
