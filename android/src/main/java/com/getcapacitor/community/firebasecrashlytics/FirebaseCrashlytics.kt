package com.getcapacitor.community.firebasecrashlytics

import com.getcapacitor.JSArray
import com.getcapacitor.PluginCall
import com.google.firebase.crashlytics.FirebaseCrashlytics as GoogleFirebaseCrashlytics
import org.json.JSONException

public class FirebaseCrashlytics internal constructor() {
    private val crashlyticsInstance: GoogleFirebaseCrashlytics = GoogleFirebaseCrashlytics.getInstance()

    public fun crash(message: String?): Unit = throw RuntimeException(message)

    // A value of another type than the one named by `type` is null here. The Java code threw a
    // NullPointerException while unboxing it, which the `!!` keep.
    public fun setContext(key: String, type: String, call: PluginCall) {
        when (type) {
            "long" -> crashlyticsInstance.setCustomKey(key, call.getInt("value")!!.toLong())
            "int" -> crashlyticsInstance.setCustomKey(key, call.getInt("value")!!)
            "boolean" -> crashlyticsInstance.setCustomKey(key, call.getBoolean("value")!!)
            "float" -> crashlyticsInstance.setCustomKey(key, call.getFloat("value")!!)
            "double" -> crashlyticsInstance.setCustomKey(key, call.getDouble("value")!!)
            else -> crashlyticsInstance.setCustomKey(key, call.getString("value") ?: "")
        }
    }

    public fun setUserId(userId: String) {
        crashlyticsInstance.setUserId(userId)
    }

    public fun addLogMessage(message: String) {
        crashlyticsInstance.log(message)
    }

    public fun setEnabled(enabled: Boolean) {
        crashlyticsInstance.setCrashlyticsCollectionEnabled(enabled)
    }

    public fun didCrashDuringPreviousExecution(): Boolean = crashlyticsInstance.didCrashOnPreviousExecution()

    public fun sendUnsentReports() {
        crashlyticsInstance.sendUnsentReports()
    }

    public fun deleteUnsentReports() {
        crashlyticsInstance.deleteUnsentReports()
    }

    public fun recordException(message: String?, stacktrace: JSArray?) {
        val throwable: Throwable = getJavaScriptException(message, stacktrace)
        crashlyticsInstance.recordException(throwable)
    }

    private fun getJavaScriptException(message: String?, stacktrace: JSArray?): JavaScriptException {
        if (stacktrace == null) {
            return JavaScriptException(message)
        }

        return try {
            JavaScriptException(message, stacktrace)
        } catch (error: JSONException) {
            System.err.println("Stacktrace is not parsable! " + error.message)
            JavaScriptException(message)
        }
    }
}
