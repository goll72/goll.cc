declare module "vfile" {
    interface DataMapMatter {
        title?: string;
        description?: string;
        tags?: string[];
        rebuild?: string[];
        layout?: string;
        url?: string;
        draft?: boolean;
    }
}

export * from "vfile";
