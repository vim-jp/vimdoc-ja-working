#! /bin/bash
#
# ローカルの vimdoc-ja-working/en/*.txt と vim/runtime/doc/*.txt を比較して
# 変更行数情報をMarkdownのtable形式でファイルに出力する。
#
# 2018-05-31 h_east

# 自分の環境にあわせて変更する必要がある
new_doc_dir=${GITHUB_WORKSPACE}/vim/runtime/doc
old_doc_dir=${GITHUB_WORKSPACE}/work/en

# 出力ファイル名
outf=doc_info.md
rm -f ${outf}

# 除外ファイル
exclude_files_str='
hebrew.txt
todo.txt
version5.txt
version6.txt
version7.txt
'
exclude_files=(`echo $exclude_files_str`)
unchanged_file_count=0

echo -n "|ファイル名" >> ${outf}
echo -n "|行数" >> ${outf}
echo -n "|変更行数" >> ${outf}
echo -n "|削除行数" >> ${outf}
echo -n "|作業者" >> ${outf}
echo -n "|メモ" >> ${outf}
echo "|" >> ${outf}

echo -n "|:--------" >> ${outf}
echo -n "|---:" >> ${outf}
echo -n "|---:" >> ${outf}
echo -n "|---:" >> ${outf}
echo -n "|:---" >> ${outf}
echo -n "|:---" >> ${outf}
echo "|" >> ${outf}

rm -f ${outf}.presort

for fp in `ls -1 ${new_doc_dir}/*.txt`; do
	fname=`basename ${fp}`
	old_fp=${old_doc_dir}/${fname}
	for (( i = 0; i < ${#exclude_files[@]}; ++i )); do
		if [ ${fname} == ${exclude_files[$i]} ]; then
			continue 2
		fi
	done

	lines=()
	is_output=true

	#echo "new fpath: ${fp}"
	#echo "base fname: ${fname}"
	#echo "old fpath: ${old_fp}"
	lines+=("|${fname}")
	set `wc -l ${fp}`
	lines+=("|${1}")
	if [ -e ${old_fp} ]; then
		add_lines=0
		del_lines=0

		cmd=`git diff --numstat ${old_fp} ${fp}`
		if [ $? -ne 0 ]; then
			set ${cmd}
			if [ ${1} != "" ]; then
				add_lines=${1}
				del_lines=${2}
			fi
		fi
		lines+=("|${add_lines}(+)")
		lines+=("|${del_lines}(-)")
		if [ ${add_lines} -eq 0 -a ${del_lines} -eq 0 ]; then
			is_output=false
			((++unchanged_file_count))
		fi
	else
		lines+=("|New")
		lines+=("|")
	fi
	lines+=("|")
	lines+=("|")
	lines+=("|")
	if ${is_output}; then
		line="$(IFS=; echo "${lines[*]}")"
		echo ${line[@]} >> ${outf}.presort
	fi
done

# Detect deleted files.
for fp in `ls -1 ${old_doc_dir}/*.txt`; do
	fname=`basename ${fp}`
	new_fp=${new_doc_dir}/${fname}

	lines=()
	if [ ! -e ${new_fp} ]; then
		lines+=("|${fname}")
		set `wc -l ${fp}`
		lines+=("|${1}")
		lines+=("|Deleted||||")
		line="$(IFS=; echo "${lines[*]}")"
		echo ${line[@]} >> ${outf}.presort
	fi
done

sort ${outf}.presort >> ${outf}

echo "" >> ${outf}
echo "更新不要の ${unchanged_file_count} ファイルの表示は省略しています。" >> ${outf}

# Listing excluded files
echo "" >> ${outf}
echo -n "※" >> ${outf}
for (( i = 0; i < ${#exclude_files[@]}; ++i )); do
	if [ ${i} -ne 0 ]; then
		echo -n "," >> ${outf}
	fi
	echo -n " ${exclude_files[$i]}" >> ${outf}
done
echo " は翻訳対象外です。" >> ${outf}

# vim:ts=4 sw=0:
