using UnityEngine;
using System.Collections;
using UnityEngine.EventSystems;

public class OnClickInt : MonoBehaviour, IPointerClickHandler
{
    public string fun;
    public int n;

    public bool usedChildIndex;

    public void OnPointerClick(PointerEventData eventData)
    {
        if (usedChildIndex)
        {
            Transform t = transform.parent;

            for (int i = 0; i < t.childCount; i++)
            {
                if (t.GetChild(i) == transform)
                {
                    n = i;
                    break;
                }
            }
        }

        LuaClient.Instance.Call(fun, n);

    }

//    public void OnPointerEnter(PointerEventData eventData)
//    {
//#if UNITY_EDITOR
//#endif
//        if (usedChildIndex)
//        {
//            Transform t = transform.parent;

//            for (int i = 0; i < t.childCount; i++)
//            {
//                if (t.GetChild(i) == transform)
//                {
//                    n = i;
//                    break;
//                }
//            }
//        }

//        LuaClient.Instance.Call(fun, n);
//    }

}
