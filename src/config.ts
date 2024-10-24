import sitemap from "vite-plugin-sitemap";

import type { UserConfig as Config } from "vite";

export default {
    server: {
        host: "::1",
        port: 48080
    },
    root: "site",
    build: {
        outDir: "../dist",
        emptyOutDir: true,
        minify: "esbuild"
    },
    plugins: [sitemap({
        /* Unfortunately, this option has a bad name */
        hostname: "https://goll.cc/",
        changefreq: "weekly",
        robots: [
            { userAgent: "GPTBot", disallow: "/" },
            { userAgent: "ChatGPT-User", disallow: "/" },
            { userAgent: "Google-Extended", disallow: "/" },
            { userAgent: "PerplexityBot", disallow: "/" },
            { userAgent: "Amazonbot", disallow: "/" },
            { userAgent: "ClaudeBot", disallow: "/" },
            { userAgent: "Omgilibot", disallow: "/" },
            { userAgent: "FacebookBot", disallow: "/" },
            { userAgent: "Applebot", disallow: "/" },
            { userAgent: "anthropic-ai", disallow: "/" },
            { userAgent: "Bytespider", disallow: "/" },
            { userAgent: "Claude-Web", disallow: "/" },
            { userAgent: "Diffbot", disallow: "/" },
            { userAgent: "ImagesiftBot", disallow: "/" },
            { userAgent: "Omgilibot", disallow: "/" },
            { userAgent: "Omgili", disallow: "/" },
            { userAgent: "YouBot", disallow: "/" }
        ]
    })],
    publicDir: "../public"
} satisfies Config;
