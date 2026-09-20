import XCTest
import Capacitor
@testable import FirebaseCrashlyticsPlugin

class FirebaseCrashlyticsTests: XCTestCase {
    // The implementation configures Firebase, which needs the GoogleService-Info.plist of an app,
    // so only the registration of the plugin is checked here.
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
}
