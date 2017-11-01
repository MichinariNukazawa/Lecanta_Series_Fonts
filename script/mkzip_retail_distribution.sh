#!/bin/bash
<<COMMENT
# brief : 製品版 zipファイルを生成する
# 	(Widnows用に、ファイル名がCP932で格納されたzipを生成する。
#
# author : MichinariNukazawa / "project daisy bell"
# 	michinari.nukazawa@gmail.com
# 	https://github.com/MichinariNukazawa/RuneAMN_Pro_Series_Fonts
# license : 2-clause BSD license
#
# depend : sudo apt-get install convmv -y)
COMMENT

ThisPath=$(cd $(dirname $0);pwd)
PathProjectRoot=$(dirname $ThisPath)

# 引数の個数をチェック
if [ 2 -eq $# ] ; then
	echo "argv:2"
else
	echo "error: invalid args: \"$@\"(num:$#)" 1>&2
	# "example: ./mkzip_free.sh RuneAMN 1.20140809235940 [retail]"
	echo "Usage: ./(this) FontSeriesName Version [retail]"
	exit 1
fi

# エンコーディング変換コマンド(ファイル名)の有無を確認
convmv --help > /dev/null
RET=$?
if [ 1 -ne $RET ] ; then
	echo "error: call convmv:$RET" 
	exit $RET
fi

# フォント名
FontSeriesName=$1
# フォントのバージョン番号
Version=$2

nameZip=${FontSeriesName}"_font_set_ver"${Version}

cd $(dirname "$ThisPath")
echo  "$ThisPath"


#### 再配布ファイルをディレクトリに集める
rm -f "$nameZip.zip"
mkdir "$nameZip"

#### フォントを収集し、変換をかける
mkdir "$nameZip/fonts"
find "releases/" -name "${FontSeriesName}*.otf"
if [ 0 -ne $? ] ; then
	echo "error find fonts"
	exit -1
fi
find "releases/" -name "${FontSeriesName}*.otf" | xargs -i cp {} "${nameZip}/fonts/"
if [ 0 -ne $? ] ; then
	echo "error find cp fonts"
	exit -1
fi

# build .ttf fonts
pushd ${nameZip}"/fonts"
mkdir "ttf"
find -name "*.otf" | xargs -I{} fontforge -lang=py -script "${PathProjectRoot}/../RuneAMN_Pro_Series_Fonts/scripts/mods/otf2ttf.py" {}
popd

#### その他のものを集める
cp "${PathProjectRoot}/../RuneAMN_Pro_Series_Fonts/docs/etcs/ttfフォントについて.txt" "$nameZip/fonts/ttf/"
cp doc/book/Lecanta_*.pdf "$nameZip/"
cp "doc/string.txt" "$nameZip/"
#cp "README.md" "$nameZip/README.txt"

find "$nameZip/" -name ".*" | xargs -i rm -rf {}
find "$nameZip/" -name "*~" | xargs -i rm -rf {}

# 個別のファイル
cp "${PathProjectRoot}/../RuneAMN_Pro_Series_Fonts/docs/etcs/Fonts_link_win.lnk" "$nameZip/"
cp "${PathProjectRoot}/../RuneAMN_Pro_Series_Fonts/docs/etcs/Install_ja.jpg" "$nameZip/インストール.jpg"

#### README.mdファイルをCP932 CRLFでエンコーディング変換する
iconv -f UTF8 -t CP932 README.md -o "$nameZip/README.txt"
sed -i 's/$/\r/' "$nameZip/README.txt"
#iconv -f UTF8 -t CP932 doc/string.txt -o "$nameZip/string.txt"
#find "$nameZip" -name "*.txt" | xargs -I{} sed -i 's/$/\r/' {}

#### ファイル名をCP932でエンコーディング変換する
convmv -f utf8 -t cp932 -r --notest "$nameZip/"
if [ 0 -ne $? ] ; then
	echo "error convmn"
	exit -1
fi
pushd "$nameZip/"
zip -9 -r "../$nameZip.zip" *
popd
rm -rf "$nameZip"

