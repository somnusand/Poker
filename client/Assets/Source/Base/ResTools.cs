using UnityEngine;
using System.Collections;
using System.IO;
using UnityEngine.UI;

public class ResTools : MonoBehaviour {

	static Hashtable h = new Hashtable ();

	static ResTools self;


	static string[] AllRes = { 
		"lua", 
		"luabase", 
		"effect", 
		"3d", 
		"ogg", 
		"res", 
		"ui",
	};

	class VerData {
		public int ver;
		public string name;
		public bool isDown;
	}

	static VerData[] gResVers;

	public static Object Load(string res) {

		int index = res.IndexOf ("/");

		string key = res.Substring (0, index);
		string data = res.Substring (index+1);


		if (key == "Lua") {
			data = data.Replace ("/", "_") + ".bytes";
			AssetBundle a = h["lua"] as AssetBundle;
			Object m = a.LoadAsset (data);
			if (m != null)
				return m;

			a = h["luabase"] as AssetBundle;
			m = a.LoadAsset (data);
			if (m != null)
				return m;

			return null;
		}

		if ( h.ContainsKey(key) ) {
			AssetBundle a = h[key] as AssetBundle;

			Object obj = a.LoadAsset(data);
		
			return obj;
		}

		#if UNITY_EDITOR 
			string[] resType = { ".prefab", ".bytes", ".ogg", ".mp3" };

			for (int j = 0; j < resType.Length; j++) {
				var a = UnityEditor.AssetDatabase.LoadAssetAtPath<Object>("Assets/Resource/" + res + resType[j]);	
				if ( a != null ) {
					return a;
				}
			}
		#endif
		return null;
	}

#if UNITY_EDITOR	
//#if false
	public void Init (string msg) {	
		h.Clear ();
		gResVers = new VerData[AllRes.Length];
		for (int i=0; i<AllRes.Length; i++)
		{
			gResVers[i] = new VerData();
			gResVers[i].ver = 100000000;
		}
		transform.SendMessage(msg);
	}

	public void SetProcess(int n) {}

	public void SetProcessEnd() {}
#else

	Transform ui;
	float process;
	float next_process;

	public void Init (string msg) {
		var canvasObj = GameObject.Find("main/Canvas");
		var ui_res = Resources.Load ("Loading");
		var ui_obj = GameObject.Instantiate (ui_res) as GameObject;
		ui = ui_obj.transform;
		ui.parent = canvasObj.transform;

		ui_obj.transform.localScale = Vector3.one;
		ui_obj.transform.localPosition = Vector3.zero;


		RectTransform rt = ui_obj.GetComponent<RectTransform>();
		if (rt)
		{
			rt.sizeDelta = new Vector2(0, 0);
		}

		process = 0;
		next_process = 10;
		StartCoroutine (InitFun(msg));
	}

	public void SetProcess(int n) 
	{
		next_process = n;
	}

	public void SetProcessEnd() {
		process = 100;
	}


	public void Update()
	{
		if (ui != null) {
			if (next_process > process) {
				process += Time.deltaTime * 20;
			}
			Slider s = ui.FindChild ("Slider").gameObject.GetComponent<Slider> ();
			s.value = process;
		}
	}

#endif

	IEnumerator InitFun(string msg)
	{


		// read ver streamingAssets
		var filePath = System.IO.Path.Combine(Application.streamingAssetsPath, "ver");
		var result = "";
		if (filePath.Contains("://"))
		{
			var www = new WWW (filePath);
			yield return www;
			result = www.text;
		}
		else
			result = System.IO.File.ReadAllText(filePath);


		var vers = new VerData[AllRes.Length];

		var resultLines = result.Split (',');

		for(int i=0; i<vers.Length; i++ )
		{
			VerData verData = new VerData ();
			verData.ver = System.Convert.ToInt32 (resultLines[i]);
			verData.isDown = false;
			verData.name = AllRes[i];
			vers [i] = verData;
		}

		string fileName = System.IO.Path.Combine(Application.persistentDataPath, "ver");
		if (File.Exists (fileName)) {
			result = System.IO.File.ReadAllText (fileName);
			resultLines = result.Split (',');

			for(int i=0; i<resultLines.Length; i++ )
			{
				VerData verData = new VerData ();
				verData.ver = System.Convert.ToInt32 (resultLines[i]);
				verData.isDown = true;
				verData.name = AllRes [i];
				VerData verOldData = vers [i];
				if (verData.ver > verOldData.ver) {
					vers[i] = verData;				
				}
			}
		}


		SetProcess (10);
		if ( h.ContainsKey("font") == false ) {
			string fileFont = System.IO.Path.Combine(Application.streamingAssetsPath, "font" );
			AssetBundle ast;
			if (fileFont.Contains ("://")) {
				var www = new WWW (fileFont);
				yield return www;
				ast = www.assetBundle;
			} else {
				var a = AssetBundle.LoadFromFileAsync (fileFont);
				yield return a;     
				ast = a.assetBundle;
			}

			h.Add("font",ast);
		}


		for(int i=0; i<vers.Length; i++)
		{			
			var verData = vers [i];

			bool needDo = false;

			if (gResVers == null) {
				needDo = true;
			} else {
				VerData verOldData = gResVers[i];
				if (verData.ver > verOldData.ver) {
					needDo = true;
				}
			}
			SetProcess ((i + 1) * 90 / vers.Length + 10);
			if (needDo) {

				if ( h.ContainsKey(AllRes [i]) ) {
					AssetBundle a = h[AllRes [i]] as AssetBundle;

					a.Unload (false);
				}


				AssetBundle assetBundle;
				if (verData.isDown) {
					filePath = System.IO.Path.Combine (Application.persistentDataPath, AllRes [i]);
					assetBundle = AssetBundle.LoadFromFile (filePath);
				}
				else {
					filePath = System.IO.Path.Combine(Application.streamingAssetsPath, AllRes[i]);
					
					if (filePath.Contains ("://")) {
						var www = new WWW (filePath);
						yield return www;
						assetBundle = www.assetBundle;
					} else {
						var a = AssetBundle.LoadFromFileAsync (filePath);
						yield return a;     
						assetBundle = a.assetBundle;
					}
				}

				if ( h.ContainsKey(verData.name) )
				{
					h[verData.name] = assetBundle;
				}
				else{
					h.Add(verData.name,assetBundle);
				}
			}
			#if UNITY_EDITOR
			yield return new WaitForSeconds (0.1f);
			#endif
		}

		SetProcessEnd ();

		gResVers = vers;

		transform.SendMessage(msg);
	}


	static int MaxVer;
	static int DownStep;
	static bool[] NeedDownStep;

	static FileStream file;

	static public bool CheckVer(int[] ver)
	{
		if (file != null) {
			file.Flush();
			file.Close();
			file = null;
		}
		
		bool needDown = false;

		NeedDownStep = new bool[ver.Length];

		MaxVer = 0;
		for (int i = 0; i < ver.Length; i++) {
			if (ver [i] > MaxVer) {
				MaxVer = ver [i];
			}

			VerData verOldData = gResVers [i];

			if (verOldData.ver < ver [i]) {
				needDown = true;
				NeedDownStep [i] = true;
			} else {
				NeedDownStep [i] = false;
			}
		}

		if (needDown) {
			string fileName = System.IO.Path.Combine(Application.persistentDataPath, "downinfo");
			if ( File.Exists(fileName ) ) {
				var filestr = System.IO.File.ReadAllText(fileName);

				string[] vers = filestr.Split (',');
				if ((vers [0].Length > 0) && (System.Convert.ToInt32 (vers [0]) == MaxVer)) {
					DownStep = System.Convert.ToInt32 (vers [1]);
				} else {

					for (int i = 0; i < AllRes.Length; i++) {
						string delFile = System.IO.Path.Combine(Application.persistentDataPath, AllRes[i]);
						File.Delete(delFile);
					}

					File.Delete(fileName);

					DownStep = 0;
				}
			}
			else{
				DownStep = 0;
			}					
		}

		return needDown;
	}

	static public int BeginDown(int step)
	{		
		if (step < DownStep) {
			return -1;
		} 
		else if (NeedDownStep [step]) {
			DownStep = step;
			string fileName = System.IO.Path.Combine (Application.persistentDataPath, "t_"+AllRes [step]);
			file = File.Open (fileName, FileMode.Append);
			return (int)file.Length;
		}
		else{
			DownStep = step;
			return -1;
		}
	}

	static public void WriteDown(byte[] datas){
		if (file != null) {
			file.Write (datas, 0, datas.Length);
		}
	}

	static public int EndDown() {
		if (file != null) {
			file.Flush();
			file.Close();
			file = null;
		}
		DownStep++;
		if (DownStep >= AllRes.Length) {
			string fileName = System.IO.Path.Combine(Application.persistentDataPath, "downinfo");
			File.Delete (fileName);

			string str = "";
			for (int i = 0; i < NeedDownStep.Length; i++) {
				if (i != 0)
					str += ",";
				if (NeedDownStep[i]) { 
					str += string.Format ("{0}", MaxVer);
					string srcName = System.IO.Path.Combine (Application.persistentDataPath, "t_"+AllRes [i]);
					string desName = System.IO.Path.Combine (Application.persistentDataPath, AllRes [i]);
					File.Delete (desName);
					File.Move( srcName, desName);
				}
				else{					
					str += string.Format ("{0}", gResVers[i].ver);
				}
			}
			fileName = System.IO.Path.Combine(Application.persistentDataPath, "ver");
			System.IO.File.WriteAllText(fileName,str);

			return -1;

		} else {
			string fileName = System.IO.Path.Combine(Application.persistentDataPath, "downinfo");
			System.IO.File.WriteAllText(fileName,string.Format("{0},{1}",MaxVer,DownStep));

			return DownStep;
		}
	}




	protected void OnApplicationQuit()
	{
		if (file != null) {
			file.Flush();
			file.Close();
			file = null;
		}
	}

}
