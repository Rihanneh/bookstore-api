import { IDatabase, ITask } from "pg-promise";

export interface IDatabaseConnection {
  getDatabase(): IDatabase<{}>;
  testConnection(): Promise<void>;
  disconnect(): Promise<void>;
  withTransaction<T>(operation: (tx: ITask<{}>) => Promise<T>): Promise<T>;
}
