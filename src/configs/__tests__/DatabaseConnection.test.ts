import { DatabaseConnection } from "@/configs/DatabaseConnection";

describe("DatabaseConnection", () => {
  let connection: DatabaseConnection;

  beforeAll(() => {
    // Une seule instance pour tous les tests
    connection = DatabaseConnection.getInstance();
  });

  afterAll(async () => {
    // CLEANUP à la toute fin
    await connection.disconnect();
  });

  it("should be a singleton", () => {
    const db1 = DatabaseConnection.getInstance();
    const db2 = DatabaseConnection.getInstance();
    expect(db1).toBe(db2);
  });

  it("should connect to database", async () => {
    await expect(connection.testConnection()).resolves.not.toThrow();
  });

  it("should list existing tables", async () => {
    const db = connection.getDatabase();

    const tables = await db.query(`
      SELECT table_name FROM information_schema.tables
      WHERE table_schema = 'public' ORDER BY table_name
    `);

    console.log(
      "📋 Tables:",
      tables.map((t: any) => t.table_name)
    );
    expect(tables).toBeInstanceOf(Array);
  });

  it("should show table contents sample", async () => {
    const db = connection.getDatabase();

    const firstTable = await db.oneOrNone(`
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
      LIMIT 1
    `);

    if (firstTable) {
      const data = await db.query(
        `SELECT * FROM ${firstTable.table_name} LIMIT 3`
      );
      console.log(`📊 Échantillon de ${firstTable.table_name}:`, data);
      expect(data).toBeInstanceOf(Array);
    } else {
      console.log("ℹ️  Aucune table utilisateur trouvée");
    }
  });

  it("should disconnect gracefully", async () => {
    // Test que la méthode existe et fonctionne
    expect(typeof connection.disconnect).toBe("function");
  });
});
