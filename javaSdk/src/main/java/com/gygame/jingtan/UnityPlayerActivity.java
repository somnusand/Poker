package com.gygame.jingtan;

/*import com.fanwei.jubaosdk.common.core.OnPayResultListener;
import com.fanwei.jubaosdk.common.util.CommonUtils;
import com.fanwei.jubaosdk.shell.FWPay;
import com.fanwei.jubaosdk.shell.PayOrder;*/
import com.unity3d.player.*;
import android.app.Activity;
import android.content.res.Configuration;
import android.graphics.PixelFormat;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.Window;


import android.content.Context;
import android.content.Intent;

import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.WXAPIFactory;

import com.gygame.jingtan.wxapi.WXEntryActivity;


import android.net.Uri;
import android.widget.Toast;

public class UnityPlayerActivity extends Activity //implements //OnPayResultListener
{
	protected UnityPlayer mUnityPlayer; // don't change the name of this variable; referenced from native code


	Context mContext = null;

	IWXAPI api;

	// Setup activity layout
	@Override protected void onCreate (Bundle savedInstanceState)
	{
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		super.onCreate(savedInstanceState);

		//FWPay.init(this,"84464624", false);
//		FWPay.getChannelType(PayOrder payOrder)
//		FWPay.pay(this,Payorder,0,OnPayResultListener);

		mContext = this;

		api = WXAPIFactory.createWXAPI(this, Constants.APP_ID, true);
		api.registerApp(Constants.APP_ID);

		getWindow().setFormat(PixelFormat.RGBX_8888); // <--- This makes xperia play happy

		mUnityPlayer = new UnityPlayer(this);
		setContentView(mUnityPlayer);
		mUnityPlayer.requestFocus();

	}

	public void JubaoPay(String name, String pay)
	{
/*		final PayOrder order = new PayOrder()
				//金额(必需)
				.setAmount(pay)
				//商品名称(必需)
				.setGoodsName("钻石")
				//商户订单号(必需)
				.setPayId(CommonUtils.setRand())
				//玩家Id(必需)
				.setPlayerId(String.valueOf(name.toCharArray(),0,5))
				.setRemark(name);
		// 主线程中调用 FWPay.pay 方法
		FWPay.pay(UnityPlayerActivity.this, order, 0, UnityPlayerActivity.this);*/

	}
/*	@Override
	public void onSuccess(Integer code, String message, String payId) {
		Toast.makeText(this, "[code=" + code + "] [message=" + message + "]" + "[payId=" + payId + "]", Toast.LENGTH_SHORT).show();
	}

	@Override
	public void onFailed(Integer code, String message, String payId) {
		Toast.makeText(this, "[code=" + code + "] [message=" + message + "]" + "[payId=" + payId + "]", Toast.LENGTH_SHORT).show();
	}*/



	public void WXLogin(String name)
	{

		//UnityPlayer.UnitySendMessage("main","OnWXLoginRet","WXLogin_error");
		Intent intent = new Intent(mContext,WXEntryActivity.class);
		intent.putExtra("Unity3d_WX", "Unity3d_WX");
		this.startActivity(intent);
	}

	public void OnCallFun(String value)
	{
		System.out.print("testtt.....1\n");
		System.out.print(value);

		String[] keys = value.split(",");

		System.out.print("testtt.....2\n");

		System.out.print(value);

		switch (keys[0]) {
			case "down":
				Download(keys[1]);
				break;
			case "share":
				if (keys.length > 3) {
					WXShare(keys[1], keys[2], keys[3]);
				}
				else if (keys.length > 2) {
					WXShare(keys[1], keys[2], "http://fir.im/ssmj");
				}
				break;
			case "share_time":
				if (keys.length > 3) {
					WXShareTime(keys[1], keys[2], keys[3]);
				}
				else if (keys.length > 2) {
					WXShareTime(keys[1], keys[2], "http://fir.im/ssmj");
				}
				break;
			case "share_shot":
				if (keys.length > 1) {
					WXSharePic(keys[1]);
				}

				break;
		}
	}


	void WXShare(String tile,String des,String url)
	{
		Intent intent = new Intent(mContext,WXEntryActivity.class);
		intent.putExtra("Unity3d_Share", url);
		intent.putExtra("tile", tile);
		intent.putExtra("des", des);
		this.startActivity(intent);
	}
	void WXShareTime(String tile,String des,String url)
	{
		Intent intent = new Intent(mContext,WXEntryActivity.class);
		intent.putExtra("Unity3d_Share", url);
		intent.putExtra("tile", tile);
		intent.putExtra("des", des);
		intent.putExtra("time", true);
		this.startActivity(intent);
	}

	void WXSharePic(String file)
	{
		Intent intent = new Intent(mContext,WXEntryActivity.class);
		intent.putExtra("Unity3d_SharePic", file);
		this.startActivity(intent);
	}


	void Download(String url)
	{
		Intent intent = new Intent();
		intent.setAction("android.intent.action.VIEW");
		Uri content_url = Uri.parse(url);
		intent.setData(content_url);
		startActivity(intent);

		this.finish();
	}

	// Quit Unity
	@Override protected void onDestroy ()
	{
		mUnityPlayer.quit();
		super.onDestroy();
	}

	// Pause Unity
	@Override protected void onPause()
	{
		super.onPause();
		mUnityPlayer.pause();
	}

	// Resume Unity
	@Override protected void onResume()
	{
		super.onResume();
		mUnityPlayer.resume();
	}

	// This ensures the layout will be correct.
	@Override public void onConfigurationChanged(Configuration newConfig)
	{
		super.onConfigurationChanged(newConfig);
		mUnityPlayer.configurationChanged(newConfig);
	}

	// Notify Unity of the focus change.
	@Override public void onWindowFocusChanged(boolean hasFocus)
	{
		super.onWindowFocusChanged(hasFocus);
		mUnityPlayer.windowFocusChanged(hasFocus);
	}

	// For some reason the multiple keyevent type is not supported by the ndk.
	// Force event injection by overriding dispatchKeyEvent().
	@Override public boolean dispatchKeyEvent(KeyEvent event)
	{
		if (event.getAction() == KeyEvent.ACTION_MULTIPLE)
			return mUnityPlayer.injectEvent(event);
		return super.dispatchKeyEvent(event);
	}

	// Pass any events not handled by (unfocused) views straight to UnityPlayer
	@Override public boolean onKeyUp(int keyCode, KeyEvent event)     { return mUnityPlayer.injectEvent(event); }
	@Override public boolean onKeyDown(int keyCode, KeyEvent event)   { return mUnityPlayer.injectEvent(event); }
	@Override public boolean onTouchEvent(MotionEvent event)          { return mUnityPlayer.injectEvent(event); }
	/*API12*/ public boolean onGenericMotionEvent(MotionEvent event)  { return mUnityPlayer.injectEvent(event); }
}
