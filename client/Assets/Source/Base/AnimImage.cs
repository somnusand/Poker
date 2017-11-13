using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class AnimImage : MonoBehaviour {

	public int id;
	public int count;
	public int index;

	public float inval;

	float time;
	ImageList list;
	Image img;

	public void Play(int vCount, int vId)
	{
		id = vId;
		count = vCount;
		index = count - 1;


	}

	// Use this for initialization
	void Start () {
		Transform  t = transform.GetChild (0);
		list = t.GetComponent<ImageList> ();

		img = gameObject.GetComponent<Image> ();

		img.sprite = list.items [count * id + index];
	}
	
	// Update is called once per frame
	void Update () {
		time += Time.deltaTime;

		if (index <= 0) {
			time = 0;
		} 
		else {
			if (time > inval) {
				time = 0;
				index--;
				img.sprite = list.items [count * id + index];
			}
		}

	}
}
