import Stripe from "stripe";
import { PaymentAdapter, CreateCheckoutInput } from "./types";

export class StripeAdapter implements PaymentAdapter {
  private stripe = new Stripe(process.env.STRIPE_SECRET_KEY as string, { apiVersion: "2024-06-20" });
  async createCheckout(input: CreateCheckoutInput) {
    const session = await this.stripe.checkout.sessions.create({
      mode: "payment",
      success_url: input.successUrl,
      cancel_url: input.cancelUrl,
      customer_email: input.email,
      locale: (input.locale as any) ?? "ms",
      payment_method_types: input.allowedPaymentMethods ?? ["fpx", "grabpay", "card"],
      line_items: input.items.map((i) => ({
        quantity: i.quantity,
        price_data: { currency: i.currency.toLowerCase(), unit_amount: i.amountCents, product_data: { name: i.name, metadata: { sku: i.sku } } }
      })),
      metadata: input.metadata
    });
    return { url: session.url!, providerRef: session.id };
  }
  async handleWebhook(rawBody: string, signature: string) {
    const event = this.stripe.webhooks.constructEvent(rawBody, signature, process.env.STRIPE_WEBHOOK_SECRET as string);
    // Map event to internal state in caller
  }
}
