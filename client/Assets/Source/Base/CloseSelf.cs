using UnityEngine;
using System.Collections;
using UnityEngine.EventSystems;



public class CloseSelf : MonoBehaviour,IPointerClickHandler
{


	public Transform root;

	public void OnPointerClick(PointerEventData eventData)
	{

		if (root == null)
		{
			root = transform;
			while ( root.parent != UIAPI.gCanvas )
			{
				root = root.parent;

				if ( root == null ) return;
			}
		}

		GameObject.Destroy(root.gameObject);
	}

}
