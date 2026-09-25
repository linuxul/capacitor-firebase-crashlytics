import Foundation
import Capacitor

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(FirebaseCrashlyticsPlugin)
public class FirebaseCrashlyticsPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "FirebaseCrashlyticsPlugin"
    public let jsName = "FirebaseCrashlytics"
    public let pluginMethods: [CAPPluginMethod] = [
        .promise("crash", FirebaseCrashlyticsPlugin.crash),
        .promise("setContext", FirebaseCrashlyticsPlugin.setContext),
        .promise("addLogMessage", FirebaseCrashlyticsPlugin.addLogMessage),
        .promise("setUserId", FirebaseCrashlyticsPlugin.setUserId),
        .promise("setEnabled", FirebaseCrashlyticsPlugin.setEnabled),
        .promise("isEnabled", FirebaseCrashlyticsPlugin.isEnabled),
        .promise("didCrashDuringPreviousExecution", FirebaseCrashlyticsPlugin.didCrashDuringPreviousExecution),
        .promise("sendUnsentReports", FirebaseCrashlyticsPlugin.sendUnsentReports),
        .promise("deleteUnsentReports", FirebaseCrashlyticsPlugin.deleteUnsentReports),
        .promise("recordException", FirebaseCrashlyticsPlugin.recordException)
    ]

    // Every method stays synchronous: the Crashlytics calls are quick, and the bridge queue keeps the keys, logs,
    // settings and recorded exceptions in the order of the calls.

    public let errorMessageMissing = "message must be provided."
    public let errorKeyMissing = "key must be provided."
    public let errorValueMissing = "value must be provided."
    public let errorUserIdMissing = "userId must be provided."
    public let errorEnabledMissing = "enabled must be provided."
    private var implementation: FirebaseCrashlytics?

    override public func load() {
        implementation = FirebaseCrashlytics()
    }

    func crash(_ call: CAPPluginCall) {
        call.resolve()
        implementation?.crash()
    }

    func setContext(_ call: CAPPluginCall) throws {
        guard let key = call.getString("key") else {
            throw CAPPluginError(errorKeyMissing)
        }
        let hasValue = call.options["value"] != nil
        if hasValue == false {
            throw CAPPluginError(errorValueMissing)
        }
        let type = call.getString("type") ?? "string"
        implementation?.setContext(key, type, call)
        call.resolve()
    }

    func addLogMessage(_ call: CAPPluginCall) throws {
        guard let message = call.getString("message") else {
            throw CAPPluginError(errorMessageMissing)
        }
        implementation?.addLogMessage(message)
        call.resolve()
    }

    func setUserId(_ call: CAPPluginCall) throws {
        guard let userId = call.getString("userId") else {
            throw CAPPluginError(errorUserIdMissing)
        }
        implementation?.setUserID(userId)
        call.resolve()
    }

    func setEnabled(_ call: CAPPluginCall) throws {
        guard let enabled = call.getBool("enabled") else {
            throw CAPPluginError(errorEnabledMissing)
        }
        implementation?.setEnabled(enabled)
        call.resolve()
    }

    func isEnabled(_ call: CAPPluginCall) {
        let enabled = implementation?.isEnabled()
        call.resolve([
            "enabled": enabled!
        ])
    }

    func didCrashDuringPreviousExecution(_ call: CAPPluginCall) {
        let crashed = implementation?.didCrashDuringPreviousExecution()
        call.resolve([
            "crashed": crashed!
        ])
    }

    func sendUnsentReports(_ call: CAPPluginCall) {
        implementation?.sendUnsentReports()
        call.resolve()
    }

    func deleteUnsentReports(_ call: CAPPluginCall) {
        implementation?.deleteUnsentReports()
        call.resolve()
    }

    func recordException(_ call: CAPPluginCall) throws {
        guard let message = call.getString("message") else {
            throw CAPPluginError(errorMessageMissing)
        }

        let stacktrace = call.getArray("stacktrace", JSObject.self)
        if stacktrace == nil || stacktrace!.isEmpty {
            let domain = call.getString("domain") ?? ""
            let code = call.getInt("code") ?? -1001

            implementation?.recordException(message, domain, code)
        } else {
            implementation?.recordExceptionWithStacktrace(message, stacktrace!)
        }
        call.resolve()
    }
}
