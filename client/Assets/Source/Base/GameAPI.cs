using UnityEngine;
using System.Collections;
using LuaInterface;
using DG.Tweening;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class GameAPI
{

    static Transform t3d;
    static Transform t2d;

    public static void Init()
    {
        t3d = GameObject.Find("3d").transform;
        t2d = GameObject.Find("Canvas").transform;
    }

    public static int LoadInt(string key, int d)
    {
        if (PlayerPrefs.HasKey(key))
        {
            return PlayerPrefs.GetInt(key);
        }
        else
        {
            return d;
        }
    }

    public static string LoadString(string key, string d)
    {
        if (PlayerPrefs.HasKey(key))
        {
            return PlayerPrefs.GetString(key);
        }
        else
        {
            return d;
        }
    }


    public static void AnimSazhi(int n1, int n2)
    {
        Transform t = UIAPI.ShowEffect(UIAPI.gCanvas, "AnimSazhi");

        AnimImage[] ms = t.GetComponentsInChildren<AnimImage>();

        ms[0].Play(4, n1 - 1);
        ms[1].Play(4, n2 - 1);
    }


    public static void SaveInt(string key, int v)
    {
        PlayerPrefs.SetInt(key, v);
        PlayerPrefs.Save();
    }

    public static void SaveString(string key, string v)
    {
        PlayerPrefs.SetString(key, v);
        PlayerPrefs.Save();
    }


    static AudioSource audioSource;
    static AudioSource soundSource;
    static string lastMusic;
    static void InitAudio()
    {
        if (audioSource == null)
        {
            var canvasObj = GameObject.Find("main/Canvas");
            audioSource = canvasObj.AddComponent<AudioSource>();
            soundSource = canvasObj.AddComponent<AudioSource>();
        }
    }

    public static void ChangeMusicValue(int value)
    {
        if (audioSource != null)
        {
            if (audioSource.isPlaying)
            {
                audioSource.volume = value / 100.0f;
            }
        }
    }


    public static void PlayMusic(string name, int value)
    {
        InitAudio();

        audioSource.volume = value / 100.0f;


        audioSource.clip = ResTools.Load("ogg/" + name) as AudioClip;
        audioSource.loop = true;
        audioSource.Play();
    }

    public static void PauseMusic()
    {
        InitAudio();

        audioSource.Pause();
    }

    public static void StopMusic()
    {
        InitAudio();

        audioSource.Stop();
    }

    public static void PlaySound(string name, int value)
    {
        InitAudio();

        if (gPauseAllSound)
            return;

        var clip = ResTools.Load("ogg/" + name) as AudioClip;
        soundSource.PlayOneShot(clip, value / 100.0f);
    }

    public static void PlaySound(AudioClip clip)
    {
        InitAudio();

        if (gPauseAllSound)
            return;

        soundSource.PlayOneShot(clip);
    }

    static bool gPauseAllSound;
    public static void PauseAllSound(bool value)
    {

        InitAudio();

        gPauseAllSound = value;

        if (value)
        {
            audioSource.Pause();
        }
        else
        {
            audioSource.UnPause();
        }
    }


    public static void WXLogin(string param)
    {
        GameObject main = GameObject.Find("main");
        CallEvent e = main.GetComponent<CallEvent>();

        e.WXLogin(param);

    }


    public static void CallFun(string param)
    {
        GameObject main = GameObject.Find("main");
        CallEvent e = main.GetComponent<CallEvent>();

        e.CallFun(param);
    }


    public static void ShareShot(string param)
    {
        GameObject main = GameObject.Find("main");
        CallEvent e = main.GetComponent<CallEvent>();

        e.ShareShot(param);
    }


    public static void LoginSpeech(int appid, string id, string name)
    {
        GameObject main = GameObject.Find("main");
        YYVoice e = main.GetComponent<YYVoice>();
        e.Login(appid, id, name);

    }

    public static void PlaySpeech(string url)
    {
        GameObject main = GameObject.Find("main");
        YYVoice e = main.GetComponent<YYVoice>();
        e.Play(url);
    }

    public static void StartSpeech(LuaFunction endFun, float time)
    {
        GameObject main = GameObject.Find("main");
        YYVoice e = main.GetComponent<YYVoice>();
        e.StartRecord(endFun, time);
    }

    public static void StopSpeech()
    {
        GameObject main = GameObject.Find("main");
        YYVoice e = main.GetComponent<YYVoice>();
        e.StopRecord();
    }



    public static void Clear3D()
    {
        for (int i = 0; i < t3d.childCount; i++)
        {
            GameObject.Destroy(t3d.GetChild(i).gameObject);
        }
    }

    public static GameObject Create3DEx(string res, Transform t)
    {
        var r = ResTools.Load("3d/" + res);
        GameObject obj = GameObject.Instantiate(r, t) as GameObject;
        obj.transform.localPosition = Vector3.zero;
        obj.transform.localScale = Vector3.one;

        obj.name = res;
        obj.layer = t.gameObject.layer;

        Transform p = obj.transform;
        for (int i = 0; i < p.childCount; i++)
        {
            p.GetChild(i).gameObject.layer = t.gameObject.layer;
        }

        return obj;
    }

    public static GameObject Create3D(string res, Vector3 pos, Vector3 euler)
    {
        var r = ResTools.Load("3d/" + res);
        GameObject obj = GameObject.Instantiate(r, t3d) as GameObject;
        obj.transform.localPosition = pos;
        obj.transform.localEulerAngles = euler;

        obj.name = res;

        return obj;
    }

    public static GameObject Create3D(string res, Vector3 pos)
    {
        var r = ResTools.Load("3d/" + res);
        GameObject obj = GameObject.Instantiate(r, t3d) as GameObject;
        obj.transform.localPosition = pos;

        obj.name = res;

        return obj;
    }

    public static GameObject Create3D(string res)
    {
        var r = ResTools.Load("3d/" + res);
        GameObject obj = GameObject.Instantiate(r, t3d) as GameObject;
        obj.transform.localPosition = Vector3.zero;
        obj.name = res;
        return obj;
    }

    public static GameObject Create2Dimage(string res)
    {
        var r = ResTools.Load("res/" + res);
        GameObject obj = GameObject.Instantiate(r, t2d) as GameObject;
        obj.transform.localPosition = Vector3.zero;
        obj.name = res;
        return obj;

    }
    public static GameObject Set2DImage(Transform t, string res)
    {
        //Debug.Log(res);
        var r = ResTools.Load("res/" + res);
        GameObject obj = GameObject.Instantiate(r, t2d) as GameObject;
        //obj.transform.localPosition = Vector3.zero;
        //obj.name = res;
        t.GetComponent<Image>().sprite = obj.GetComponent<Image>().sprite;
        GameObject.Destroy(obj);
        return t.gameObject;
    }

    public static GameObject FindObj(string path)
    {
        return t3d.transform.FindChild(path).gameObject;
    }

    public static GameObject FindObj(GameObject obj, string path)
    {
        return obj.transform.FindChild(path).gameObject;
    }

    public static void SetPai(GameObject obj, int type, int n)
    {
        TestUV uv = obj.GetComponent<TestUV>();
        uv.SetData(type, n);
    }

    public static void AddAngles(GameObject obj, Vector3 r)
    {
        obj.transform.localEulerAngles += r;
    }

    public static void DoKill(GameObject obj)
    {
        obj.transform.DOKill();
    }

    public static void DoMove(GameObject obj, float time, Vector3 pos)
    {
        obj.transform.DOMove(pos, time);
    }

    public static void DoMove2(GameObject obj, float time, Vector3 pos)
    {
        //		Vector3[] path = new Vector3[2];
        //		path [1] = pos;
        //		path [0] = obj.transform.position + new Vector3(0,3,0) + (obj.transform.position - pos).normalized * 0.01f;
        //
        //		obj.transform.DOPath(path,time,PathType.Linear);
        obj.transform.DOJump(pos, 2, 0, time);
    }

    public static void DoJump(GameObject obj, float time, Vector3 pos, float pow)
    {
        obj.transform.DOJump(pos, pow, 0, time);
    }


    public static void DoRotate(GameObject obj, float time, Vector3 pos)
    {
        obj.transform.DORotate(pos, time);
    }

    public static void DoRotateAdd(GameObject obj, float time, Vector3 pos)
    {
        obj.transform.DORotate(pos, time, RotateMode.LocalAxisAdd);
    }

    public static void DoCameraNear(float time, float dis, float waitTime)
    {
        CameraMove c = Camera.main.transform.GetComponent<CameraMove>();
        c.DoNear(time, dis, waitTime);
    }

    public static void PlayAnim(GameObject obj, string anim)
    {
        Animation a = obj.GetComponent<Animation>();
        a.Stop();
        a.CrossFade(anim);
    }

    public static void PlayAnimIdle(GameObject obj, string anim)
    {
        Animation a = obj.GetComponent<Animation>();
        if (a.isPlaying)
            return;
        a.Play(anim);
    }

    public static void AnimSazhi3D(GameObject obj, int n1, int n2)
    {
        AnimSaiZhi a = obj.GetComponent<AnimSaiZhi>();
        a.AnimSai(n1, n2);


    }

    static public void SetColor(GameObject t, byte r, byte g, byte b)
    {
        if (t != null)
        {
            Renderer s = t.GetComponent<Renderer>();
            s.material.color = new Color32(r, g, b, (byte)255);
        }
    }


    static public bool CheckVer(int[] ver)
    {
        return ResTools.CheckVer(ver);
    }

    static public int BeginDown(int step)
    {
        return ResTools.BeginDown(step);
    }

    static public void WriteDown(byte[] datas)
    {
        ResTools.WriteDown(datas);
    }

    static public void EndDown()
    {
        ResTools.EndDown();
    }

    static public void ResetLoad()
    {
        SceneManager.LoadScene(0);
    }

    static public void UnloadRes()
    {
        Resources.UnloadUnusedAssets();
    }

    static public void EnableChildN(GameObject obj, int n)
    {
        if (obj != null)
        {
            Transform t = obj.transform;
            for (int i = 0; i < t.childCount; i++)
            {
                if (n == i)
                {
                    t.GetChild(i).gameObject.SetActive(true);
                }
                else
                {
                    t.GetChild(i).gameObject.SetActive(false);
                }
            }
        }
    }


    static public int GetPlatform()
    {
#if UNITY_ANDROID
        return 0;
#elif UNITY_IOS
		return 1;
#else
		return -1;
#endif


    }

    static public Transform GetNode(Transform t, string path)
    {
        for (int i = 0; i < t.childCount; i++)
        {
            Transform child = t.GetChild(i);
            if (child.name == path)
                return child;

            child = GetNode(child, path);
            if (child != null)
                return child;
        }

        return null;
    }

    static public Transform SetGridLayoutGroup(Transform t, int value)
    {
        GridLayoutGroup grp = t.GetComponent<GridLayoutGroup>();
        if (value == 1)
        {
            grp.enabled = true;
        }
        else
        {
            grp.enabled = false;
        }

        return null;
    }
}
