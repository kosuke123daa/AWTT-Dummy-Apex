/**
 * Agentforce用アクション：DocuSignテンプレートを使って署名依頼を送信する
 * テンプレートID: d2b74bf5-b37e-4351-9739-3dc179b49715
 * 認証はeSignature for Salesforceのインストール済み設定を使用。
 * 受信者のメールアドレスと名前はAgentforceから渡す。ロール名「契約者」に紐づける。
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
        @InvocableVariable(label='エンベロープID' description='送信されたDocuSignエンベロープのID')
        public String envelopeId;

        @InvocableVariable(label='送信ステータス' description='送信結果のステータス')
        public String status;

        @InvocableVariable(label='メッセージ' description='処理結果のメッセージ')
        public String message;
    }

    @InvocableMethod(
        label='DocuSign署名依頼を送信'
        description='DocuSignテンプレートを使って署名依頼を送信します。'
        callout=true
    )
    public static List<SendEnvelopeResult> sendEnvelope(List<SendEnvelopeRequest> requests) {
        SendEnvelopeRequest req = requests[0];
        SendEnvelopeResult result = new SendEnvelopeResult();

        try {
            // テンプレートIDをdfsle.UUID形式に変換
            dfsle.UUID templateId = dfsle.UUID.parse(TEMPLATE_ID);

            // テンプレートからドキュメントを生成
            dfsle.Document doc = dfsle.Document.fromTemplate(templateId, TEMPLATE_NAME);

            // 受信者をテンプレートのロール「契約者」に紐づけて生成
            dfsle.Recipient recipient = dfsle.Recipient.fromSource(
                req.recipientName,
                req.recipientEmail,
                null,
                ROLE_NAME,
                null
            );

            // 空のエンベロープを作成（Salesforceレコードとの紐付けなし）
            dfsle.Envelope envelope = dfsle.EnvelopeService.getEmptyEnvelope(null);

            // エンベロープにドキュメント（テンプレート）と受信者を追加
            envelope = envelope
                .withDocuments(new List<dfsle.Document>{ doc })
                .withRecipients(new List<dfsle.Recipient>{ recipient });

            // 送信
            envelope = dfsle.EnvelopeService.sendEnvelope(envelope, true);

            result.envelopeId = envelope.docuSignId == null ? null : String.valueOf(envelope.docuSignId);
            result.status     = 'sent';
            result.message    = '署名依頼を送信しました。';

        } catch (Exception e) {
            result.envelopeId = null;
            result.status     = 'error';
            result.message    = '送信に失敗しました: ' + e.getMessage();
        }

        return new List<SendEnvelopeResult>{ result };
    }
}
