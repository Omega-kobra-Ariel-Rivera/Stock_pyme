package cl.riverasystems.stock_pyme

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

/**
 * StockPyme — Rivera Systems.
 * FLAG_SECURE bloquea capturas de pantalla, grabación de pantalla,
 * transmisión a otras pantallas y oculta la app en "apps recientes".
 */
class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )
        super.onCreate(savedInstanceState)
    }
}
