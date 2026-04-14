package com.studio.os

import android.content.Context
import android.content.res.AssetManager
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import java.io.*

// ─── Data types ──────────────────────────────────────────────────────────────

enum class LineKind { NORMAL, HEADER, PROMPT, SUCCESS, WARNING, ERROR, INPUT }

data class OutputEntry(val text: String, val kind: LineKind = LineKind.NORMAL)

// ─── ViewModel ───────────────────────────────────────────────────────────────

class EngineBridgeViewModel : ViewModel() {
    private val _output    = MutableStateFlow<List<OutputEntry>>(emptyList())
    private val _isRunning = MutableStateFlow(false)

    val output:    StateFlow<List<OutputEntry>> = _output.asStateFlow()
    val isRunning: StateFlow<Boolean>           = _isRunning.asStateFlow()

    private var bridge: EngineBridge? = null

    fun start(context: Context) {
        if (bridge != null) return
        bridge = EngineBridge(context) { entry ->
            viewModelScope.launch(Dispatchers.Main) {
                _output.value = _output.value + entry
            }
        }
        viewModelScope.launch(Dispatchers.IO) {
            _isRunning.value = true
            bridge!!.start()
            _isRunning.value = false
        }
    }

    fun restart(context: Context) {
        viewModelScope.launch(Dispatchers.IO) {
            bridge?.stop()
            bridge = null
            _output.value = emptyList()
            delay(300)
            start(context)
        }
    }

    fun sendInput(text: String) {
        _output.value = _output.value + OutputEntry("▶ $text", LineKind.INPUT)
        viewModelScope.launch(Dispatchers.IO) { bridge?.send(text) }
    }

    fun clearOutput() { _output.value = emptyList() }

    override fun onCleared() {
        super.onCleared()
        bridge?.stop()
    }
}

// ─── Engine Bridge ────────────────────────────────────────────────────────────

class EngineBridge(
    private val context: Context,
    private val onLine: (OutputEntry) -> Unit
) {
    private var process: Process? = null
    private var writer: PrintWriter? = null
    private val rootDir get() = File(context.filesDir, "system")
    private val stateDir get() = File(rootDir, "state")

    companion object {
        init {
            try { System.loadLibrary("bootstrap") } catch (_: UnsatisfiedLinkError) {}
        }
    }

    // Called from native bootstrap to set up environment
    external fun nativeInit(appFilesDir: String): Boolean

    // ─── Bootstrap ───────────────────────────────────────────────────────────

    private fun bootstrap() {
        val prefs = context.getSharedPreferences("studio_prefs", Context.MODE_PRIVATE)
        val firstRun = !prefs.getBoolean("bootstrapped", false)

        if (firstRun || !rootDir.exists()) {
            emit("Bootstrapping Studio OS…", LineKind.WARNING)
            copyAssets(context.assets, "system-base", rootDir)
            makeScriptsExecutable(rootDir)
            prefs.edit().putBoolean("bootstrapped", true).apply()
            emit("Bootstrap complete.", LineKind.SUCCESS)
        }
        stateDir.mkdirs()
    }

    private fun copyAssets(assets: AssetManager, src: String, dest: File) {
        val list = assets.list(src) ?: return
        if (list.isEmpty()) {
            // It's a file
            dest.parentFile?.mkdirs()
            assets.open(src).use { input ->
                dest.outputStream().use { output -> input.copyTo(output) }
            }
        } else {
            // It's a directory
            dest.mkdirs()
            list.forEach { child ->
                copyAssets(assets, "$src/$child", File(dest, child))
            }
        }
    }

    private fun makeScriptsExecutable(dir: File) {
        dir.walkTopDown().forEach { file ->
            if (file.isFile && (file.extension.isEmpty() || file.extension == "sh")) {
                file.setExecutable(true)
            }
        }
    }

    // ─── Process lifecycle ────────────────────────────────────────────────────

    fun start() {
        bootstrap()

        val bootScript = File(rootDir, "core/boot")
        if (!bootScript.exists()) {
            emit("ERROR: boot script not found at ${bootScript.absolutePath}", LineKind.ERROR)
            return
        }

        val env = buildEnvironment()
        val pb  = ProcessBuilder("/system/bin/sh", bootScript.absolutePath)
        pb.environment().putAll(env)
        pb.redirectErrorStream(true)
        pb.directory(rootDir)

        process = pb.start()
        writer  = PrintWriter(BufferedWriter(OutputStreamWriter(process!!.outputStream)))

        // Read output in this coroutine
        BufferedReader(InputStreamReader(process!!.inputStream)).use { reader ->
            var line: String?
            while (reader.readLine().also { line = it } != null) {
                val text = line!!
                emit(text, classifyLine(text))
            }
        }

        val exit = process!!.waitFor()
        emit("── Engine stopped (exit $exit) ──", LineKind.WARNING)
    }

    fun send(text: String) {
        writer?.println(text)
        writer?.flush()
    }

    fun stop() {
        writer?.close()
        process?.destroy()
        process = null
        writer  = null
    }

    // ─── Helpers ─────────────────────────────────────────────────────────────

    private fun emit(text: String, kind: LineKind = LineKind.NORMAL) = onLine(OutputEntry(text, kind))

    private fun buildEnvironment(): Map<String, String> {
        val root = rootDir.absolutePath
        return mapOf(
            "SYSTEM_ROOT"   to root,
            "PATH"          to "$root/bin:$root/usr/bin:/system/bin:/system/xbin",
            "HOME"          to "$root/home",
            "STATE_DIR"     to stateDir.absolutePath,
            "PROJECTS_DIR"  to File(context.filesDir, "projects").absolutePath,
            "APP_FILES_DIR" to context.filesDir.absolutePath,
            "TERM"          to "xterm-256color",
            "LANG"          to "en_US.UTF-8",
            "SH"            to "/system/bin/sh"
        )
    }

    private fun classifyLine(line: String): LineKind = when {
        line.startsWith("═") || line.startsWith("─") || line.startsWith("╔") -> LineKind.HEADER
        line.startsWith("[✓]") || line.startsWith("[OK]")                     -> LineKind.SUCCESS
        line.startsWith("[!]") || line.startsWith("[WARN]")                   -> LineKind.WARNING
        line.startsWith("[✗]") || line.startsWith("[ERR]") || line.startsWith("ERROR:") -> LineKind.ERROR
        line.endsWith(":") && line.length < 60                                 -> LineKind.PROMPT
        else                                                                    -> LineKind.NORMAL
    }
}
