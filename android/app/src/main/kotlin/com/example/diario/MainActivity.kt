package com.carlos.diarioprivado

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.android.gms.nearby.Nearby
import com.google.android.gms.nearby.connection.*

class MainActivity : FlutterActivity() {

    private val CHANNEL = "nearby"
    private lateinit var connectionsClient: ConnectionsClient

    // Lista de dispositivos conectados
    private val connectedEndpoints = mutableSetOf<String>()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        connectionsClient = Nearby.getConnectionsClient(this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startAdvertising" -> {
                        startAdvertising()
                        result.success(null)
                    }
                    "startDiscovery" -> {
                        startDiscovery()
                        result.success(null)
                    }
                    "sendMessage" -> {
                        val msg = call.argument<String>("msg") ?: ""
                        sendMessage(msg)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    // ================= ADVERTISING =================
    private fun startAdvertising() {
        val options = AdvertisingOptions.Builder()
            .setStrategy(Strategy.P2P_POINT_TO_POINT)
            .build()

        connectionsClient.startAdvertising(
            "FlutterDevice",
            packageName,
            connectionLifecycleCallback,
            options
        ).addOnSuccessListener {
            sendStatus("📡 Conexión disponible")
        }.addOnFailureListener {
            sendStatus("❌ Error advertising: ${it.message}")
        }
    }

    // ================= DISCOVERY =================
    private fun startDiscovery() {
        val options = DiscoveryOptions.Builder()
            .setStrategy(Strategy.P2P_POINT_TO_POINT)
            .build()

        connectionsClient.startDiscovery(
            packageName,
            endpointDiscoveryCallback,
            options
        ).addOnSuccessListener {
            sendStatus("🔍 Búsqueda activa")
        }.addOnFailureListener {
            sendStatus("❌ Error discovery: ${it.message}")
        }
    }

    // ================= MENSAJES =================
    private fun sendMessage(msg: String) {
        if (connectedEndpoints.isEmpty()) {
            sendStatus("⚠️ No hay dispositivos conectados")
            return
        }

        val payload = Payload.fromBytes(msg.toByteArray())
        for (endpoint in connectedEndpoints) {
            connectionsClient.sendPayload(endpoint, payload)
        }

        sendStatus("📤 Mensaje enviado: $msg")
    }

    // ================= CALLBACKS =================
    private val connectionLifecycleCallback = object : ConnectionLifecycleCallback() {

        override fun onConnectionInitiated(
            endpointId: String,
            connectionInfo: ConnectionInfo
        ) {
            sendStatus("🤝 Conexión iniciada")
            connectionsClient.acceptConnection(endpointId, payloadCallback)
        }

        override fun onConnectionResult(
            endpointId: String,
            result: ConnectionResolution
        ) {
            if (result.status.isSuccess) {
                connectedEndpoints.add(endpointId)
                sendStatus("✅ Conectado con $endpointId")
            } else {
                sendStatus("❌ Conexión fallida")
            }
        }

        override fun onDisconnected(endpointId: String) {
            connectedEndpoints.remove(endpointId)
            sendStatus("🔌 Dispositivo desconectado")
        }
    }

    private val endpointDiscoveryCallback = object : EndpointDiscoveryCallback() {

        override fun onEndpointFound(
            endpointId: String,
            info: DiscoveredEndpointInfo
        ) {
            sendStatus("🔍 Dispositivo encontrado")

            connectionsClient.requestConnection(
                "FlutterDevice",
                endpointId,
                connectionLifecycleCallback
            )
        }

        override fun onEndpointLost(endpointId: String) {
            sendStatus("⚠️ Dispositivo perdido")
        }
    }

    private val payloadCallback = object : PayloadCallback() {

        override fun onPayloadReceived(endpointId: String, payload: Payload) {
            val msg = String(payload.asBytes() ?: return)
            sendStatus("📩 Mensaje recibido: $msg")
        }

        override fun onPayloadTransferUpdate(
            endpointId: String,
            update: PayloadTransferUpdate
        ) {}
    }

    // ================= ENVIAR A FLUTTER =================
    private fun sendStatus(msg: String) {
        MethodChannel(
            flutterEngine!!.dartExecutor.binaryMessenger,
            CHANNEL
        ).invokeMethod("onMessage", msg)
    }
}
