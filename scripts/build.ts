import process from "node:process";
import build from "../src/build.ts";

const env = process.env["NODE_ENV"];

if (env === "production" || env === "development")
    await build(env);
else
    throw new Error(`Invalid value for NODE_ENV: ${env}`);
