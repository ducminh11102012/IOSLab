import { z } from "zod";

export const spawnDeviceSchema = z.object({
  name: z.string().min(2),
  runtime: z.string().min(2),
  modelId: z.string().optional()
});

export const transitionDeviceSchema = z.object({
  id: z.string().uuid(),
  target: z.enum(["booting", "ready", "busy", "shutting_down", "stopped", "error"])
});
