package com.faithfocus.faithfocus

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.colorResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/**
 * Contenu de l'overlay de verrouillage (Tâche 5). Couleurs plates
 * exclusivement issues de res/values/colors.xml, synchronisé manuellement
 * avec lib/core/theme/app_colors.dart — aucun dégradé, aucune couleur ad
 * hoc (cf. contraintes de design transverses).
 */
@Composable
fun LockScreenOverlay(
    appLabel: String,
    message: String,
    remainingTimeLabel: String,
    onStartQuiz: () -> Unit,
    onGoHome: () -> Unit,
) {
    Surface(color = colorResource(R.color.ff_background)) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(32.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
        ) {
            Text(
                text = "$appLabel est en pause",
                color = colorResource(R.color.ff_text_primary),
                fontSize = 22.sp,
                fontWeight = FontWeight.SemiBold,
                textAlign = TextAlign.Center,
            )

            Spacer(Modifier.height(16.dp))

            Text(
                text = message,
                color = colorResource(R.color.ff_text_secondary),
                fontSize = 16.sp,
                textAlign = TextAlign.Center,
            )

            Spacer(Modifier.height(24.dp))

            Text(
                text = remainingTimeLabel,
                color = colorResource(R.color.ff_text_secondary),
                fontSize = 14.sp,
            )

            Spacer(Modifier.height(32.dp))

            Button(
                onClick = onStartQuiz,
                colors = ButtonDefaults.buttonColors(
                    containerColor = colorResource(R.color.ff_primary),
                ),
            ) {
                Text(
                    text = "Faire un quiz de 3 minutes",
                    color = colorResource(R.color.ff_surface),
                )
            }

            Spacer(Modifier.height(12.dp))

            TextButton(onClick = onGoHome) {
                Text(
                    text = "Retour à l'accueil",
                    color = colorResource(R.color.ff_text_secondary),
                )
            }
        }
    }
}
