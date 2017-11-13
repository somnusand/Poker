using UnityEngine;
using System.Collections;
using UnityEditor;
using System.IO;

using UnityEngine.UI;
using System.Collections.Generic;
using System;


[InitializeOnLoad]
public static class UITools {


	[MenuItem("Tools/MakeCardsResToBase")]
	static void MakeCardsResToBase ()
	{
		string res_path = "Assets/cards";

		for (int p=1; p<=4; p++) {
			for (int i = 1; i <= 3; i++) {
				for (int j = 1; j <= 9; j++) {
					int n = p;

					if (n == 4)
						n = 2;

					int i1 = 0;

					if (i == 1) {
						i1 = 2;
					}
					else if (i == 2) {
						i1 = 1;
					}
					else if (i == 3) {
						i1 = 3;
					}

					string orgName = string.Format ("{0}/{1}/mingmah_{2}{3}.png",res_path,n,i1,j); 	
					string desName = string.Format ("{0}/p{1}s{2}_{3}.png",res_path,p,i,j); 	

					File.Copy(orgName,desName);
				}
			}
		}


		for (int i = 1; i <= 3; i++) {
			for (int j = 1; j <= 9; j++) {
				int p = 4;

				int	n = 2;

				int i1 = 0;

				if (i == 1) {
					i1 = 2;
				}
				else if (i == 2) {
					i1 = 1;
				}
				else if (i == 3) {
					i1 = 3;
				}

				string orgName = string.Format ("{0}/{1}/handmah_{2}{3}.png",res_path,n,i1,j); 	
				string desName = string.Format ("{0}/p{1}b{2}_{3}.png",res_path,p,i,j); 	

				File.Copy(orgName,desName,true);
			}
		}

	}

//	[MenuItem("Tools/SetAllBaseBundles")]
//	static void SetAllBaseBundles ()
//	{
//		assetKeys = new Hashtable ();
//
//		SetBaseBundle ("UI");
//		assetKeys = null;
//	}

	[MenuItem("Tools/CopyResMp3")]
	static void CopyMp3Files()
	{
		CopyMp3Files ("ogg/voice");
	}

	static void CopyMp3Files(string sourceDir)
	{		
		sourceDir = Application.dataPath + "/Resource/" + sourceDir;      
		string searchPattern = "*.mp3";
		SearchOption option = SearchOption.AllDirectories;

		string[] files = Directory.GetFiles(sourceDir, searchPattern, option);
		int len = sourceDir.Length;

		if (sourceDir[len - 1] == '/' || sourceDir[len - 1] == '\\')
		{
			--len;
		}

		for (int i = 0; i < files.Length; i++)
		{
			string str = files[i].Remove(0, len+1);
			str = str.Replace ("\\", "/");
			str = str.Replace ("/", "_");
			string dest = sourceDir + "/" + str;
			string dir = Path.GetDirectoryName(dest);
			Directory.CreateDirectory(dir);
			File.Copy(files[i], dest, true);
		}
	}

	[MenuItem("Tools/BuildAllAssetBundles")]
	static void BuildAllAssetBundles ()
	{
		string path = AssetDatabase.GetAssetPath(UnityEditor.Selection.activeObject);  
		
		CopyLuaFiles(LuaConst.luaDir,"lua");
		CopyLuaFiles(LuaConst.toluaDir,"luabase");


		AssetDatabase.Refresh();	
		AssetDatabase.SaveAssets ();

		string[] res = { 
			"lua", 
			"luabase", 
			"effect", 
			"3d", 
			"ogg", 
			"res", 
			"ui",
		};
		string[] res_time_path = { 
			LuaConst.luaDir, 
			LuaConst.toluaDir, 
			null, 
			null, 
			null, 
			null, 
			null, 
		};

		for (int i = 0; i < res.Length; i++) {
			SetBaseBundle (res [i]);
		}

		AssetDatabase.SaveAssets ();
		BuildPipeline.BuildAssetBundles(Application.streamingAssetsPath, BuildAssetBundleOptions.DeterministicAssetBundle, EditorUserBuildSettings.activeBuildTarget);
		AssetDatabase.Refresh ();

		File.Delete (Application.streamingAssetsPath + "/ver");

		string str = "";
		for (int i = 0; i < res.Length; i++) {
			DateTime t;

			if (res_time_path [i] == null) {
				t = GetDirTime(Application.dataPath + "/Resource/" + res[i]);
			} else {
				t = GetDirTime(res_time_path[i]);
			}

			int key = t.Year - 2000;
			key = key * 12 + t.Month;
			key = key * 31 + t.Day;
			key = key * 24 + t.Hour;
			key = key * 60 + t.Minute;
			if (i != 0)
				str += ",";
			str += string.Format ("{0}",key);
		}	

		#if UNITY_IOS 
		string ser_path =  "/../../server/res_ios/";
		#else
		string ser_path =  "/../../server/res/";
		#endif

		File.WriteAllText(Application.streamingAssetsPath + "/ver",str);

		for (int i = 0; i < res.Length; i++) {
			string fileName = System.IO.Path.Combine(Application.streamingAssetsPath, res[i]);

			File.Copy(fileName, Application.dataPath + ser_path + res [i],true);
		}

		string file = System.IO.Path.Combine(Application.streamingAssetsPath, "ver");

		File.Copy (file, Application.dataPath + ser_path + "ver",true);
	}	


	

	static void CopyLuaFiles(string sourceDir,string res)
	{		
		string destDir = Application.dataPath + "/Resource/" + res;      
		string searchPattern = "*.lua";
		SearchOption option = SearchOption.AllDirectories;

		string[] files = Directory.GetFiles(sourceDir, searchPattern, option);
		int len = sourceDir.Length;

		if (sourceDir[len - 1] == '/' || sourceDir[len - 1] == '\\')
		{
			--len;
		}

		for (int i = 0; i < files.Length; i++)
		{
			string str = files[i].Remove(0, len+1);
			str = str.Replace ("\\", "/");
			str = str.Replace ("/", "_");
			string dest = destDir + "/" + str;
			dest += ".bytes";
			string dir = Path.GetDirectoryName(dest);
			Directory.CreateDirectory(dir);
			File.Copy(files[i], dest, true);
		}
	}

	static DateTime GetDirTime(string destDir)
	{	
		string searchPattern = "*.*";
		SearchOption option = SearchOption.AllDirectories;

		string[] files = Directory.GetFiles(destDir, searchPattern, option);

		DateTime t = File.GetLastWriteTime (destDir);
		for (int i = 0; i < files.Length; i++)
		{
			if (files [i].IndexOf(".DS_Store") > 0 ) continue;
			var t2 = File.GetLastWriteTime (files [i]);
			if (t2 > t)
				t = t2;
		}

		return t;
	}


	static void SetBaseBundle(string res)
	{			
		int len = Application.dataPath.Length - 6;
		string dir = Application.dataPath + "/Resource/" + res;

		string[] resType = { "*.prefab", "*.bytes", "*.ogg", "*.mp3" };

		for (int j = 0; j < resType.Length; j++) {
			string[] files = Directory.GetFiles (dir, resType[j], SearchOption.AllDirectories);	

			for (int i = 0; i < files.Length; i++) {			
				var str = files [i].Substring (len);
				var importer = AssetImporter.GetAtPath (str);
				if (importer != null) {
					importer.assetBundleName = res;
					importer.assetBundleVariant = null;   
				}
			}
		}
	}

//	[MenuItem("Tools/BuildAllAssetBundles")]
//	static void BuildAllAssetBundles ()
//	{
//		BeginBundles ();
//
//		SetBundle ("ogg");
//		SetBundle ("effect");
//		SetBundle ("res");
//		SetBundle ("UI");
//
//		ToLuaMenu.BuildNotJitBundles();
//
//
//		EndBundles ();
//	}


//	static List<AssetImporter> assetList;
//	static Hashtable assetKeys;
//
//	static void BeginBundles ()
//	{
////		if ( Directory.Exists(Application.streamingAssetsPath) )
////		{
////			Directory.Delete(Application.streamingAssetsPath,true);
////		}
//
//		assetList = new List<AssetImporter> ();
//		assetKeys = new Hashtable ();
//	}
//
//	static void EndBundles ()
//	{
//		for (int i = 0; i < assetList.Count; i++)
//		{
//			assetList[i].assetBundleName = null;
//		}
//
//		AssetDatabase.Refresh();
//		
//		assetList = null;
//		assetKeys = null;
//		
//	}

//	static void SetResToBundle(string file,string bundleName="base")
//	{
//		
//		if (assetKeys.ContainsKey (file)) {
//				return;		
//		}
//		
//		AssetImporter importer = AssetImporter.GetAtPath(file);    
//
//
//		if (importer != null)
//		{
//			importer.assetBundleName = bundleName;
//			importer.assetBundleVariant = null;   
//
//
//			if (assetList != null) assetList.Add (importer);	
//			assetKeys.Add (file, assetKeys.Count + 1);
//		}
//	}
//
//	static void SetBaseBundle(string dir)
//	{
//		string res_path = "Assets/Resources/" + dir;
//
//		string[] files = Directory.GetFiles( res_path, "*.prefab", SearchOption.AllDirectories);
//
//
//		for (int i = 0; i < files.Length; i++)
//		{
//			int pos = files [i].IndexOf ("Assets");
//			files[i] = files[i].Substring(pos);
//		}
//
//
//
//		string[] desTypes = {
//			"jpg",
//			"jpeg",
//			"png",
//			"tga",
//		};
//
//		for (int i = 0; i < files.Length; i++)
//		{
//			string[] depens = AssetDatabase.GetDependencies(files[i]);       
//
//			for (int  j= 0; j< depens.Length; j++)
//			{
//				for (int n=0; n<desTypes.Length; n++)
//				{
//					if (depens [j].IndexOf (desTypes [n]) > 0) {
//						SetResToBundle (depens [j]);
//						break;
//					}
//				}
//			}
//		}
//
//
//	}
//
//	static void SetBundle(string dir,bool res = false)
//	{
//		string res_path = "Assets/Resources/" + dir;
//
//		string[] files = Directory.GetFiles( res_path, "*.*", SearchOption.AllDirectories);
//
//		List<string> fileList = new List<string> ();
//
//
//		for (int i = 0; i < files.Length; i++) {
//			
//			if (files[i].IndexOf (".meta") > 0)
//				continue;
//
//			fileList.Add (files [i]);
//		}
//
//		files = fileList.ToArray ();
//
//
//		string bundleName = dir;
//		bundleName = bundleName.ToLower();
//
//		for (int i = 0; i < files.Length; i++)
//		{
//			int pos = files [i].IndexOf ("Assets");
//			files[i] = files[i].Substring(pos);
//			SetResToBundle(files[i],bundleName);
//		}
//
//		if (res) {
//
//			string[] desTypes = {
//				"jpg",
//				"jpeg",
//				"png",
//				"tga",
//			};
//				
//			for (int i = 0; i < files.Length; i++)
//			{
//				string[] depens = AssetDatabase.GetDependencies(files[i]);       
//
//				for (int  j= 0; j< depens.Length; j++)
//				{
//					for (int n=0; n<desTypes.Length; n++)
//					{
//						if (depens [j].IndexOf (desTypes [n]) > 0) {
//							SetResToBundle (depens [j]);
//							break;
//						}
//					}
//				}
//			}
//		}
//
//	}

	[MenuItem("Tools/SplitImage")]
	public static void SplitImage()
	{
		string path = "face";


		DirectoryInfo info = new DirectoryInfo(Application.dataPath+"/Arts/"+path);
		FileInfo[] files = info.GetFiles("*.png");


		GameObject obj = new GameObject();


		for(int i=0; i< files.Length; i++)
		{			
		}
	}

	[MenuItem("Tools/ClearSave")]
	public static void ClearSave()
	{
		PlayerPrefs.DeleteAll ();
	}

	[MenuItem("Tools/Gen Resource")]
	public static void GenerateRes()
	{
		string path = "cards";
		//string path = "face";
		//string path = "shaizi";


		DirectoryInfo info = new DirectoryInfo(Application.dataPath+"/Arts/"+path);
		FileInfo[] files = info.GetFiles("*.png");


		GameObject obj = new GameObject();



		ImageList list = obj.AddComponent<ImageList>();

		list.items = new Sprite[files.Length];

		for(int i=0; i< files.Length; i++)
		{
			
			list.items[i] = UnityEditor.AssetDatabase.LoadAssetAtPath<Sprite>("Assets/Arts/"+path+"/"+files[i].Name);
		}
	}


	[MenuItem("Tools/JustPosBase")]
	public static void JustPosBase()
	{
		for (int i=0; i<UnityEditor.Selection.objects.Length; i++)
		{
			GameObject obj = (GameObject)UnityEditor.Selection.objects[i];

			GroupOffset s = obj.GetComponent<GroupOffset>();




			if  ( s != null)
			{	
				Vector3 basePos = obj.transform.GetChild(0).transform.localPosition;
				for (int j=1; j<obj.transform.childCount; j++)
				{
					Transform c = obj.transform.GetChild(j);
					c.localPosition = basePos + s.offset * j;
				}
			}
		}
	}

	[MenuItem("Tools/JustPos")]
	public static void JustPos()
	{
		for (int i=0; i<UnityEditor.Selection.objects.Length; i++)
		{
			GameObject obj = (GameObject)UnityEditor.Selection.objects[i];

			GroupOffset s = obj.GetComponent<GroupOffset>();




			if  ( s != null)
			{	

				for (int j=0; j<obj.transform.childCount; j++)
				{
					int x = j;

					if ( s.lineCount > 0 )
					{
						x = j % s.lineCount;
					}





					Transform c = obj.transform.GetChild(j);
					c.localPosition = x * s.offset;
					c.localScale = Vector3.one;

					Image img = c.gameObject.GetComponent<Image> ();
					Sprite spr = img.sprite;

					float sc = 1;
					if (s.offset.x != 0) {
						if (spr.texture.width != s.offset.x) {
							sc = Mathf.Abs(s.offset.x/ spr.texture.width); 
						}
						c.localPosition += new Vector3(s.off,0,0) * x;

						if ( s.justCount>0) c.localPosition += new Vector3(s.justOff,0,0) * (j/s.justCount);
					} else {
						if (spr.texture.height != s.offset.y) {
							sc = Mathf.Abs(s.offset.y/ spr.texture.height); 

						}
						c.localPosition += new Vector3(0,s.off,0) * x;

						if ( s.justCount>0) c.localPosition += new Vector3(0,s.justOff,0) * (j/s.justCount);
					}

					RectTransform rtTrans = c.transform as RectTransform;
					rtTrans.sizeDelta = new Vector2(spr.texture.width*sc,spr.texture.height*sc);

					if ( s.lineCount > 0 )
					{
						if (s.offset.x != 0) {
							c.localPosition += new Vector3(0,(j / s.lineCount) * s.lineHeight);
						} else {
							c.localPosition += new Vector3((j / s.lineCount) * s.lineHeight,0);
						}						

					}

				}
			}
		}
	}
}
