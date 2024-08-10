// I am baffled that a library that does this (allowing me to *not* escape stuff) doesn't exist yet
// Well, there's @fartlabs/ht, but it uses string concatenation, which is inefficient

// Yes, this is incomplete.

type HTMLAttrs = Record<string, string | number>;
type HTMLTag = "a" | "blockquote" | "button" | "div" | "span" | "input" | "form" | "label" | "textarea" | "time" | "h1" | "h2" | "h3" | "h4" | "h5" | "h6" | "sub" | "text";

export type HTMLElement = {
    tag: HTMLTag,
    attrs?: HTMLAttrs | string,
    children: (HTMLElement | string)[]
};

export const render = (element: HTMLElement) => {
    function helper(element: HTMLElement, buffer: string[]) {
        if (element.tag !== "text") {
            buffer.push("<");
            buffer.push(element.tag);

            if (typeof element.attrs === "object") {
                for (const [key, val] of Object.entries(element.attrs)) {
                    buffer.push(" ");

                    buffer.push(key);
                    buffer.push("=");
                    buffer.push(`"`);
                    buffer.push(val.toString());
                    buffer.push(`"`);
                }
            }

            buffer.push(">");
        }

        if (typeof element.attrs === "string") {
            buffer.push(element.attrs);
        }

        for (const child of element.children) {
            if (typeof child === "object") {
                helper(child, buffer);
            } else {
                buffer.push(child);
            }
        }

        if (element.tag !== "text") {
            buffer.push("</");
            buffer.push(element.tag);
            buffer.push(">");
        }

        return buffer;
    }

    return helper(element, []);
}

const elementHandler = {
    get: (_, property: HTMLTag) =>
        (attrs: HTMLAttrs, ...children: (HTMLElement | string)[]) => ({
            tag: property,
            attrs,
            children
        })
} satisfies ProxyHandler<Record<HTMLTag, (attrs: HTMLAttrs, ...children: (HTMLElement | string)[]) => HTMLElement>>;

const html = new Proxy({} as Record<HTMLTag, (attrs: HTMLAttrs, ...children: HTMLElement[]) => HTMLElement>, elementHandler);

export default html;
