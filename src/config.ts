import sitemap from "vite-plugin-sitemap";

import type { UserConfig as ViteConfig } from "vite";

export type ServerConfig = {
    source: string,
    root: string,
    host: string,
    port: number,
    hash: {
        comments: string,
        blank: string
    }
};

export type Config = {
    vite: ViteConfig,
    server: ServerConfig
};

const server = {
    source: "site",
    root: "dist",
    host: "::1",
    port: 48080,
    hash: {
        comments: "adff5dd6c568691636650f6c476e67aeab67c04071629ec758e80075f72bb375",
        blank: "5683b4ba31466c5999c35921ac36e39a968f75641fd8a1358389be50a3efc309",
    }
} satisfies ServerConfig;

export default {
    server,
    vite: {
        server: {
            host: server.host,
            port: server.port,
            hmr: true
        },
        root: server.source,
        build: {
            outDir: `../${server.root}`,
            emptyOutDir: true,
        },
        plugins: [sitemap({
            /* Unfortunately, this option has a bad name */
            hostname: "https://goll.cc/",
            changefreq: "weekly",
            robots: [
                { userAgent: "GPTBot",  disallow: "/" },
                { userAgent: "ChatGPT-User",  disallow: "/" },
                { userAgent: "Google-Extended",  disallow: "/" },
                { userAgent: "PerplexityBot",  disallow: "/" },
                { userAgent: "Amazonbot",  disallow: "/" },
                { userAgent: "ClaudeBot",  disallow: "/" },
                { userAgent: "Omgilibot",  disallow: "/" },
                { userAgent: "FacebookBot",  disallow: "/" },
                { userAgent: "Applebot",  disallow: "/" },
                { userAgent: "anthropic-ai",  disallow: "/" },
                { userAgent: "Bytespider",  disallow: "/" },
                { userAgent: "Claude-Web",  disallow: "/" },
                { userAgent: "Diffbot",  disallow: "/" },
                { userAgent: "ImagesiftBot",  disallow: "/" },
                { userAgent: "Omgilibot",  disallow: "/" },
                { userAgent: "Omgili",  disallow: "/" },
                { userAgent: "YouBot",  disallow: "/" }
            ]
        })],
        publicDir: "../public"
    }
} satisfies Config;
