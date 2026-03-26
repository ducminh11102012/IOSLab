import { JobStatus } from "../../simulator/models/types";
import { DomainError } from "../../utils/errors";

const transitions: Record<JobStatus, JobStatus[]> = {
  queued: ["scheduled", "failed"],
  scheduled: ["running", "failed"],
  running: ["completed", "retrying", "failed"],
  retrying: ["queued", "failed"],
  completed: [],
  failed: []
};

export function transitionJobState(from: JobStatus, to: JobStatus): JobStatus {
  if (!transitions[from]?.includes(to)) {
    throw new DomainError(`Invalid job transition: ${from} -> ${to}`, 409);
  }
  return to;
}
