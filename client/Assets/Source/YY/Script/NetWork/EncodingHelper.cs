using UnityEngine;
using System.Collections;
using System;
using System.Runtime.InteropServices;
using System.Collections.Generic;
using System.Text;
using YunvaIM;
public class EncodingHelper : MonoSingleton<EncodingHelper> {

	List<IntPtr> mMemList = new List<IntPtr>();
	
	public void clearMems()
	{
		foreach (IntPtr ptr in mMemList)
		{
			Marshal.FreeHGlobal(ptr);
		}
		
		mMemList.Clear();
	}

	private IntPtr string2encoding(string text, Encoding coding){
		IntPtr retPtr;
		
		if (text == null)
			text = "";
		
		
		byte[] utf8bytes = coding.GetBytes(text);
		byte[] ext = new byte[utf8bytes.Length + 1];
		for (int i = 0; i < utf8bytes.Length; i++)
		{
			ext[i] = utf8bytes[i];
		}
		
		ext[utf8bytes.Length] = 0;
		
		retPtr = Marshal.AllocHGlobal(utf8bytes.Length + 1);
		Marshal.Copy(ext, 0, retPtr, ext.Length);
		
		mMemList.Add(retPtr);
		
		return retPtr;
	}

	public IntPtr string2utf8(string text)
	{
		return string2encoding(text, Encoding.UTF8);
	}

	public IntPtr string2default(string text){
//		IntPtr retPtr = Marshal.StringToHGlobalAnsi(text);
//		mMemList.Add(retPtr);
		IntPtr retPtr = string2encoding(text, Encoding.Default);
		return retPtr;
	}

	void OnApplicationQuit(){
		EncodingHelper.instance.clearMems();
	}
}
