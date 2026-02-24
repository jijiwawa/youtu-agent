import { db } from "@/lib/db";
import { evaluationData } from "@/lib/db/schema";
import { NextResponse } from "next/server";
import { desc } from "drizzle-orm";

export async function GET() {
    console.log("GET /api/exp_ids called");
    try {
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
        return NextResponse.json(expIds);
    } catch (error) {
        console.error("Error in GET /api/exp_ids:", error);
        return NextResponse.json({ error: "Internal server error" }, { status: 500 });
    }
}