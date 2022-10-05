#!/usr/bin/env bash

function help()
{
    echo "Usage:$0 poems.txt"
}

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
    PoemInfo="$(fetchPoemInfo ${PoemTitle})"
    PoemAuthor="$(extractPoemAuthor "${PoemInfo}")"
    PoemContent="$(extractPoemContent "${PoemInfo}")"
    formatPoemForAnki "${PoemTitle}" "${PoemAuthor}" "${PoemContent}"
}

function fetchPoemInfo
{
    PoemTitle="$1"
    curl -Ls -G --data-urlencode "value=${PoemTitle}" "https://so.gushiwen.org/search.aspx"|grep 'textarea'|head -n 1|stripTag |sed 's/http.*$//'
}

function extractPoemAuthor()
{
    PoemInfo="$1"
    echo "${PoemInfo}"|sed 's/.*——//'|sed 's/《.*//'
}

function extractPoemContent()
{
    PoemInfo="$1"
    echo "${PoemInfo}"|sed 's/——.*//'
}

function formatPoemForAnki()
{
    PoemTitle="$1"
    PoemAuthor="$2"
    PoemContent="$3"
    # echo "PoemTitle"
    # echo "${PoemTitle}"
    # echo "PoemInfo"
    # echo "${PoemInfo}"
    # echo "PoemAuthor"
    # echo "${PoemAuthor}"
    # echo "PoemContent"
    # echo "${PoemContent}"
    echo -n "${PoemTitle}|${PoemAuthor}|"
    echo ${PoemContent} |convertPoemText
    echo 
    
}

if [[ $# -eq 3 ]];then
   formatPoemForAnki "$1" "$2" "$(cat $3)"
   else
   cat "$1" |while read poem
   do
     fetchPoem "$poem"
   done
fi
