package com.studio.os

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.IBinder
import androidx.core.app.NotificationCompat

class EngineService : Service() {

    private val CHANNEL_ID = "studio_engine"
    private val NOTIF_ID   = 1

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        createNotificationChannel()
        val notif = buildNotification()
        startForeground(NOTIF_ID, notif)
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Studio OS Engine",
            NotificationManager.IMPORTANCE_LOW
        ).apply {
            description = "Studio OS backend engine"
        }
        val nm = getSystemService(NotificationManager::class.java)
        nm.createNotificationChannel(channel)
    }

    private fun buildNotification(): Notification {
        val intent = Intent(this, StudioActivity::class.java)
        val pending = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Studio OS")
            .setContentText("Engine running")
            .setSmallIcon(android.R.drawable.ic_menu_manage)
            .setContentIntent(pending)
            .setOngoing(true)
            .build()
    }
}
