using UnityEngine;
using System.Collections;

public class AllTop : MonoBehaviour {

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {

		Transform t = transform.parent;

		if (t.GetChild (t.childCount - 1) != transform) {
			transform.parent = null;
			transform.parent = t;
		}
	}
}
