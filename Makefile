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
	for f in hebrew todo version5 version6 version7 version8; do sed -e '1s/version/バージョン/' < en/$$f.txt > target/html/doc/$$f.jax; done
	patch -p1 < tools/untranslated.diff
	cp tools/buildhtml.vim tools/makehtml.vim target/html
	-cd target/html/doc ; vim --cmd "set rtp^=../../../tools" -eu ../buildhtml.vim -c "qall!"

clean:
	rm -rf target
