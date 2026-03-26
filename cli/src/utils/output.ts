import chalk from "chalk";

export const out = {
  info: (msg: string) => console.log(chalk.cyan(msg)),
  success: (msg: string) => console.log(chalk.green(msg)),
  warn: (msg: string) => console.log(chalk.yellow(msg)),
  error: (msg: string) => console.error(chalk.red(msg)),
  json: (obj: unknown) => console.log(JSON.stringify(obj, null, 2))
};
