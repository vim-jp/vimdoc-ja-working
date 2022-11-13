.PHONY: all check replace html clean

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

clean:
	rm -rf target
