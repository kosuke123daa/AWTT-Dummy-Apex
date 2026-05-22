/**
 * Agentforce用アクション：DocuSignテンプレートを使って署名依頼を送信する
 * テンプレートID: d2b74bf5-b37e-4351-9739-3dc179b49715
 * 受信者はテンプレートに設定済みのため、テンプレート指定のみで送信可能。
 * 認証はeSignature for Salesforceのインストール済み設定を使用。
 */
public with sharing class SendEnvelopeFromTemplate {

    private static final String TEMPLATE_ID = 'd2b74bf5-b37e-4351-9739-3dc179b49715';
    private static final String TEMPLATE_NAME = 'PlantCare スタンダード 保守サービス契約書';

    public class SendEnvelopeRequest {
        @InvocableVariable(label='送信メモ' description='Agentforceから渡される送信依頼の補足メモ（任意）')
        public String memo;
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
        SendEnvelopeResult result = new SendEnvelopeResult();

        try {
            // テンプレートIDをdfsle.UUID形式に変換
            dfsle.UUID templateId = dfsle.UUID.parse(TEMPLATE_ID);

            // テンプレートからドキュメントを生成
            dfsle.Document doc = dfsle.Document.fromTemplate(templateId, TEMPLATE_NAME);

            // 空のエンベロープを作成（Salesforceレコードとの紐付けなし）
            dfsle.Envelope envelope = dfsle.EnvelopeService.getEmptyEnvelope(null);

            // エンベロープにドキュメント（テンプレート）を追加
            envelope = envelope.withDocuments(new List<dfsle.Document>{ doc });

            // 送信（受信者はテンプレートに設定済みのためここでは不要）
            envelope = dfsle.EnvelopeService.sendEnvelope(envelope, true);

            result.envelopeId = envelope.docuSignId == null ? null : envelope.docuSignId.toString();
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
