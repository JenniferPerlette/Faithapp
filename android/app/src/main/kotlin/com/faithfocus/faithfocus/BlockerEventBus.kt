package com.faithfocus.faithfocus

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel

/**
 * Relais en mémoire entre [BlockingAccessibilityService] (qui détecte les
 * tentatives d'ouverture d'apps non whitelistées) et [AppBlockerPlugin]
 * (qui expose ces événements à Flutter via EventChannel). Les deux
 * composants s'exécutent dans le même process Android ; un singleton
 * suffit donc, pas besoin d'IPC.
 */
object BlockerEventBus {

    @Volatile
    private var eventSink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    fun attach(sink: EventChannel.EventSink) {
        eventSink = sink
    }

    fun detach() {
        eventSink = null
    }

    /** EventSink.success doit être appelé sur le thread principal. */
    fun emitBlockedAppAttempt(packageName: String) {
        mainHandler.post {
            eventSink?.success(packageName)
        }
    }
}
