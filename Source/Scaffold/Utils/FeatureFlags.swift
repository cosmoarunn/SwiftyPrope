//
//  FeatureFlags.swift
//  Prope
//
//  Created by ARUN PANNEERSELVAM on 14/12/2024.
//

import Foundation
import UIKit

enum FeatureBuild: Int {
    case dev
    case `internal`
    case beta
    case production
}

private extension FeatureBuild {
    func includes(_ level: FeatureBuild) -> Bool {
        return self.rawValue <= level.rawValue
    }
}

extension FeatureBuild {
#if DEBUG
    static let current: FeatureBuild = .dev
#else
    static let current: FeatureBuild = .internal
#endif
}


func  LocalizationNotNeeded(_ s: String) -> String {
    return s;
}


private let build =  FeatureBuild.current // FeatureBuild.current

/// Flags that we'll leave in the code base indefinitely that are helpful for
/// development should go here, rather than cluttering up FeatureFlags.
public enum DebugFlags {
    public static let internalLogging = build.includes(.internal)

    public static let betaLogging = build.includes(.beta)

    public static let testPopulationErrorAlerts = build.includes(.beta)

    public static let audibleErrorLogging = build.includes(.internal)

    public static let internalSettings = build.includes(.internal)

    public static let internalMegaphoneEligible = build.includes(.internal)

    public static let reduceLogChatter: Bool = {
        // This is a little verbose to make it easy to change while developing.
        if CurrentAppContext().isRunningTests {
            return true
        }
        return false
    }()

    public static let aggressiveProfileFetching = TestableFlag(
        false,
        title: LocalizationNotNeeded("Aggressive profile fetching"),
        details: LocalizationNotNeeded("Client will update profiles aggressively.")
    )

    // Currently this flag is only honored by NetworkManager,
    // but we could eventually honor in other places as well:
    //
    // * The socket manager.
    // * Places we make requests using tasks.
    public static let logCurlOnSuccess = false

    public static let verboseNotificationLogging = build.includes(.internal)

    public static let deviceTransferVerboseProgressLogging = build.includes(.internal)

    public static let messageDetailsExtraInfo = build.includes(.internal)

    public static let exposeCensorshipCircumvention = build.includes(.internal)

    public static let dontSendContactOrGroupSyncMessages = TestableFlag(
        false,
        title: LocalizationNotNeeded("Don't send contact or group sync messages"),
        details: LocalizationNotNeeded("Client will not send contact or group info to linked devices.")
    )

    public static let forceAttachmentDownloadFailures = TestableFlag(
        false,
        title: LocalizationNotNeeded("Force attachment download failures."),
        details: LocalizationNotNeeded("All attachment downloads will fail.")
    )

    public static let forceAttachmentDownloadPendingMessageRequest = TestableFlag(
        false,
        title: LocalizationNotNeeded("Attachment download vs. message request."),
        details: LocalizationNotNeeded("Attachment downloads will be blocked by pending message request.")
    )

    public static let forceAttachmentDownloadPendingManualDownload = TestableFlag(
        false,
        title: LocalizationNotNeeded("Attachment download vs. manual download."),
        details: LocalizationNotNeeded("Attachment downloads will be blocked by manual download.")
    )

    public static let extraDebugLogs = build.includes(.internal)

    public static let paymentsIgnoreCurrencyConversions = TestableFlag(
        false,
        title: LocalizationNotNeeded("Payments: Ignore currency conversions"),
        details: LocalizationNotNeeded("App will behave as though currency conversions are unavailable")
    )

    public static let paymentsHaltProcessing = TestableFlag(
        false,
        title: LocalizationNotNeeded("Payments: Halt Processing"),
        details: LocalizationNotNeeded("Processing of payments will pause")
    )

    public static let paymentsIgnoreBadData = TestableFlag(
        false,
        title: LocalizationNotNeeded("Payments: Ignore bad data"),
        details: LocalizationNotNeeded("App will skip asserts for invalid data")
    )

    public static let paymentsFailOutgoingSubmission = TestableFlag(
        false,
        title: LocalizationNotNeeded("Payments: Fail outgoing submission"),
        details: LocalizationNotNeeded("Submission of outgoing transactions will always fail")
    )

    public static let paymentsFailOutgoingVerification = TestableFlag(
        false,
        title: LocalizationNotNeeded("Payments: Fail outgoing verification"),
        details: LocalizationNotNeeded("Verification of outgoing transactions will always fail")
    )

    public static let paymentsFailIncomingVerification = TestableFlag(
        false,
        title: LocalizationNotNeeded("Payments: Fail incoming verification"),
        details: LocalizationNotNeeded("Verification of incoming receipts will always fail")
    )

    public static let paymentsDoubleNotify = TestableFlag(
        false,
        title: LocalizationNotNeeded("Payments: Double notify"),
        details: LocalizationNotNeeded("App will send two payment notifications and sync messages for each outgoing payment")
    )

    public static let paymentsNoRequestsComplete = TestableFlag(
        false,
        title: LocalizationNotNeeded("Payments: No requests complete"),
        details: LocalizationNotNeeded("MC SDK network activity never completes")
    )

    public static let paymentsMalformedMessages = TestableFlag(
        false,
        title: LocalizationNotNeeded("Payments: Malformed messages"),
        details: LocalizationNotNeeded("Payment notifications and sync messages are malformed.")
    )

    public static let paymentsSkipSubmissionAndOutgoingVerification = TestableFlag(
        false,
        title: LocalizationNotNeeded("Payments: Skip Submission And Verification"),
        details: LocalizationNotNeeded("Outgoing payments won't be submitted or verified.")
    )

    public static let messageSendsFail = TestableFlag(
        false,
        title: LocalizationNotNeeded("Message Sends Fail"),
        details: LocalizationNotNeeded("All outgoing message sends will fail.")
    )

    public static let disableUD = TestableFlag(
        false,
        title: LocalizationNotNeeded("Disable sealed sender"),
        details: LocalizationNotNeeded("Sealed sender will be disabled for all messages.")
    )

    public static let callingUseTestSFU = TestableFlag(
        false,
        title: LocalizationNotNeeded("Calling: Use Test SFU"),
        details: LocalizationNotNeeded("Group calls will connect to sfu.test.voip.signal.org.")
    )

    public static let delayedMessageResend = TestableFlag(
        false,
        title: LocalizationNotNeeded("Sender Key: Delayed message resend"),
        details: LocalizationNotNeeded("Waits 10s before responding to a resend request.")
    )

    public static let fastPlaceholderExpiration = TestableFlag(
        false,
        title: LocalizationNotNeeded("Sender Key: Early placeholder expiration"),
        details: LocalizationNotNeeded("Shortens the valid window for message resend+recovery."),
        toggleHandler: { _ in
           // SSKEnvironment.shared.messageDecrypterRef.cleanUpExpiredPlaceholders()
        }
    )

    public static func allTestableFlags() -> [TestableFlag] {
        return [
            aggressiveProfileFetching,
            callingUseTestSFU,
            delayedMessageResend,
            disableUD,
            dontSendContactOrGroupSyncMessages,
            fastPlaceholderExpiration,
            forceAttachmentDownloadFailures,
            forceAttachmentDownloadPendingManualDownload,
            forceAttachmentDownloadPendingMessageRequest,
            messageSendsFail,
            paymentsDoubleNotify,
            paymentsFailIncomingVerification,
            paymentsFailOutgoingSubmission,
            paymentsFailOutgoingVerification,
            paymentsHaltProcessing,
            paymentsIgnoreBadData,
            paymentsIgnoreCurrencyConversions,
            paymentsMalformedMessages,
            paymentsNoRequestsComplete,
            paymentsSkipSubmissionAndOutgoingVerification,
        ]
    }
}

// MARK: -

public class TestableFlag {
    private let defaultValue: Bool
    private let flag: AtomicBool
    public let title: String
    public let details: String
    public let toggleHandler: ((Bool) -> Void)?

    fileprivate init(_ defaultValue: Bool,
                     title: String,
                     details: String,
                     toggleHandler: ((Bool) -> Void)? = nil) {
        self.defaultValue = defaultValue
        self.title = title
        self.details = details
        self.flag = AtomicBool(defaultValue, lock: .sharedGlobal)
        self.toggleHandler = toggleHandler

        // Normally we'd store the observer here and remove it in deinit.
        // But TestableFlags are always static; they don't *get* deinitialized except in testing.
        NotificationCenter.default.addObserver(forName: Self.ResetAllTestableFlagsNotification,
                                               object: nil, queue: nil) { [weak self] _ in
            guard let self = self else { return }
            self.set(self.defaultValue)
        }
    }

    public func get() -> Bool {
        guard build.includes(.internal) else {
            return defaultValue
        }
        return flag.get()
    }

    public func set(_ value: Bool) {
        flag.set(value)

        toggleHandler?(value)
    }

    @objc
    private func switchDidChange(_ sender: UISwitch) {
        set(sender.isOn)
    }

    public var switchSelector: Selector { #selector(switchDidChange(_:)) }

    public static let ResetAllTestableFlagsNotification = NSNotification.Name("ResetAllTestableFlags")
}