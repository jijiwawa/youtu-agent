import { db } from "./src/lib/db";
import { evaluationData } from "./src/lib/db/schema";
import { desc } from "drizzle-orm";

async function testGetExpIds() {
  try {
    console.log("Testing exp_ids query...");
    const data = await db
      .select({
        exp_id: evaluationData.exp_id,
      })
      .from(evaluationData)
      .groupBy(evaluationData.exp_id)
      .orderBy(desc(evaluationData.exp_id));

    console.log("Query result:", data);
    const expIds = data.map((d: { exp_id: string }) => d.exp_id);
    console.log("Exp IDs:", expIds);
  } catch (error) {
    console.error("Error querying exp_ids:", error);
  }
}

testGetExpIds();