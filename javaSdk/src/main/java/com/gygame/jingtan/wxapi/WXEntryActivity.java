package  com.gygame.jingtan.wxapi;



import com.tencent.mm.sdk.modelmsg.SendAuth;
import com.tencent.mm.sdk.modelmsg.SendMessageToWX;
import com.tencent.mm.sdk.modelmsg.WXImageObject;
import com.tencent.mm.sdk.modelmsg.WXMediaMessage;
import com.tencent.mm.sdk.modelmsg.WXWebpageObject;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.IWXAPIEventHandler;
import com.tencent.mm.sdk.openapi.WXAPIFactory;

import com.gygame.jingtan.Constants;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;



import com.tencent.mm.sdk.modelbase.BaseReq;
import com.tencent.mm.sdk.modelbase.BaseResp;

import android.app.AlertDialog;

import com.gygame.jingtan.R;
import com.unity3d.player.*;

import java.io.ByteArrayOutputStream;

public class WXEntryActivity extends Activity implements IWXAPIEventHandler{

	private static final int THUMB_SIZE = 150;

    private IWXAPI api;

	static Activity firstAcivity;

	static boolean neet_ret;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);



		if ( this.getIntent().hasExtra("Unity3d_WX") ) {
			neet_ret = true;

			api = WXAPIFactory.createWXAPI(this, Constants.APP_ID, false);

			firstAcivity = this;

			SendAuth.Req req = new SendAuth.Req();
			req.scope = "snsapi_userinfo";
			req.state = "none";
			api.sendReq(req);

			//finish();
		}
		else if ( this.getIntent().hasExtra("Unity3d_Share") )
		{
			neet_ret = false;

			firstAcivity = this;

			api = WXAPIFactory.createWXAPI(this, Constants.APP_ID, false);

			String url = 	this.getIntent().getStringExtra("Unity3d_Share");

			String tile = 	this.getIntent().getStringExtra("tile");
			String des = 	this.getIntent().getStringExtra("des");

			WXWebpageObject webpage = new WXWebpageObject();
			webpage.webpageUrl = url;

			WXMediaMessage msg = new WXMediaMessage(webpage);

			msg.title = tile;
			msg.description =  des;

			Bitmap thumb = BitmapFactory.decodeResource(getResources(),R.drawable.app_icon);
			msg.thumbData = bmpToByteArray(thumb,true);

			SendMessageToWX.Req req = new SendMessageToWX.Req();
			req.transaction = buildTransaction("webpage");

			req.message = msg;
			if ( this.getIntent().hasExtra("time") ){

				req.scene = SendMessageToWX.Req.WXSceneTimeline;
			}
			else{
				req.scene = SendMessageToWX.Req.WXSceneSession;
			}

			api.sendReq(req);

			finish();
		}
		else if ( this.getIntent().hasExtra("Unity3d_SharePic") )
		{
			neet_ret = false;

			firstAcivity = this;

			api = WXAPIFactory.createWXAPI(this, Constants.APP_ID, false);

			String url = 	this.getIntent().getStringExtra("Unity3d_SharePic");

			WXImageObject imgObj = new WXImageObject();
			imgObj.setImagePath(url);

			WXMediaMessage msg = new WXMediaMessage();
			msg.mediaObject = imgObj;

			Bitmap bitmap = BitmapFactory.decodeFile(url);
			Bitmap thumbBmp = Bitmap.createScaledBitmap(bitmap, THUMB_SIZE, THUMB_SIZE, true);
			msg.thumbData = bmpToByteArray(thumbBmp, true); // 设置缩略图


			SendMessageToWX.Req req = new SendMessageToWX.Req();
			req.transaction = buildTransaction("img");

			req.message = msg;
			req.scene = SendMessageToWX.Req.WXSceneSession;

			api.sendReq(req);

			finish();
		}
		else {

			api = WXAPIFactory.createWXAPI(this, Constants.APP_ID, false);
			api.handleIntent(getIntent(), this);
		}
	}

	public static byte[] bmpToByteArray(final Bitmap bmp, final boolean needRecycle) {
		ByteArrayOutputStream output = new ByteArrayOutputStream();
		bmp.compress(Bitmap.CompressFormat.JPEG, 70, output);
		if (needRecycle) {
			bmp.recycle();
		}

		byte[] result = output.toByteArray();
		try {
			output.close();
		} catch (Exception e) {
			e.printStackTrace();
		}

		return result;
	}

	private String buildTransaction(final String type) {
		return (type == null) ? String.valueOf(System.currentTimeMillis()) : type + System.currentTimeMillis();
	}

	@Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);

		setIntent(intent);
        api.handleIntent(intent, this);
	}


	@Override
	public void onReq(BaseReq req) {

	}

	@Override
	public void onResp(BaseResp resp) {

		if ( neet_ret ) {
			switch (resp.errCode) {
				case BaseResp.ErrCode.ERR_OK:
					String code = ((SendAuth.Resp) resp).code;
					UnityPlayer.UnitySendMessage("main", "OnWXLoginRet", code);
					break;

				default:
					UnityPlayer.UnitySendMessage("main", "OnWXLoginRet", "WXLogin_error");
					break;
			}
		}
        finish();

		if ( firstAcivity != null) {
			firstAcivity.finish();
			firstAcivity = null;
		}
	}

	public void showDialog(String str) {


		AlertDialog.Builder builder = new AlertDialog.Builder(this);
		builder.setTitle("test");
		builder.setMessage(str);

		builder.show();
	}


}