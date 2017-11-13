using UnityEngine;
using System.Collections;
using UnityEngine.EventSystems;

public class AddValue : MonoBehaviour,IPointerClickHandler {

	public bool isAdd;

	public GameObject obj;


	
	public void OnPointerClick(PointerEventData eventData)
	{
		
		ValueList v = obj.GetComponent<ValueList> ();

		if (isAdd) {
			v.AddValue ();
		} else {
			v.SubValue ();
		}
	}
}
