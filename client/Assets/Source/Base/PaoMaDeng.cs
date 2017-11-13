using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class PaoMaDeng : MonoBehaviour {

	public Text r;
	public float rWidth;

	float posX;

	// Use this for initialization
	void Start () {
		posX = 0;
	}
	
	// Update is called once per frame
	void Update () {
		RectTransform rt = transform as RectTransform;
		rWidth = r.preferredWidth + rt.sizeDelta.x + 50;

		float dx = Time.deltaTime * 100;
		posX += dx;
		r.transform.localPosition -= new Vector3(dx,0,0);

		if (posX > rWidth ) {
			r.transform.localPosition += new Vector3 (posX, 0, 0);
			posX = 0;
		}
	}
}
