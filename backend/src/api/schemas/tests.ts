import { z } from "zod";

export const runTestSchema = z.object({
  testTarget: z.string().min(1),
  maxRetries: z.number().int().min(0).max(5).optional(),
  requiredRuntime: z.string().optional(),
  requiredModelId: z.string().optional()
});
