package jp.co.infocity.rf_flutter;


import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.res.Resources;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.content.Intent;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.firebase.messaging.FirebaseMessaging;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import jp.co.infocity.richflyer.RichFlyer;
import jp.co.infocity.richflyer.RichFlyerResultListener;
import jp.co.infocity.richflyer.action.RFAction;
import jp.co.infocity.richflyer.action.RFActionListener;
import jp.co.infocity.richflyer.history.RFContent;
import jp.co.infocity.richflyer.util.RFResult;
import jp.co.infocity.richflyer.view.TranslucentDialogActivity;
import jp.co.infocity.richflyer.RichFlyerPostingResultListener;

/**
 * RichflyerSdkFlutterPlugin
 */
public class RichflyerSdkFlutterPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    public static MethodChannel channel;
    private Activity activity = null;
    private String serviceKey = "";
    private String themeColor = "";
    private ArrayList<String> launchOptions = new ArrayList<String>();


    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "jp.co.infocity/richflyer");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {

        switch (call.method) {
            case "RFInitialize":
                // 初期化
                Map<String, Object> settings = call.argument("settings");
                RFInitialize(settings);
                break;

            case "registerSegments":
                // セグメントの登録
                Map<String, String> segments = call.argument("segments");
                registerSegments(segments);
                break;

            case "postMessage":
                // イベント駆動型プッシュリクエスト
                ArrayList<String> events = call.argument("events");
                Map<String, String> variables = call.argument("variables");
                Integer standbyTime = call.argument("standbyTime");

                postMessage(events, variables, standbyTime);
                break;

            case "cancelMessage":
                // イベント駆動型プッシュリクエストのキャンセル
                String eventPostId = call.arguments();
                cancelPosting(eventPostId);

                break;

            case "getSegments":
                // セグメントの取得
                result.success(getSegments());
                break;

            case "getReceivedData":
                // 通知の受信履歴を取得する
                result.success(getHistory());
                break;

            case "getLatestReceivedData":
                // 最新のプッシュ通知を取得する
                result.success(getLatestNotification());
                break;

            case "showReceivedData":
                // 通知情報を表示する
                String notificationId = call.arguments();
                showHistoryNotification(notificationId);
                break;

            case "openNotification":
                // 通知受信時の情報取得
                break;

            case "resetBadgeNumber":
                // バッジの非表示：iOS独自メソッド
                break;

            case "setForegroundNotification":
                // フォアグラウンド通知のオプション設定：iOS独自メソッド
                break;

            default:
                result.notImplemented();
        }
    }

    // デバイストークン登録処理など
    private void RFInitialize(Map<String, Object> settings) {
        // 通知から起動した時に呼ばれるアクティビティ
        final Class targetActivity = activity.getClass();
        RichFlyer.checkNotificationPermission(activity);

        if (settings != null) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                settings.forEach((key, value) -> {
                    switch (key) {
                        case "RICHFLYER_SERVICE_KEY":
                            serviceKey = String.valueOf(value);
                            break;
                        case "RICHFLYER_THEME_COLOR":
                            themeColor = String.valueOf(value);
                            break;
                        case "RICHFLYER_TEXT":
                            if ((Boolean) value)
                                launchOptions.add("text");
                            break;
                        case "RICHFLYER_IMAGE":
                            if ((Boolean) value)
                                launchOptions.add("image");
                            break;
                        case "RICHFLYER_GIF":
                            if ((Boolean) value)
                                launchOptions.add("gif");
                            break;
                        case "RICHFLYER_MOVIE":
                            if ((Boolean) value)
                                launchOptions.add("movie");
                            break;
                        default:
                            break;
                    }
                });
            }
        }
        String[] strLaunchOptions = launchOptions.toArray(new String[0]);

        // デバイストークンを取得
        FirebaseMessaging.getInstance().getToken().addOnCompleteListener(task -> {
            String deviceToken = task.getResult();
            RichFlyer flyer = new RichFlyer(activity.getApplicationContext(), deviceToken, serviceKey,
                    themeColor, targetActivity);

            flyer.startSetting(new RichFlyerResultListener() {
                @Override
                public void onCompleted(RFResult result) {
                    String json = toJson(result);
                    channel.invokeMethod("onCallbackResult", json);
                    if (result.isResult()) {
                        // 設定された通知のみ起動時通知を行う
                        RichFlyer.setLaunchMode(activity.getApplicationContext(), strLaunchOptions);
                    }
                }
            });
        });
    }

    // セグメント登録処理
    private void registerSegments(Map<String, String> segments) {
        RichFlyer.registerSegments(segments, activity.getApplicationContext(), new RichFlyerResultListener() {
            @Override
            public void onCompleted(RFResult result) {
                String json = toJson(result);
                channel.invokeMethod("onCallbackResult", json);
            }
        });
    }

    private void postMessage(ArrayList<String> events, Map<String,String> variables, Integer standbyTime) {
        RichFlyer.postMessage(events.toArray(new String[events.size()]), variables, standbyTime, activity.getApplicationContext(), new RichFlyerPostingResultListener() {
            @Override
            public void onCompleted(RFResult result, String[] eventPostIds) {
                Map<String, Object> res = new HashMap<>();
                res.put("result", result.isResult());
                res.put("errorCode", result.getErrorCode());
                res.put("message", result.getMessage());
                res.put("eventPostIds", eventPostIds);

                String json = toJson(res);
                channel.invokeMethod("onCallbackPostMessage", json);
            }
        });
    }

    private void cancelPosting(String eventPostId) {
        RichFlyer.cancelPosting(eventPostId, activity.getApplicationContext(), new RichFlyerPostingResultListener() {
            @Override
            public void onCompleted(RFResult result, String[] eventPostIds) {
                String json = toJson(result);
                channel.invokeMethod("onCallbackResult", json);
            }
        });
    }

    // セグメントの取得
    private Map<String, String> getSegments() {
        Map<String, String> segments = RichFlyer.getSegments(activity.getApplicationContext());
        return segments;
    }

    // 通知受信履歴の取得
    private String getHistory() {
        ArrayList<RFContent> history = RichFlyer.getHistory(activity.getApplicationContext());
        return toJson(history);
    }

    // 最新のプッシュ通知の取得
    private String getLatestNotification() {
        RFContent content = RichFlyer.getLatestNotification(activity.getApplicationContext());
        return toJson(content);
    }

    // 通知履歴の表示
    private void showHistoryNotification(String notificationId) {
        ArrayList<RFContent> contents = RichFlyer.getHistory(activity.getApplicationContext());
        for (RFContent content : contents) {
            if (content.getNotificationId().equals(notificationId)) {
                RichFlyer.showHistoryNotification(activity.getApplicationContext(), content.getNotificationId());
                break;
            }
        }
    }

    // プッシュ通知受信時の処理
    private void openNotification(Intent intent) {

        if (RichFlyer.richFlyerAction(intent)) {
            RichFlyer.parseAction(intent, new RFActionListener() {
                // カスタムアクションボタンが押下された時
                @Override
                public void onRFEventOnClickButton(@NonNull RFAction action, @NonNull String notifyAction) {
                    String json = toJson(action);
                    channel.invokeMethod("openNotificationButtonAndroid", json);
                }
                // アプリを起動ボタンなどからアプリを起動した時
                @Override
                public void onRFEventOnClickStartApplication(@Nullable String notificationId, @Nullable String extendedProperty, @NonNull String notifyAction) {
                    Map<String, String> data = new HashMap<>();
                    if (notificationId != null) {
                        data.put("notificationId", notificationId);
                    } else {
                        data.put("notificationId", "");
                    }

                    if (extendedProperty != null) {
                        data.put("extendedProperty", extendedProperty);
                    } else {
                        data.put("extendedProperty", "");
                    }
                    String json = toJson(data);
                    channel.invokeMethod("openNotificationStartApp", json);
                }
            });
        }
    }

    // jsonへ変換する
    private String toJson(Object obj) {
        ObjectMapper objectMapper = new ObjectMapper();
        String json = null;
        try {
            if (obj != null) {
                json = objectMapper.writeValueAsString(obj);
            } else {
                return null;
            }
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }
        return json;
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();

        binding.addOnNewIntentListener(new PluginRegistry.NewIntentListener() {
            @Override
            public boolean onNewIntent(@NonNull Intent intent) {
                openNotification(intent);
                return false;
            }
        });

        activity.getApplication().registerActivityLifecycleCallbacks(new Application.ActivityLifecycleCallbacks() {
            @Override
            public void onActivityCreated(@NonNull Activity activity, @Nullable Bundle bundle) {
            }

            @Override
            public void onActivityStarted(@NonNull Activity activity) {
                if (activity instanceof TranslucentDialogActivity) {
                    return;
                }
                Intent intent = activity.getIntent();
                openNotification(intent);
            }

            @Override
            public void onActivityResumed(@NonNull Activity activity) {
            }

            @Override
            public void onActivityPaused(@NonNull Activity activity) {
            }

            @Override
            public void onActivityStopped(@NonNull Activity activity) {
            }

            @Override
            public void onActivitySaveInstanceState(@NonNull Activity activity, @NonNull Bundle bundle) {
            }

            @Override
            public void onActivityDestroyed(@NonNull Activity activity) {
            }
        });
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    }

    @Override
    public void onDetachedFromActivity() {
        this.activity = null;
    }
}
