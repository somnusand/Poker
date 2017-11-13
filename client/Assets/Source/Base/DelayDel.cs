using UnityEngine;
using System.Collections;

public class DelayDel : MonoBehaviour {

	public float delayTime = 3;

	// Use this for initialization
	void Start () {
		GameObject.Destroy (gameObject, delayTime);	
	}
	

}
