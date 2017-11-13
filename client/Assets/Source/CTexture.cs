using UnityEngine;
using System.Collections;
using System;
using System.IO;

public class CTexture : MonoBehaviour
{
    //大图的人
    public Texture2D m_texPlayer;
    //小图的人
    private Texture2D[,] m_texPlayers;
    //当前帧
    private int m_iCurFram;
    //当前动画
    private int m_iCurAnimation;
    //限制帧的时间
    private float m_fTime = 0;

    //小图的宽和高
    public int m_iMinPicWidth = 48;
    public int m_iMinPicHeight = 64;
    //一行有多少个小图
    public int m_iMinPicRowCount = 4;
    //一列有多少个小图
    public int m_iMinPicColumnCount = 4;

    //动画控制
    //暂停
    private bool m_bStop = false;
    //一秒多少帧
    private float m_fFps = 4;

    private string m_sFps = "";

    void Start()
    {
        m_texPlayers = new Texture2D[4, 4];
        m_iCurAnimation = 0;
        m_sFps = m_fFps.ToString();
        //加载图片资源
        LoadTexture();

        for (int i = 0; i < m_iMinPicColumnCount; ++i)
        {
            for (int j = 0; j < m_iMinPicRowCount; ++j)
                DePackTexture(i, j);
        }
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.A))
        {
            m_iCurAnimation = 2;
        }
        if (Input.GetKeyDown(KeyCode.S))
        {
            m_iCurAnimation = 3;
        }
        if (Input.GetKeyDown(KeyCode.W))
        {
            m_iCurAnimation = 0;
        }
        if (Input.GetKeyDown(KeyCode.D))
        {
            m_iCurAnimation = 1;
        }
    }

    void OnGUI()
    {
        DrawAnimation(m_texPlayers, new Rect(100, 100, m_iMinPicWidth, m_iMinPicHeight));

        if (GUI.Button(new Rect(200, 20, 80, 50), "开始/暂停"))
        {
            m_bStop = m_bStop == false ? true : false;
        }

        m_sFps = GUI.TextField(new Rect(200, 80, 80, 40), m_sFps);
        if (GUI.Button(new Rect(200, 150, 50, 40), "应用"))
        {
            m_fFps = float.Parse(m_sFps);
        }
    }

    //加载图片资源
    void LoadTexture()
    {
        using (FileStream file = File.Open(Application.dataPath + "/Textures/Player.png", FileMode.Open))
        {
            using (BinaryReader reader = new BinaryReader(file))
            {
                m_texPlayer = new Texture2D(192, 256, TextureFormat.ARGB4444, false);
                m_texPlayer.LoadImage(reader.ReadBytes((int)file.Length));
            }
        }
    }

    //切图
    void DePackTexture(int i, int j)
    {
        int cur_x = i * m_iMinPicWidth;
        int cur_y = j * m_iMinPicHeight;

        Texture2D newTexture = new Texture2D(m_iMinPicWidth, m_iMinPicHeight);

        for (int m = cur_y; m < cur_y + m_iMinPicHeight; ++m)
        {
            for (int n = cur_x; n < cur_x + m_iMinPicWidth; ++n)
            {
                newTexture.SetPixel(n - cur_x, m - cur_y, m_texPlayer.GetPixel(n, m));
            }
        }
        newTexture.Apply();
        m_texPlayers[i, j] = newTexture;
    }

    void DrawAnimation(Texture[,] tex, Rect rect)
    {
        //绘制当前帧
        GUI.DrawTexture(rect, tex[m_iCurFram, m_iCurAnimation], ScaleMode.StretchToFill, true, 0.0f);
        //计算限制帧的时间
        m_fTime += Time.deltaTime;
        //超过限制帧切换贴图
        if (m_fTime >= 1.0 / m_fFps && m_bStop == false)
        {
            //帧序列切换
            m_iCurFram = ++m_iCurFram % 4;
            //限制帧清空
            m_fTime = 0;
            //超过帧动画总数从第0帧开始
            if (m_iCurFram >= tex.Length)
            {
                m_iCurFram = 0;
            }
        }
    }
}