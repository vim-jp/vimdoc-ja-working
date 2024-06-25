SRC_JAX := $(wildcard doc/*.jax vim_faq/*.jax)
OUT_JAX := $(addprefix target/html/doc/,$(notdir $(SRC_JAX)))
TAGS_JAX := target/html/doc/tags.jax
HTML := $(OUT_JAX:.jax=.html) $(TAGS_JAX:.jax=.html)

.PHONY: all check replace html clean
.PHONY: html2 tags

all:

check:
	nvcheck doc/*.jax vim_faq/*.jax
	vim -eu tools/maketags.vim

replace:
	nvcheck -i doc/*.jax vim_faq/*.jax

html:
	rm -rf target/html
	mkdir -p target/html/doc
	cp doc/*.jax vim_faq/*.jax target/html/doc
	-cd target/html/doc ; vim -eu ../../../tools/buildhtml.vim -c "qall!"

html2: $(HTML)

tags: $(TAGS_JAX)

target/html/doc/%.jax: doc/%.jax
	-@mkdir -p target/html/doc
	cp $< $@

target/html/doc/%.jax: vim_faq/%.jax
	-@mkdir -p target/html/doc
	cp $< $@

$(TAGS_JAX): $(OUT_JAX)
	rm -f $@
	-cd target/html/doc ; vim -eu ../../../tools/build_tag.vim -c "qall!"

target/html/doc/%.html: target/html/doc/%.jax $(TAGS_JAX)
	-@mkdir -p target/html/doc
	-cd target/html/doc ; vim -eu ../../../tools/build_html.vim $(notdir $(<F)) $(notdir $@) -c "qall!"

clean:
	rm -rf target
