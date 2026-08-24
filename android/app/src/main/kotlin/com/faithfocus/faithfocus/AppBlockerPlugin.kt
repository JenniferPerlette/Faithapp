package com.faithfocus.faithfocus

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.Settings
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.text.ParseException
import java.text.SimpleDateFormat
import java.util.Locale
import java.util.TimeZone

private const val METHOD_CHANNEL_NAME = "com.faithfocus/blocker"
private const val EVENT_CHANNEL_NAME = "com.faithfocus/blocker_events"

// Défense en profondeur (OWASP Mobile M4) : la validation côté Dart
// (Tâche 3) ne doit pas être la seule barrière, un appel MethodChannel
// pouvant en théorie être émis par un autre composant du même process.
private const val MAX_WHITELIST_SIZE = 50
private const val MAX_TIMER_SECONDS = 24 * 60 * 60

/**
 * Reçoit les appels du MethodChannel "com.faithfocus/blocker" et relaie les
 * événements de blocage de [BlockingAccessibilityService] via l'EventChannel
 * "com.faithfocus/blocker_events".
 */
class AppBlockerPlugin :
    FlutterPlugin,
    MethodChannel.MethodCallHandler,
    ActivityAware,
    EventChannel.StreamHandler {

    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var appContext: Context
    private lateinit var sessionStore: FocusSessionStore
    private var activity: Activity? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        appContext = binding.applicationContext
        sessionStore = FocusSessionStore(appContext)

        methodChannel = MethodChannel(binding.binaryMessenger, METHOD_CHANNEL_NAME)
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(binding.binaryMessenger, EVENT_CHANNEL_NAME)
        eventChannel.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        BlockerEventBus.attach(events)
    }

    override fun onCancel(arguments: Any?) {
        BlockerEventBus.detach()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "requestPermissions" -> result.success(requestPermissions())
            "startFocusSession" -> handleStartFocusSession(call, result)
            "stopFocusSession" -> {
                sessionStore.stopSession()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    /**
     * L'accessibilité et le dessin par-dessus les autres apps sont des
     * "permissions spéciales" Android : leur octroi passe obligatoirement
     * par un écran système dédié, pas par un dialogue runtime classique, et
     * l'utilisateur y répond de façon asynchrone. Si l'une des deux manque,
     * on ouvre l'écran de paramètres correspondant et on retourne false ;
     * côté Dart, il faut rappeler requestPermissions() (typiquement au
     * retour au premier plan de l'app) pour connaître l'état à jour.
     */
    private fun requestPermissions(): Boolean {
        val accessibilityGranted = isAccessibilityServiceEnabled()
        val overlayGranted = Settings.canDrawOverlays(appContext)

        if (accessibilityGranted && overlayGranted) return true

        if (!overlayGranted) {
            startSettingsIntent(
                Intent(
                    Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                    Uri.parse("package:${appContext.packageName}"),
                ),
            )
        } else {
            startSettingsIntent(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
        }
        return false
    }

    private fun startSettingsIntent(intent: Intent) {
        val currentActivity = activity
        if (currentActivity != null) {
            currentActivity.startActivity(intent)
        } else {
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            appContext.startActivity(intent)
        }
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        val expectedComponent =
            "${appContext.packageName}/${BlockingAccessibilityService::class.java.name}"
        val enabledServices = Settings.Secure.getString(
            appContext.contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES,
        ) ?: return false
        return enabledServices.split(':').any { it.equals(expectedComponent, ignoreCase = true) }
    }

    private fun handleStartFocusSession(call: MethodCall, result: MethodChannel.Result) {
        val whitelistedPackageIds = call.argument<List<String>>("whitelistedPackageIds")
        if (whitelistedPackageIds == null ||
            whitelistedPackageIds.size > MAX_WHITELIST_SIZE ||
            whitelistedPackageIds.any { it.isBlank() }
        ) {
            result.error("invalid_arguments", "whitelistedPackageIds invalide", null)
            return
        }

        val timerDurationSeconds = call.argument<Int>("timerDurationSeconds")
        if (timerDurationSeconds != null &&
            (timerDurationSeconds <= 0 || timerDurationSeconds > MAX_TIMER_SECONDS)
        ) {
            result.error("invalid_arguments", "timerDurationSeconds invalide", null)
            return
        }

        val scheduledStartEpochMillis = call.argument<String>("scheduledStart")?.let {
            parseIsoToEpochMillis(it) ?: run {
                result.error("invalid_arguments", "scheduledStart invalide", null)
                return
            }
        }
        val scheduledEndEpochMillis = call.argument<String>("scheduledEnd")?.let {
            parseIsoToEpochMillis(it) ?: run {
                result.error("invalid_arguments", "scheduledEnd invalide", null)
                return
            }
        }

        val timerEndEpochMillis = timerDurationSeconds?.let {
            System.currentTimeMillis() + it * 1000L
        }

        sessionStore.startSession(
            whitelistedPackageIds = whitelistedPackageIds,
            scheduledStartEpochMillis = scheduledStartEpochMillis,
            scheduledEndEpochMillis = scheduledEndEpochMillis,
            timerEndEpochMillis = timerEndEpochMillis,
        )
        result.success(null)
    }

    /**
     * Parse le format produit par `DateTime.toIso8601String()` côté Dart :
     * suffixe 'Z' + micro/millisecondes pour un DateTime UTC, sans suffixe
     * (interprété dans le fuseau horaire par défaut de l'appareil) sinon.
     * Les fractions de seconde sont tronquées aux millisecondes.
     */
    private fun parseIsoToEpochMillis(iso8601: String): Long? {
        return try {
            val isUtc = iso8601.endsWith("Z")
            val body = if (isUtc) iso8601.dropLast(1) else iso8601
            val truncated = Regex("""(\.\d{3})\d*$""").replace(body) { it.groupValues[1] }
            val pattern = if (truncated.contains('.')) {
                "yyyy-MM-dd'T'HH:mm:ss.SSS"
            } else {
                "yyyy-MM-dd'T'HH:mm:ss"
            }
            val format = SimpleDateFormat(pattern, Locale.US)
            format.timeZone = if (isUtc) TimeZone.getTimeZone("UTC") else TimeZone.getDefault()
            format.isLenient = false
            format.parse(truncated)?.time
        } catch (e: ParseException) {
            null
        }
    }
}
