using UnityEngine;
using System.Collections;

using UnityEngine.EventSystems;

public class OnDragInt : MonoBehaviour, IBeginDragHandler,IEndDragHandler,IDragHandler {


	public string fun;
	public int n;

	public bool usedChildIndex;
	 	

	Vector2 dragPos;

	public void OnBeginDrag(PointerEventData eventData)
	{
		dragPos = eventData.position;
		GetN (new Vector2(transform.position.x,transform.position.y),0);
	}

	public void OnEndDrag(PointerEventData eventData)
	{
		GetN (eventData.position - dragPos,2);
	}

	public void OnDrag(PointerEventData eventData)
	{
		GetN (eventData.position - dragPos,1);

	}



	void GetN(Vector2 pos, int cmd) 
	{		
		if (usedChildIndex)
		{
			Transform t = transform.parent;

			for(int i=0; i<t.childCount; i++)
			{
				if ( t.GetChild(i) == transform )
				{
					n = i;
					break;
				}
			}
		}

		object[] objs = new object[4];
		objs [0] = n;
		objs [1] = cmd;
		objs [2] = pos.x;
		objs [3] = pos.y;


		LuaClient.Instance.Call(fun,objs);
	}
}
