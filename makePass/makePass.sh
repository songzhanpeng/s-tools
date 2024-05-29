#!/bin/bash

# Usage: ./generate_password.sh [word_count] [password_count]
# 
# Description: 该脚本用于生成随机密码，基于牛津3000单词列表。
# 可以通过传入参数来指定单词的个数，默认为 3。
# 可以通过传入第二个参数指定生成的密码个数，默认为 1。
# 生成的密码会输出到终端，并复制到剪贴板中。
#
# 参数：
# - word_count（可选）: 指定单词的个数，默认为 3。
# - password_count (可选): 指定密码的个数，默认为1。

# 牛津3000单词列表文件路径
file_path="./The_Oxford_3000.txt"

# 检查文件是否存在，如果不存在则下载
if [ ! -f "$file_path" ]; then
    echo "正在下载牛津3000单词列表..."
    curl -O https://gist.githubusercontent.com/gandli/2534e8e0bd6256571bdd1618dcf3b1b1/raw/3adbe01ce31ef05ddfb8d9abdd81de0eb4762eb2/The_Oxford_3000.txt
fi

word_count=${1:-3}     # 获取传入的单词个数参数，默认为 3
password_count=${2:-1} # 获取传入的密码个数参数，默认为 1

for ((c = 1; c <= password_count; c++)); do
    password=""
    while true; do
        # 生成明文
        plaintext=$(
            shuf -n $word_count "$file_path" | tr '\n' ' '
            echo
        )
        plaintext=${plaintext%?}

        password=""
        # 根据规则转换明文为密码
        for ((j = 0; j < ${#plaintext}; j++)); do
            letter=${plaintext:j:1}
            leet=""
            # 对于每个字符，应用随机 Leetspeak 规则
            case "$letter" in
            a)
                leet=("a" "A" "4" "@")
                ;;
            b)
                leet=("b" "B" "8")
                ;;
            c)
                leet=("c" "C" "(")
                ;;
            d)
                leet=("d" "D")
                ;;
            e)
                leet=("e" "E" "3" "&")
                ;;
            f)
                leet=("f" "F")
                ;;
            g)
                leet=("g" "G" "9")
                ;;
            h)
                leet=("h" "H")
                ;;
            i)
                leet=("i" "I" "1" "!")
                ;;
            j)
                leet=("j" "J")
                ;;
            k)
                leet=("k" "K")
                ;;
            l)
                leet=("l" "L" "1")
                ;;
            m)
                leet=("m" "M")
                ;;
            n)
                leet=("n" "N")
                ;;
            o)
                leet=("o" "O" "0")
                ;;
            p)
                leet=("p" "P")
                ;;
            q)
                leet=("q" "Q" "9")
                ;;
            r)
                leet=("r" "R")
                ;;
            s)
                leet=("s" "S" "5" "$")
                ;;
            t)
                leet=("t" "T" "7" "+")
                ;;
            u)
                leet=("u" "U")
                ;;
            v)
                leet=("v" "V")
                ;;
            w)
                leet=("w" "W")
                ;;
            x)
                leet=("x" "X")
                ;;
            y)
                leet=("y" "Y")
                ;;
            z)
                leet=("z" "Z" "2")
                ;;
            *)
                leet=("$letter")
                ;;
            esac
            random_rule_index=$(shuf -i 0-$((${#leet[@]} - 1)) -n 1)
            letter=${leet[$random_rule_index]}
            password+="$letter"
        done

        # 检查密码是否符合要求，即必须包含大小写字母、数字和特殊符号
        if [[ $password =~ [a-z] && $password =~ [A-Z] && $password =~ [0-9] && $password =~ [^a-zA-Z0-9] ]]; then
            break
        fi
    done
    password=$(echo "$password" | tr ' ' '-')
    echo "明文为：$plaintext"
    echo "密码为：$password"

    # 检查可用的剪贴板命令并复制密码
    if command -v pbcopy &> /dev/null; then
        echo "pbcopy is available"
        echo -n "$password" | pbcopy
        echo "密码已复制到剪贴板 (macOS)"
    elif command -v clip &> /dev/null; then
        echo "clip is available"
        echo -n "$password" | clip
        echo "密码已复制到剪贴板 (Windows)"
    elif command -v xclip &> /dev/null; then
        echo "xclip is available"
        echo -n "$password" | xclip -selection clipboard
        echo "密码已复制到剪贴板 (Linux, xclip)"
    elif command -v xsel &> /dev/null; then
        echo "xsel is available"
        echo -n "$password" | xsel --clipboard --input
        echo "密码已复制到剪贴板 (Linux, xsel)"
    else
        echo "没有找到可用的剪贴板命令。请安装 pbcopy, clip, xclip 或 xsel。"
        exit 1
    fi
done
