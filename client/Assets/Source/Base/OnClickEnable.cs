using UnityEngine;
using System.Collections;
using UnityEngine.EventSystems;

public class OnClickEnable : MonoBehaviour,IPointerClickHandler {

	public GameObject[] enableList;

	public GameObject[] disanableList;



	public void OnPointerClick(PointerEventData eventData)
	{

		if (enableList != null) {
			for (int i = 0; i < enableList.Length; i++) {
				enableList [i].SetActive (true);
			}
		}

		if (disanableList != null) {
			for (int i = 0; i < disanableList.Length; i++) {
				disanableList [i].SetActive (false);
			}
		}
	}
}
