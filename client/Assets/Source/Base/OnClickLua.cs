using UnityEngine;
using System.Collections;
using UnityEngine.EventSystems;
using LuaInterface;

public class OnClickLua : MonoBehaviour,IPointerClickHandler {

	public LuaFunction fun;

	public void OnPointerClick(PointerEventData eventData)
	{
		fun.Call ();
	}

}
