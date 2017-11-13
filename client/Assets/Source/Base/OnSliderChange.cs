using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class OnSliderChange : MonoBehaviour {

	public string fun;

	public bool setValue;

	void Start () {


		Slider s = GetComponent<Slider> ();

		s.onValueChanged.AddListener((float value) => OnToggleClick(value));
	}


	void OnToggleClick (float value) {
		if (setValue == false) {
			LuaClient.Instance.Call (fun, value);
		}
	}


}
