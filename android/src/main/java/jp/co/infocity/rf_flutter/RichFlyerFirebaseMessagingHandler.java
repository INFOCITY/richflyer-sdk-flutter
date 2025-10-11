package jp.co.infocity.rf_flutter;

import android.content.Context;
import androidx.annotation.NonNull;
import java.util.Map;
import jp.co.infocity.richflyer.RFSendPushInformation;
import jp.co.infocity.richflyer.RichFlyer;
import jp.co.infocity.richflyer.RichFlyerResultListener;
import jp.co.infocity.richflyer.util.RFResult;

public class RichFlyerFirebaseMessagingHandler {

    private final Context context;

    public RichFlyerFirebaseMessagingHandler(Context context) {
        this.context = context.getApplicationContext();
    }

    public void onMessageReceived(Map<String, String> data) {
        // 通知受信時に通知バーに表示するアイコンを設定
        int notificationIcon = context.getResources().getIdentifier("rf_notification", "mipmap", context.getPackageName());
        RFSendPushInformation spi = new RFSendPushInformation(context, notificationIcon);
        // 通知ドロワーに受信したプッシュ通知を表示する
        if (spi.isRichFlyerNotification(data)) {
            // RichFlyerからの通知を表示する。
            spi.setPushData(data);
        }
    }

    public void onNewToken(@NonNull String token) {
        // デバイストークンを管理サーバに通知する
        RichFlyer richFlyer = new RichFlyer(context);
        richFlyer.tokenRefresh(token, new RichFlyerResultListener() {
            @Override
            public void onCompleted(RFResult result) {
            }
        });
    }
}
