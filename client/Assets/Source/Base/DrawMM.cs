using UnityEngine;
using System.Collections;

public class DrawMM : MonoBehaviour {

	// Use this for initialization
	void Start () {
		UIAPI.SetEmImage (null, 123);

		ImageList n = UIAPI.emsList;



		for (int i = 0; i < n.items.Length; i++) {
			var t = transform.GetChild(i);

			UIAPI.SetEmImage (t, i);
		}

	}
	
}
