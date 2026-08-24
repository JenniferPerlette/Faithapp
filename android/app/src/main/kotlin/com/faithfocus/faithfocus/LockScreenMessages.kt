package com.faithfocus.faithfocus

enum class MessageTone {
    GENTLE_RECENTERING,
    INVITATION,
    NEUTRAL_FACTUAL,
    CURIOSITY,
}

/**
 * Banque de messages affichés sur l'overlay de verrouillage (Tâche 5).
 * Ton volontairement non culpabilisant : "reviens à l'essentiel" plutôt que
 * "tu as encore craqué", quelle que soit la catégorie.
 */
object LockScreenMessages {

    private val messagesByTone: Map<MessageTone, List<String>> = mapOf(
        MessageTone.GENTLE_RECENTERING to listOf(
            "Reviens à l'essentiel, un instant.",
            "Une respiration, puis l'essentiel.",
            "Le silence a aussi ses réponses.",
        ),
        MessageTone.INVITATION to listOf(
            "Et si tu ouvrais Sa Parole maintenant ?",
            "Trois minutes avec un verset t'attendent.",
            "Une leçon t'attend, à ton rythme.",
        ),
        MessageTone.NEUTRAL_FACTUAL to listOf(
            "Cette application est mise en pause pendant ta session Focus.",
            "Session Jeûne Digital en cours.",
            "Le blocage se lève automatiquement à la fin de la session.",
        ),
        MessageTone.CURIOSITY to listOf(
            "Sais-tu combien de fois le mot « paix » apparaît dans les Psaumes ?",
            "Une question t'attend dans le quiz du jour.",
            "Curieux de connaître ta série actuelle ?",
        ),
    )

    private val allMessages: List<String> = messagesByTone.values.flatten()

    /**
     * Tire un message au hasard parmi toutes les catégories, en excluant
     * [previous] pour ne jamais afficher deux fois le même message
     * d'affilée.
     */
    fun pickRandom(previous: String? = null): String {
        val candidates = if (allMessages.size > 1) {
            allMessages.filter { it != previous }
        } else {
            allMessages
        }
        return candidates.random()
    }
}
