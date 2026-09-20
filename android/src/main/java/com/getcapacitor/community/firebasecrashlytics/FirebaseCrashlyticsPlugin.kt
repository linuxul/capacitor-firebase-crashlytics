package com.getcapacitor.community.firebasecrashlytics

import android.Manifest
import com.getcapacitor.JSObject
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin
import com.getcapacitor.annotation.Permission

@CapacitorPlugin(
    name = "FirebaseCrashlytics",
    permissions = [
        Permission(strings = [Manifest.permission.ACCESS_NETWORK_STATE], alias = "network"),
        Permission(strings = [Manifest.permission.INTERNET], alias = "internet"),
        Permission(strings = [Manifest.permission.WAKE_LOCK], alias = "wakelock")
    ]
)
public class FirebaseCrashlyticsPlugin : Plugin() {
    private lateinit var implementation: FirebaseCrashlytics

    override fun load() {
        implementation = FirebaseCrashlytics()
    }

    @PluginMethod
    public fun crash(call: PluginCall) {
        val message = call.getString("message")
        if (message == null) {
            call.reject(ERROR_MESSAGE_MISSING)
            return
        }
        call.resolve()
        implementation.crash(message)
    }

    @PluginMethod
    public fun setContext(call: PluginCall) {
        val key = call.getString("key")
        if (key == null) {
            call.reject(ERROR_KEY_MISSING)
            return
        }
        val hasValue = call.data.has("value")
        if (!hasValue) {
            call.reject(ERROR_VALUE_MISSING)
            return
        }
        // "string" is the default, so type is never null here
        val type = call.getString("type", "string")!!
        implementation.setContext(key, type, call)
        call.resolve()
    }

    @PluginMethod
    public fun setUserId(call: PluginCall) {
        val userId = call.getString("userId")
        if (userId == null) {
            call.reject(ERROR_USERID_MISSING)
            return
        }
        implementation.setUserId(userId)
        call.resolve()
    }

    @PluginMethod
    public fun addLogMessage(call: PluginCall) {
        val message = call.getString("message")
        if (message == null) {
            call.reject(ERROR_MESSAGE_MISSING)
            return
        }
        implementation.addLogMessage(message)
        call.resolve()
    }

    @PluginMethod
    public fun setEnabled(call: PluginCall) {
        val enabled = call.getBoolean("enabled")
        if (enabled == null) {
            call.reject(ERROR_ENABLED_MISSING)
            return
        }
        implementation.setEnabled(enabled)
        call.resolve()
    }

    @PluginMethod
    public fun isEnabled(call: PluginCall) {
        call.unimplemented("Not implemented on Android.")
    }

    @PluginMethod
    public fun didCrashDuringPreviousExecution(call: PluginCall) {
        val crashed = implementation.didCrashDuringPreviousExecution()
        val ret = JSObject()
        ret.put("crashed", crashed)
        call.resolve(ret)
    }

    @PluginMethod
    public fun sendUnsentReports(call: PluginCall) {
        implementation.sendUnsentReports()
        call.resolve()
    }

    @PluginMethod
    public fun deleteUnsentReports(call: PluginCall) {
        implementation.deleteUnsentReports()
        call.resolve()
    }

    @PluginMethod
    public fun recordException(call: PluginCall) {
        val message = call.getString("message")
        if (message == null) {
            call.reject(ERROR_MESSAGE_MISSING)
            return
        }

        val stacktrace = call.getArray("stacktrace", null)
        implementation.recordException(message, stacktrace)
        call.resolve()
    }

    public companion object {
        public const val ERROR_MESSAGE_MISSING: String = "message must be provided."
        public const val ERROR_KEY_MISSING: String = "key must be provided."
        public const val ERROR_VALUE_MISSING: String = "value must be provided."
        public const val ERROR_USERID_MISSING: String = "userId must be provided."
        public const val ERROR_ENABLED_MISSING: String = "enabled must be provided."
    }
}
