package `in`.bugle.deshgujarat

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import androidx.annotation.NonNull;


class MainActivity: FlutterActivity() {
    private val CHANNEL = "in.bugle.deshgujarat/VuforiaChannel"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        MethodChannel(flutterEngine.getDartExecutor(),CHANNEL).setMethodCallHandler{ call,result ->
      if(call.method.equals("StartVuforiaActivity")){
        val intent=Intent(this,VuforiaActivity::class.java)
        startActivity(intent)
//          startActivity(intent.putExtra("Target", VuforiaActivity.getImageTargetId()))
        result.success("VuforiaActivityStarted")
      }
      else{
        result.notImplemented()
      }
    }
    }

    
}
