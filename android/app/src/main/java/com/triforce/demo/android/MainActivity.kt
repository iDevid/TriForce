package com.triforce.demo.android

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Card
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.produceState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.triforce.demo.android.ui.theme.TriForceAndroidTheme
import com.triforce.sharedmodels.PlayerCharacter
import com.triforce.sharednetworklayer.PlayerNetworkService
import com.triforce.sharednetworklayer.SharedNetworkEnvironment
import kotlinx.coroutines.future.await
import org.swift.swiftkit.core.SwiftArena

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            TriForceAndroidTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    CharacterScreen()
                }
            }
        }
    }
}

private data class CharacterListUiState(
    val isLoading: Boolean = true,
    val characters: List<PlayerCharacter> = emptyList(),
    val errorMessage: String? = null
)

@Composable
private fun CharacterScreen() {
    val state by produceState(initialValue = CharacterListUiState()) {
        value = try {
            val arena = SwiftArena.ofConfined()
            val service = PlayerNetworkService.init(SharedNetworkEnvironment.development(arena), arena)
            val characters = service.fetchCharacters(arena).await().toList()
            CharacterListUiState(
                isLoading = false,
                characters = characters
            )
        } catch (_: Exception) {
            CharacterListUiState(
                isLoading = false,
                errorMessage = "Couldn't load characters through the shared Swift network layer."
            )
        }
    }

    when {
        state.isLoading -> LoadingState()
        state.errorMessage != null -> ErrorState(message = state.errorMessage ?: "")
        else -> CharacterList(characters = state.characters)
    }
}

@Composable
private fun LoadingState() {
    Column(
        modifier = Modifier.fillMaxSize(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        CircularProgressIndicator()
        Text(
            text = "Loading Zelda characters...",
            modifier = Modifier.padding(top = 16.dp),
            style = MaterialTheme.typography.bodyLarge
        )
    }
}

@Composable
private fun ErrorState(message: String) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text(text = "Backend Unavailable", style = MaterialTheme.typography.headlineSmall)
        Text(
            text = message,
            modifier = Modifier.padding(top = 8.dp),
            style = MaterialTheme.typography.bodyMedium
        )
        Text(
            text = "Run the Vapor server locally, then relaunch the app.",
            modifier = Modifier.padding(top = 8.dp),
            style = MaterialTheme.typography.bodySmall
        )
    }
}

@Composable
private fun CharacterList(characters: List<PlayerCharacter>) {
    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        item {
            Text(text = "Zelda Characters", style = MaterialTheme.typography.headlineMedium)
            Text(
                text = "Fetched by the Swift 6.3 bridge and rendered in Android.",
                modifier = Modifier.padding(top = 4.dp),
                style = MaterialTheme.typography.bodyMedium
            )
        }

        items(characters, key = { it.id }) { character ->
            Card(modifier = Modifier.fillMaxWidth()) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp)
                ) {
                    Text(text = character.name, style = MaterialTheme.typography.titleLarge)
                    Text(
                        text = "${character.hearts} hearts • ${character.rupees} rupees",
                        modifier = Modifier.padding(top = 6.dp),
                        style = MaterialTheme.typography.bodyMedium
                    )
                }
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun CharacterScreenPreview() {
    TriForceAndroidTheme {
        Surface(
            modifier = Modifier.fillMaxSize(),
            color = MaterialTheme.colorScheme.background
        ) {
            LoadingState()
        }
    }
}
