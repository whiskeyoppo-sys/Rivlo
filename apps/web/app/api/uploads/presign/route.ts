import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

const s3 = new S3Client({
  region: "auto",
  endpoint: process.env.S3_ENDPOINT,
  credentials: { accessKeyId: process.env.S3_KEY!, secretAccessKey: process.env.S3_SECRET! }
});

export async function POST(req: Request) {
  const { contentType, key } = await req.json();
  const cmd = new PutObjectCommand({ Bucket: process.env.S3_BUCKET!, Key: key, ContentType: contentType, ACL: "private" });
  const url = await getSignedUrl(s3, cmd, { expiresIn: 300 });
  return Response.json({ url, key });
}
