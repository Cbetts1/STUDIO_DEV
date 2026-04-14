package com.studio.os

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.BackHandler
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel

class StudioActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            StudioTheme {
                StudioUI()
            }
        }
    }
}

// ─── Colours ────────────────────────────────────────────────────────────────
object StudioColors {
    val Background   = Color(0xFF0D0D0D)
    val Surface      = Color(0xFF1A1A1A)
    val Border       = Color(0xFF2E2E2E)
    val Accent       = Color(0xFF00E5FF)
    val AccentDim    = Color(0xFF007A8A)
    val TextPrimary  = Color(0xFFE0E0E0)
    val TextSecondary= Color(0xFF888888)
    val Success      = Color(0xFF4CAF50)
    val Warning      = Color(0xFFFF9800)
    val Error        = Color(0xFFF44336)
    val Prompt       = Color(0xFF00E5FF)
}

@Composable
fun StudioTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = darkColorScheme(
            background = StudioColors.Background,
            surface    = StudioColors.Surface,
            primary    = StudioColors.Accent,
            onPrimary  = Color.Black,
            onSurface  = StudioColors.TextPrimary,
            onBackground = StudioColors.TextPrimary
        ),
        content = content
    )
}

// ─── Main UI ─────────────────────────────────────────────────────────────────
@Composable
fun StudioUI(vm: EngineBridgeViewModel = viewModel()) {
    val context   = LocalContext.current
    val output    by vm.output.collectAsState()
    val isRunning by vm.isRunning.collectAsState()
    val listState = rememberLazyListState()
    var input     by remember { mutableStateOf("") }
    val focusReq  = remember { FocusRequester() }

    // Auto-scroll to bottom when new output arrives
    LaunchedEffect(output.size) {
        if (output.isNotEmpty()) listState.animateScrollToItem(output.size - 1)
    }

    // Start engine when UI is first composed
    LaunchedEffect(Unit) {
        vm.start(context)
        focusReq.requestFocus()
    }

    BackHandler(enabled = true) {
        vm.sendInput("0")   // "0" or "back" is always the go-back command
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(StudioColors.Background)
            .systemBarsPadding()
    ) {
        // ── Title bar ──────────────────────────────────────────────────────
        TitleBar(isRunning = isRunning, onRestart = { vm.restart(context) })

        // ── Output panel ──────────────────────────────────────────────────
        LazyColumn(
            state  = listState,
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth()
                .padding(horizontal = 12.dp, vertical = 4.dp)
        ) {
            items(output) { line ->
                OutputLine(line)
            }
        }

        // ── Divider ───────────────────────────────────────────────────────
        Divider(color = StudioColors.Border, thickness = 1.dp)

        // ── Quick-action row ──────────────────────────────────────────────
        QuickActions(
            onHelp  = { vm.sendInput("?") },
            onBack  = { vm.sendInput("0") },
            onClear = { vm.clearOutput() }
        )

        // ── Input row ────────────────────────────────────────────────────
        InputRow(
            value       = input,
            onValueChange = { input = it },
            focusRequester = focusReq,
            onSend = {
                val text = input.trim()
                if (text.isNotEmpty()) {
                    vm.sendInput(text)
                    input = ""
                }
            }
        )
    }
}

// ─── Components ───────────────────────────────────────────────────────────────

@Composable
fun TitleBar(isRunning: Boolean, onRestart: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(StudioColors.Surface)
            .padding(horizontal = 16.dp, vertical = 10.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = "◈ STUDIO OS",
            style = TextStyle(
                color      = StudioColors.Accent,
                fontSize   = 18.sp,
                fontFamily = FontFamily.Monospace,
                fontWeight = FontWeight.Bold
            ),
            modifier = Modifier.weight(1f)
        )
        // Status dot
        val dotColor = if (isRunning) StudioColors.Success else StudioColors.Error
        Box(
            modifier = Modifier
                .size(10.dp)
                .clip(RoundedCornerShape(50))
                .background(dotColor)
        )
        Spacer(modifier = Modifier.width(12.dp))
        IconButton(onClick = onRestart, modifier = Modifier.size(32.dp)) {
            Icon(
                imageVector        = Icons.Default.Refresh,
                contentDescription = "Restart engine",
                tint               = StudioColors.TextSecondary,
                modifier           = Modifier.size(20.dp)
            )
        }
    }
}

@Composable
fun OutputLine(line: OutputEntry) {
    val (text, kind) = line
    val color = when (kind) {
        LineKind.PROMPT  -> StudioColors.Prompt
        LineKind.SUCCESS -> StudioColors.Success
        LineKind.WARNING -> StudioColors.Warning
        LineKind.ERROR   -> StudioColors.Error
        LineKind.HEADER  -> StudioColors.Accent
        LineKind.INPUT   -> StudioColors.AccentDim
        else             -> StudioColors.TextPrimary
    }
    Text(
        text  = text,
        style = TextStyle(
            color      = color,
            fontSize   = 13.sp,
            fontFamily = FontFamily.Monospace,
            lineHeight = 18.sp
        ),
        modifier = Modifier.padding(vertical = 1.dp)
    )
}

@Composable
fun QuickActions(onHelp: () -> Unit, onBack: () -> Unit, onClear: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(StudioColors.Surface)
            .padding(horizontal = 8.dp, vertical = 4.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        QuickBtn("? Help",  StudioColors.AccentDim, onHelp)
        QuickBtn("← Back",  StudioColors.AccentDim, onBack)
        QuickBtn("✕ Clear", StudioColors.AccentDim, onClear)
    }
}

@Composable
fun QuickBtn(label: String, color: Color, onClick: () -> Unit) {
    OutlinedButton(
        onClick  = onClick,
        border   = ButtonDefaults.outlinedButtonBorder.copy(
            brush = androidx.compose.ui.graphics.SolidColor(color)
        ),
        contentPadding = PaddingValues(horizontal = 12.dp, vertical = 4.dp),
        modifier = Modifier.height(32.dp)
    ) {
        Text(
            text  = label,
            style = TextStyle(
                color      = color,
                fontSize   = 11.sp,
                fontFamily = FontFamily.Monospace
            )
        )
    }
}

@Composable
fun InputRow(
    value: String,
    onValueChange: (String) -> Unit,
    focusRequester: FocusRequester,
    onSend: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(StudioColors.Surface)
            .padding(horizontal = 12.dp, vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text  = "▶",
            color = StudioColors.Accent,
            style = TextStyle(fontFamily = FontFamily.Monospace, fontSize = 14.sp),
            modifier = Modifier.padding(end = 8.dp)
        )
        OutlinedTextField(
            value         = value,
            onValueChange = onValueChange,
            modifier      = Modifier
                .weight(1f)
                .focusRequester(focusRequester),
            textStyle = TextStyle(
                color      = StudioColors.TextPrimary,
                fontFamily = FontFamily.Monospace,
                fontSize   = 14.sp
            ),
            placeholder = {
                Text(
                    "type a number or command…",
                    color  = StudioColors.TextSecondary,
                    style  = TextStyle(fontFamily = FontFamily.Monospace, fontSize = 13.sp)
                )
            },
            singleLine    = true,
            keyboardOptions = KeyboardOptions(imeAction = ImeAction.Send),
            keyboardActions = KeyboardActions(onSend = { onSend() }),
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor   = StudioColors.Accent,
                unfocusedBorderColor = StudioColors.Border,
                cursorColor          = StudioColors.Accent
            )
        )
        Spacer(modifier = Modifier.width(8.dp))
        IconButton(
            onClick  = onSend,
            modifier = Modifier
                .size(44.dp)
                .clip(RoundedCornerShape(8.dp))
                .background(StudioColors.Accent)
        ) {
            Icon(
                imageVector        = Icons.Default.Send,
                contentDescription = "Send",
                tint               = Color.Black
            )
        }
    }
}
