import { Body, Controller, Post } from "@nestjs/common";

@Controller("live")
export class LiveController {
  private liveState: { active: boolean; productId?: string; until?: number } = { active: false };

  @Post("hook")
  async hook(@Body() b: { active: boolean; productId?: string }) {
    this.liveState = { active: b.active, productId: b.productId, until: Date.now() + 15 * 60 * 1000 };
    return { ok: true };
  }
}
