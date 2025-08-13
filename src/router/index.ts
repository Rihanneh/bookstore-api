import type { IRouteManager } from '@/interfaces/http/IRouteManager';
import { RouteManagerSingleton as RouteManager } from '@/router/RouteManagerSingleton';

/**
 * Export simple du Singleton
 */
const routeManager: IRouteManager = RouteManager.getInstance();

export default routeManager.getRouter();
export { routeManager };
