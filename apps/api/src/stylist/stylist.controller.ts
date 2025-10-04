import { Body, Controller, Post } from "@nestjs/common";

type FitInput = { productId: string; heightCm?: number; weightKg?: number; fit?: "regular"|"oversized"|"slim"; consent: boolean; };

@Controller("stylist")
export class StylistController {
  @Post("size")
  async recommend(@Body() body: FitInput) {
    if (!body.consent) return { reason: "no_consent", size: null, looks: [] };
    const size = this.simpleSize(body.heightCm, body.weightKg, body.fit);
    const looks = [{ productId: "classic-tshirt", reason: "Similar fit and material" }];
    return { size, looks, explainability: "Based on your height/weight and fit preference." };
  }
  private simpleSize(h?: number, w?: number, fit?: string) {
    if (!h || !w) return "M";
    const bmi = w / Math.pow(h / 100, 2);
    if (bmi < 19) return fit === "oversized" ? "M" : "S";
    if (bmi < 24) return "M";
    return fit === "slim" ? "L" : "XL";
  }
}
