/**
 * Agentforce用アクション：リスクのある契約書をDocuSign Navigatorから抽出する（デモ用ハリボテ）
 *
 * 「間」の仕組み:
 * Agentforce から呼ばれると、まず DocuSign Navigator への外部 Callout を
 * 1回実行する（Named Credential: DocuSignNavigator を使用）。
 * Callout のタイムアウトを意図的に長めに設定することで、
 * 実際の処理感・待ち時間をデモ上で演出している。
 * レスポンス内容は使用せず、固定のモックデータを返す。
 */
public with sharing class ContractRiskAnalyzer {

    public class ContractRiskResult {
        @InvocableVariable(label='契約書タイトル' description='抽出された契約書の名称')
        public String agreementTitle;

        @InvocableVariable(label='契約書URL' description='DocuSign Navigator上の契約書URL')
        public String documentUrl;

        @InvocableVariable(label='Reason' description='抽出された具体的な根拠')
        public String riskReason;
    }

    public class ContractRiskRequest {
        @InvocableVariable(label='分析クエリ' description='Agentforceから渡される依頼内容')
        public String query;
    }

    @InvocableMethod(
        label='DocuSign契約書を抽出'
        description='DocuSign Navigatorからリクエストされた契約書を抽出して返します。'
        callout=true
    )
    public static List<ContractRiskResult> getRiskyContracts(List<ContractRiskRequest> requests) {

        // DocuSign Navigatorへのダミーリクエストで「分析中」の間を演出
        simulateNavigatorCall();

        // モックデータを組み立てて返す
        ContractRiskResult result = new ContractRiskResult();
        result.agreementTitle = 'PlantCare スタンダード 保守サービス契約書';
        result.documentUrl    = 'https://apps-d.docusign.com/send/navigator/agreements/52a32464-9996-4042-9151-54003a46e11e?force_reauth=true&accountId=68caeeed-03a5-42f0-94af-3d56304e4d71';
        result.riskReason     = '主要交換部材の調達元が海外のため地政学リスク・物流遅延による部材確保困難のおそれあり、現行単価が据え置きのまま自動更新されるとインフレ・燃料費高騰分を回収できないリスク、有効期限まで3ヶ月以内のため値上げ交渉の機会が限られる';

        return new List<ContractRiskResult>{ result };
    }

    /**
     * DocuSign Navigator API への Callout を1回行い、処理時間を演出する。
     * Named Credential「DocuSignNavigator」が未設定の環境では
     * 例外を握りつぶして無視し、デモの続行を優先する。
     */
    private static void simulateNavigatorCall() {
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:DocuSignNavigator/v1/agreements?limit=1');
            req.setMethod('GET');
            req.setTimeout(8000); // 8秒タイムアウト → "分析中"の演出
            new Http().send(req);
        } catch (Exception e) {
            // Named Credential 未設定 or タイムアウト → デモ継続のため無視
        }
    }
}
