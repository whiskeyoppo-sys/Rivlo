import { getPrismaClient } from "./client";

async function main() {
  const prisma = getPrismaClient();

  const category = await prisma.category.upsert({
    where: { slug: "apparel" },
    update: {},
    create: { name: "Apparel", slug: "apparel" }
  });

  await prisma.product.upsert({
    where: { sku: "TSHIRT-001" },
    update: {},
    create: {
      slug: "classic-tshirt",
      name: "Classic T-Shirt",
      description: "Organic cotton T-shirt",
      priceCents: 2500,
      currency: "USD",
      sku: "TSHIRT-001",
      imageUrl: "https://placehold.co/600x400",
      categoryId: category.id,
      sustainabilityScore: 0.7
    }
  });
}

main().then(() => {
  console.log("Seed completed");
  process.exit(0);
}).catch((err) => {
  console.error(err);
  process.exit(1);
});
