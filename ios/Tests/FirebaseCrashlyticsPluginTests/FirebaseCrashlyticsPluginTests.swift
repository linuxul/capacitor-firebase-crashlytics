import XCTest
import Capacitor
@testable import FirebaseCrashlyticsPlugin

class FirebaseCrashlyticsTests: XCTestCase {
    // The implementation configures Firebase, which needs the GoogleService-Info.plist of an app,
    // so only the registration of the plugin and the argument checks, which come first, are tested here.
    func testBridgedPlugin() {
        let plugin = FirebaseCrashlyticsPlugin()

        XCTAssertEqual("FirebaseCrashlyticsPlugin", plugin.identifier)
        XCTAssertEqual("FirebaseCrashlytics", plugin.jsName)
        XCTAssertEqual(
            [
                "crash", "setContext", "addLogMessage", "setUserId", "setEnabled", "isEnabled",
                "didCrashDuringPreviousExecution", "sendUnsentReports", "deleteUnsentReports", "recordException"
            ],
            plugin.pluginMethods.map { $0.name })
    }

    func testMissingArgumentsAreRejected() {
        let plugin = FirebaseCrashlyticsPlugin()

        XCTAssertEqual(thrownError(plugin.setContext, "setContext")?.message, "key must be provided.")
        XCTAssertEqual(thrownError(plugin.setContext, "setContext", ["key": "screen"])?.message, "value must be provided.")
        XCTAssertEqual(thrownError(plugin.addLogMessage, "addLogMessage")?.message, "message must be provided.")
        XCTAssertEqual(thrownError(plugin.setUserId, "setUserId")?.message, "userId must be provided.")
        XCTAssertEqual(thrownError(plugin.setEnabled, "setEnabled")?.message, "enabled must be provided.")
        let error = thrownError(plugin.recordException, "recordException")
        XCTAssertEqual(error?.message, "message must be provided.")
        XCTAssertNil(error?.code)
    }

    /// The error `method` throws, which the bridge rejects the call with; nil when it does not throw.
    private func thrownError(_ method: (CAPPluginCall) throws -> Void, _ name: String, _ options: JSObject = [:]) -> CAPPluginError? {
        let call = CAPPluginCall(callbackId: "test", methodName: name, options: options, success: { _, _ in
            XCTFail("\(name) answers by throwing")
        }, error: { _ in
            XCTFail("\(name) answers by throwing")
        })
        do {
            try method(call)
            XCTFail("\(name) must throw")
            return nil
        } catch let error as CAPPluginError {
            return error
        } catch {
            XCTFail("unexpected error \(error)")
            return nil
        }
    }
}
