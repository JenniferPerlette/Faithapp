package com.faithfocus.faithfocus

import android.content.Context
import android.content.SharedPreferences
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey

/**
 * Stockage local de l'état de la session Focus (whitelist de packages,
 * bornes temporelles). Utilise EncryptedSharedPreferences (Jetpack
 * Security) plutôt que des SharedPreferences en clair, conformément à la
 * contrainte OWASP Mobile M9 (Insecure Data Storage) : whitelist et
 * horaires de blocage sont potentiellement révélateurs des habitudes de
 * l'utilisateur.
 */
class FocusSessionStore(context: Context) {

    private val prefs: SharedPreferences

    init {
        val masterKey = MasterKey.Builder(context)
            .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
            .build()

        prefs = EncryptedSharedPreferences.create(
            context,
            PREFS_FILE_NAME,
            masterKey,
            EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
            EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM,
        )
    }

    fun startSession(
        whitelistedPackageIds: List<String>,
        scheduledStartEpochMillis: Long?,
        scheduledEndEpochMillis: Long?,
        timerEndEpochMillis: Long?,
    ) {
        prefs.edit()
            .putStringSet(KEY_WHITELIST, whitelistedPackageIds.toSet())
            .putLong(KEY_SCHEDULED_START, scheduledStartEpochMillis ?: NO_VALUE)
            .putLong(KEY_SCHEDULED_END, scheduledEndEpochMillis ?: NO_VALUE)
            .putLong(KEY_TIMER_END, timerEndEpochMillis ?: NO_VALUE)
            .putBoolean(KEY_STARTED, true)
            .apply()
    }

    fun stopSession() {
        prefs.edit().putBoolean(KEY_STARTED, false).apply()
    }

    /**
     * Recalculée à chaque appel à partir des bornes stockées : le service
     * d'accessibilité ne dépend donc jamais d'un simple flag statique pour
     * décider de bloquer, et arrête automatiquement le blocage en fin
     * d'horaire ou de minuteur, sans attendre un appel explicite à
     * stopFocusSession() (cf. Tâche 4).
     */
    fun isSessionActive(nowEpochMillis: Long = System.currentTimeMillis()): Boolean {
        if (!prefs.getBoolean(KEY_STARTED, false)) return false

        val timerEnd = prefs.getLong(KEY_TIMER_END, NO_VALUE)
        if (timerEnd != NO_VALUE && nowEpochMillis >= timerEnd) return false

        val scheduledEnd = prefs.getLong(KEY_SCHEDULED_END, NO_VALUE)
        if (scheduledEnd != NO_VALUE && nowEpochMillis >= scheduledEnd) return false

        val scheduledStart = prefs.getLong(KEY_SCHEDULED_START, NO_VALUE)
        if (scheduledStart != NO_VALUE && nowEpochMillis < scheduledStart) return false

        return true
    }

    fun isPackageWhitelisted(packageName: String): Boolean {
        return prefs.getStringSet(KEY_WHITELIST, emptySet())?.contains(packageName) ?: false
    }

    /**
     * Temps restant avant la fin de la session active, ou `null` si aucune
     * session active ou si elle n'a ni minuteur ni plage horaire (ne
     * devrait pas arriver en pratique, les deux étant fournis à
     * [startSession]). Utilisé par l'overlay (Tâche 5) pour afficher le
     * temps restant, jamais comme source de vérité pour décider de bloquer
     * (cf. [isSessionActive]).
     */
    fun remainingMillis(nowEpochMillis: Long = System.currentTimeMillis()): Long? {
        if (!isSessionActive(nowEpochMillis)) return null

        val timerEnd = prefs.getLong(KEY_TIMER_END, NO_VALUE)
        val scheduledEnd = prefs.getLong(KEY_SCHEDULED_END, NO_VALUE)

        val ends = listOfNotNull(
            timerEnd.takeIf { it != NO_VALUE },
            scheduledEnd.takeIf { it != NO_VALUE },
        )
        val earliestEnd = ends.minOrNull() ?: return null
        return earliestEnd - nowEpochMillis
    }

    companion object {
        private const val PREFS_FILE_NAME = "faithfocus_focus_session_secure"
        private const val KEY_WHITELIST = "whitelisted_package_ids"
        private const val KEY_SCHEDULED_START = "scheduled_start_epoch_millis"
        private const val KEY_SCHEDULED_END = "scheduled_end_epoch_millis"
        private const val KEY_TIMER_END = "timer_end_epoch_millis"
        private const val KEY_STARTED = "started"
        private const val NO_VALUE = -1L
    }
}
