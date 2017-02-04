.PHONY: all html htmlbatch clean

all:

check:
	nvcheck doc/*.jax vim_faq/*.jax

replace:
	nvcheck -i doc/*.jax vim_faq/*.jax

html:
	rm -rf target/html
	mkdir -p target/html/doc
	cp -R syntax target/html
	cp doc/*.jax vim_faq/*.jax target/html/doc
	cp tools/buildhtml.vim tools/makehtml.vim target/html
	-cd target/html/doc ; vim -c "set rtp^=../../../tools" -eu ../buildhtml.vim -c "qall!"

clean:
	rm -rf target
