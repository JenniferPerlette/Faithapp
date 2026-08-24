/**
 * Calcul du streak, exclusivement à partir d'horodatages serveur (jamais
 * d'une date envoyée par le client), pour neutraliser la manipulation de
 * l'horloge locale du téléphone.
 */

function daysBetweenUtc(a: Date, b: Date): number {
  const utcA = Date.UTC(a.getUTCFullYear(), a.getUTCMonth(), a.getUTCDate());
  const utcB = Date.UTC(b.getUTCFullYear(), b.getUTCMonth(), b.getUTCDate());
  return Math.round((utcB - utcA) / (24 * 60 * 60 * 1000));
}

export interface StreakUpdate {
  currentStreakDays: number;
  longestStreakDays: number;
}

export function computeStreakUpdate(params: {
  now: Date;
  lastActivityDate: Date | null;
  currentStreakDays: number;
  longestStreakDays: number;
}): StreakUpdate {
  const { now, lastActivityDate, currentStreakDays, longestStreakDays } =
    params;

  let newCurrentStreak: number;
  if (lastActivityDate === null) {
    newCurrentStreak = 1;
  } else {
    const gapDays = daysBetweenUtc(lastActivityDate, now);
    if (gapDays <= 0) {
      // Activité déjà comptabilisée aujourd'hui : le streak ne bouge pas.
      newCurrentStreak = currentStreakDays;
    } else if (gapDays === 1) {
      newCurrentStreak = currentStreakDays + 1;
    } else {
      // Plus d'un jour d'écart : la série est rompue.
      newCurrentStreak = 1;
    }
  }

  return {
    currentStreakDays: newCurrentStreak,
    longestStreakDays: Math.max(longestStreakDays, newCurrentStreak),
  };
}
