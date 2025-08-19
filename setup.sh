#!/bin/bash

# 🚀 トンネル点検エージェント協調システム 環境構築
# 参考: setup_full_environment.sh

set -e  # エラー時に停止

# 色付きログ関数
log_info() {
    echo -e "\033[1;32m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[1;34m[SUCCESS]\033[0m $1"
}

echo "🏗️ トンネル点検エージェント協調システム 環境構築"
echo "================================================="
echo ""

# STEP 1: 既存セッションクリーンアップ
log_info "🧹 既存セッションクリーンアップ開始..."

tmux kill-session -t multiagent 2>/dev/null && log_info "multiagentセッション削除完了" || log_info "multiagentセッションは存在しませんでした"
tmux kill-session -t president 2>/dev/null && log_info "presidentセッション削除完了" || log_info "presidentセッションは存在しませんでした"

# 完了ファイルクリア
mkdir -p ./tmp
rm -f ./tmp/*_done.txt 2>/dev/null && log_info "既存の完了ファイルをクリア" || log_info "完了ファイルは存在しませんでした"
rm -f ./tmp/*_progress.log 2>/dev/null && log_info "既存の進捗ログをクリア" || log_info "進捗ログは存在しませんでした"

log_success "✅ クリーンアップ完了"
echo ""

# STEP 2: multiagentセッション作成（4ペイン：営業・技術・経理・人事）
log_info "📺 multiagentセッション作成開始 (4ペイン)..."

# 最初のペイン作成
tmux new-session -d -s multiagent -n "agents"

# 2x2グリッド作成（合計4ペイン）
tmux split-window -h -t "multiagent:0"      # 水平分割（左右）
tmux select-pane -t "multiagent:0.0"
tmux split-window -v                        # 左側を垂直分割
tmux select-pane -t "multiagent:0.2"
tmux split-window -v                        # 右側を垂直分割

# ペインタイトル設定
log_info "ペインタイトル設定中..."
PANE_TITLES=("営業" "技術" "経理" "人事")
PANE_COLORS=("\033[1;33m" "\033[1;36m" "\033[1;32m" "\033[1;35m")  # 黄、シアン、緑、紫

for i in {0..3}; do
    tmux select-pane -t "multiagent:0.$i" -T "${PANE_TITLES[$i]}"
    
    # 作業ディレクトリ設定
    tmux send-keys -t "multiagent:0.$i" "cd $(pwd)" C-m
    
    # カラープロンプト設定
    tmux send-keys -t "multiagent:0.$i" "export PS1='(\[${PANE_COLORS[$i]}\]${PANE_TITLES[$i]}\[\033[0m\]) \[\033[1;32m\]\w\[\033[0m\]\$ '" C-m
    
    # ウェルカムメッセージ
    tmux send-keys -t "multiagent:0.$i" "echo '=== ${PANE_TITLES[$i]}担当 エージェント ==='" C-m
    tmux send-keys -t "multiagent:0.$i" "echo '準備完了'" C-m
done

log_success "✅ multiagentセッション作成完了"
echo ""

# STEP 3: presidentセッション作成（1ペイン）
log_info "👑 社長セッション作成開始..."

tmux new-session -d -s president
tmux send-keys -t president "cd $(pwd)" C-m
tmux send-keys -t president "export PS1='(\[\033[1;31m\]社長\[\033[0m\]) \[\033[1;32m\]\w\[\033[0m\]\$ '" C-m
tmux send-keys -t president "echo '=== 社長 セッション ==='" C-m
tmux send-keys -t president "echo '経営統括責任者'" C-m
tmux send-keys -t president "echo '=================='" C-m

log_success "✅ 社長セッション作成完了"
echo ""

# STEP 4: 環境確認・表示
log_info "🔍 環境確認中..."

echo ""
echo "📊 セットアップ結果:"
echo "==================="

# tmuxセッション確認
echo "📺 Tmux Sessions:"
tmux list-sessions
echo ""

# ペイン構成表示
echo "📋 ペイン構成:"
echo "  multiagentセッション（4ペイン）:"
echo "    Pane 0: 営業     (営業担当)"
echo "    Pane 1: 技術     (技術担当)"
echo "    Pane 2: 経理     (経理担当)"
echo "    Pane 3: 人事     (人事担当)"
echo ""
echo "  presidentセッション（1ペイン）:"
echo "    Pane 0: 社長     (経営統括)"

echo ""
log_success "🎉 トンネル点検システム環境セットアップ完了！"
echo ""
echo "📋 次のステップ:"
echo "  1. 🔗 セッションアタッチ:"
echo "     tmux attach-session -t multiagent   # 各部門確認"
echo "     tmux attach-session -t president    # 社長確認"
echo ""
echo "  2. 🤖 Claude Code起動:"
echo "     # 手順1: 社長認証"
echo "     tmux send-keys -t president 'claude --dangerously-skip-permissions' C-m"
echo "     # 手順2: 認証後、各部門一括起動"
echo "     for i in {0..3}; do tmux send-keys -t multiagent:0.\$i 'claude --dangerously-skip-permissions' C-m; done"
echo ""
echo "  3. 📜 指示書確認:"
echo "     社長: instructions/president.md"
echo "     営業: instructions/営業担当.md"
echo "     技術: instructions/技術担当.md"
echo "     経理: instructions/経理担当.md"
echo "     人事: instructions/人事担当.md"
echo "     システム構造: CLAUDE.md"
echo ""
echo "  4. 🎯 業務開始例:"
echo "     社長に「あなたは社長です。〇〇トンネルの定期点検を計画してください」と入力" 