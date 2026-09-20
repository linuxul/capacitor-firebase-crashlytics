package com.getcapacitor.community.firebasecrashlytics

import com.getcapacitor.JSArray
import org.json.JSONException

public class JavaScriptException(message: String?) : Exception(message) {
    @Throws(JSONException::class)
    public constructor(message: String?, stackTrace: JSArray?) : this(message) {
        handleStacktrace(stackTrace)
    }

    @Throws(JSONException::class)
    private fun handleStacktrace(stackTrace: JSArray?) {
        if (stackTrace == null) {
            return
        }

        val trace =
            Array(stackTrace.length()) { i ->
                val elem = stackTrace.getJSONObject(i)

                StackTraceElement(
                    "",
                    elem.optString("functionName", "(anonymous function)"),
                    elem.optString("fileName", "(unknown file)"),
                    elem.optInt("lineNumber", -1)
                )
            }

        setStackTrace(trace)
    }
}
