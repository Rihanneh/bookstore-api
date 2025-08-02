import express, { Express } from 'express';
import cors from 'cors';
import routes, { routeManager } from '@/router';
import { IPublicRoutes } from '@/interfaces/http/IPublicRoutes';
import data from '../data/products.json';
import { STATUS_CODES } from 'http';

const app: Express = express();

// Configuration de l'application
app.use(express.json()); // Parse le JSON de req.body => Middleware

// CORS EN PREMIER (Middleware)
app.use(
  cors({
    origin: ['http://localhost:5500', 'http://127.0.0.1:5500'],
    methods: ['GET', 'POST', 'PUT', 'DELETE']
  })
); // Autorisations les requêtes cross-origin => Middleware

//route santé
app.get('/health', (_req: Request, res: Response): void => {
  res.status(200).json({
    status: 'ok',
    data: data,
    message: 'API is running'
  });
});

// Routes principales
app.use('/api/v1', routes); // Dirige vers nos routes => Middleware

// Debug des routes publiques
const publicRoutes: IPublicRoutes = routeManager.getPublicRoutes();
console.log('Routes publiques:', publicRoutes.getAll());

export default app;
