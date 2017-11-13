using UnityEngine;
using System;
using System.Collections;

namespace YunvaIM
{
    public enum ProtocolEnum:uint
    {
        #region IM_LOGIN
        IM_LOGIN_REQ = 0x11000,                 //云娃登录请求
        IM_LOGIN_RESP = 0x11001,                //云娃登录返回
        IM_THIRD_LOGIN_REQ=0x11002,             //cp账号登录请求
        IM_THIRD_LOGIN_RESP = 0x11003,          //cp账号登录返回
        IM_LOGOUT_REQ = 0x11004,                //注销
        IM_DEVICE_SETINFO=0x11012,              //设置设备信息
        IM_RECONNECTION_NOTIFY = 0x11013,       //重连成功通知
        IM_GET_THIRDBINDINFO_REQ = 0x11014,     //获取第三方账号信息
        IM_GET_THIRDBINDINFO_RESP = 0x11015,    //获取第三方信息返回
        IM_NET_STATE_NOTIFY = 0x11016 ,         //网络状态通知
        #endregion

        #region IM_TOOS
        IM_RECORD_STRART_REQ    =   0x19000,        //开始录音(最长60秒)
        IM_RECORD_STOP_REQ  =   0x19001,            //停止录音请求  回调返回录音文件路径名
        IM_RECORD_STOP_RESP =   0x19002,            //停止录音返回  回调返回录音文件路径名
        IM_RECORD_STARTPLAY_REQ =   0x19003,        //播放录音请求
        IM_RECORD_FINISHPLAY_RESP = 0x19004,        //播放语音完成
        IM_RECORD_STOPPLAY_REQ  =   0x19005,        //停止播放语音
        IM_SPEECH_START_REQ     =0x19006,           //开始语音识别
        IM_SPEECH_STOP_REQ  =0x19007,               //停止语音识别
        IM_SPEECH_STOP_RESP     =   0x19009,        //语音识别完成返回
        IM_SPEECH_SETLANGUAGE_REQ   =   0x19008,    //设置语音识别语言
        IM_UPLOAD_FILE_REQ      =   0x19010 ,       //上传文件
        IM_UPLOAD_FILE_RESP     =    0x19011 ,      //上传文件回应
        IM_DOWNLOAD_FILE_REQ=   0x19012,            //下载文件请求
        IM_DOWNLOAD_FILE_RESP=0x19013,              //下载文件回应
        IM_RECORD_SETINFO_REQ = 0x19014,            //设置录音信息
        IM_RECORD_VOLUME_NOTIFY = 0x19015,          //录音声音大小通知
		IM_RECORD_PLAY_PERCENT_NOTIFY = 0x19016,	//播放URL下载进度
		IM_TOOL_HAS_CACHE_FILE = 0x19017,			//判断URL文件是否存在
        #endregion


        #region IM_CHANNEL
        IM_CHANNEL_LOGIN_REQ = 0x16007,         //登录 注:登录账号传入了通配符，会直接登录， 不需要再调此登录
        IM_CHANNEL_LOGIN_RESP=0x16008,
        IM_CHANNEL_LOGOUT_REQ = 0x16009,        //退出频道
		IM_CHANNEL_MODIFY_REQ=0x16011,          //修改通配符
		IM_CHANNEL_MODIFY_RESP=0x16012,         //修改通配符回应
        #endregion

    };
  public  enum YvNet : int
    {
        YvNetDisconnect=0,
        YvNetConnect=1,
    };
  public   enum Yvimspeech_language
    {
        im_speech_zn = 1, //中文
        im_speech_ct = 2, //粤语
        im_speech_en = 3, //英语
    };
	public   enum yvimspeech_outlanguage
	{
		im_speechout_simplified       = 0,  //简体中文
		im_speechout_traditional      = 1,  //繁体中文
	};

	public enum yvspeech
	{
		speech_file = 0,              //文件识别
		speech_file_and_url = 1,      //文件识别返回url
		speech_url = 2,               //url识别
		speech_live = 3,              //实时语音识别(未完成)
	}
	public enum YvlogLevel
	{
		LOG_LEVEL_OFF = 0,  //0：关闭日志
		LOG_LEVEL_DEBUG = 1, //1：Debug默认该级别
		LOG_LEVEL_INFO=2,   //2:info
		LOG_LEVEL_ERROR=3   //3:error
	}
}
