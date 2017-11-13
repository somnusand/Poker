using UnityEngine;
using System;
using System.Runtime.InteropServices;
using System.Collections;
using YunvaIM;
public class YunvaMsgBase
{

    public static YunvaMsgBase GetMsg(uint CmdId, object Parser)
    {
        switch (CmdId)
        {
            case (uint)ProtocolEnum.IM_THIRD_LOGIN_RESP:
                return new ImThirdLoginResp(Parser);
            case (uint)ProtocolEnum.IM_RECORD_STOP_RESP:
                return new ImRecordStopResp(Parser);
            case (uint)ProtocolEnum.IM_SPEECH_STOP_RESP:
                return new ImSpeechStopResp(Parser);
            case (uint)ProtocolEnum.IM_RECORD_FINISHPLAY_RESP:
                return new ImRecordFinishPlayResp(Parser);
            case (uint)ProtocolEnum.IM_NET_STATE_NOTIFY:
                return new ImNetStateNotify(Parser);
            case (uint)ProtocolEnum.IM_RECORD_VOLUME_NOTIFY:
                return new ImRecordVolumeNotify(Parser);
            case (uint) ProtocolEnum.IM_RECONNECTION_NOTIFY:
                return new ImReconnectionNotify(Parser);
            case  (uint)ProtocolEnum.IM_UPLOAD_FILE_RESP:
                return new ImUploadFileResp(Parser);
            case (uint)ProtocolEnum.IM_DOWNLOAD_FILE_RESP:
                return new ImDownLoadFileResp(Parser);
			case (uint)ProtocolEnum.IM_RECORD_PLAY_PERCENT_NOTIFY:
				return new ImPlayPercentNotify(Parser);
            case (uint)ProtocolEnum.IM_GET_THIRDBINDINFO_RESP:
                return new ImGetThirdBindInfoResp(Parser);
            case (uint)ProtocolEnum.IM_CHANNEL_LOGIN_RESP:
                return new ImChannelLoginResp(Parser);
            default:
                return null;
        }
    }
}


