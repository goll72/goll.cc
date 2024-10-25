import { Webhooks } from "@octokit/webhooks";

import build from "../src/build.ts";

import { spawn } from "node:child_process";
import { createServer, type IncomingMessage, type ServerResponse } from "node:http";

import "dotenv/config";

const webhooks = new Webhooks({
    secret: process.env.WEBHOOK_SECRET!,
});

function getRequestBody(request: IncomingMessage): Promise<string> {
    return new Promise(resolve => {
        const chunks = [];

        request.addListener("data", chunk => chunks.push(chunk))
               .addListener("end", () => {
                   const body = Buffer.concat(chunks).toString();
                   resolve(body);
               });
    });
}

function spawnWithExitCode(command: string, args: string[]): Promise<number> {
    return new Promise(resolve => {
        const task = spawn(command, args, { stdio: "inherit" });
        task.addListener("exit", code => resolve(code));
    });
}

const handleWebhook = async (request: IncomingMessage, response: ServerResponse) => {
    const signature = request.headers["x-hub-signature-256"];
    const body = await getRequestBody(request);

    const status = await webhooks.verify(body, signature as string);

    if (!status) {
        console.warn("[webhook] received bogus event, ignoring...");

        response.statusCode = 401;
        response.end();
        
        return;
    }

    console.log("[webhook] received push event from github repo");

    response.statusCode = 200;
    response.end();

    const pull = await spawnWithExitCode("git", ["pull"]);

    if (pull !== 0)
        console.warn("[webhook] `git pull' failed!");

    await build("production");

    // XXX: this is duplicated in src/config.ts  
    const rsync = await spawnWithExitCode("rsync", ["-r", "-p", "--delete", "./dist/", process.env.SERVER_ROOT]);

    if (rsync !== 0)
        console.warn("[webhook] `rsync' failed!");
};

const webhookServer = createServer(handleWebhook);

webhookServer.listen(22222, "::1");
