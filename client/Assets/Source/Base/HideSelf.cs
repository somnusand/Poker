using UnityEngine;
using System.Collections;
using UnityEngine.EventSystems;

public class HideSelf : MonoBehaviour ,IPointerClickHandler
{


	public Transform root;

	public void OnPointerClick(PointerEventData eventData)
	{

		if (root == null)
		{
			root = transform;
			while ( root.parent != UIAPI.gCanvas )
			{
				root = transform.parent;

				if ( root == null ) return;
			}
		}

		root.gameObject.SetActive (false);
	}

}