using UnityEngine;
using System.Collections;
using DG.Tweening;

public class CameraMove : MonoBehaviour {

	Vector3 curPos;

	// Use this for initialization
	void Start () {
		curPos = this.transform.position;
	}

	public void DoNear(float time,float dis,float waitTime)
	{
		transform.DOMove (curPos + transform.forward * dis, time);

		StartCoroutine (DelayReset (waitTime,time));
	}

	IEnumerator DelayReset(float waitTime,float time)
	{
		yield return new WaitForSeconds (waitTime);
		transform.DOMove (curPos,time);
	}



}
