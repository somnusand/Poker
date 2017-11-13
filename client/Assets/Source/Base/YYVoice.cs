using UnityEngine;
using System.Collections;
using YunvaIM;
using System;
using System.Collections.Generic;
using LuaInterface;

public class YYVoice : MonoBehaviour {





	// Use this for initialization
	void Start () {




	}


	bool mLogin;
	bool mRecording;

	void OnDestroy()
	{
		if ( mLogin )
		{
			YunVaImSDK.instance.YunVaLogOut();
		}
	}

	bool mInit;

	public void Login(int appid, string sUserId,string name)
	{

		#if UNITY_EDITOR
       	if ( true ) return;
        #endif

		if (mInit == false)
        {
           EventListenerManager.AddListener(ProtocolEnum.IM_RECORD_VOLUME_NOTIFY, ImRecordVolume);//录音音量大小回调监听
           int init = YunVaImSDK.instance.YunVa_Init(0, (uint)appid, Application.persistentDataPath, false);
           if (init == 0)
           {
               UIAPI.DebugLog("初始化成功...");
           }
           else
           {
               UIAPI.DebugLog("初始化失败...");
           }

           mLogin = false;
           mRecording = false;

           mInit = true;
        }

        if (mLogin)
        {
           return;
        }

        string ttFormat = "{{\"nickname\":\"{0}\",\"uid\":\"{1}\"}}";
        string tt = string.Format(ttFormat, sUserId, sUserId);
        string[] wildcard = new string[2];
        wildcard[0] = "0x001";
        wildcard[1] = "0x002";
        YunVaImSDK.instance.YunVaOnLogin(tt, "1", wildcard, 0, (data) =>
        {
           if (data.result == 0)
           {
               mLogin = true;
               YunVaImSDK.instance.RecordSetInfoReq(true);//开启录音的音量大小回调

               UIAPI.DebugLog("登录成功");
           }
           else
           {
               UIAPI.DebugLog("登录失败");
           }
        });
    }


	LuaFunction endFun;
	Coroutine clipCor;

	void DoStopFun(string url)
	{
		endFun.BeginPCall ();
		endFun.Push (url);
		endFun.PCall ();
		endFun.EndPCall ();
	}


	public void StartRecord(LuaFunction fun,float maxTime)
	{
		if (mRecording) {
			return;
		}

		if (mLogin == false) {
			return;
		}

		YunVaImSDK.instance.RecordStopPlayRequest();
		GameAPI.PauseAllSound (true);

		UIAPI.DebugLog("开始录音");

		#if UNITY_EDITOR
		if ( true ) return;
		#endif

		endFun = fun;
		clipCor = StartCoroutine (OnTimeOut (maxTime));

		mRecording = true;
		string filePath = string.Format("{0}/{1}.amr", Application.persistentDataPath, DateTime.Now.ToFileTime());
		YunVaImSDK.instance.RecordStartRequest(filePath);
	}

	IEnumerator OnTimeOut(float maxTime)
	{
		yield return new WaitForSeconds(maxTime);

		clipCor = null;
		StopRecord ();
	}

	public  void StopRecord()
	{
		#if UNITY_EDITOR
		if ( true ) return;
		#endif

		if (mLogin == false) {
			return;
		}

		GameAPI.PauseAllSound (false);

		UIAPI.DebugLog("结束录音");

		if (clipCor != null) {
			StopCoroutine (clipCor);
			clipCor = null;
		}

		YunVaImSDK.instance.RecordStopRequest(StopRecordResponse);
	}

	public void Play(string recordUrlPath)
	{
		#if UNITY_EDITOR
		if ( true ) return;
		#endif

		if (mLogin == false) {
			return;
		}

		if (recordUrlPath == null)
			return;

		if (recordUrlPath == "")
			return;

		string ext = DateTime.Now.ToFileTime().ToString();
		YunVaImSDK.instance.RecordStartPlayRequest("",recordUrlPath,ext,(data2) =>
		{
			if (data2.result == 0)
			{
				UIAPI.DebugLog("播放成功");
			}
			else
			{
				UIAPI.DebugLog("播放失败");

			}
		});
	}

	public void StopPlay()
	{
		#if UNITY_EDITOR
		if ( true ) return;
		#endif

		if (mLogin == false) {
			return;
		}

		YunVaImSDK.instance.RecordStopPlayRequest();
	}


	private void  StopRecordResponse(ImRecordStopResp  data)
	{
		#if UNITY_EDITOR
		if ( true ) return;
		#endif

		mRecording = false;
		UIAPI.DebugLog("结束事件");

		if(!string.IsNullOrEmpty(data.strfilepath))
		{
			if (data.time < 0.5f)
				return;

			string recordPath=data.strfilepath;
			UIAPI.DebugLog("停止录音返回:"+recordPath);

			string fileId = DateTime.Now.ToFileTime().ToString();
			YunVaImSDK.instance.UploadFileRequest(recordPath, fileId, (data1) =>
			{
				if(data1.result==0)
				{
					string recordUrlPath = data1.fileurl;

					SendMessage("DoStopFun",recordUrlPath);

					UIAPI.DebugLog("上传成功:"+recordUrlPath);

					return;
				}
				else
				{
					UIAPI.DebugLog("上传失败:"+data1.msg);
				}
			});
		}

		SendMessage("DoStopFun","");
	}



	private void ImRecordVolume(object data)
	{
		ImRecordVolumeNotify RecordVolumeNotify = data as ImRecordVolumeNotify;
		LuaClient.Instance.Call("ImRecordVolume", RecordVolumeNotify.v_volume );
	}

	// Update is called once per frame
	void Update () {

	}
}
