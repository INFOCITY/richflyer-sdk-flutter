//
//  NotificationService.swift
//  NotificationService
//
//

import UserNotifications
import RichFlyer

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            if (RFApp.isRichFlyerNotification(userInfo: bestAttemptContent.userInfo)) {
                // RichFlyerで配信したプッシュ通知
                RFNotificationService.configureRFNotification(content: bestAttemptContent,
                                                              appGroupId: "group.net.richflyer.app",
                                                              displayNavigate: true,
                                                              completeHandler: { (content) in
                                                                contentHandler(content)
                })
            } else {
                // RichFlyer以外で配信したプッシュ通知
                contentHandler(bestAttemptContent)
            }
        }
    }
    
    override func serviceExtensionTimeWillExpire() {        
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
