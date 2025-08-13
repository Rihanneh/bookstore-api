import { IPublicRoutes } from '@/interfaces/http/IPublicRoutes.js';

/**
 * Implémentation concrète des routes publiques
 * DIP : Implémente l'interface
 */
export class PublicRoutes implements IPublicRoutes {
  // Set permet de créer un tableau avec des valeurs uniques
  private readonly routes: Set<string> = new Set([
    '/auth/login',
    '/auth/register',
    '/auth/forgot-password'
  ]);

  public isPublic(path: string): boolean {
    return this.routes.has(path);
  }

  public add(route: string): void {
    this.routes.add(route);
  }

  public getAll(): string[] {
    return Array.from(this.routes);
  }
}
