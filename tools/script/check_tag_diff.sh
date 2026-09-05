#! /bin/bash
#
# en/*.txt と doc/*.jax のヘルプタグを突き合わせて食い違いを検出する。
# 翻訳のときにタグラベルを書き損なうと参照が切れるので、それを拾う。
# タグの抽出には helptags を使うので判定は Vim 本体と同じになる。
#
# タグ名だけでなく、どのファイルにあるかまで見る。
# 重複タグは vimhelptagcheck の担当なのでここでは扱わない。
#
# 2026-09-06 h_east       : Create initial file.

set -u

vim_cmd=${VIM_CMD:-vim}

tmpdir=$(mktemp -d)
trap 'rm -rf "${tmpdir}"' EXIT

if ! "${vim_cmd}" -eu NONE -c 'helptags en' -c 'helptags doc' -c 'qa!'; then
  echo "helptags に失敗しました" >&2
  exit 1
fi

if [ ! -f en/tags ] || [ ! -f doc/tags-ja ]; then
  echo "タグファイルが生成されませんでした" >&2
  exit 1
fi

# タグ名とファイル名 (拡張子を除く) の組にそろえる
cut -f1,2 en/tags | sed 's/\.txt$//' | sort >"${tmpdir}/en"
grep -v '^!_TAG_FILE_ENCODING' doc/tags-ja | cut -f1,2 | sed 's/\.jax$//' | sort \
  >"${tmpdir}/ja"

# $1:一覧 $2:元ディレクトリ $3:元拡張子 $4:先ディレクトリ $5:先拡張子
report() {
  awk -F'\t' -v sd="$2" -v se="$3" -v dd="$4" -v de="$5" \
    '{ printf "%s/%s%s: タグ *%s* が %s/%s%s にありません\n", sd, $2, se, $1, dd, $2, de }' \
    "$1"
}

comm -23 "${tmpdir}/en" "${tmpdir}/ja" >"${tmpdir}/en_only"
comm -13 "${tmpdir}/en" "${tmpdir}/ja" >"${tmpdir}/ja_only"

if [ ! -s "${tmpdir}/en_only" ] && [ ! -s "${tmpdir}/ja_only" ]; then
  exit 0
fi

report "${tmpdir}/en_only" en .txt doc .jax
report "${tmpdir}/ja_only" doc .jax en .txt
exit 1
