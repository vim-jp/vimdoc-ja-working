#! /bin/bash
#
# doc/*.jax と en/*.txt の行頭の空白にある不要なスペースを検出する。
# タブは次のタブストップまで送るので、その直前にあるスペースは表示に
# 影響しない。
# 検出したら file:line 形式で報告して異常終了する。
#
# 引数でファイルを指定できる。省略時は上記を対象にする。
# vim_faq/*.jax は英語原文の vim_faq.txt 自体が同じ書き方なので対象外。
#
# 2026-09-06 h_east       : Create initial file.

set -u

targets=("$@")
if [ ${#targets[@]} -eq 0 ]; then
  targets=(doc/*.jax en/*.txt)
fi

hit=$(grep -nP '^[ \t]* \t' "${targets[@]}")

if [ -z "${hit}" ]; then
  exit 0
fi

echo "${hit}" | sed 's/^\([^:]*:[0-9]*\):.*/\1: 行頭のタブの直前に不要なスペースがあります/'
exit 1
