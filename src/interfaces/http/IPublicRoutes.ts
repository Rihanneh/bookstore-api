/**
 * Interface pour la gestion des routes publiques
 * ISP : Contrat clair et minimal
 */
export interface IPublicRoutes {
  isPublic(path: string): boolean;
  add(route: string): void;
  getAll(): string[];
}
