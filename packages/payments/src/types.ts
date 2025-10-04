export interface LineItem { name: string; sku: string; quantity: number; amountCents: number; currency: string; }
export interface CreateCheckoutInput {
  orderId: string; successUrl: string; cancelUrl: string; email?: string; locale?: string;
  allowedPaymentMethods?: string[]; items: LineItem[]; metadata?: Record<string,string>;
}
export interface PaymentAdapter {
  createCheckout(input: CreateCheckoutInput): Promise<{ url: string; providerRef: string }>; 
  handleWebhook(rawBody: string, signatureHeader: string): Promise<void>;
}
