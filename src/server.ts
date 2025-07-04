import app from "./app";
import dotenv from "dotenv";

// Configuration des environnements
const environment: string = process.env.NODE_ENV ?? "development";
const envFile: string = `.env.${environment}`;

// Chargement de la configuration
dotenv.config({ path: envFile });

// Configuration du serveur
const PORT: number = parseInt(process.env.NODE_PORT ?? "3000", 10);

// Démarrage du serveur
app.listen(PORT, (): void => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Environment ${environment}`);
  console.log(`Visit: http://localhost:${PORT}`);
});
