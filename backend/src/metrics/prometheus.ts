import { Counter, Gauge, Registry, collectDefaultMetrics } from "prom-client";

export const metricsRegistry = new Registry();
if (process.env.NODE_ENV !== "test") {
  collectDefaultMetrics({ register: metricsRegistry });
}

export const activeDevicesGauge = new Gauge({
  name: "ioslab_active_devices",
  help: "Number of active simulators",
  registers: [metricsRegistry]
});

export const queuedJobsGauge = new Gauge({
  name: "ioslab_queued_jobs",
  help: "Number of queued jobs",
  registers: [metricsRegistry]
});

export const executedJobsCounter = new Counter({
  name: "ioslab_executed_jobs_total",
  help: "Total executed test jobs",
  registers: [metricsRegistry]
});
