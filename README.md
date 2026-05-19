# AWTT Dummy Apex

Agentforce デモ用のハリボテ Apex クラス集です。

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

### 返却値

| フィールド | 内容 |
|---|---|
| `agreementTitle` | PlantCare スタンダード 保守サービス契約書 |
| `documentUrl` | DocuSign Navigator 上の契約書 URL |
| `riskReason` | 価格改定方式・調達元区分・不可抗力区分・自動更新・有効期限に関するリスク理由 |

### 「分析中」の間の演出

Named Credential `DocuSignNavigator` 経由でダミーの外部 Callout を1回実行し、タイムアウト（デフォルト8秒）を利用して処理感を演出しています。Named Credential が未設定の環境でも例外を握りつぶすためデモは正常に動作します。

タイムアウト秒数は `simulateNavigatorCall()` 内の `setTimeout` の値を変更することで調整できます。

```apex
req.setTimeout(8000); // ミリ秒で指定
```

### Agentforce 向けの質問例

> 世界的なインフレーションや燃料費の高騰に加え、紛争などによってサプライチェーンが不安定になっているが、自社にリスクがある契約書を洗い出して、契約内容を見直したい。リスクがある契約書を探してほしい。

### デプロイ手順

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
