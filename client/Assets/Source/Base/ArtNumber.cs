using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class ArtNumber : MonoBehaviour {

	public ImageList res;

	public Image[] imgs;


	public void SetNumber(int n)
	{
		for (int i = 0; i < imgs.Length; i++) {
			int value = n % 10;
			if (value == 0 && i == imgs.Length-1) {
				imgs [i].enabled = false;
				break;
			}
			imgs[i].sprite = res.items [value];
			n = n / 10;
		}
	}

	public void SetNumber2(int n)
	{
		if (n < 10) {
			imgs [0].enabled = true;
			imgs [1].enabled = false;
			imgs[0].sprite = res.items [n];
		} else {
			imgs [0].enabled = true;
			imgs [1].enabled = true;
			imgs[0].sprite = res.items [n/10];
			imgs[1].sprite = res.items [n%10];
		}
	}

}
