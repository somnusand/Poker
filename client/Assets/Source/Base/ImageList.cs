using UnityEngine;
using System.Collections;

using UnityEngine.UI;

public class ImageList : MonoBehaviour {


	public Sprite[] items;

	Hashtable table;


	void Awake()
	{
		table = new Hashtable();

		for(int i=0; i<items.Length; i++)
		{
			table.Add(items[i].name,items[i]);
		}

	}

	public Sprite Get(string name)
	{
		return table[name] as Sprite;
	}

}
