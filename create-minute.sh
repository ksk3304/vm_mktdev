#!/bin/bash

# logsディレクトリ内のログファイルをminutesディレクトリにHTMLとしてコピーするスクリプト

LOG_DIR="logs"
MINUTE_DIR="minutes"
INDEX_HTML="minutes/index.html"
CSS_FILE="style.css"

# minutesディレクトリがなければ作成
mkdir -p "$MINUTE_DIR"

# index.htmlのヘッダー部分を生成
cat << EOF > "$INDEX_HTML"
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>バーチャル議事録</title>
    <link rel="stylesheet" href="$CSS_FILE">
</head>
<body>
    <div class="container">
        <header>
            <h1>バーチャル議事録</h1>
        </header>
        <ul class="minute-list">
EOF

# ログファイルを検索して一覧に追加
for log_file in $(find "$LOG_DIR" -name "*.txt" -type f | sort -r); do
    filename=$(basename "$log_file")
    html_file="$MINUTE_DIR/${filename%.txt}.html"
    upload_date=$(date -r $(stat -f %m "$log_file") "+%Y-%m-%d %H:%M:%S")

    # --- で区切られたMarkdown部分を抽出
    markdown_content=$(awk '/---/ {p=1; next} p' "$log_file")
    
    # プレーンテキスト部分（---より前）を抽出
    plain_text_content=$(awk 'BEGIN{ORS="\\n"}/---/{exit}{print}' "$log_file")

    # showdownを使ってMarkdownをHTMLに変換
    converted_html=$(echo "$markdown_content" | node -e "
        const fs = require('fs');
        const showdown = require('showdown');
        const converter = new showdown.Converter();
        const text = fs.readFileSync(0, 'utf-8');
        const html = converter.makeHtml(text);
        console.log(html);
    ")

    # ログファイルの内容をHTMLに変換
    {
        echo "<!DOCTYPE html>"
        echo "<html lang=\"ja\">"
        echo "<head>"
        echo "    <meta charset=\"UTF-8\">"
        echo "    <title>$filename</title>"
        echo "    <link rel=\"stylesheet\" href=\"$CSS_FILE\">"
        echo "</head>"
        echo "<body>"
        echo "    <div class=\"container\">"
        echo "        <div class=\"log-content-wrapper\">"
        echo "            <a href=\"index.html\" class=\"back-link\">← 議事録一覧に戻る</a>"
        echo "            <h2>$filename</h2>"
        echo "            <pre>${plain_text_content}</pre>"
        echo "            <div class=\"markdown-body\">"
        echo "$converted_html"
        echo "            </div>"
        echo "        </div>"
        echo "    </div>"
        echo "</body>"
        echo "</html>"
    } > "$html_file"

    # index.htmlにリンクを追加
    echo "            <li><a href=\"${filename%.txt}.html\"><span>${filename}</span><span class=\"upload-date\">${upload_date}</span></a></li>" >> "$INDEX_HTML"
done

# index.htmlのフッター部分を生成
cat << EOF >> "$INDEX_HTML"
        </ul>
    </div>
</body>
</html>
EOF

echo "議事録の生成が完了しました。"
echo "次のファイルを開いて確認してください: $INDEX_HTML"
echo "open $INDEX_HTML"