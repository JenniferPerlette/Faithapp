package com.faithfocus.faithfocus

import android.app.Service
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.PixelFormat
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.view.Gravity
import android.view.WindowManager
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.platform.ComposeView
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LifecycleRegistry
import androidx.lifecycle.ViewModelStore
import androidx.lifecycle.ViewModelStoreOwner
import androidx.lifecycle.setViewTreeLifecycleOwner
import androidx.lifecycle.setViewTreeViewModelStoreOwner
import androidx.savedstate.SavedStateRegistry
import androidx.savedstate.SavedStateRegistryController
import androidx.savedstate.SavedStateRegistryOwner
import androidx.savedstate.setViewTreeSavedStateRegistryOwner

/**
 * Overlay plein écran (TYPE_APPLICATION_OVERLAY) affiché par-dessus une app
 * non whitelistée pendant une session Focus active (déclenché par
 * [BlockingAccessibilityService], cf. Tâche 4).
 *
 * Comportement volontaire : cet overlay ne se ferme JAMAIS tout seul après
 * un délai d'inactivité — seules les actions explicites "Faire un quiz" et
 * "Retour à l'accueil" le referment. Il se referme aussi si la session
 * Focus elle-même se termine pendant qu'il est affiché : ce n'est pas une
 * fermeture par inactivité, mais la conséquence normale de la fin du
 * blocage (même logique qu'en Tâche 4).
 *
 * Hébergé dans un Service (pas une Activity), le contenu Compose a besoin
 * d'un LifecycleOwner/ViewModelStoreOwner/SavedStateRegistryOwner fournis
 * manuellement — Compose ne les déduit pas automatiquement en dehors d'une
 * Activity.
 */
class OverlayLockScreenService :
    Service(),
    LifecycleOwner,
    ViewModelStoreOwner,
    SavedStateRegistryOwner {

    private val lifecycleRegistry = LifecycleRegistry(this)
    override val lifecycle: Lifecycle get() = lifecycleRegistry

    override val viewModelStore = ViewModelStore()

    private val savedStateRegistryController = SavedStateRegistryController.create(this)
    override val savedStateRegistry: SavedStateRegistry
        get() = savedStateRegistryController.savedStateRegistry

    private lateinit var sessionStore: FocusSessionStore
    private lateinit var windowManager: WindowManager
    private var overlayView: ComposeView? = null
    private var lastMessage: String? = null

    private var appLabelState by mutableStateOf("")
    private var messageState by mutableStateOf("")
    private var remainingTimeLabelState by mutableStateOf("")

    private val tickHandler = Handler(Looper.getMainLooper())
    private val tickRunnable = object : Runnable {
        override fun run() {
            updateRemainingTimeOrDismiss()
            tickHandler.postDelayed(this, TICK_INTERVAL_MILLIS)
        }
    }

    override fun onCreate() {
        super.onCreate()
        savedStateRegistryController.performRestore(null)
        lifecycleRegistry.currentState = Lifecycle.State.CREATED
        sessionStore = FocusSessionStore(applicationContext)
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        lifecycleRegistry.currentState = Lifecycle.State.STARTED
        lifecycleRegistry.currentState = Lifecycle.State.RESUMED
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val blockedPackageName = intent?.getStringExtra(EXTRA_BLOCKED_PACKAGE)
        if (blockedPackageName != null) {
            showOrUpdateOverlay(blockedPackageName)
        }
        return START_NOT_STICKY
    }

    private fun showOrUpdateOverlay(blockedPackageName: String) {
        appLabelState = resolveAppLabel(blockedPackageName)
        lastMessage = LockScreenMessages.pickRandom(previous = lastMessage)
        messageState = lastMessage.orEmpty()

        if (overlayView == null) {
            addOverlayView()
            tickHandler.post(tickRunnable)
        }
        updateRemainingTimeOrDismiss()
    }

    private fun resolveAppLabel(packageName: String): String {
        return try {
            val info = packageManager.getApplicationInfo(packageName, 0)
            packageManager.getApplicationLabel(info).toString()
        } catch (e: PackageManager.NameNotFoundException) {
            packageName
        }
    }

    private fun updateRemainingTimeOrDismiss() {
        val remainingMillis = sessionStore.remainingMillis()
        if (remainingMillis == null) {
            // Session Focus terminée : plus rien à bloquer, l'overlay n'a
            // plus lieu d'être affiché (cf. Tâche 4, arrêt automatique).
            stopSelf()
            return
        }
        remainingTimeLabelState = formatRemaining(remainingMillis)
    }

    private fun formatRemaining(millis: Long): String {
        val totalSeconds = (millis / 1000).coerceAtLeast(0)
        val hours = totalSeconds / 3600
        val minutes = (totalSeconds % 3600) / 60
        return if (hours > 0) "Encore $hours h $minutes min" else "Encore $minutes min"
    }

    private fun addOverlayView() {
        val composeView = ComposeView(this).apply {
            setViewTreeLifecycleOwner(this@OverlayLockScreenService)
            setViewTreeViewModelStoreOwner(this@OverlayLockScreenService)
            setViewTreeSavedStateRegistryOwner(this@OverlayLockScreenService)
            setContent {
                LockScreenOverlay(
                    appLabel = appLabelState,
                    message = messageState,
                    remainingTimeLabel = remainingTimeLabelState,
                    onStartQuiz = ::onStartQuizClicked,
                    onGoHome = ::onGoHomeClicked,
                )
            }
        }

        val overlayType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }

        val layoutParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            overlayType,
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT,
        ).apply {
            gravity = Gravity.TOP or Gravity.START
        }

        windowManager.addView(composeView, layoutParams)
        overlayView = composeView
    }

    /**
     * Le moteur de quiz et la navigation Flutter vers un quiz aléatoire non
     * complété n'existent pas encore (Tâche 8). En attendant, on relance
     * FaithFocus au premier plan avec un extra signalant l'intention ; le
     * routage effectif sera câblé une fois l'UI de quiz disponible.
     */
    private fun onStartQuizClicked() {
        removeOverlay()
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        launchIntent?.apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            putExtra(EXTRA_REQUESTED_ROUTE, ROUTE_RANDOM_QUIZ)
        }
        launchIntent?.let { startActivity(it) }
        stopSelf()
    }

    private fun onGoHomeClicked() {
        removeOverlay()
        val homeIntent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        startActivity(homeIntent)
        stopSelf()
    }

    private fun removeOverlay() {
        overlayView?.let { view -> windowManager.removeView(view) }
        overlayView = null
        tickHandler.removeCallbacks(tickRunnable)
    }

    override fun onDestroy() {
        removeOverlay()
        lifecycleRegistry.currentState = Lifecycle.State.DESTROYED
        viewModelStore.clear()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    companion object {
        const val EXTRA_BLOCKED_PACKAGE = "blocked_package_name"
        const val EXTRA_REQUESTED_ROUTE = "requested_route"
        const val ROUTE_RANDOM_QUIZ = "quiz/random"
        private const val TICK_INTERVAL_MILLIS = 60_000L
    }
}
