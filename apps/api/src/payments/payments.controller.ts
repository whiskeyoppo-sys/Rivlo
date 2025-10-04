import { Body, Controller, Headers, Post, Req, Res } from "@nestjs/common";
import { StripeAdapter } from "@repo/payments";
import { IPay88Adapter } from "@repo/payments";

@Controller("payments")
export class PaymentsController {
  private stripe = new StripeAdapter();
  private ipay88 = new IPay88Adapter();

  @Post("checkout")
  async checkout(@Body() body: any) {
    const items = await this.resolveCart(body.cartId);
    const adapter = (body.provider ?? "stripe") === "ipay88" ? this.ipay88 : this.stripe;
    const { url } = await adapter.createCheckout({
      orderId: body.cartId,
      successUrl: `${process.env.WEB_URL}/checkout/success`,
      cancelUrl: `${process.env.WEB_URL}/cart`,
      email: body.email,
      locale: "ms-MY",
      allowedPaymentMethods: ["fpx", "grabpay", "card"],
      items,
      metadata: { cartId: body.cartId }
    });
    return { url };
  }

  @Post("webhook/stripe")
  async webhookStripe(@Req() req: any, @Headers("stripe-signature") sig: string, @Res() res: any) {
    await this.stripe.handleWebhook(req.rawBody, sig);
    res.status(200).send("ok");
  }

  private async resolveCart(cartId: string) {
    // TODO: Query DB, validate prices, tax, and inventory
    return [] as any[];
  }
}
