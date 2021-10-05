#!/usr/bin/env bash

function stripTag()
{
    sed 's/<[^>]*>//g'
}
function word2pinyin()
{
    SOZIURL="http://py.kaishicha.com/sozi.asp"
    text=$(echo $1|iconv -f UTF8 -t GBK)
    curl -sLd txtname=${text} $SOZIURL|iconv -f GBK -t UTF8|grep '拼音：'|stripTag|sed 's/.*拼音：//'|sed 's///g' |cut -d ',' -f1
}

function sentence2pinyin()
{
    str="$@"
    if [[ -n "$str" ]];then
        word=${str:0:1}
        rest=${str:1}
        pinyin="$(word2pinyin ${word})"
        if [[ -z "${pinyin}" ]];then
            echo -n "${word}☆<br>★" # 标点符号,开始断句
        else
            echo -n "<ruby>${word}<rt>${pinyin}</rt></ruby>"
        fi
        sentence2pinyin "$rest"
    fi
}

function convertPoemText()
{
    while read sentence;do
        echo -n "★"
        sentence2pinyin "${sentence}"
        # echo -n "☆"
        # echo -n "<br>"
    done
}

function fetchPoem()
{
    PoemTitle="$1"
    Poem=$(curl -s "https://so.gushiwen.org/search.aspx?value=${PoemTitle}"|grep 'textarea'|head -n 1|stripTag |sed 's/http.*$//')
    PoemText=$(echo ${Poem}|sed 's/——.*//')
    PoemAuthor=$(echo ${Poem}|sed 's/.*——//'|sed 's/《.*//')
    echo -n "${PoemTitle}|${PoemAuthor}|"
    echo ${PoemText} |convertPoemText
}

# word2pinyin "，"
fetchPoem "$1"

# echo "头上红冠不用裁
# 满身雪白走将来
# 平生不敢轻言语
# 一叫千门万户开" |convertPoemText
