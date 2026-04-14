package com.studio.os

import android.app.Application
import android.content.Context

class StudioApp : Application() {
    override fun onCreate() {
        super.onCreate()
        instance = this
    }

    companion object {
        lateinit var instance: StudioApp
            private set

        val appContext: Context get() = instance.applicationContext
    }
}
