#define NOT_USED_LOG

using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using LuaInterface;
using System.Collections.Generic;

public class UIAPI {

	public static Transform gCanvas;
	static NetImage netImage;


	static ImageList imgList;
	public static ImageList emsList;

	static public void Init()
	{
		if ( gCanvas == null )
		{
			var canvasObj = GameObject.Find("main/Canvas");
			gCanvas = canvasObj.transform;

			netImage = canvasObj.AddComponent<NetImage> ();
		}
	}

	#if NOT_USED_LOG
	public static void DebugLog(string str)
	{
	}
	#else
	static Transform debug_main;
	static string[] strs;
	public static void DebugLog(string str)
	{
		if (strs == null) {
			strs = new string[10];
		}

		for (int i = strs.Length-1; i >0; i--) {
			strs [i] = strs[i-1];
		}
		strs [0] = str;



		if (debug_main == null) {
			debug_main = CreateUI ("Debug");
		}



		string dis_str = "";
		for (int i = 0; i < strs.Length; i++) {
			dis_str += strs[i];
			dis_str += "\n";
		}

		Text t = debug_main.FindChild("Text").GetComponent<Text> ();
		t.text = dis_str;
	}
	#endif


	static public void CloseAll()
	{
		if (gCanvas) {
			for (int i = 0; i < gCanvas.childCount; i++) {
				GameObject.Destroy(gCanvas.GetChild(i).gameObject);
			}
		}

	}

	static public void SetToCenter(Transform t, Transform to)
	{
		t.position = to.position;
	}

//	static public Transform CloneUI(Transform t)
//	{
//		GameObject obj = GameObject.Instantiate(t.gameObject) as GameObject;
//		obj.transform.SetParent(t.parent);
//		obj.transform.localScale = t.localScale;
//		obj.transform.localPosition = t.localPosition;
//
//		OnClickInt f = obj.GetComponent<OnClickInt> ();
//		if ( f != null ) f.enabled = false;
//
//		OnDragInt f2 = obj.GetComponent<OnDragInt> ();
//		if ( f2 != null ) f2.enabled = false;
//
//		return obj.transform;
//	}

	static public Transform CreateUI(string res)
	{
		return CreateUI(res,true);
	}

	static public Transform CreateUI(string res,bool zero_size)
	{
		var prefab = ResTools.Load("ui/" + res);

		Debug.Assert(prefab, "can't find [" + res + "] in resource.");


		GameObject obj = GameObject.Instantiate(prefab) as GameObject;

		obj.transform.SetParent(gCanvas);

		obj.transform.localScale = Vector3.one;
		obj.transform.localPosition = Vector3.zero;

		if (zero_size)
		{
			RectTransform rt = obj.GetComponent<RectTransform>();
			if (rt)
			{
				rt.sizeDelta = new Vector2(0, 0);
			}
		}

		int pos = res.LastIndexOf('/');
		obj.name = res.Substring(pos + 1);

		return obj.transform;
	}

	static public Transform CreateUIEx(string res)
	{
		var prefab = ResTools.Load("UI/" + res);

		Debug.Assert(prefab, "can't find [" + res + "] in resource.");


		GameObject obj = GameObject.Instantiate(prefab) as GameObject;

		obj.transform.SetParent(gCanvas);

		int pos = res.LastIndexOf('/');
		obj.name = res.Substring(pos + 1);

		return obj.transform;
	}


	static public Transform CloneUI(Transform t)
	{
		GameObject obj = GameObject.Instantiate(t.gameObject) as GameObject;
		obj.transform.SetParent(t.parent);
		obj.transform.localScale = t.localScale;
		obj.transform.localPosition = t.localPosition;

		obj.layer = t.gameObject.layer;

		OnClickInt f = obj.GetComponent<OnClickInt> ();
		if ( f != null ) f.enabled = false;

		OnDragInt f2 = obj.GetComponent<OnDragInt> ();
		if ( f2 != null ) f2.enabled = false;

		return obj.transform;
	}

	static public void DeleteUI(string name)
	{
		Transform child = gCanvas.FindChild (name);
		if (child!=null) {
			GameObject.Destroy (child.gameObject);
		}

	}

	static public void DeletetAllChild(Transform t)
	{
		if (t == null) {
			return;
		}

		for (int i = 0; i < t.childCount; i++) {
			GameObject.Destroy(t.GetChild(i).gameObject);
		}
	}



	static public Transform CreateChild(Transform t,string res,bool zero_size)
	{
		var prefab = ResTools.Load(res);

		if (prefab == null) {

			Debug.Log ("can't found res:" + res);
			return null;
		} else {

			GameObject obj = GameObject.Instantiate (prefab, t) as GameObject;

			obj.transform.localScale = Vector3.one;
			obj.transform.localPosition = Vector3.zero;

			if (zero_size)
			{
				RectTransform rt = obj.GetComponent<RectTransform>();
				if (rt)
				{
					rt.sizeDelta = new Vector2(0, 0);
				}
			}

			int pos = res.LastIndexOf('/');
			obj.name = res.Substring(pos + 1);

			return obj.transform;

		}
	}


	static public Transform ShowOne(string res)
	{
		int pos = res.LastIndexOf('/');
		string name = res.Substring(pos + 1);

		Transform t = gCanvas.FindChild(name);
		if ( t == null )
		{
			t = CreateUI(res);
		}

		return t;
	}

	static public void CloseOne(string res)
	{
		int pos = res.LastIndexOf('/');
		string name = res.Substring(pos + 1);

		Transform t = gCanvas.FindChild(name);
		if ( t != null )
		{
			GameObject.Destroy(t.gameObject);
		}
	}

	static public void CloneChildCount(Transform t,int count)
	{	

		Transform child = t.GetChild(0);
		for(int i=t.childCount; i<count; i++ )
		{
			GameObject obj = GameObject.Instantiate (child.gameObject) as GameObject;

			obj.transform.parent = t;
		}

		GridLayoutGroup g = t.GetComponent<GridLayoutGroup> ();

	}


	static public void ClearInput(Transform t)
	{
		if ( t != null )
		{
			InputNumber i = t.GetComponent<InputNumber>();
			if ( i!= null )
			{
				i.Clear();
			}
		}
	}

	static public void SetText(Transform t,string text)
	{
		if ( t != null )
		{
			Text i = t.GetComponent<Text>();
			i.text = text;
		}
	}

	static public void SetToggle(Transform t,int n)
	{
		if ( t != null )
		{
			Toggle i = t.GetComponent<Toggle>();
			i.isOn = (n != 0);
		}
	}

	static public void SetToggle(Transform t,bool n)
	{
		if ( t != null )
		{
			Toggle i = t.GetComponent<Toggle>();
			i.isOn = n;
		}
	}

	static public void SetImage(Transform t,string name)
	{
		if (name == null)
			return;

		if (name == "")
			return;

		if ( name.IndexOf("http:") == 0 )
		{
			netImage.SetImage (t, name);
			return;
		}

		if ( imgList == null )
		{
			var obj = ResTools.Load("res/cards");
			GameObject gameObj = GameObject.Instantiate(obj) as GameObject;
			imgList = gameObj.GetComponent<ImageList>();
		}

		if ( t != null )
		{
			Image s = t.GetComponent<Image>();
			s.sprite = imgList.Get(name);
		}
	}

	static public void SetEmImage(Transform t,int n)
	{
		if ( emsList == null )
		{
			var obj = ResTools.Load("res/emotions");
			GameObject gameObj = GameObject.Instantiate(obj) as GameObject;
			emsList = gameObj.GetComponent<ImageList>();
		}

		if ( t != null )
		{
			Image s = t.GetComponent<Image>();
			s.sprite = emsList.items [n];
		}
	}

	static public void SetImageColor(Transform t,byte r,byte g, byte b)
	{
		if ( t != null )
		{
			Image s = t.GetComponent<Image>();
			s.color = new Color32(r,g,b,(byte)255);
		}
	}

	static public void SetTextColor(Transform t,byte r,byte g, byte b)
	{
		if ( t != null )
		{
			Text s = t.GetComponent<Text>();
			s.color = new Color32(r,g,b,(byte)255);
		}
	}


	static public void SliderValue(Transform t,int m)
	{
		if ( t != null )
		{
			Slider s = t.GetComponent<Slider>();

			OnSliderChange onChange = t.GetComponent<OnSliderChange>();

			if (onChange)
				onChange.setValue = true;
			s.value = m;

			if (onChange)
				onChange.setValue = false;
		}
	}


	static public void SliderCount(Transform t,int count)
	{
		if ( t != null )
		{
			Slider s = t.GetComponent<Slider>();
			var onChange = s.onValueChanged;
			s.onValueChanged = null;
			s.maxValue = count;
			s.onValueChanged = onChange;
		}
	}


	static public void SetArtNumber(Transform t,int n)
	{


		if ( t != null )
		{
			ArtNumber com =  t.GetComponent<ArtNumber>();
			com.SetNumber (n);
		}
	}

	static public void SetArtNumber2(Transform t,int n)
	{


		if ( t != null )
		{
			ArtNumber com =  t.GetComponent<ArtNumber>();
			com.SetNumber2 (n);
		}
	}



	static public void SetNumberImage(Transform t,int n)
	{


		if ( t != null )
		{

			ImageList	list =  t.parent.GetComponent<ImageList>();


			Image s = t.GetComponent<Image>();
			s.sprite = list.items[n];
		}
	}



	static public Transform ShowEffect(Transform t,string name)
	{
		if ( t != null )
		{
			return CreateChild(t, "effect/" + name, false);
		}

		return null;
	}


	static public Transform ShowImageEffect(Transform t,string name,string img)
	{
		if ( imgList == null )
		{
			var obj = ResTools.Load("res/cards");
			GameObject gameObj = GameObject.Instantiate(obj) as GameObject;
			imgList = gameObj.GetComponent<ImageList>();
		}

		if ( t != null )
		{
			Transform child = CreateChild (t, "effect/" + name, false);

			Image s = child.GetComponent<Image>();
			s.sprite = imgList.Get(img);

			return child;
		}

		return null;
	}

	static public void ShowImageEffectColor(Transform t,string name,string img,byte r,byte g, byte b)
	{
		if ( imgList == null )
		{
			var obj = ResTools.Load("res/cards");
			GameObject gameObj = GameObject.Instantiate(obj) as GameObject;
			imgList = gameObj.GetComponent<ImageList>();
		}

		if ( t != null )
		{
			Transform child = CreateChild (t, "effect/" + name, false);

			Image s = child.GetComponent<Image>();
			s.sprite = imgList.Get(img);
			s.color = new Color (r, g, b);
		}
	}

	static public void SetOnClick(Transform t, LuaFunction fun)
	{
		if (t) {

			OnClickLua onClick = t.gameObject.GetComponent<OnClickLua> ();
			if ( onClick == null )
			{
				onClick = t.gameObject.AddComponent<OnClickLua> ();
			}
			onClick.fun = fun;
		}
	}

	static public void Gray(Transform t)
	{
		if (t != null) {
			Graphic[] ss = t.GetComponentsInChildren <Graphic>();
			for (int i = 0; i < ss.Length; i++) {
				ss[i].color = new Color(0.5f,0.5f,0.5f);
			}
		}
	}


	static public void SetPaiEx(Transform t, int type)
	{
		if (t != null) {
			Transform child;
			if (t.childCount > 0) {
				child = t.GetChild (0);
			} else {
				Image img = t.GetComponent<Image> ();
				string key = img.sprite.name.Substring (0, 3);


				GameObject obj = GameObject.Instantiate (t.gameObject);
				obj.transform.SetParent (t);
				child = obj.transform;

				RectTransform rt = t as RectTransform;


				RectTransform rtChild = child as RectTransform;

				child.localScale = Vector3.one;

				float d = rt.sizeDelta.x / img.sprite.texture.width;
				rtChild.sizeDelta = new Vector2 (d * 31 * 1.1f, d * 35 * 1.1f);

				Image childImg = child.GetComponent<Image> ();
				childImg.color = new Color32 (255, 255, 255, 200);

				childImg.raycastTarget = false;
				OnClickInt cnClick = child.GetComponent<OnClickInt> ();
				if (cnClick != null) {
					cnClick.enabled = false;
				}

				if (key == "p4b") {
					child.localPosition = new Vector3 (-20, 15, 0) * d;
					child.localEulerAngles = new Vector3 (0, 0, 0);
				} else if (key == "p4s") {
					child.localPosition = new Vector3 (-20, 45, 0) * d;
					child.localEulerAngles = new Vector3 (30, 0, 0);
				} else if (key == "p1s") {
					child.localPosition = new Vector3 (-14, 4, 0) * d;
					child.localEulerAngles = new Vector3 (30, 0, 90);
					child.localScale *= 0.5f;
				} else if (key == "p2s") {
					child.localPosition = new Vector3 (-20, 45, 0) * d;
					child.localEulerAngles = new Vector3 (30, 0, 00);
				} else if (key == "p3s") {
					child.localPosition = new Vector3 (14, 12, 0) * d;
					child.localEulerAngles = new Vector3 (30, 0, 270);
					child.localScale *= 0.5f;
				} else {
					type = 4;
				}
			}

			if (type == 1) {
				child.gameObject.SetActive (true);
				SetImage (child, "lai");
			} else if (type == 2 ) {
				child.gameObject.SetActive (true);
				SetImage (child, "pi");
			}
			else {
				child.gameObject.SetActive (false);
			}
		}
	}

	static public void SetY(Transform t,float y)
	{
		t.transform.position = new Vector3 (t.transform.position.x, y, t.transform.position.z);
	}
}
