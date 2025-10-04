"use client";
import { useState } from "react";

export function CheckoutButton({ cartId, provider = "stripe" }: { cartId: string; provider?: "stripe"|"ipay88" }) {
  const [loading, setLoading] = useState(false);
  return (
    <button aria-label="Checkout" disabled={loading} onClick={async () => {
      setLoading(true);
      const r = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/payments/checkout`, {
        method: "POST", headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ cartId, provider, locale: "ms-MY", currency: "MYR" })
      });
      const { url } = await r.json(); window.location.href = url;
    }}>{loading ? "Redirecting…" : "Checkout"}</button>
  );
}
