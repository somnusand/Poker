using UnityEngine;
using System.Collections;
using UnityEngine.EventSystems;
public class OnOverClickInt : MonoBehaviour, IPointerEnterHandler, IPointerClickHandler
{
    public string fun;
    public int n;

    public bool usedChildIndex;
    // Use this for initialization
    void Start()
    {

    }
    public void OnPointerEnter(PointerEventData eventData)
    {
#if UNITY_EDITOR
        return;
#endif
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

    public void OnPointerClick(PointerEventData eventData)
    {
#if UNITY_EDITOR

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

#endif
        return;
    }
}
