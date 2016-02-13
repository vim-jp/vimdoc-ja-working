.PHONY: all html htmlbatch clean

all:

check:
	nvcheck doc/*.jax vim_faq/*.jax

html:
	rm -rf target/html
	mkdir -p target/html/doc
	cp -R syntax target/html
	cp doc/*.jax vim_faq/*.jax target/html/doc
	cp tools/buildhtml.vim tools/makehtml.vim tools/tohtml.vim target/html
	( cd target/html/doc && vim -eu ../buildhtml.vim -c "qall!" )

clean:
	rm -rf target
