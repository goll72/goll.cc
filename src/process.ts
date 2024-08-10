import { unified } from "unified";

import remarkGfm from "remark-gfm";
import remarkMath from "remark-math";
import remarkParse from "remark-parse";
import remarkPresetLintConsistent from "remark-preset-lint-consistent";
import remarkRehype from "remark-rehype";

import rehypeAutolinkHeadings from "rehype-autolink-headings";
import rehypeKatex from "rehype-katex";
import rehypeSlug from "rehype-slug";
import rehypeStringify from "rehype-stringify";
import rehypeTreeSitter from "rehype-tree-sitter";

/* Turns Markdown input files into HTML */
export const markdownProcessor = ({ trusted }: { trusted: boolean }) => {
    let processor = unified()
        .use(remarkPresetLintConsistent)
        .use(remarkParse)
        .use(remarkGfm)
        .use(remarkMath)
        .use(remarkRehype, {
            allowDangerousHtml: trusted
        });

    if (trusted) {
        processor = processor
            .use(rehypeSlug)
            .use(rehypeAutolinkHeadings, {
                headingProperties: {
                    class: "heading-autolink"
                },
                behavior: "wrap",
                test: ["h2", "h3", "h4", "h5", "h6"]
            });
    }

    return processor
        .use(rehypeKatex, {
            strict: true
        })
        .use(rehypeTreeSitter, {
            treeSitterGrammarRoot: "src/grammars",
            scopeMap: {
                c: "source.c",
                bash: "source.bash",
                sh: "source.bash",
                shell: "source.bash"
            }
        })
        .use(rehypeStringify, {
            allowDangerousCharacters: trusted,
            allowDangerousHtml: trusted
        });
}
