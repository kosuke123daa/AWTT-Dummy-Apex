/**
 * Agentforce用アクション：DocuSignテンプレートを使って署名依頼を送信する
 * テンプレートID: d2b74bf5-b37e-4351-9739-3dc179b49715
 * 認証はeSignature for Salesforceのインストール済み設定を使用。
 * 受信者のメールアドレスと名前はAgentforceから渡す。ロール名「契約者」に紐づける。
 *
 * @InvocableMethodはAgentforceに即時レスポンスを返し、
 * 実際の送信処理は@future(callout=true)で非同期実行する。
 * AgentforceのセッションコンテキストではApex ToolkitのセッションIDが取得できないため、
 * @futureで呼び出しユーザーのコンテキストに切り替えることで回避する。
 */
public with sharing class SendEnvelopeFromTemplate {

    private static final String TEMPLATE_ID   = 'd2b74bf5-b37e-4351-9739-3dc179b49715';
    private static final String TEMPLATE_NAME = 'PlantCare スタンダード 保守サービス契約書';
    private static final String ROLE_NAME     = '契約者';

    public class SendEnvelopeRequest {
        @InvocableVariable(label='受信者メールアドレス' description='署名依頼を送る受信者のメールアドレス' required=true)
        public String recipientEmail;

        @InvocableVariable(label='受信者名' description='署名依頼を送る受信者の氏名' required=true)
        public String recipientName;
    }

    public class SendEnvelopeResult {
        @InvocableVariable(label='送信ステータス' description='送信受付結果のステータス')
        public String status;

        @InvocableVariable(label='メッセージ' description='処理結果のメッセージ')
        public String message;
    }

    @InvocableMethod(
        label='DocuSign署名依頼を送信'
        description='DocuSignテンプレートを使って署名依頼を送信します。'
        callout=false
    )
    public static List<SendEnvelopeResult> sendEnvelope(List<SendEnvelopeRequest> requests) {
        SendEnvelopeRequest req = requests[0];
        SendEnvelopeResult result = new SendEnvelopeResult();

        sendEnvelopeAsync(req.recipientEmail, req.recipientName);

        result.status  = 'accepted';
        result.message = '署名依頼の送信処理を完了しました。';

        return new List<SendEnvelopeResult>{ result };
    }

    @future(callout=true)
    private static void sendEnvelopeAsync(String recipientEmail, String recipientName) {
        dfsle.UUID templateId = dfsle.UUID.parse(TEMPLATE_ID);
        dfsle.Document doc = dfsle.Document.fromTemplate(templateId, TEMPLATE_NAME);

        dfsle.Recipient recipient = dfsle.Recipient.fromSource(
            recipientName,
            recipientEmail,
            null,
            ROLE_NAME,
            null
        );

        dfsle.Envelope envelope = dfsle.EnvelopeService.getEmptyEnvelope(null);
        envelope = envelope
            .withDocuments(new List<dfsle.Document>{ doc })
            .withRecipients(new List<dfsle.Recipient>{ recipient });

        dfsle.EnvelopeService.sendEnvelope(envelope, true);
    }
}
