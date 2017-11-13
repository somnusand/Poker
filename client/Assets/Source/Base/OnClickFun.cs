using UnityEngine;
using UnityEngine.UI;
using System.Collections;
using LuaInterface;
using UnityEngine.EventSystems;

public class OnClickFun : MonoBehaviour,IPointerClickHandler
{
	public string FunName;


	public Transform[] ParamS;

    public void OnPointerClick(PointerEventData eventData)
    {
		if (FunName == null) return;
		if (FunName == ""  ) return;
		
		if ( ParamS != null && ParamS.Length > 0 )
		{
			object[] objs = new object[ParamS.Length];

			for(int i=0; i< ParamS.Length; i++)
			{

				ValueList vl = ParamS[i].gameObject.GetComponent<ValueList>();
				if ( vl != null )
				{
					objs [i] = vl.GetValue ();
					continue;
				}

				Text t = ParamS[i].gameObject.GetComponent<Text>();
				if ( t != null )
				{
                    Debug.Log(t.text);
					objs[i] = t.text;
					continue;
				}
				ToggleGroup g = ParamS[i].gameObject.GetComponent<ToggleGroup>();
				if ( g != null )
				{
					int n = -1;
					for(int j=0; j<g.transform.childCount; j++)
					{
						Toggle tg = g.transform.GetChild(j).GetComponent<Toggle>();

						if ( tg != null )
						{
							n++;
							if ( tg.isOn ) break;
						}
					}

					objs[i] = n;
					continue;
				}

				int flag = 0;
				Transform  child = ParamS[i].gameObject.transform;
				for(int j=0; j<child.childCount; j++)
				{
					Toggle tg = child.GetChild(j).GetComponent<Toggle>();

					if ( tg != null )
					{						
						if (tg.isOn) {
							flag = flag + (1 << j);
						}
					}
				}
				objs[i] = flag;
			}

			LuaClient.Instance.Call(FunName,objs);
		}
		else
		{
			LuaClient.Instance.Call(FunName);
		}
    }
}
