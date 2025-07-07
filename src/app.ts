import express, { Express, Request, Response } from 'express';

const app: Express = express();

// Middleware JSON
app.use(express.json());

// Route de santé (health check)
app.get('/health', (_req: Request, res: Response): void => {
  res.status(200).json({
    status: 'OK',
    message: 'API is running'
  });
});

// Route par défaut
app.get('/', (_req: Request, res: Response): void => {
  res.send(`
        <h1> Bookstore API </h1>
        <p><a href="/health"> Health Check </a></p>`);
});

export default app;
