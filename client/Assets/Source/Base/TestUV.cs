using UnityEngine;
using System.Collections;

public class TestUV : MonoBehaviour {

	public int nx;
	public int ny;

	public int startX;
	public int startY;

	public int invalX;
	public int invalY;
	public int width;
	public int height;



	// Use this for initialization
	void Start () {		
		
	}

	#if UNITY_EDITOR
	// Update is called once per frame
	void Update () {
		SetData (ny, nx);
	}
	#endif

	public void SetData(int type,int index)
	{
		nx = index;
		ny = type;

		Vector2 dx = new Vector2 (width / 1024.0f, height / 1024.0f);
		Vector2 off = new Vector2 (invalX / 1024.0f, invalY / 1024.0f);
		Vector2 start = new Vector2 (startX / 1024.0f, startY / 1024.0f);

		Vector2 vs = start + new Vector2(off.x*(nx-1),off.y*ny);


		MeshFilter m  = GetComponent<MeshFilter> ();

		Vector2[] new_uv = new Vector2[m.mesh.uv.Length];
		for (int i = 0; i < m.mesh.uv.Length; i++) {		

			new_uv [i] = m.mesh.uv[i];
			if (i == 56) {
				new_uv [i] = new Vector2(vs.x,1-vs.y+dx.y);
			}
			if (i == 57) {
				new_uv [i] =  new Vector2(vs.x+dx.x,1-vs.y+dx.y);
			}
			if (i == 58) {
				new_uv [i] = new Vector2(vs.x+dx.x,1-vs.y);
			}
			if (i == 59) {
				new_uv [i] = new Vector2(vs.x,1-vs.y);
			}
		}

		m.mesh.uv = new_uv;
	}
}
