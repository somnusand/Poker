
using UnityEngine;
using System.Collections;
using DG.Tweening;

public class AnimSaiZhi : MonoBehaviour {

	// Use this for initialization
	void Start () {
		//transform.GetChild(0).gameObject.SetActive(false);
		//transform.GetChild(1).gameObject.SetActive(false);
		DoRotateEnd (transform.GetChild (0));
		DoRotateEnd (transform.GetChild (1));
	}

	public void AnimSai(int n1,int n2)
	{		
		//transform.GetChild(0).gameObject.SetActive(true);
		//transform.GetChild(1).gameObject.SetActive(true);
		StartCoroutine (DelayReset (n1,n2));
	}

	IEnumerator DelayReset(int n1,int n2)
	{
		DoRotateStart (transform.GetChild (0));
		DoRotateStart (transform.GetChild (1));

		yield return new WaitForSeconds (1);

		DoRotateN (transform.GetChild (0), n1);
		DoRotateN (transform.GetChild (1), n2);

		yield return new WaitForSeconds (1);

		//transform.GetChild(0).gameObject.SetActive(false);
		//transform.GetChild(1).gameObject.SetActive(false);
	}

	void DoRotateStart(Transform t)
	{
		//t.gameObject.SetActive (true);
		SAnim s = t.GetComponent<SAnim> ();
		s.enabled = true;
	}

	void DoRotateEnd(Transform t)
	{
		//t.gameObject.SetActive (true);
		SAnim s = t.GetComponent<SAnim> ();
		s.enabled = false;
	}

	void DoRotateN(Transform t,int n)
	{
		SAnim s = t.GetComponent<SAnim> ();
		s.enabled = false;

		Vector3 r = Vector3.zero;
		switch (n) {
		case 1:
			r = new Vector3 (90, 0, 0);
			break;
		case 2:
			r = new Vector3 (180, 0, 0);
			break;
		case 3:
			r = new Vector3 (0, 0, 90);
			break;
		case 4:
			r = new Vector3 (0, 0, 270);
			break;
		case 5:
			r = new Vector3 (0, 0, 0);
			break;
		case 6:
			r = new Vector3 (270, 0, 0);
			break;
		}

		t.DORotate (r, 0.1f);
	}


	#if UNITY_EDITOR
	float time;
	// Update is called once per frame
	void Update () {
		
//		time -= Time.deltaTime;
//		if (time <= 0) {
//			AnimSai (1, 2);
//			time = 2;
//		}
	}
	#endif
}
