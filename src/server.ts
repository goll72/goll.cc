// Serves the website (already built in `dist`), providing
// comments functionality by using Prisma.

import path from "node:path";
import { readFile } from "node:fs/promises";
import { VFile } from "vfile";

import { Application, Router, Status } from "@oak/oak";
import { type Page, type Comment, PrismaClient } from "@prisma/client";

import config from "./config.ts";
import { markdownProcessor } from "./process.ts";
import html, { type HTMLElement, render } from "./html.ts";

const router = new Router();
const prisma = new PrismaClient();

const EDITING_DISCLAIMER = `Editing with Markdown and <span class="katex"><span class="katex-mathml"><math xmlns="http://www.w3.org/1998/Math/MathML"><semantics><mrow><mtext>LaTeX</mtext></mrow><annotation encoding="application/x-tex">\LaTeX</annotation></semantics></math></span><span class="katex-html" aria-hidden="true"><span class="base"><span class="strut" style="height:0.8988em;vertical-align:-0.2155em;"></span><span class="mord text"><span class="mord textrm">L</span><span class="mspace" style="margin-right:-0.36em;"></span><span class="vlist-t"><span class="vlist-r"><span class="vlist" style="height:0.6833em;"><span style="top:-2.905em;"><span class="pstrut" style="height:2.7em;"></span><span class="mord"><span class="mord textrm mtight sizing reset-size6 size3">A</span></span></span></span></span></span><span class="mspace" style="margin-right:-0.15em;"></span><span class="mord text"><span class="mord textrm">T</span><span class="mspace" style="margin-right:-0.1667em;"></span><span class="vlist-t vlist-t2"><span class="vlist-r"><span class="vlist" style="height:0.4678em;"><span style="top:-2.7845em;"><span class="pstrut" style="height:3em;"></span><span class="mord"><span class="mord textrm">E</span></span></span></span><span class="vlist-s">​</span></span><span class="vlist-r"><span class="vlist" style="height:0.2155em;"><span></span></span></span></span><span class="mspace" style="margin-right:-0.125em;"></span><span class="mord textrm">X</span></span></span></span></span></span> is supported. There is no authentication. You can't delete comments.`;

const renderCommentThread = async (url: string, startingFromId?: number) => {
    const page = await prisma.page.findFirstOrThrow({ where: { url } });

    const comments = await prisma.comment.findMany({
        where: {
            pageId: page.id
        },
        orderBy: {
            createdAt: "desc"
        }
    });

    const childrenMap: Map<number, Comment[]> = new Map();

    for (const comment of comments) {
        const children = childrenMap.get(comment.parentId) ?? [];

        if (children.length === 0) {
            childrenMap.set(comment.parentId, children);
        }

        children.push(comment);
    }

    // Roots of the comment hierarchy we are interested in
    let root: Comment[];

    if (startingFromId !== undefined) {
        root = [ comments.find(x => x.id === startingFromId) ];
    }

    // If root[0] is undefined, we have received an invalid `id`
    if (startingFromId === undefined || root[0] === undefined) {
        root = childrenMap.get(null);
    }

    const { a, blockquote, div, span, sub, time, text } = html;

    function generate(current: Comment): HTMLElement {
        const date = current.createdAt.toISOString()
            .split(".")[0]
            .replace("T", " ")
            .replace(/:\d+$/, "");

        const children = childrenMap.get(current.id)?.map(generate);

        return div({ class: "comment-thread" },
            div({ class: "comment-heading" },
                span({}, current.username),
                span({ class: "comment-info" },
                    time({ class: "comment-time", datetime: date }, date),
                    ...(current.id === startingFromId ? [] : [
                        a({ class: "comment-view", href: `${url.replace(/\/+$/, "")}/comments/?id=${current.id}` }, "view in thread")
                    ])
                )
            ),
            div({ class: "comment-text" }, current.content),
            ...(children === undefined ? [] : [blockquote({}, ...children)])
        );
    }

    const thread = text(null, ...root.map(generate));

    return thread;
}

const renderTemplateCentered = async (content: HTMLElement) => {
    const skeleton = await readFile(path.join(config.server.root, "blank", "index.html"));

    return skeleton.toString().replace(config.server.hash.blank,
        render(
            html.div({ style: "height: 80vh", class: "text-center" },
                content
            )
        ).join("")
    );
}

const notFound = async (url: string) => {
    return renderTemplateCentered(html.h1({}, `404 Not Found - ${url}`));
}

// Sends a response with the comment thread *only*, starting from the comment specified by the id search parameter
router.get("(.*/)comments", async ctx => {
    const { searchParams } = ctx.request.url;

    const commentId = Number(searchParams.get("id"));

    let thread: HTMLElement;

    try {
        thread = await renderCommentThread(ctx.params[0], Number.isNaN(commentId) ? undefined : commentId);
    } catch {
        ctx.response.body = await notFound(ctx.request.url.pathname);
        ctx.response.status = Status.NotFound;

        return;
    }

    const skeleton = await readFile(path.join(config.server.root, "blank", "index.html"));

    const { div, h2, form, input, label, textarea, button, sub } = html;

    const output = skeleton.toString().replace(config.server.hash.blank,
        render(
            div({},
                h2({}, "Comment Thread"),
                form({ method: "POST", action: ctx.request.url.pathname },
                    div({},
                        div({},
                            label({ for: "username"}, "Username: "),
                            input({ type: "text", name: "username", id: "new-comment-username" })
                        ),
                        input({ type: "hidden", name: "replyto", value: commentId }),
                        textarea({ name: "content", id: "new-comment-content", placeholder: "Write a comment..." }),
                        div({ id: "new-comment-disclaimer" },
                            sub({}, EDITING_DISCLAIMER),
                            button({ type: "submit" }, "reply")
                        )
                    )
                ),
                thread
            )
        ).join("")
    );

    ctx.response.body = output;
});

// The order in which the routes are added matter
router.get("(/.*)", async (ctx, next) => {
    try {
        const filePath = path.join(config.server.root, ctx.request.url.pathname);

        if (path.basename(filePath) === "index.html" || !filePath.startsWith(config.server.root)) {
            ctx.response.body = await notFound(ctx.request.url.pathname);
            ctx.response.status = Status.NotFound;

            return;
        }

        ctx.response.body = await readFile(filePath);
    } catch {
        await next();
    }
});

// Sends corresponding HTML file with comments
router.get("(/.*)", async ctx => {
    try {
        const filePath = path.join(config.server.root, ctx.request.url.pathname, "index.html");

        if (!filePath.startsWith(config.server.root)) {
            ctx.response.body = await notFound(ctx.request.url.pathname);
            ctx.response.status = Status.BadRequest;

            return;
        }

        const content = await readFile(filePath);

        let thread: HTMLElement;

        try {
            thread = await renderCommentThread(ctx.params[0], undefined);
        } catch {}

        const { div, h2, form, input, label, textarea, sub, button } = html;

        const output = content.toString().replace(config.server.hash.comments,
            render(
                div({},
                    h2({}, "Comments"),
                    form({ method: "POST", action: `${ctx.request.url.pathname}comments/` },
                        div({},
                            label({ for: "username"}, "Username: "),
                            input({ type: "text", name: "username", id: "new-comment-username" })
                        ),
                        textarea({ name: "content", id: "new-comment-content", placeholder: "Write a comment..."}),
                        div({ id: "new-comment-disclaimer" },
                            sub({}, EDITING_DISCLAIMER),
                            button({ type: "submit" }, "send")
                        )
                    ),
                    thread
                )
            ).join("")
        );

        ctx.response.body = output;
    } catch {
        ctx.response.body = await notFound(ctx.request.url.pathname);
        ctx.response.status = Status.NotFound;
    }
});

// Receives a new comment request for a given page and processes it
router.post("(.*/)comments", async ctx => {
    const data = await ctx.request.body.form();

    // Note to self: Number(null) -> 0, Number("") -> 0
    let parentId = Number(data.get("replyto"));
    // Number(undefined) -> NaN
    parentId = Number.isNaN(parentId) ? 0 : parentId;

    const content = data.get("content");

    const username = data.get("username")
        .toString()
        .replace(/[^a-zA-Z0-9_-]+/g, "");

    if (username === "" || username !== data.get("username") || username.length > 64) {
        ctx.response.body = await renderTemplateCentered(html.h1({}, "Invalid username"));
        ctx.response.status = Status.BadRequest;

        return;
    }

    if (content.trim() === "" || content.length > 6000) {
        ctx.response.body = await renderTemplateCentered(html.h1({}, "Invalid comment text"));
        ctx.response.status = Status.BadRequest;

        return;
    }

    if (parentId !== null) {
        try {
            await prisma.comment.findUnique({
                where: {
                    id: parentId
                }
            });
        } catch {
            ctx.response.body = await renderTemplateCentered(html.h1({}, "Invalid comment to reply to"));
            ctx.response.status = Status.BadRequest;

            return;
        }
    }

    let page: Page;

    try {
        page = await prisma.page.findFirst({
            where: {
                url: ctx.params[0]
            }
        });
    } catch {
        ctx.response.body = await renderTemplateCentered(html.h1({}, "Invalid page"));
        ctx.response.status = Status.BadRequest;

        return;
    }

    const file = new VFile({ value: content.toString() });

    const processed = await markdownProcessor({ trusted: false })
        .process(file);

    await prisma.comment.create({
        data: {
            content: String(processed),
            pageId: page.id,
            username,
            ...(parentId === 0 ? {} : { parentId })
        }
    });

    ctx.response.redirect(new URL(ctx.params[0], ctx.request.url));
    // ctx.response.status = Status.Created;
    // ctx.response.body = await renderTemplateCentered(html.h1({}, "Comment added successfully!"));
    // ctx.response.headers.append("location", `http://localhost:8080/${ctx.params[0]}`);

});

const app = new Application();

app.use(router.routes());
app.use(router.allowedMethods());

app.listen({
    hostname: config.server.host,
    port: config.server.port
});
