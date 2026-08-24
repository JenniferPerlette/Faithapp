package com.faithfocus.faithfocus

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.view.accessibility.AccessibilityEvent

/**
 * Détecte le premier plan de l'appareil (TYPE_WINDOW_STATE_CHANGED) et
 * bloque l'ouverture de toute app non whitelistée pendant une session Focus
 * active. La whitelist et les bornes de session sont lues depuis
 * [FocusSessionStore], stockées chiffrées (OWASP Mobile M9).
 */
class BlockingAccessibilityService : AccessibilityService() {

    private lateinit var sessionStore: FocusSessionStore

    /**
     * Évite de relancer l'overlay à chaque micro-événement d'accessibilité
     * tant que l'app bloquée reste au premier plan.
     */
    private var lastBlockedPackageName: String? = null

    override fun onServiceConnected() {
        super.onServiceConnected()
        sessionStore = FocusSessionStore(applicationContext)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event?.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return
        val packageName = event.packageName?.toString() ?: return

        // Réévalué à chaque événement plutôt que mis en cache : la session
        // s'arrête donc automatiquement en fin d'horaire/minuteur, sans
        // attendre un appel explicite à stopFocusSession() (cf. Tâche 4).
        if (!sessionStore.isSessionActive()) {
            lastBlockedPackageName = null
            return
        }

        if (packageName == applicationContext.packageName || isSystemUiPackage(packageName)) {
            return
        }

        if (sessionStore.isPackageWhitelisted(packageName)) {
            lastBlockedPackageName = null
            return
        }

        if (packageName == lastBlockedPackageName) return
        lastBlockedPackageName = packageName

        BlockerEventBus.emitBlockedAppAttempt(packageName)
        startOverlay(packageName)
    }

    private fun startOverlay(blockedPackageName: String) {
        val intent = Intent(this, OverlayLockScreenService::class.java)
            .putExtra(OverlayLockScreenService.EXTRA_BLOCKED_PACKAGE, blockedPackageName)
        startService(intent)
    }

    private fun isSystemUiPackage(packageName: String): Boolean {
        return packageName == "com.android.systemui" || packageName == "android"
    }

    override fun onInterrupt() {
        // Requis par AccessibilityService ; rien à nettoyer ici.
    }
}
