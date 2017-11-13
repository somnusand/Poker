using UnityEngine;
using System.Collections;

public class TestPiLai : MonoBehaviour {

	// Use this for initialization
	void Start () {
		Transform t;
		for (int k = 1; k <= 4; k++) {
			t = transform.FindChild ("Player" + k + "/Old/");
			for (int i = 0; i < 3; i++) {
				UIAPI.SetPaiEx (t.GetChild (i), i);
			}
			t = transform.FindChild ("Player" + k + "/Pai/");
			for (int i = 0; i < 3; i++) {
				UIAPI.SetPaiEx (t.GetChild (i), i);
			}
			t = transform.FindChild ("Player" + k + "/Hold/");
			for (int i = 0; i < 3; i++) {
				UIAPI.SetPaiEx (t.GetChild (i), i);
			}
			t = transform.FindChild ("Player" + k + "/PaiHu/");
			for (int i = 0; i < 3; i++) {
				UIAPI.SetPaiEx (t.GetChild (i), i);
			}
		}

	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
