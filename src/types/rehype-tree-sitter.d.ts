declare module "rehype-tree-sitter" {
    import type { Root } from "hast";
    import type { Plugin } from "unified";

    interface Options {
        /**
         * This option is **REQUIRED**. This is the source folder path on your
         * file system where tree-sitter will look for grammar source
         * repositories. Without this variable set, the plugin will throw an
         * error asking you to set it.
         */
        treeSitterGrammarRoot: string;
        /**
         * This option is a mapping of `language-{}` to tree-sitter scope
         * (`source.js`, `scope.xml`, `scope.sh`). There is a default mapping
         * included that supports a couple languages, but if you are using a
         * custom grammar, it's required that you place the mapping between
         * language identifier (usually found in the code block attributes)
         * and the scope.
         */
        scopeMap?: Record<string, string>;
    }

    /**
     * Highlight the code within the tree. This works by transforming the
     * text within the code block into annotated `<span>` elements.
     * The span elements will have their class list as the highlight
     * name stack from tree-sitter.
     */
    const rehypeTreeSitter: Plugin<[(Options | null | undefined)?], Root, string>;

    export default rehypeTreeSitter;
}
