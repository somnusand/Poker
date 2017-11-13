using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using System.Collections.Generic;

public class NetImage : MonoBehaviour {


	Hashtable table;


	class DownloadUnit{
		public string addr;
		public Transform t;
	}

	bool canDownload;
	List<DownloadUnit> downloadList;

	void Awake()
	{
		table = new Hashtable();
		downloadList = new List<DownloadUnit> ();
		canDownload = true;
	}


	void Update()
	{
		if (downloadList == null)
			return;
			
		if (canDownload) {
			while (downloadList.Count > 0) {
				DownloadUnit item = downloadList [0];
				if (table.ContainsKey (item.addr)) {
					downloadList.RemoveAt (0);
					SetImageBase (item.t, item.addr);
				} else {
					canDownload = false;
					StartCoroutine (GetTexture (item.addr));
					break;
				}
			}
		}
	}

	public void SetImage(Transform t, string addr)
	{
		if (table == null)
			return;
		
		if (table.ContainsKey (addr)) {
			SetImageBase (t, addr);
		} else {
			DownloadUnit item = new DownloadUnit();
			item.addr = addr;
			item.t = t;
			if (downloadList != null) downloadList.Add(item);
		}
	}

	void SetImageBase(Transform t, string addr)
	{
		Texture2D img = table [addr] as Texture2D;
		if (t != null) {
			Image s = t.GetComponent<Image> ();
			if (s != null) {
				s.sprite = Sprite.Create(img, new Rect(0, 0, img.width, img.height), new Vector2(0, 0));
			}
		}
	}

	IEnumerator GetTexture(string url)
	{
		WWW www = new WWW(url);
		yield return www;
		if (www.isDone && www.error == null)
		{
			Texture2D img = www.texture;
			if (table != null) table.Add (url, img);
		}

		canDownload = true;
	}
}
