using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class ValueList : MonoBehaviour {

	public int[] values;

	public int valueIndex;

	void Start()
	{
		valueIndex = 0;
		UpdateDis ();
	}

	void UpdateDis()
	{
		Text t = gameObject.GetComponent<Text> ();
		t.text = "" + values [valueIndex];
	}

	public int GetValue()
	{
		return values [valueIndex];
	}


	public void AddValue()
	{
		valueIndex++;
		if (valueIndex >= values.Length) {
			valueIndex = values.Length - 1;
		}
		UpdateDis ();
	}

	public void SubValue()
	{
		valueIndex--;
		if (valueIndex < 0) {
			valueIndex = 0;
		}
		UpdateDis ();
	}


}
