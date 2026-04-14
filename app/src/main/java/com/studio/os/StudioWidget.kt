package com.studio.os

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

class StudioWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        appWidgetIds.forEach { id ->
            updateWidget(context, appWidgetManager, id)
        }
    }

    companion object {
        fun updateWidget(context: Context, mgr: AppWidgetManager, id: Int) {
            val views = RemoteViews(context.packageName, R.layout.widget_studio)

            // Read last status line from prefs
            val prefs  = context.getSharedPreferences("studio_prefs", Context.MODE_PRIVATE)
            val status = prefs.getString("widget_status", "Tap to open Studio OS") ?: "Tap to open Studio OS"
            val state  = prefs.getString("widget_state", "idle") ?: "idle"

            views.setTextViewText(R.id.widget_title,  "◈ STUDIO OS")
            views.setTextViewText(R.id.widget_status, status)
            views.setTextViewText(R.id.widget_state,  state.uppercase())

            // Launch app on tap
            val intent = Intent(context, StudioActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
            }
            val pending = PendingIntent.getActivity(
                context, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_root, pending)

            mgr.updateAppWidget(id, views)
        }
    }
}
