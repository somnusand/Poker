using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Runtime.InteropServices;
using YunvaIM;
namespace YunvaIM
{
    public class YunVaImSDK : MonoSingleton<YunVaImSDK>
    {
        #region 事件监听
        public override void Init() 
        {
            DontDestroyOnLoad(this);

            #region IM_LOGIN
            EventListenerManager.AddListener(ProtocolEnum.IM_THIRD_LOGIN_RESP, CPLoginResponse);
            #endregion

            #region IM_TOOL
            EventListenerManager.AddListener(ProtocolEnum.IM_RECORD_STOP_RESP, RecordStopRespInfo);
            EventListenerManager.AddListener(ProtocolEnum.IM_RECORD_FINISHPLAY_RESP, RecordFinishPlayRespInfo);
            EventListenerManager.AddListener(ProtocolEnum.IM_SPEECH_STOP_RESP, RecordRecognizeRespInfo);
            EventListenerManager.AddListener(ProtocolEnum.IM_UPLOAD_FILE_RESP, UploadFileRespInfo);
            EventListenerManager.AddListener(ProtocolEnum.IM_DOWNLOAD_FILE_RESP, DownLoadFileRespInfo);
            #endregion
        }
        #endregion
        #region 初始化SDK
        /// <summary>
        /// 初始化
        /// </summary>
		/// <returns>返回 0表示成功，-1表示失败 .</returns>
		/// <param name="context">回调上下文.</param>
        /// <param name="appid">Appid.</param>
		/// <param name="path">保存数据库文件，提供路径.</param>
		/// <param name="isTest">If set to <c>是否为测试环境，true为测试环境</c> is test.</param>
        public int YunVa_Init(uint context, uint appid, string path, bool isTest, bool oversea=false)
        {
            YunvaLogPrint.YvDebugLog("YunVa_Init", string.Format("context:{0},appid:{1},path:{2},isTest:{3},oversea:{4}", context, appid, path, isTest, oversea));
            return YunVaImInterface.instance.InitSDK(context, appid, path, isTest, oversea);
		}
        #endregion

        #region 登录
        public  System.Action  ActionReLoginSuccess;
       
        private  System.Action<ImThirdLoginResp>  ActionLoginResponse;
        
        /// <summary>
        /// 云娃登录（第三方登录方式）CP接入推荐用这种方式
        /// </summary>
        /// <param name="tt"></param>
        /// <param name="gameServerID">服务器ID</param>
        /// <param name="wildCard"></param>
        /// <param name="readStatus"></param>
        /// <param name="Response"></param>   
       
        public void YunVaOnLogin(string tt, string gameServerID, string[] wildCard, int readStatus,  System.Action<ImThirdLoginResp> Response)
        {
			YunvaLogPrint.YvDebugLog ("YunVaOnLogin", string.Format ("tt:{0},gameServerID:{1},readStatus:{2},1", tt, gameServerID, readStatus));
             ActionLoginResponse = Response;

            uint parser = YunVaImInterface.instance.YVpacket_get_parser();
            YunVaImInterface.instance.YVparser_set_string(parser, 1, tt);
            YunVaImInterface.instance.YVparser_set_string(parser, 2, gameServerID);            
            for (int i = 0; i < wildCard.Length;i++ )
            {
				YunvaLogPrint.YvDebugLog("YunVaOnLogin",string.Format("wildCard-{0}:{1}",i,wildCard[i]));
                YunVaImInterface.instance.YVparser_set_string(parser, 3, wildCard[i]);
            }
            YunVaImInterface.instance.YVparser_set_uint8(parser, 4, readStatus);
            YunVaImInterface.instance.YV_SendCmd(CmdChannel.IM_LOGIN, (uint)ProtocolEnum.IM_THIRD_LOGIN_REQ, parser);           
        }

        /// <summary>
        /// 登出帐号
        /// </summary>
        public void YunVaLogOut()
        {
			YunvaLogPrint.YvDebugLog ("YunVaLogOut", "YunVaLogOut...");
            uint parser = YunVaImInterface.instance.YVpacket_get_parser();
            YunVaImInterface.instance.YV_SendCmd(CmdChannel.IM_LOGIN, (uint)ProtocolEnum.IM_LOGOUT_REQ, parser);
        }
     
        private void CPLoginResponse(object data)
        {
           
            if (data is ImThirdLoginResp)
            {
               
                ImThirdLoginResp dataResp = new ImThirdLoginResp();
                if ( ActionLoginResponse != null)
                {  
                     ActionLoginResponse((ImThirdLoginResp)data);
                     ActionLoginResponse = null;
                }
            }
        }
        
        private void ReLoginNotify(object data)
        {
            if( ActionReLoginSuccess!=null)
            {
                 ActionReLoginSuccess();
            }
        }

        #endregion

        #region 工具
		public  System.Action<bool> RecordingCallBack;//录音回调
        /// <summary>
        /// 开始录音（最长60秒）
        /// </summary>
        /// <param name="filePath"></param>
        /// <param name="ext"></param>
        public int RecordStartRequest(string filePath, int speech=0, string ext = "")
        {
            YunvaLogPrint.YvDebugLog("RecordStartRequest", string.Format("filePath:{0},speech:{1},ext:{2}", filePath, speech, ext));
			if(RecordingCallBack!=null)
				RecordingCallBack(true);
            uint parser = YunVaImInterface.instance.YVpacket_get_parser();
            YunVaImInterface.instance.YVparser_set_string(parser, 1, filePath);
            YunVaImInterface.instance.YVparser_set_string(parser, 2, ext);
            YunVaImInterface.instance.YVparser_set_integer(parser, 3, speech);
            int ret = YunVaImInterface.instance.YV_SendCmd(CmdChannel.IM_TOOLS, (uint)ProtocolEnum.IM_RECORD_STRART_REQ, parser);
            Debug.Log("RecordStartRequest ret=" + ret);
            return ret;
        }

        private  System.Action<ImRecordStopResp>  ActionRecordStopResponse;
        /// <summary>
        /// 停止录音请求  回调返回录音文件路径名
        /// </summary>
        /// <param name="Response">返回的回调</param>
        public void RecordStopRequest(System.Action<ImRecordStopResp> StopResponse, System.Action<ImUploadFileResp> UploadResp=null,System.Action<ImSpeechStopResp> SpeechResp=null)
        {
			YunvaLogPrint.YvDebugLog ("RecordStopRequest", "RecordStopRequest...");
			if(RecordingCallBack!=null)
				RecordingCallBack(false);
            ActionRecordStopResponse = StopResponse;
            ActionUploadFileResp = UploadResp;
            ActionRecognizeResp = SpeechResp;
            uint parser = YunVaImInterface.instance.YVpacket_get_parser();
            YunVaImInterface.instance.YV_SendCmd(CmdChannel.IM_TOOLS, (uint)ProtocolEnum.IM_RECORD_STOP_REQ, parser);
        }

        private void RecordStopRespInfo(object data)
        {
            if (data is ImRecordStopResp)
            {
                if( ActionRecordStopResponse!=null)
                {
                     ActionRecordStopResponse((ImRecordStopResp)data);
                     ActionRecordStopResponse = null;
                }
            }
        }
        private Dictionary<string,  System.Action<ImRecordFinishPlayResp>> RecordFinishPlayRespMapping = new Dictionary<string,  System.Action<ImRecordFinishPlayResp>>();
        /// <summary>
        /// 播放录音请求
        /// </summary>
        /// <param name="url">录音的url路径</param>
        /// <param name="Response">回调方法</param>
        /// <param name="filePath">录音文件路径  （可以不必两者都传 但至少要传入一个）</param>
        /// <param name="ext">扩展标记</param>
        public int RecordStartPlayRequest(string filePath, string url, string ext,  System.Action<ImRecordFinishPlayResp> Response)
        {
			YunvaLogPrint.YvDebugLog ("RecordStartPlayRequest", string.Format ("filePath:{0},url:{1},ext:{2}", filePath, url,ext));
			if(!RecordFinishPlayRespMapping.ContainsKey(ext)){
				RecordFinishPlayRespMapping.Add(ext, Response);
			}

            uint parser = YunVaImInterface.instance.YVpacket_get_parser();
			if(!string.IsNullOrEmpty(url)){
				YunVaImInterface.instance.YVparser_set_string(parser, 1, url);
			}

			if(!string.IsNullOrEmpty(filePath)){
				YunVaImInterface.instance.YVparser_set_string(parser, 2, filePath);
			}
			else{
				Debug.Log(string.Format("{0}: is url voice", url));
				YunVaImInterface.instance.YVparser_set_string(parser, 2, "");
			}

			YunVaImInterface.instance.YVparser_set_string(parser, 3, ext);
           	return YunVaImInterface.instance.YV_SendCmd(CmdChannel.IM_TOOLS, (uint)ProtocolEnum.IM_RECORD_STARTPLAY_REQ, parser);
        }

        private void RecordFinishPlayRespInfo(object data)
        {
            if (data is ImRecordFinishPlayResp)
            {
                ImRecordFinishPlayResp reData = (ImRecordFinishPlayResp)data;
				string key = reData.ext;
                 System.Action<ImRecordFinishPlayResp> callback;
				if(RecordFinishPlayRespMapping.TryGetValue(key, out callback)){
					if(callback != null){
						callback(reData);
					}

					RecordFinishPlayRespMapping.Remove(key);
				}
				else{
					Debug.LogError (key + ": callback not found");
				}
            }
        }

        /// <summary>
        /// 停止播放语音
        /// </summary>
        public void RecordStopPlayRequest()
        {
			YunvaLogPrint.YvDebugLog ("RecordStopPlayRequest","RecordStopPlayRequest...");
            uint parser = YunVaImInterface.instance.YVpacket_get_parser();
            YunVaImInterface.instance.YV_SendCmd(CmdChannel.IM_TOOLS, (uint)ProtocolEnum.IM_RECORD_STOPPLAY_REQ, parser);
        }

        //private Dictionary<string,  System.Action<ImSpeechStopResp>> RecognizeRespMapping = new Dictionary<string,  System.Action<ImSpeechStopResp>>();
        System.Action<ImSpeechStopResp> ActionRecognizeResp;
        /// <summary>
        /// 开始语音识别
        /// </summary>
        /// <param name="filePath"></param>
        /// <param name="Response"></param>
        /// <param name="ext"></param>

		public void SpeechStartRequest(string filePath, string ext, System.Action<ImSpeechStopResp> Response,int type=(int)yvspeech.speech_file,string url="")
        {
			YunvaLogPrint.YvDebugLog ("SpeechStartRequest", string.Format ("filePath:{0},ext:{1},type:{2},url:{3}", filePath, ext,type,url));
			//string ext = DateTime.Now.ToFileTime().ToString();
			//RecognizeRespMapping.Add(ext, Response);
            ActionRecognizeResp = Response;
            uint parser = YunVaImInterface.instance.YVpacket_get_parser();
            YunVaImInterface.instance.YVparser_set_string(parser, 1, filePath);
            YunVaImInterface.instance.YVparser_set_string(parser, 2, ext);
			YunVaImInterface.instance.YVparser_set_integer(parser, 3, type);
			YunVaImInterface.instance.YVparser_set_string(parser, 4, url);
            YunVaImInterface.instance.YV_SendCmd(CmdChannel.IM_TOOLS, (uint)ProtocolEnum.IM_SPEECH_START_REQ, parser);
        }
        private void RecordRecognizeRespInfo(object data)
        {
            if (data is ImSpeechStopResp)
            {
                if (ActionRecognizeResp != null)
                {
                    ActionRecognizeResp((ImSpeechStopResp)data);
                    ActionRecognizeResp = null;
                }
                /*
				Debug.Log("record recognize...");
                ImSpeechStopResp reData = (ImSpeechStopResp)data;
				string key = reData.ext;
                 System.Action<ImSpeechStopResp> callback;
				if(RecognizeRespMapping.TryGetValue(key, out callback)){
					if(callback != null){
						callback(reData);
					}
					RecognizeRespMapping.Remove(key);
				}
                 * */
            }
        }

        /// <summary>
        /// 设置语音识别语言
        /// </summary>
        /// <param name="langueage"></param>
		public void SpeechSetLanguage(Yvimspeech_language langueage=Yvimspeech_language.im_speech_zn,yvimspeech_outlanguage outlanguage=yvimspeech_outlanguage.im_speechout_simplified)
		{
			YunvaLogPrint.YvDebugLog ("SpeechSetLanguage", string.Format ("langueage:{0},outlanguage:{1}", langueage, outlanguage));
			uint parser = YunVaImInterface.instance.YVpacket_get_parser();
			YunVaImInterface.instance.YVparser_set_integer(parser, 1, (int)langueage);
			YunVaImInterface.instance.YVparser_set_integer(parser, 2, (int)outlanguage);
			YunVaImInterface.instance.YV_SendCmd(CmdChannel.IM_TOOLS, (uint)ProtocolEnum.IM_SPEECH_SETLANGUAGE_REQ, parser);
		}
        private  System.Action<ImUploadFileResp>  ActionUploadFileResp;
        /// <summary>
        /// 上传文件
        /// </summary>
        /// <param name="filePath"></param>
        /// <param name="Response"></param>
        /// <param name="fileId"></param>
		public void UploadFileRequest(string filePath,string fileId,  System.Action<ImUploadFileResp> Response)
        {
			YunvaLogPrint.YvDebugLog ("UploadFileRequest", string.Format ("filePath:{0},fileId:{1}", filePath, fileId));
            ActionUploadFileResp = Response;
            uint parser = YunVaImInterface.instance.YVpacket_get_parser();
            YunVaImInterface.instance.YVparser_set_string(parser, 1, filePath);
            YunVaImInterface.instance.YVparser_set_string(parser, 2, fileId);
            YunVaImInterface.instance.YV_SendCmd(CmdChannel.IM_TOOLS, (uint)ProtocolEnum.IM_UPLOAD_FILE_REQ, parser);
        }
        private void UploadFileRespInfo(object data)
        {
            if (data is ImUploadFileResp)
            {
                if (ActionUploadFileResp != null)
                {
                     ActionUploadFileResp((ImUploadFileResp)data);
                     ActionUploadFileResp = null;
                    
                }
            }
        }

        private  System.Action<ImDownLoadFileResp>  ActionDownLoadFileResp;
        /// <summary>
        /// 下载文件请求
        /// </summary>
        /// <param name="url"></param>
        /// <param name="Response"></param>
        /// <param name="filePath"></param>
        /// <param name="fileid"></param>
        public void DownLoadFileRequest(string url, string filePath, string fileid,  System.Action<ImDownLoadFileResp> Response)
        {
			YunvaLogPrint.YvDebugLog ("DownLoadFileRequest", string.Format ("url:{0},filePath:{1},fileid:{2}",url,filePath, fileid));
            ActionDownLoadFileResp = Response;
            uint parser = YunVaImInterface.instance.YVpacket_get_parser();
            YunVaImInterface.instance.YVparser_set_string(parser, 1, url);
            YunVaImInterface.instance.YVparser_set_string(parser, 2, filePath);
            YunVaImInterface.instance.YVparser_set_string(parser, 3, fileid);
            YunVaImInterface.instance.YV_SendCmd(CmdChannel.IM_TOOLS, (uint)ProtocolEnum.IM_DOWNLOAD_FILE_REQ, parser);
        }
        private void DownLoadFileRespInfo(object data)
        {
            if (data is ImDownLoadFileResp)
            {
                if( ActionDownLoadFileResp!=null)
                {
                     ActionDownLoadFileResp((ImDownLoadFileResp)data);
                     ActionDownLoadFileResp = null;
                }
            }
        }
        //
        /// <summary>
        /// 设置音量信息。
        /// </summary>
        /// <param name="length">声音长度</param>
        /// <param name="isVolume">true为返回音量，false不返回音量</param>
         public void RecordSetInfoReq(bool isVolume=false)
        {
			YunvaLogPrint.YvDebugLog ("RecordSetInfoReq", string.Format ("isVolume:{0}",isVolume));
            RecordSetInfoReq(isVolume,60);
        }
        
        public void RecordSetInfoReq(bool isVolume,int length)
        {
			YunvaLogPrint.YvDebugLog ("RecordSetInfoReq", string.Format ("isVolume:{0},length:{1}",isVolume,length));
            uint parser = YunVaImInterface.instance.YVpacket_get_parser();
            if(isVolume)
            { 
                YunVaImInterface.instance.YVparser_set_integer(parser, 1, length);
                YunVaImInterface.instance.YVparser_set_integer(parser, 2, 1);
            }
            else
            {
                YunVaImInterface.instance.YVparser_set_integer(parser, 1, length);
                YunVaImInterface.instance.YVparser_set_integer(parser, 2, 0);
            }
            YunVaImInterface.instance.YV_SendCmd(CmdChannel.IM_TOOLS, (uint)ProtocolEnum.IM_RECORD_SETINFO_REQ, parser);
        }

		public bool CheckCacheFile(string url){
			YunvaLogPrint.YvDebugLog ("CheckCacheFile", string.Format ("url:{0}",url));
			uint parser = YunVaImInterface.instance.YVpacket_get_parser();
			YunVaImInterface.instance.YVparser_set_string(parser, 1, url);
			int ret = YunVaImInterface.instance.YV_SendCmd(CmdChannel.IM_TOOLS, (uint)ProtocolEnum.IM_TOOL_HAS_CACHE_FILE, parser);
			return ret == 0;
		}
        #endregion

        /// <summary>
        /// 是否打印日志
        /// </summary>
        /// <param name="logLevel">LOG_LEVEL_OFF = 0,  //0：关闭日志,LOG_LEVEL_DEBUG = 1 //1：Debug默认该级别</param>
        public void YvLog_setLogLevel(int logLevel = (int)YvlogLevel.LOG_LEVEL_DEBUG)
        {
            YunvaLogPrint.YvLog_setLogLevel(logLevel);
        }
    }
}
