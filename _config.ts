import lume from "lume/mod.ts";
import esbuild from "lume/plugins/esbuild.ts";
import katex from "lume/plugins/katex.ts";
import prism from "lume/plugins/prism.ts";

import anchor from "npm:markdown-it-anchor";
import footnote from "npm:markdown-it-footnote";

// Include other languages, eventually
import "npm:prismjs@1.29.0/components/prism-c.js";

const markdown = {
    plugins: [
        [anchor, {
            permalink: anchor.permalink.headerLink()
        }],
        footnote
    ],
};

const site = lume({}, { markdown });

site.ignore("README.md");

site.use(esbuild());
site.use(katex({
    options: {
        delimiters: [
            { left: "\\[", right: "\\]", display: true },
            { left: "$$", right: "$$", display: true },
            { left: "\\(", right: "\\)", display: false },
            { left: "$", right: "$", display: false }
        ]
    }
}));
site.use(prism());

site.copy("assets", "/");

export default site;
