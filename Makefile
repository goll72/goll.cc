BUILD ?= build

TYP_SRC := site/index.typ \
           site/blog/index.typ \
           site/blog/restoring-sqrt.typ \
           site/blog/linux-weird.typ \
           site/misc/index.typ \
           site/misc/brachistochrone.typ \
           site/pt/index.typ \
           site/pt/blog/index.typ \
           site/pt/blog/restoring-sqrt.typ \
           site/pt/misc/index.typ \
           site/pt/misc/brachistochrone.typ

CSS_SRC := site/styles.css

SRC := $(TYP_SRC) $(CSS_SRC)
DEP := $(SRC:site/%=$(BUILD)/deps/%.d)

GEN := $(TYP_SRC:%.typ=$(BUILD)/%.html) \
       $(CSS_SRC:%.css=$(BUILD)/%.css) \
       $(BUILD)/site/feed.xml \
       $(BUILD)/site/pt/feed.xml \
       $(BUILD)/site/assets/favicon.png

all: $(BUILD)/ $(dir $(DEP) $(GEN)) $(GEN)

serve: all
	miniserve -I --index index.html --pretty-urls $(BUILD)/site

clean:
	rm -f $(GEN)

clean-deps:
	rm -f $(DEP)

-include $(DEP)

$(BUILD)/:
	mkdir -p $@
	echo '*' > $(BUILD)/.gitignore  

$(BUILD)/%/: 
	mkdir -p $@

$(BUILD)/site/%.html: site/%.typ
	typst compile --root site --features html -f html --deps $(BUILD)/deps/$*.typ.d --deps-format make --input path=/$*.typ $< $@
	sed -i 's: site/lib/meta.typ::' $(BUILD)/deps/$*.typ.d

$(BUILD)/site/%.css: site/%.css
	esbuild --bundle --format=esm --loader:.woff=file --loader:.woff2=file --asset-names='assets/[name]' --outbase=$(BUILD)/site --outfile=$@ --metafile=/dev/stdout $< | jq -r --arg in $< --arg out $@ '"\($$out): \([ .inputs | keys[] | select(. != $$in)] | join(" "))"' > $(BUILD)/deps/$*.css.d

$(BUILD)/meta.json: site/lib/meta.typ scripts/parse-meta.jq
	typst query --features html --target html site/lib/meta.typ '<meta>' --input meta-export=true --field value --one | jq --argjson langs '["pt"]' -f scripts/parse-meta.jq > $@

$(BUILD)/last-modified.json: .git/HEAD .git/refs/heads scripts/last-modified.jq
	@git diff-index --quiet HEAD -- || echo " :: Building $(BUILD)/last-modified.json with a dirty working tree." >&2

	git last-modified -r site | jq -R -n -f scripts/last-modified.jq > $@.tmp
	git show -s --format=%aI `jq --raw-output '.commits[]' < $@.tmp` \
	    | jq -R -n --slurpfile mod $@.tmp '[$$mod[0].commits, [inputs]] | transpose | map({(.[0]): .[1]}) | add | ($$mod[0] + {"dates": .})' > $@

	rm $@.tmp

$(BUILD)/site%feed.xml: $(BUILD)/meta.json $(BUILD)/last-modified.json scripts/generate-feed.jq
	jq --raw-output --arg prefix $* --arg date "$(shell date -u +'%Y-%m-%dT%H:%M:%SZ')" --slurpfile mod $(BUILD)/last-modified.json -f scripts/generate-feed.jq < $(BUILD)/meta.json > $@

$(BUILD)/%: %
	cp $< $@

.PHONY: all serve clean
