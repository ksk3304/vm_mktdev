#!/bin/bash

# 🚀 トンネル点検エージェント間メッセージ送信スクリプト

# エージェント→tmuxターゲット マッピング
get_agent_target() {
    case "$1" in
        "president"|"社長") echo "president" ;;
        "営業") echo "multiagent:0.0" ;;
        "技術") echo "multiagent:0.1" ;;
        "経理") echo "multiagent:0.2" ;;
        "人事") echo "multiagent:0.3" ;;
        *) echo "" ;;
    esac
}

show_usage() {
    cat << EOF
🏗️ トンネル点検エージェント間メッセージ送信

使用方法:
  $0 [エージェント名] [メッセージ]
  $0 --list

利用可能エージェント:
  社長/president - 経営統括責任者
  営業          - 営業担当
  技術          - 技術担当
  経理          - 経理担当
  人事          - 人事担当

使用例:
  $0 社長 "〇〇トンネルの点検を計画してください"
  $0 営業 "新規顧客の開拓状況を報告してください"
  $0 技術 "AI診断システムの導入計画を策定してください"
  $0 経理 "月次決算を開始してください"
  $0 人事 "技術者の採用計画を作成してください"
EOF
}

# エージェント一覧表示
show_agents() {
    echo "📋 利用可能なエージェント:"
    echo "=========================="
    echo "  社長/president → president:0     (経営統括責任者)"
    echo "  営業          → multiagent:0.0  (営業担当)"
    echo "  技術          → multiagent:0.1  (技術担当)"
    echo "  経理          → multiagent:0.2  (経理担当)" 
    echo "  人事          → multiagent:0.3  (人事担当)"
}

# ログ記録
log_send() {
    local agent="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_filename=$(date '+%Y%m%d')_send.log
    
    mkdir -p logs
    echo "[$timestamp] $agent: SENT - \"$message\"" >> "logs/$log_filename"
}

# メッセージ送信
send_message() {
    local target="$1"
    local message="$2"
    
    echo "📤 送信中: $target ← '$message'"
    
    # Claude Codeのプロンプトを一度クリア
    tmux send-keys -t "$target" C-c
    sleep 0.3
    
    # メッセージ送信
    tmux send-keys -t "$target" "$message"
    sleep 0.1
    
    # エンター押下
    tmux send-keys -t "$target" C-m
    sleep 0.5
}

# ターゲット存在確認
check_target() {
    local target="$1"
    local session_name="${target%%:*}"
    
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        echo "❌ セッション '$session_name' が見つかりません"
        return 1
    fi
    
    return 0
}

# メイン処理
main() {
    if [[ $# -eq 0 ]]; then
        show_usage
        exit 1
    fi
    
    # --listオプション
    if [[ "$1" == "--list" ]]; then
        show_agents
        exit 0
    fi
    
    if [[ $# -lt 2 ]]; then
        show_usage
        exit 1
    fi
    
    local agent_name="$1"
    local message="$2"
    
    # エージェントターゲット取得
    local target
    target=$(get_agent_target "$agent_name")
    
    if [[ -z "$target" ]]; then
        echo "❌ エラー: 不明なエージェント '$agent_name'"
        echo "利用可能エージェント: $0 --list"
        exit 1
    fi
    
    # ターゲット確認
    if ! check_target "$target"; then
        exit 1
    fi
    
    # メッセージ送信
    send_message "$target" "$message"
    
    # ログ記録
    log_send "$agent_name" "$message"
    
    echo "✅ 送信完了: $agent_name に '$message'"
    
    return 0
}

main "$@" 