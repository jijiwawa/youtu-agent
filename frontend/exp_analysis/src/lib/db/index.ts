// db/index.ts
import * as schema from "./schema";
import * as dotenv from "dotenv";
import * as path from "path";

dotenv.config({ path: "../../.env" });

if (!process.env.UTU_DB_URL) {
  throw new Error("UTU_DB_URL is not set");
}

const dbUrl = process.env.UTU_DB_URL;

export const db = (() => {
  if (dbUrl.startsWith("sqlite:///")) {
    // 导入 SQLite
    const { drizzle: sqliteDrizzle } = require("drizzle-orm/better-sqlite3");
    const Database = require("better-sqlite3");

    let dbPath = dbUrl.replace("sqlite:///", "");
    // 如果是相对路径，相对于项目根目录（而不是当前工作目录）
    if (!dbPath.startsWith("/")) {
      // 硬编码路径，确保连接到项目根目录下的test.db文件
      dbPath = path.join("/Users/a111/Desktop/code/youtu-agent", dbPath);
    }
    
    const sqlite = new Database(dbPath);

    return sqliteDrizzle(sqlite, { schema });
  } else {
    // 导入 PostgreSQL
    const { drizzle: pgDrizzle } = require("drizzle-orm/postgres-js");
    const postgres = require("postgres");

    const client = postgres(dbUrl);
    return pgDrizzle(client, { schema });
  }
})();
