using UnityEngine;
using System.Collections;
using System;
using YunvaIM;

public class Demo : MonoBehaviour
{
    private string sUserId="123";
    private string labelText = "ssss";
    string filePath = "";
	private string recordPath=string.Empty;//返回录音地址
	private string recordUrlPath=string.Empty;//返回录音url地址
	public GUISkin guiSkin;

	void Start ()
    {
        EventListenerManager.AddListener(ProtocolEnum.IM_RECORD_VOLUME_NOTIFY, ImRecordVolume);//录音音量大小回调监听
        int init = YunVaImSDK.instance.YunVa_Init(0, 300000, Application.persistentDataPath, true);
		if (init == 0) 
		{
			Debug.Log("初始化成功...");
			labelText="初始化成功...";
		} 
		else 
		{
			Debug.Log("初始化失败...");
			labelText="初始化失败...";
		}
	}

    void OnGUI()
    {
		if (guiSkin != null) 
		{
			GUI.skin=guiSkin;
		}
        GUI.Box(new Rect(10f, 10f, 340, 900f), "菜单");
        sUserId = GUI.TextField(new Rect(20f, 50f, 150f, 100f), sUserId);
        if(GUI.Button(new Rect(20f,150f,150f,100f),"登录"))
        {
			string ttFormat = "{{\"nickname\":\"{0}\",\"uid\":\"{1}\"}}";
            string tt = string.Format(ttFormat, sUserId, sUserId);
			string[] wildcard = new string[2];
			wildcard[0] = "0x001";
			wildcard[1] = "0x002";
			YunVaImSDK.instance.YunVaOnLogin(tt, "1111", wildcard, 0, (data) => 
            {
                if (data.result == 0)
                {
                    labelText = string.Format("登录成功，昵称:{0},用户ID:{1}", data.nickName, data.userId);
                    YunVaImSDK.instance.RecordSetInfoReq(true);//开启录音的音量大小回调
                }
                else
                {
                    labelText = string.Format("登录失败，错误消息：{0}", data.msg);
                }
            });
        }
		if (GUI.Button(new Rect(20f, 250f, 150f, 100f), "开始录音"))
        {
            labelText = "正在录音中。。。。。。";
            filePath = string.Format("{0}/{1}.amr", Application.persistentDataPath, DateTime.Now.ToFileTime());
            Debug.Log("FilePath:" + filePath);
            YunVaImSDK.instance.RecordStartRequest(filePath);
        }
		if(GUI.Button(new Rect(20f,350f, 150f, 100f),"停止录音"))
        {
            labelText = "停止录音.........";
            YunVaImSDK.instance.RecordStopRequest(StopRecordResponse);
        }
		if(GUI.Button(new Rect(20f,450f, 150f, 100f),"播放语音"))
		{
			labelText = "播放语音.........";
			string ext = DateTime.Now.ToFileTime().ToString();
			YunVaImSDK.instance.RecordStartPlayRequest(recordPath,"",ext,(data2) =>
			                                            {
				if (data2.result == 0)
				{
					Debug.Log("播放成功");	
					labelText = "播放成功";
				}
				else
				{
					Debug.Log("播放失败");
				    labelText = "播放失败";
				}
			});
		}
		if(GUI.Button(new Rect(190f,50f, 150f, 100f),"停止播放"))
		{
			labelText = "停止播放.........";
			Debug.Log("停止播放");
			YunVaImSDK.instance.RecordStopPlayRequest();
		}
		if(GUI.Button(new Rect(190f,150f, 150f, 100f),"语音识别"))
		{
			labelText = "语音识别.........";
			Debug.Log("语音识别");
            string ext = DateTime.Now.ToFileTime().ToString();
            YunVaImSDK.instance.SpeechStartRequest(recordPath, ext, (data3) =>
			                                        { 
				if(data3.result==0)
				{
                    labelText = "识别成功，识别内容:" + data3.text;
				}
				else
				{
					labelText = "识别失败，原因:" + data3.msg;
				}
			});
		}
		if(GUI.Button(new Rect(190f,250f, 150f, 100f),"上传语音"))
		{
			Debug.Log("准备上传：" + recordPath);
			labelText = "准备上传:"+ recordPath;
              string fileId = DateTime.Now.ToFileTime().ToString();
              YunVaImSDK.instance.UploadFileRequest(recordPath, fileId, (data1) =>
			  {
				if(data1.result==0)
				{
					recordUrlPath=data1.fileurl;
					Debug.Log("上传成功:"+recordUrlPath);
					labelText = "上传成功:"+recordUrlPath;
				}
				else
				{
					labelText ="上传失败:"+data1.msg;
					Debug.Log("上传失败:"+data1.msg);
				}
			});
		}
		if(GUI.Button(new Rect(190f,350f, 150f, 100f),"下载语音"))
		{
			labelText = "下载语音......";
			string DownLoadfilePath = string.Format("{0}/{1}.amr", Application.persistentDataPath, DateTime.Now.ToFileTime());
			Debug.Log("下载语音:"+DownLoadfilePath);
            string fileid = DateTime.Now.ToFileTime().ToString();
            YunVaImSDK.instance.DownLoadFileRequest(recordUrlPath, DownLoadfilePath, fileid, (data4) =>
			                                       {
				if(data4.result==0)
				{
					Debug.Log("下载成功:"+data4.filename);
					labelText = "下载成功:"+data4.filename;
				}
				else
				{
					Debug.Log("下载失败:"+data4.msg);
					labelText = "下载失败:"+data4.msg;
				}
			});
		}
        if (GUI.Button(new Rect(190f, 450f, 150f, 100f), "登出"))
        {
            YunVaImSDK.instance.YunVaLogOut();
        }
        GUI.Label(new Rect(400f, 10f, 500f, 30f), "返回提示");
        GUI.Label(new Rect(400f, 30f, 500f, 50f), labelText); 
    }

	private void  StopRecordResponse(ImRecordStopResp  data)
    {
        if(!string.IsNullOrEmpty(data.strfilepath))
        {
			recordPath=data.strfilepath;
			labelText = "停止录音返回:"+recordPath;
			Debug.Log("停止录音返回:"+recordPath);
        }
    }
    public void ImRecordVolume(object data)
    {
        ImRecordVolumeNotify RecordVolumeNotify = data as ImRecordVolumeNotify;
        Debug.Log("ImRecordVolumeNotify:v_volume=" + RecordVolumeNotify.v_volume);
    }
   
}
