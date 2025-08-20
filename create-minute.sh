#!/bin/bash

# logsディレクトリ内のログファイルをminutesディレクトリにHTMLとして整理するスクリプト

LOG_DIR="logs"
MINUTE_DIR="minutes"
INDEX_HTML="minutes/index.html"

# minutesディレクトリがなければ作成
mkdir -p "$MINUTE_DIR"

# CSSファイルを作成
cat << 'EOF' > "$MINUTE_DIR/style.css"
body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
    line-height: 1.6;
    color: #333;
    max-width: 1200px;
    margin: 0 auto;
    padding: 20px;
    background-color: #f5f5f5;
}

.container {
    background-color: white;
    border-radius: 8px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    padding: 30px;
}

header {
    border-bottom: 3px solid #007bff;
    padding-bottom: 20px;
    margin-bottom: 30px;
}

h1, h2 {
    color: #2c3e50;
}

h1 {
    font-size: 2.5em;
    margin: 0;
}

h2 {
    font-size: 1.8em;
    border-bottom: 2px solid #e0e0e0;
    padding-bottom: 10px;
}

h3 {
    font-size: 1.4em;
    color: #34495e;
    margin-top: 25px;
}

h4 {
    font-size: 1.2em;
    color: #555;
    margin-top: 20px;
}

.minute-list {
    list-style: none;
    padding: 0;
}

.minute-list li {
    background-color: #f8f9fa;
    margin: 10px 0;
    padding: 15px;
    border-radius: 5px;
    border-left: 4px solid #007bff;
    transition: all 0.3s ease;
}

.minute-list li:hover {
    background-color: #e3f2fd;
    transform: translateX(5px);
}

.minute-list a {
    text-decoration: none;
    color: #333;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.minute-list .date {
    font-weight: bold;
    color: #007bff;
}

.minute-list .subject {
    flex-grow: 1;
    margin: 0 20px;
}

.minute-list .upload-date {
    color: #666;
    font-size: 0.9em;
}

.back-link {
    display: inline-block;
    margin-bottom: 20px;
    color: #007bff;
    text-decoration: none;
    font-weight: bold;
}

.back-link:hover {
    text-decoration: underline;
}

.log-content {
    background-color: #f5f5f5;
    padding: 20px;
    border-radius: 5px;
    margin: 20px 0;
    font-family: 'Courier New', monospace;
    white-space: pre-wrap;
    word-wrap: break-word;
    border: 1px solid #ddd;
}

.markdown-body {
    margin-top: 30px;
    padding: 20px;
    background-color: #fafafa;
    border-radius: 5px;
}

.markdown-body ul, .markdown-body ol {
    padding-left: 30px;
}

.markdown-body ul ul, .markdown-body ol ol {
    margin-top: 10px;
}

.markdown-body li {
    margin: 5px 0;
}

.markdown-body blockquote {
    border-left: 4px solid #007bff;
    padding-left: 20px;
    margin-left: 0;
    color: #666;
    font-style: italic;
}

.markdown-body code {
    background-color: #e8e8e8;
    padding: 2px 6px;
    border-radius: 3px;
    font-family: 'Courier New', monospace;
}

.markdown-body pre {
    background-color: #2d2d2d;
    color: #f8f8f2;
    padding: 15px;
    border-radius: 5px;
    overflow-x: auto;
}

.markdown-body table {
    border-collapse: collapse;
    width: 100%;
    margin: 20px 0;
}

.markdown-body th, .markdown-body td {
    border: 1px solid #ddd;
    padding: 12px;
    text-align: left;
}

.markdown-body th {
    background-color: #007bff;
    color: white;
}

.markdown-body tr:nth-child(even) {
    background-color: #f2f2f2;
}

.department-section {
    margin: 20px 0;
    padding: 15px;
    border-left: 3px solid #28a745;
    background-color: #f8fff9;
}

.president-summary {
    margin-top: 30px;
    padding: 20px;
    background-color: #fff3cd;
    border: 2px solid #ffc107;
    border-radius: 5px;
}

.decision-item {
    background-color: #d4edda;
    padding: 10px;
    margin: 10px 0;
    border-radius: 5px;
    border-left: 4px solid #28a745;
}

.action-item {
    background-color: #cce5ff;
    padding: 10px;
    margin: 10px 0;
    border-radius: 5px;
    border-left: 4px solid #004085;
}
EOF

# index.htmlのヘッダー部分を生成
cat << 'EOF' > "$INDEX_HTML"
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>トンネル点検会社 バーチャル経営会議 議事録</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>🏢 トンネル点検会社 バーチャル経営会議</h1>
            <p>AIエージェントによる経営会議の議事録アーカイブ</p>
        </header>
        <h2>📋 議事録一覧</h2>
        <ul class="minute-list">
EOF

# ログファイルを日付順に処理
for log_file in $(find "$LOG_DIR" -name "*.log" -type f 2>/dev/null | sort -r); do
    filename=$(basename "$log_file")
    base_name="${filename%.log}"
    
    # 日付を抽出（YYYYMMDD形式を想定）
    if [[ $base_name =~ ^([0-9]{4})([0-9]{2})([0-9]{2}) ]]; then
        year="${BASH_REMATCH[1]}"
        month="${BASH_REMATCH[2]}"
        day="${BASH_REMATCH[3]}"
        
        # 年月ディレクトリを作成
        mkdir -p "$MINUTE_DIR/$year/$month"
        
        # HTMLファイルのパス
        html_file="$MINUTE_DIR/$year/$month/${base_name}.html"
        relative_path="$year/$month/${base_name}.html"
        
        # ファイルの更新日時を取得
        if [[ "$OSTYPE" == "darwin"* ]]; then
            upload_date=$(stat -f "%Sm" -t "%Y年%m月%d日 %H:%M" "$log_file")
        else
            upload_date=$(stat -c "%y" "$log_file" | cut -d' ' -f1,2 | cut -d'.' -f1)
        fi
        
        # ログファイルから議題を抽出（最初の行から）
        subject=$(head -n 1 "$log_file" 2>/dev/null | grep -o '議題：[^】]*' | sed 's/議題：//' || echo "会議記録")
        
        # --- で区切られたMarkdown部分を抽出
        markdown_content=$(awk '/^---$/ {p=1; next} p' "$log_file")
        
        # プレーンテキスト部分（---より前）を抽出
        plain_text_content=$(awk '/^---$/{exit}{print}' "$log_file")
        
        # Markdownコンテンツが存在する場合のみHTMLに変換
        if [ -n "$markdown_content" ]; then
            # pandocがインストールされている場合は使用、なければ簡易変換
            if command -v pandoc &> /dev/null; then
                converted_html=$(echo "$markdown_content" | pandoc -f markdown -t html)
            else
                # 簡易的なMarkdown変換
                converted_html=$(echo "$markdown_content" | sed -e 's/^#### \(.*\)/<h4>\1<\/h4>/' \
                    -e 's/^### \(.*\)/<h3>\1<\/h3>/' \
                    -e 's/^## \(.*\)/<h2>\1<\/h2>/' \
                    -e 's/^# \(.*\)/<h1>\1<\/h1>/' \
                    -e 's/^\* \(.*\)/<li>\1<\/li>/' \
                    -e 's/^- \(.*\)/<li>\1<\/li>/' \
                    -e 's/\*\*\([^*]*\)\*\*/<strong>\1<\/strong>/g' \
                    -e 's/^$/<br>/')
            fi
        else
            converted_html="<p>Markdown形式の議事録はまだ作成されていません。</p>"
        fi
        
        # 個別のHTMLファイルを生成
        cat << HTML > "$html_file"
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>議事録 - $year年$month月$day日</title>
    <link rel="stylesheet" href="../../style.css">
</head>
<body>
    <div class="container">
        <a href="../../index.html" class="back-link">← 議事録一覧に戻る</a>
        <header>
            <h1>議事録 - $year年$month月$day日</h1>
            <p>議題: $subject</p>
            <p>作成日時: $upload_date</p>
        </header>
        
        <section>
            <h2>📝 原文ログ</h2>
            <div class="log-content">$plain_text_content</div>
        </section>
        
        <section class="markdown-body">
            <h2>📋 議事録詳細</h2>
            $converted_html
        </section>
    </div>
</body>
</html>
HTML
        
        # index.htmlにリンクを追加
        cat << HTML >> "$INDEX_HTML"
            <li>
                <a href="$relative_path">
                    <span class="date">$year年$month月$day日</span>
                    <span class="subject">$subject</span>
                    <span class="upload-date">$upload_date</span>
                </a>
            </li>
HTML
    fi
done

# index.htmlのフッター部分を生成
cat << 'EOF' >> "$INDEX_HTML"
        </ul>
        <footer style="margin-top: 50px; padding-top: 20px; border-top: 1px solid #ddd; text-align: center; color: #666;">
            <p>© 2025 トンネル点検会社 | AIエージェント経営会議システム</p>
        </footer>
    </div>
</body>
</html>
EOF

echo "✅ 議事録の生成が完了しました。"
echo "📁 保存先: $MINUTE_DIR/"
echo "🌐 ウェブサイトを確認: open $INDEX_HTML"