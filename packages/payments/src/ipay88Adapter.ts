import { PaymentAdapter, CreateCheckoutInput } from "./types";

export class IPay88Adapter implements PaymentAdapter {
  async createCheckout(input: CreateCheckoutInput) {
    // TODO: Implement real iPay88 API integration
    return { url: input.cancelUrl, providerRef: `ipay88_${input.orderId}` };
  }
  async handleWebhook() {
    // TODO: verify signature and map status
  }
}
