# AWTT Dummy Apex

Agentforce デモ用の Apex クラス集です。

---

## ContractRiskAnalyzer

### 概要

Agentforce から呼び出すと、DocuSign Navigator からリスクのある契約書を抽出したように見せるデモ用 Apex クラスです。世界的なインフレ・燃料費高騰・地政学リスクを背景とした契約見直しデモを想定しています。

### Agentforce への登録情報

| 項目 | 値 |
|---|---|
| クラス名 | `ContractRiskAnalyzer` |
| メソッド名 | `getRiskyContracts` |
| Action ラベル | `DocuSign契約書を抽出` |

### 入力

| フィールド | 必須 | 内容 |
|---|---|---|
| `query` | 任意 | Agentforceから渡される依頼内容 |

### 出力

| フィールド | 内容 |
|---|---|
| `agreementTitle` | 抽出された契約書の名称 |
| `documentUrl` | DocuSign Navigator 上の契約書 URL |
| `riskReason` | 抽出された具体的な根拠 |

### 「分析中」の間の演出

Named Credential `DocuSignNavigator` 経由でダミーの外部 Callout を1回実行し、タイムアウト（デフォルト8秒）を利用して処理感を演出しています。Named Credential が未設定の環境でも例外を握りつぶすためデモは正常に動作します。

タイムアウト秒数は `simulateNavigatorCall()` 内の `setTimeout` の値を変更することで調整できます。

```apex
req.setTimeout(8000); // ミリ秒で指定
```

### Agentforce 向けの質問例

> 世界的なインフレーションや燃料費の高騰に加え、紛争などによってサプライチェーンが不安定になっているが、自社にリスクがある契約書を洗い出して、契約内容を見直したい。リスクがある契約書を探してほしい。

---

## SendEnvelopeFromTemplate

### 概要

Agentforce から呼び出すと、DocuSign テンプレートを使って署名依頼を送信する Apex クラスです。eSignature for Salesforce のインストール済み認証設定と DocuSign Apex Toolkit を使用します。

### Agentforce への登録情報

| 項目 | 値 |
|---|---|
| クラス名 | `SendEnvelopeFromTemplate` |
| メソッド名 | `sendEnvelope` |
| Action ラベル | `DocuSign署名依頼を送信` |
| テンプレートID | `d2b74bf5-b37e-4351-9739-3dc179b49715` |
| テンプレートロール名 | `契約者` |

### 入力

| フィールド | 必須 | 内容 |
|---|---|---|
| `recipientEmail` | 必須 | 署名依頼を送る受信者のメールアドレス |
| `recipientName` | 必須 | 署名依頼を送る受信者の氏名 |

### 出力

| フィールド | 内容 |
|---|---|
| `envelopeId` | 送信されたDocuSignエンベロープのID |
| `status` | `sent` または `error` |
| `message` | 処理結果のメッセージ |

### 注意事項

DocuSign Apex Toolkit はテンプレートに受信者が設定済みでも、Apex側でロールに紐づけた受信者指定が必要です。

実行ユーザー（Agentforceシステムユーザーを含む）が DocuSign の OAuth 接続を完了していない場合、`Current session unavailable` エラーが発生します。事前に該当ユーザーで DocuSign の OAuth 認証を通しておく必要があります。

---

## デプロイ手順

```bash
# 1. クローン
git clone https://github.com/kosuke123daa/awtt-dummy-apex.git
cd awtt-dummy-apex
git checkout claude/agentforce-contract-risk-demo-E6RD8

# 2. Org 認証
sf org login web --alias awtt-demo

# 3. デプロイ
sf project deploy start --source-dir force-app --target-org awtt-demo
```

### 最新を取得して再デプロイ

```bash
cd ~/awtt-dummy-apex
git pull origin claude/agentforce-contract-risk-demo-E6RD8
sf project deploy start --source-dir force-app --target-org awtt-demo
```
