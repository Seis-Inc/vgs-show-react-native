package com.vgsshowreactnative

import android.content.Context
import android.view.View
import android.widget.LinearLayout
import android.widget.RelativeLayout
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactContext
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.uimanager.events.RCTEventEmitter
import com.verygoodsecurity.vgsshow.VGSShow
import com.verygoodsecurity.vgsshow.core.listener.VGSOnResponseListener
import com.verygoodsecurity.vgsshow.core.network.client.VGSHttpMethod
import com.verygoodsecurity.vgsshow.core.network.model.VGSRequest
import com.verygoodsecurity.vgsshow.core.network.model.VGSResponse
import com.verygoodsecurity.vgsshow.widget.VGSTextView

class VgsAttrInstance(context: ReactContext) : LinearLayout(context) {
  var vgsText: VGSTextView = VGSTextView(context);
  lateinit var vgsShow: VGSShow
  private var reactContext: ReactContext = context;

  init {
    this.layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
    vgsText.layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
    this.addView(vgsText);
  }

  fun initWithParams(vaultId: String, environment: String, customHeaders: ReadableMap?) {
    this.vgsShow = VGSShow(context, vaultId, environment);

    customHeaders?.let {
      val iterator = it.keySetIterator();

      while (iterator.hasNextKey()) {
        val key = iterator.nextKey();
        val value = it.getString(key);
        vgsShow.setCustomHeader(key, value as String);
      }
    }

    vgsShow.subscribe(this.vgsText);
  }

  fun revealData(
    reqId: Int,
    path: String,
    method: String,
    payload: ReadableMap
  ) {
    System.out.println("Called revealData");
    System.out.println("Triggered revealData for: $method $path (tagId = ${this.id}, reqId = $reqId)");

    val methodVal = if (method == "post") VGSHttpMethod.POST else VGSHttpMethod.GET;
    var request = VGSRequest.Builder(path, methodVal);

    if (payload != null && methodVal != VGSHttpMethod.GET) {
      request = request.body(payload.toHashMap())
    }

    val self = this;

      this.vgsShow.addOnResponseListener(object : VGSOnResponseListener {
        override fun onResponse(response: VGSResponse) {
          when (response) {
            is VGSResponse.Success -> {
              val code = response.code;
              System.out.println("Done revealData for: $method $path(tagId = ${self.id}, reqId = $reqId), code = $code");

              val event = Arguments.createMap()
              event.putInt("code", code)
              event.putInt("reqId", reqId)

              self.reactContext.getJSModule(RCTEventEmitter::class.java).receiveEvent(self.id, "onReqDone", event)
            }

            is VGSResponse.Error -> {
              val code = response.code;
              val error = response.message;

              System.out.println("Failed revealData for: $method $path(tagId = ${self.id}, reqId = $reqId), code = $code, error = $error");

              val event = Arguments.createMap()
              event.putInt("code", code)
              event.putString("error", error)
              event.putInt("reqId", reqId)

              self.reactContext.getJSModule(RCTEventEmitter::class.java).receiveEvent(self.id, "onReqDone", event)
            }
          }
        }
      })

    this.vgsShow.requestAsync(request.build());
  }

  fun copyToClipboard() {
    vgsText.copyToClipboard()
  }
}
