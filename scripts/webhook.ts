import { Webhooks } from "@octokit/webhooks";

import build from "../src/build.ts";

import { spawn } from "node:child_process";
import { createServer, type IncomingMessage, type ServerResponse } from "node:http";

import "dotenv/config";

const webhooks = new Webhooks({
    secret: process.env.WEBHOOK_SECRET!,
});

const handleWebhook = async (request: IncomingMessage, response: ServerResponse) => {
    const signature = request.headers["x-hub-signature-256"];
    const body = request.read();

    const status = await webhooks.verify(body, signature as string);

    if (!status) {
        response.statusCode = 401;
        return;
    }

    response.statusCode = 200;

    const git = spawn("git", ["pull"]);

    git.addListener("exit", async code => {
        if (code !== 0)
            throw new Error("`git pull' failed!");

        await build("production");

        // XXX: this is duplicated in src/config.ts  
        const rsync = spawn("rsync", ["-r", "-p", "dist", process.env.SERVER_ROOT]);

        rsync.addListener("exit", code => {
            if (code !== 0)
                throw new Error("`rsync' failed!");
        })
    });
};

const webhookServer = createServer(handleWebhook);

webhookServer.listen(22222, "::1");
