
using UnityEngine;
using System.Collections;
using LuaInterface;
using System.Runtime.InteropServices;



public class CallEvent : MonoBehaviour {

	#if UNITY_IOS
	[DllImport("__Internal")]
	private static extern void _OnCallFun(string value);
	#endif

	public void CallFun(string value)
	{
		#if UNITY_ANDROID
		using (AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer"))
		{
			using( AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity"))
			{
				jo.Call("OnCallFun",value);
			}
		}
		#endif

		#if UNITY_IOS
		_OnCallFun(value);
		#endif
	}

	void OnCallFun(string value)
	{
		LuaClient.Instance.Call ("OnCallFun", value);
	}

	public void ShareShot(string value)
	{
		string filename = Application.persistentDataPath  + "/src.jpg";

		StartCoroutine (ShareShotFun (filename, value));
	}


	IEnumerator ShareShotFun(string filename,string str)//等到帧渲染结束开始截图
	{
		yield return new WaitForEndOfFrame();

		Texture2D scrShot = new Texture2D(Screen.width, Screen.height, TextureFormat.RGB24,false);
		scrShot.ReadPixels(new Rect(0,0,Screen.width, Screen.height), 0, 0);
		scrShot.Apply();

		byte[] bytes = scrShot.EncodeToJPG(); //.EncodeToPNG();
		System.IO.File.WriteAllBytes(filename, bytes);

		CallFun ("share_shot," + filename + "," + str);
	}

	public void WXLogin(string value)
	{
	#if UNITY_EDITOR
		StartCoroutine( Delay_OnWXLoginRet("Test" ) );
	#else
		#if UNITY_ANDROID
			using (AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer"))
			{
				using( AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity"))
				{
					jo.Call("WXLogin",value);
				}
			}
		#endif

		#if UNITY_IOS
		_OnCallFun("login");
		#endif
	#endif
	}

	IEnumerator Delay_OnWXLoginRet(string str)
	{
		yield return new WaitForSeconds(0.1f);

		OnWXLoginRet (str);
	}

	public void OnWXLoginRet(string msg)
	{
		LuaClient.Instance.Call ("OnWXLoginRet", msg);
	}



	#if used_self_api
	LuaFunction onClipEnd;
	Coroutine clipCor;
	int clipId;

	AudioClip clip;

	public void PlaySpeech(LuaByteBuffer t)
	{
		if (t.buffer != null) {

			GameAPI.PlaySound (GetClip (t.buffer));
		}
	}


	public void StartSpeech(LuaFunction end,float maxTime)
	{

		if (Microphone.IsRecording (null)) {
			return;
		}

		onClipEnd = end;

		GameAPI.PauseAllSound(true);


		clip = Microphone.Start(null, false, (int)maxTime, sepDef);

		clipCor = StartCoroutine (OnTimeOut (maxTime));
	}

	IEnumerator OnTimeOut(float maxTime)
	{
		yield return new WaitForSeconds(maxTime);

		clipCor = null;
		StopSpeech ();
	}

	public void StopSpeech()
	{
		if (clipCor != null) {
			StopCoroutine (clipCor);
			clipCor = null;
		}

		Microphone.End(null);

		GameAPI.PauseAllSound(false);

		if (onClipEnd != null) {
			onClipEnd.BeginPCall ();
			if (clip != null) {
				byte[] buf = GetClipData ();
				LuaByteBuffer l = new LuaByteBuffer (buf);
				onClipEnd.Push (l);
			}
			onClipEnd.PCall ();
			onClipEnd.EndPCall ();

			onClipEnd = null;
		}
	}


	const int rescaleFactor = 32767;
	const int sepDef = 10000;

	public AudioClip GetClip(byte[] data)
	{

		SpeexDecoder decoder = new SpeexDecoder(BandMode.Wide);

		short[] decodedFrame = new short[data.Length/2]; // should be the same number of samples as on the capturing side
		decoder.Decode(data, 0, data.Length, decodedFrame, 0, false);


		float[] samples = new float[data.Length/2];

		for (int i = 0; i < samples.Length; i++)
		{
			samples[i] = decodedFrame[i] * 1.0f / rescaleFactor;
		}


		AudioClip newClip = AudioClip.Create ("", samples.Length, 1, sepDef, false);
		newClip.SetData(samples,0);

		return newClip;
	}

	public byte[] GetClipData()
	{
		float[] samples = new float[clip.samples];


		SpeexDecoder decoder = new SpeexDecoder(BandMode.Wide);

		clip.GetData(samples, 0);


		short[] outData = new short[samples.Length];



		for (int i = 0; i < samples.Length; i++)
		{
			outData[i] = (short)(samples[i] * rescaleFactor);
		}


		SpeexEncoder encoder = new SpeexEncoder(BandMode.Wide);


		byte[] encodedData = new byte[samples.Length*2];

		encoder.Encode(outData, 0, outData.Length, encodedData, 0, encodedData.Length);

		testText = "length:" + encodedData.Length;

		return encodedData;
	}


	string testText = "test";

	void OnGUI()
	{
		GUI.Label(new Rect (0, 0, 100, 100), testText);
	}
	#endif

}
