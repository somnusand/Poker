using UnityEngine;
using System.Collections;
using UnityEngine.EventSystems;

public class OnDownUp  : MonoBehaviour,IPointerDownHandler,IPointerUpHandler
{
	public string DownName;
	public string UpName;


	public void OnPointerDown(PointerEventData eventData)
	{
		LuaClient.Instance.Call(DownName);	
	}

	public void OnPointerUp(PointerEventData eventData)
	{
		LuaClient.Instance.Call(UpName);	
	}
}