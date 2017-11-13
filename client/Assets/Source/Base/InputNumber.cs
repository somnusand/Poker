using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class InputNumber : MonoBehaviour {

	public Transform inputNode;
	public Transform displayNode;

	public string FunName;

	int[] numbers;
	int   inputCount;

	// Use this for initialization
	void Start () {
		numbers = new int[displayNode.childCount];
		Clear();

		for (int i=0; i<inputNode.childCount; i++)
		{
			Button btn = inputNode.GetChild(i).GetComponent<Button>();
			btn.onClick.AddListener(delegate() {
				this.OnClick(btn.transform); 
			});
		}
	}

	void OnClick(Transform obj)
	{
		int n = -1;
		for (int i=0; i<inputNode.childCount; i++)
		{
			if (inputNode.GetChild(i) == obj)
			{
				n = i + 1;
				break;
			}
		}

		if ( n == -1 )
		{
		}
		else if ( n == 10 )
		{
			Clear();
		}
		else if (n == 12 )
		{
			if ( inputCount > 0 )
			{
				inputCount--;
				Transform child = displayNode.GetChild(inputCount);
				child.FindChild("Text").gameObject.SetActive(false);
			}
		}
		else
        {
            if (n == 11) n = 0;
            //if (n == 10) n = 9;

            if ( inputCount < displayNode.childCount )
			{
				Transform child = displayNode.GetChild(inputCount);
				child.FindChild("Text").gameObject.SetActive(true);

				numbers[inputCount] = n;
				Text t = child.FindChild("Text").GetComponent<Text>();
				t.text = "" + n;
				inputCount++;

				if ( inputCount >= displayNode.childCount) 
				{
					int count = 0;
					for (int i=0; i<inputCount; i++)
					{
						count = count * 10 + numbers[i];
					}

					if ( FunName != null && FunName.Length > 0 )
					{
						LuaClient.Instance.Call(FunName,count);
					}
				}
			}
		}

	}

	public void Clear()
	{
		for (int i=0; i<displayNode.childCount; i++)
		{
			displayNode.GetChild(i).FindChild("Text").gameObject.SetActive(false);
		}
		inputCount = 0;
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
