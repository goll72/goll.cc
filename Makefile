BUILD ?= build

TYP_SRC := site/index.typ \
           site/blog/index.typ \
           site/blog/restoring-sqrt.typ \
           site/blog/linux-weird.typ \
           site/misc/index.typ \
           site/pt/index.typ \
           site/pt/blog/index.typ \
           site/pt/blog/restoring-sqrt.typ \
           site/pt/misc/index.typ

CSS_SRC := site/styles.css

SRC := $(TYP_SRC) $(CSS_SRC)
DEP := $(SRC:site/%=$(BUILD)/deps/%.d)

GEN := $(TYP_SRC:%.typ=$(BUILD)/%.html) \
       $(CSS_SRC:%.css=$(BUILD)/%.css) \
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

$(BUILD)/site/%.css: site/%.css
	esbuild --bundle --format=esm --loader:.woff=file --loader:.woff2=file --asset-names='assets/[name]' --outbase=$(BUILD)/site --outfile=$@ --metafile=/dev/stdout $< | jq -r --arg in $< --arg out $@ '"\($$out): \([ .inputs | keys[] | select(. != $$in)] | join(" "))"' > $(BUILD)/deps/$*.css.d

$(BUILD)/%: %
	cp $< $@

.PHONY: all serve clean
