const response = await fetch("/tags.json");

if (!response.ok) {
    throw new Error("Could not fetch /tags.json");
}

// Maps page path to list of tag strings for that page
const tags: Record<string, string[]> = await response.json();

// Maps tag name to set of page paths that have that tag
const pages: Record<string, Set<string>> = {};

for (const page of Object.keys(tags)) {
    const tagsForPage = tags[page]!;

    for (const tag of tagsForPage) {
        pages[tag] = pages[tag] ?? new Set();
        pages[tag].add(page);
    }
}

const placeholderText: Record<string, string> = {
    en: "🔍 Search pages… (#tag for tags)",
    pt: "🔍 Pesquisar páginas… (#tag para tags)",
};

/** Find the word (non-whitespace run) at a given cursor position. */
function getTermAtCursor(query: string, cursorPos: number): { term: string; start: number } | null {
    const termRegex = /\S+/g;
    let match: RegExpExecArray | null;
    while ((match = termRegex.exec(query)) !== null) {
        if (cursorPos >= match.index && cursorPos <= match.index + match[0].length) {
            return { term: match[0], start: match.index };
        }
    }
    return null;
}

async function main() {
    const pageList = document.querySelector(".page-list") as HTMLUListElement;
    if (!pageList) return;

    // Only suggest tags that belong to pages actually listed on this page.
    const listedPaths = new Set<string>();
    pageList.querySelectorAll("li a").forEach(a => {
        const href = a.getAttribute("href") ?? "";
        const path = href.replace(/\/$/, "");

        if (path) listedPaths.add(path);
    });

    const tagNames = Object.keys(pages).filter(tag =>
        [...pages[tag]!].some(pagePath => listedPaths.has(pagePath))
    ).sort();

    /* ---- DOM setup ---- */

    const searchContainer = document.createElement("div");
    searchContainer.className = "search-container";

    const searchInput = document.createElement("input");
    searchInput.type = "search";
    const lang = document.documentElement.getAttribute("lang") ?? "en";
    searchInput.placeholder = placeholderText[lang] ?? placeholderText.en!;

    const clearButton = document.createElement("button");
    clearButton.className = "search-clear";
    clearButton.textContent = "\u00D7";
    clearButton.style.display = "none";

    const tagDropdown = document.createElement("div");
    tagDropdown.className = "tag-dropdown";
    tagDropdown.style.display = "none";

    const searchWrapper = document.createElement("div");
    searchWrapper.append(searchInput, clearButton);
    searchContainer.append(searchWrapper, tagDropdown);
    pageList.before(searchContainer);

    /* ---- State ---- */

    let activeTermInfo: { term: string; start: number } | null = null;
    let activeMatches: string[] = [];
    let selectedIndex = -1;

    /* ---- Helpers ---- */

    /** Replace the current #term at the cursor with a chosen tag. */
    function selectTag(tag: string, termInfo: { term: string; start: number }) {
        const before = searchInput.value.slice(0, termInfo.start);
        const after = searchInput.value.slice(termInfo.start + termInfo.term.length);
        const newValue = before + "#" + tag + after;
        searchInput.value = newValue;
        const cursor = before.length + 1 + tag.length;
        searchInput.selectionStart = searchInput.selectionEnd = cursor;
        filterPages(newValue);
        tagDropdown.style.display = "none";
        tagDropdown.innerHTML = "";
        selectedIndex = -1;
    }

    /** Populate the tag dropdown based on what the user is typing. */
    function updateTagSuggestions() {
        const cursorPos = searchInput.selectionStart ?? 0;
        const termInfo = getTermAtCursor(searchInput.value, cursorPos);

        if (termInfo && termInfo.term.startsWith("#")) {
            const prefix = termInfo.term.slice(1).toLowerCase();
            // Exclude an exact match so the dropdown doesn't reappear
            // right after selecting a tag.
            const matches = tagNames.filter(
                t => t.toLowerCase().startsWith(prefix) && t.toLowerCase() !== prefix
            );

            if (matches.length > 0) {
                activeTermInfo = termInfo;
                activeMatches = matches;
                selectedIndex = -1;
                tagDropdown.innerHTML = "";

                for (const tag of matches) {
                    const option = document.createElement("div");
                    option.className = "tag-dropdown-item";
                    option.textContent = "#" + tag;
                    option.addEventListener("mousedown", e => {
                        e.preventDefault();
                        selectTag(tag, termInfo!);
                    });
                    option.addEventListener("mouseenter", () => {
                        const items = tagDropdown.querySelectorAll(".tag-dropdown-item");
                        items.forEach((el, i) => el.classList.toggle("selected", i === matches.indexOf(tag)));
                        selectedIndex = matches.indexOf(tag);
                    });
                    tagDropdown.append(option);
                }

                tagDropdown.style.display = "block";
                return;
            }
        }

        activeTermInfo = null;
        activeMatches = [];
        selectedIndex = -1;
        tagDropdown.style.display = "none";
    }

    /** Toggle list items visibility based on the search query. */
    function filterPages(query: string) {
        const terms = query.trim().split(/\s+/).filter(Boolean);
        const items = pageList.querySelectorAll("li");

        if (terms.length === 0) {
            items.forEach(item => (item as HTMLElement).style.display = "");
            return;
        }

        const tagTerms: string[] = [];
        const textTerms: string[] = [];

        for (const term of terms) {
            if (term.startsWith("#")) {
                const tagName = term.slice(1);
                if (tagName) tagTerms.push(tagName);
            } else {
                textTerms.push(term.toLowerCase());
            }
        }

        items.forEach(item => {
            const li = item as HTMLElement;

            for (const tagName of tagTerms) {
                const matchingPages = pages[tagName];
                if (!matchingPages) {
                    li.style.display = "none";
                    return;
                }
                const anchor = li.querySelector("a");
                if (!anchor) {
                    li.style.display = "none";
                    return;
                }
                const href = anchor.getAttribute("href") ?? "";
                let found = false;
                for (const pagePath of matchingPages) {
                    if (href === pagePath || href === "/" + pagePath || href.endsWith("/" + pagePath)) {
                        found = true;
                        break;
                    }
                }
                if (!found) {
                    li.style.display = "none";
                    return;
                }
            }

            for (const text of textTerms) {
                const h3 = li.querySelector("h3");
                const p = li.querySelector("p");
                
                const h3Text = h3?.textContent?.toLowerCase() ?? "";
                const pText = p?.textContent?.toLowerCase() ?? "";
                
                if (!h3Text.includes(text) && !pText.includes(text)) {
                    li.style.display = "none";
                    return;
                }
            }

            li.style.display = "";
        });
    }

    /* ---- Event listeners ---- */

    searchInput.addEventListener("input", () => {
        filterPages(searchInput.value);
        updateTagSuggestions();
        clearButton.style.display = searchInput.value ? "" : "none";
    });

    searchInput.addEventListener("keydown", e => {
        if (tagDropdown.style.display === "none" || !activeTermInfo) return;

        const items = tagDropdown.querySelectorAll<HTMLElement>(".tag-dropdown-item");
        if (items.length === 0) return;

        if (e.key === "ArrowDown") {
            e.preventDefault();
            selectedIndex = selectedIndex >= items.length - 1 ? 0 : selectedIndex + 1;
            items.forEach((el, i) => el.classList.toggle("selected", i === selectedIndex));
            items[selectedIndex]?.scrollIntoView({ block: "nearest" });
        } else if (e.key === "ArrowUp") {
            e.preventDefault();
            selectedIndex = selectedIndex <= 0 ? items.length - 1 : selectedIndex - 1;
            items.forEach((el, i) => el.classList.toggle("selected", i === selectedIndex));
            items[selectedIndex]?.scrollIntoView({ block: "nearest" });
        } else if (e.key === "Enter" && selectedIndex >= 0) {
            e.preventDefault();
            selectTag(activeMatches[selectedIndex]!, activeTermInfo);
        } else if (e.key === "Escape") {
            e.preventDefault();
            tagDropdown.style.display = "none";
            tagDropdown.innerHTML = "";
            selectedIndex = -1;
        }
    });

    clearButton.addEventListener("click", () => {
        searchInput.value = "";
        filterPages("");
        clearButton.style.display = "none";
    });

    document.addEventListener("click", e => {
        if (!searchContainer.contains(e.target as Node)) {
            tagDropdown.style.display = "none";
        }
    });
}

document.addEventListener("DOMContentLoaded", main)

if (document.readyState === "complete") {
    await main();
}
