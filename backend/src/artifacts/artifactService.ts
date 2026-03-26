import fs from "node:fs/promises";
import path from "node:path";

export interface ArtifactRecord {
  id: string;
  jobId: string;
  path: string;
  type: "log" | "screenshot" | "xcresult";
  content?: string;
}

export class ArtifactService {
  private readonly artifacts: ArtifactRecord[] = [];

  async add(record: ArtifactRecord): Promise<void> {
    this.artifacts.push(record);
    if (record.content) {
      await fs.mkdir(path.dirname(record.path), { recursive: true });
      await fs.writeFile(record.path, record.content, "utf-8");
    }
  }

  listForJob(jobId: string): ArtifactRecord[] {
    return this.artifacts.filter((a) => a.jobId === jobId);
  }
}
