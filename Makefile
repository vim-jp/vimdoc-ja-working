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
	-cd target/html/doc ; vim --cmd "set rtp^=../../../tools" -eu ../../../tools/buildhtml.vim -c "qall!"

clean:
	rm -rf target
