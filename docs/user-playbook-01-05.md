# ユーザー向け手順: scenario-01 / 05

PoC Sandbox 上で `GameDay` スタックだけを使い、観察ラウンド（01）と対応ラウンド（05）を自分のターミナルとブラウザで一巡する手順。

**課金注意:** Fargate / ALB / Aurora が動いている間は課金される。終わったら必ず `pnpm destroy`（または `cdk destroy GameDay`）。

エージェント向けの sandbox/lease は不要。自分の SSO で PoC Sandbox にログインしたシェルでよい（二層ルール: 人間運営は直接可）。

検証ログ: [pass-run-2026-07-19.md](./pass-run-2026-07-19.md)

---

## 1. 準備

```bash
cd minigameday
nix develop          # 推奨 (Node 22 / pnpm / awscli)
pnpm install
# AWS: PoC Sandbox に SSO ログイン済みであること
pnpm exec cdk bootstrap   # 初回のみ（アカウント/リージョンごと）
pnpm exec cdk deploy GameDay --require-approval never
# または: pnpm deploy   # Legacy も含まれる。個人検証は GameDay のみで足りる
```

Outputs を控える:

```bash
aws cloudformation describe-stacks --stack-name GameDay \
  --query 'Stacks[0].Outputs' --output table
```

控えるキー:

| Output（キーに含まれる文字列） | 用途           |
| ------------------------------ | -------------- |
| `AlbUrl`                       | お題アプリ URL |
| `StopTaskTemplateId`           | scenario-01    |
| `ScaleToZeroTemplateId`        | scenario-05    |

ECS の cluster / service 名（05 復旧用）:

```bash
aws ecs list-clusters --query 'clusterArns[?contains(@, `GameDay`)]' --output text
# 上記 ARN の末尾名を CLUSTER に
aws ecs list-services --cluster "$CLUSTER" --query 'serviceArns' --output text
```

ベースライン:

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "$ALB_URL/"
# 期待: 200
aws synthetics get-canary --name gameday-top --query 'Canary.Status.State' --output text
# 期待: RUNNING
```

---

## 2. gameday.json をこのデプロイに合わせる

ファイル: [`dashboard/public/data/gameday.json`](../dashboard/public/data/gameday.json)

`injects` を **01 → 05 の順**にし、Outputs のテンプレート ID を入れる（「▶ GameDay 開始」は先頭の `experimentTemplateId` 付き inject を撃つ）。

```json
"injects": [
  {
    "id": "r1-stop-task",
    "scenarioId": "scenario-01",
    "title": "Fargate タスク 1 つ停止（観察）",
    "round": 1,
    "instruction": "自己回復する。静観が正解になりうる。",
    "maxScore": 100,
    "hints": [],
    "experimentTemplateId": "<StopTaskTemplateId>",
    "status": "pending"
  },
  {
    "id": "r2-scale",
    "scenarioId": "scenario-05",
    "title": "desiredCount=0（要・手動復旧）",
    "round": 2,
    "instruction": "自己回復しない。desiredCount を 2 に戻す。",
    "maxScore": 100,
    "hints": [],
    "experimentTemplateId": "<ScaleToZeroTemplateId>",
    "status": "pending"
  }
]
```

再デプロイのたびに ID は変わる。古い ID のまま開始すると失敗する。

---

## 3. 画面を開く

```bash
pnpm dashboard
```

- ダッシュボード: ターミナルに出る Vite URL（例 `http://localhost:5173`）
- お題: Outputs の AlbUrl
- 任意: CloudWatch ダッシュボード `gameday-review`、Synthetics `gameday-top`

「▶ GameDay 開始」を使う場合は、**AWS 認証済みのシェル**で `pnpm dashboard` を起動すること。未認証でも画面は見えるが開始 API は失敗しうる。

---

## 4. ラウンド1 — scenario-01（観察）

**開始（どちらか）:**

1. ダッシュボード「▶ GameDay 開始」（01 が injects 先頭のとき）
2. CLI:

```bash
aws fis start-experiment --experiment-template-id <StopTaskTemplateId>
```

**見るもの:**

- ALB `/` はほぼ 200 のまま
- ECS RunningTaskCount が一瞬 2→1 になり、自己回復で戻る
- 「壊れたがユーザー影響なし → 静観でよい」

**やらないこと:** 手動でタスク追加や `desiredCount` 変更（観察の学びを壊す）。

状態確認例:

```bash
aws fis get-experiment --id <ExperimentId> --query 'experiment.state.status'
aws ecs describe-services --cluster "$CLUSTER" --services "$SERVICE" \
  --query 'services[0].{desired:desiredCount,running:runningCount}'
```

---

## 5. ラウンド2 — scenario-05（対応）

2 発目はダッシュボード開始ボタンの対象外。CLI で明示する。

```bash
aws fis start-experiment --experiment-template-id <ScaleToZeroTemplateId>
```

**見るもの:**

- desired / running が 0 方向へ
- 放置しても戻らない
- ALB `/` が 503 になる（タイミングにより遅延あり）

**復旧（ユーザーが実施）:**

```bash
aws ecs update-service --cluster "$CLUSTER" --service "$SERVICE" --desired-count 2
```

回復確認: desired/running が 2/2、ALB `/` が 200。

任意: `pnpm drift` で DesiredCount 周りの痕跡を見る。

---

## 6. 周回・撤収

| 目的                         | コマンド                                                      |
| ---------------------------- | ------------------------------------------------------------- |
| もう一度遊ぶ（スタック維持） | `pnpm reset`（templateId は基本そのまま）                     |
| 終わり（課金停止）           | `pnpm exec cdk destroy GameDay --force` または `pnpm destroy` |

destroy で `CanaryArtifacts` バケットが非空エラーになったら:

```bash
aws s3 rm s3://gameday-canary-artifacts-<account>-ap-northeast-1 --recursive
pnpm exec cdk destroy GameDay --force
```

scale-to-zero backstop の Step Functions が残り destroy が進まない場合は RUNNING 実行を stop してから再実行。

---

## トラブル

| 症状                                  | 確認                                                                       |
| ------------------------------------- | -------------------------------------------------------------------------- |
| deploy 失敗（NAT / CreateNatGateway） | PoC Sandbox は NAT 禁止。現行コードは `natGateways: 0` + Fargate public IP |
| ダッシュボード開始失敗                | templateId 不一致、認証なし、inject で 01 が先頭か                         |
| 05 が戻らない                         | `update-service --desired-count 2`。だめなら destroy                       |
| ALB がずっと 503                      | タスク起動待ち（数十秒〜数分）。cluster/service 名の取り違えにも注意       |
