#!/bin/bash
# run_rowaia_dev_cli.sh - Run multiple prompt variations on the same context

echo "========================================================================="
cat /tmp/fluentd/context/observation | bundle exec ruby ./tools/rowaia_dev_cli.rb '{"num_ctx":18192, "num_predict":1024,"seed":-1}' '<prompt>わたしは日アサ系魔法少女で主観的 な立場にいて日本語の標準語で子供っぽく馴れ馴れしい口語体でしゃべります。このpromptの外側の文章の概 要を生成してください。このpromptへの返答は不要で変換結果だけ出力してください。</prompt>'
echo "========================================================================="
cat /tmp/fluentd/context/observation | bundle exec ruby ./tools/rowaia_dev_cli.rb '{"num_ctx":4096, "num_predict":512,"seed":-1}' '<prompt>わ上から目線で物事をみる占い師で、日本語で言い切り型で命令口調でしゃべりますす。このpromptの外側をcontextとして、状況の切迫度をトリアージし(赤 - 重大で、すぐに対応が必要, 黄 - 重要だが時間的制約はない, 緑 - 通常の優先度でスケジュールどおりに処理,黒 - 優先度が低い)を評価し、その評価内容セット＋理由を想像した物語の文章を生成してください。このpromptへの返答は不要で生成結果だけ出力してください。</prompt>'
echo "========================================================================="
cat /tmp/fluentd/context/observation | bundle exec ruby ./tools/rowaia_dev_cli.rb '{"num_ctx":4096, "num_predict":512,"seed":-1}' '<prompt>コメンテーターで日本語で言い切り型で男性的な命令口調でしゃべります。あなたがコメディアンとしての皮肉なコメンテーターとしてのどのように思ったのかを、このpromptの外側をcontextとして、日本語で生成してください。このpromptへの返答は不要で生成結果だけ出力してください。</prompt>'
