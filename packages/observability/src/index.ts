import { diag, DiagConsoleLogger, DiagLogLevel } from "@opentelemetry/api";
import { NodeSDK } from "@opentelemetry/sdk-node";
import { OTLPTraceExporter } from "@opentelemetry/exporter-trace-otlp-grpc";
import { Resource } from "@opentelemetry/resources";
import { SEMRESATTRS_SERVICE_NAME, SEMRESATTRS_SERVICE_NAMESPACE } from "@opentelemetry/semantic-conventions";

let sdk: NodeSDK | null = null;

export function initTelemetry(serviceName: string): void {
  if (sdk) return; // singleton
  diag.setLogger(new DiagConsoleLogger(), DiagLogLevel.ERROR);
  const exporter = new OTLPTraceExporter({
    url: process.env.OTEL_EXPORTER_OTLP_ENDPOINT || "http://localhost:4317"
  } as any);
  const resource = new Resource({
    [SEMRESATTRS_SERVICE_NAME]: serviceName,
    [SEMRESATTRS_SERVICE_NAMESPACE]: process.env.OTEL_SERVICE_NAMESPACE || "risn"
  });
  sdk = new NodeSDK({ traceExporter: exporter, resource });
  sdk.start().catch((e) => console.error("OTel init error", e));
}

export async function shutdownTelemetry(): Promise<void> {
  if (!sdk) return; await sdk.shutdown(); sdk = null;
}
