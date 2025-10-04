export type ProductMeta = { id: string; category: string; priceCents: number; sustainabilityScore?: number };
export type UserProfile = { consentPersonalization: boolean; recentProductIds?: string[]; priceBandCents?: [number, number] };

export function recommendProducts(user: UserProfile, catalog: ProductMeta[], k = 6): string[] {
  // Opt-in only
  if (!user.consentPersonalization) return catalog.slice(0, k).map((p) => p.id);
  const [min, max] = user.priceBandCents || [0, Infinity];
  const filtered = catalog.filter((p) => p.priceCents >= min && p.priceCents <= max);
  // Bias toward same category of recent items and sustainable items
  const recentSet = new Set(user.recentProductIds || []);
  const scored = filtered.map((p) => {
    let s = (p.sustainabilityScore || 0.5) * 0.2;
    if ([...recentSet].some((id) => id === p.id)) s += 0.5;
    return { id: p.id, score: s };
  });
  return scored.sort((a, b) => b.score - a.score).slice(0, k).map((x) => x.id);
}
