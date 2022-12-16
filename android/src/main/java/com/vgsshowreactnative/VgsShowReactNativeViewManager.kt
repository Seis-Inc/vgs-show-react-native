package com.vgsshowreactnative

import android.graphics.Typeface
import android.os.Build
import android.util.TypedValue
import android.view.View
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.common.MapBuilder
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.views.text.ReactFontManager

class VgsShowReactNativeViewManager : SimpleViewManager<View>() {
  override fun getName() = "VgsShowReactNativeView"

  private lateinit var reactContext: ThemedReactContext;

  override fun createViewInstance(reactContext: ThemedReactContext): View {
    this.reactContext = reactContext;
    return VgsAttrInstance(reactContext);
  }

  override fun getExportedCustomBubblingEventTypeConstants(): MutableMap<String, Any> {
    return MapBuilder.builder<String, Any>().put(
      "onReqDone",
      MapBuilder.of(
        "phasedRegistrationNames",
        MapBuilder.of("bubbled", "onReqDone")
      )
    ).build()
  }

  override fun receiveCommand(view: View, commandId: String, args: ReadableArray?) {
    when (commandId) {
      "revealData" -> (view as VgsAttrInstance).revealData(
        args?.getInt(0) as Int,
        args.getString(1) as String,
        args.getString(2) as String,
        args.getMap(3) as ReadableMap
      )
      "copyToClipboard" -> (view as VgsAttrInstance).copyToClipboard()
    }
  }

  @ReactProp(name = "contentPath")
  fun setContentPath(view: View, contentPath: String) {
    (view as VgsAttrInstance).vgsText.setContentPath(contentPath);
  }

  @ReactProp(name = "placeholder")
  fun setPlaceholder(view: View, placeholder: String) {
    (view as VgsAttrInstance).vgsText.setHint(placeholder);
  }

  @ReactProp(name = "textColor", customType = "Color")
  fun setTextColor(view: View, value: Int) {
    (view as VgsAttrInstance).vgsText.setTextColor(value);
    view.vgsText.setHintTextColor(value);
  }

  @ReactProp(name = "placeholderColor", customType = "Color")
  fun setPlaceholderColor(view: View, value: Int) {
    (view as VgsAttrInstance).vgsText.setHintTextColor(value);
  }

  @ReactProp(name = "bgColor", customType = "Color")
  fun setBgColor(view: View, value: Int) {
    (view as VgsAttrInstance).vgsText.setBackgroundColor(value);
  }

  @ReactProp(name = "characterSpacing")
  fun setCharacterSpacing(view: View, value: Float) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      (view as VgsAttrInstance).vgsText.setLetterSpacing(value)
    };
  }

  @ReactProp(name = "fontSize")
  fun setFontSize(view: View, value: Float) {
    (view as VgsAttrInstance).vgsText.setTextSize(TypedValue.COMPLEX_UNIT_PX, value)
  }

  @ReactProp(name = "fontFamily")
  fun setFontFamily(view: View, value: String) {
    ReactFontManager.getInstance().getTypeface(value, Typeface.NORMAL, this.reactContext.assets)?.let {
      (view as VgsAttrInstance).vgsText.setTypeface(
        it
      )
    };
  }

  @ReactProp(name = "initParams")
  fun setInitParams(view: View, initParams: ReadableMap) {
    val vaultId = initParams.getString("vaultId");
    val environment = initParams.getString("environment");
    val customHeaders = initParams.getMap("customHeaders");

    vaultId?.let {
      val valId = it;
      environment?.let {
        (view as VgsAttrInstance).initWithParams(valId, it, customHeaders);
      }
    }
  }
}
