export type SustainabilityFactors = { material?: "organic"|"recycled"|"standard"; manufacturing?: "local"|"regional"|"global"; certification?: ("GOTS"|"OEKO_TEX")[] };
export function computeSustainabilityScore(f: SustainabilityFactors): { score: number; notes: string[] } {
  let score = 0.5; const notes: string[] = [];
  if (f.material === "organic") { score += 0.2; notes.push("Organic materials"); }
  if (f.material === "recycled") { score += 0.15; notes.push("Recycled content"); }
  if (f.manufacturing === "local") { score += 0.1; notes.push("Locally manufactured"); }
  if (f.certification?.includes("GOTS")) { score += 0.1; notes.push("GOTS certified"); }
  if (f.certification?.includes("OEKO_TEX")) { score += 0.05; notes.push("OEKO-TEX certified"); }
  return { score: Math.min(1, Math.max(0, score)), notes };
}
