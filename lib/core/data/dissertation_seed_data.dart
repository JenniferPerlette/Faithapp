import '../models/dissertation.dart';

/// Les 6 dissertations de démonstration visibles dans le design ("Mes
/// dissertations" du Profil et de l'écran dédié), utilisées pour seeder le
/// dépôt local au premier lancement. Les dates sont calculées par décalage
/// depuis "aujourd'hui" (plutôt que codées en dur) pour reproduire l'écart
/// relatif du mock (3 août / 29 juillet / 21 juillet / 14 juillet / 7
/// juillet / 30 juin, par rapport à un "aujourd'hui" du 6 août) quelle que
/// soit la date réelle d'exécution de l'app.
List<Dissertation> seedDissertations() {
  final now = DateTime.now();
  DateTime daysAgo(int days) => now.subtract(Duration(days: days));

  return [
    Dissertation(
      id: 'seed-patience',
      themeId: 'patience',
      themeTitle: 'La patience',
      content:
          "La patience n'est pas l'absence d'action, mais la capacité à "
          "attendre sans perdre l'espérance. Jacques 1:4 rappelle qu'elle "
          "mène l'épreuve à son plein effet, afin que nous soyons parfaits "
          "et accomplis, sans rien qui manque. Ce que j'ai retenu de cette "
          "étude, c'est que la patience n'est pas une vertu passive : elle "
          "se construit, jour après jour, dans les petites attentes du "
          "quotidien avant de tenir dans les grandes épreuves.",
      submittedAt: daysAgo(3),
      updatedAt: daysAgo(3),
    ),
    Dissertation(
      id: 'seed-pardon',
      themeId: 'pardon',
      themeTitle: 'Le pardon',
      content:
          "Pardonner soixante-dix fois sept fois (Matthieu 18:21-22), ce "
          "n'est pas tenir un compte, mais renoncer à compter. Colossiens "
          "3:13 nous invite à nous supporter les uns les autres et à nous "
          "pardonner réciproquement, comme le Seigneur nous a pardonné. "
          "J'ai compris que le pardon ne dépend pas de ce que l'autre "
          "mérite, mais de ce que j'ai moi-même déjà reçu. Il ne guérit "
          "pas l'autre en premier : il me libère, moi.",
      submittedAt: daysAgo(8),
      updatedAt: daysAgo(8),
    ),
    Dissertation(
      id: 'seed-esperance',
      themeId: 'esperance',
      themeTitle: "L'espérance",
      content:
          "Romains 15:13 parle d'un Dieu d'espérance qui nous remplit de "
          "toute joie et de toute paix dans la foi. Hébreux 11:1 définit "
          "la foi comme une ferme assurance des choses qu'on espère. "
          "L'espérance chrétienne n'est pas de l'optimisme : elle "
          "s'appuie sur une promesse, pas sur les circonstances. C'est "
          "cette différence qui m'a marquée dans cette recherche.",
      submittedAt: daysAgo(16),
      updatedAt: daysAgo(16),
    ),
    Dissertation(
      id: 'seed-amour',
      themeId: 'amour',
      themeTitle: "L'amour du prochain",
      content:
          "1 Corinthiens 13 décrit un amour qui prend patience, qui rend "
          "service, qui ne s'irrite pas. Marc 12:31 le résume en une "
          "phrase : aimer son prochain comme soi-même. Ce que je retiens, "
          "c'est que cet amour n'est pas un sentiment qu'on attend de "
          "ressentir, mais une décision qu'on prend, envers des personnes "
          "qu'on n'a pas choisies.",
      submittedAt: daysAgo(23),
      updatedAt: daysAgo(23),
    ),
    Dissertation(
      id: 'seed-justice',
      themeId: 'justice',
      themeTitle: 'La justice',
      content:
          "Michée 6:8 résume ce que Dieu demande : pratiquer la justice, "
          "aimer la miséricorde et marcher humblement. Ésaïe 1:17 ajoute "
          "un appel concret : défendre l'opprimé, faire droit à "
          "l'orphelin. La justice biblique n'est pas seulement une idée : "
          "elle se traduit par des actes envers les plus vulnérables.",
      submittedAt: daysAgo(30),
      updatedAt: daysAgo(30),
    ),
    Dissertation(
      id: 'seed-foi',
      themeId: 'foi',
      themeTitle: 'La foi',
      content:
          "Hébreux 11:1 et Romains 10:17 se répondent : la foi vient de "
          "ce qu'on entend, et cette écoute produit une assurance des "
          "choses qu'on ne voit pas encore. Cette étude m'a rappelé que "
          "la foi se nourrit, elle ne se décrète pas : elle grandit dans "
          "l'écoute régulière, pas seulement dans les moments de doute.",
      submittedAt: daysAgo(37),
      updatedAt: daysAgo(37),
    ),
  ];
}
