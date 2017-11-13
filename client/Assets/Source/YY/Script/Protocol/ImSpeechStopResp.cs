using UnityEngine;
using System.Collections;
namespace YunvaIM
{
    public class ImSpeechStopResp : YunvaMsgBase
    {
        public int result;
        public string msg;
        public string text;
        public string ext;
		public string url;
        public ImSpeechStopResp(object Parser)
        {
            uint parser = (uint)Parser;
            result = YunVaImInterface.parser_get_integer(parser, 1, 0);
            msg = YunVaImInterface.IntPtrToString(YunVaImInterface.parser_get_string(parser, 2, 0));
            text = YunVaImInterface.IntPtrToString(YunVaImInterface.parser_get_string(parser, 3, 0));
            ext = YunVaImInterface.IntPtrToString(YunVaImInterface.parser_get_string(parser, 4, 0));     
			url = YunVaImInterface.IntPtrToString(YunVaImInterface.parser_get_string(parser, 5, 0));  
            YunVaImInterface.eventQueue.Enqueue(new InvokeEventClass(ProtocolEnum.IM_SPEECH_STOP_RESP, this));

			YunvaLogPrint.YvDebugLog ("ImSpeechStopResp", string.Format ("result:{0},msg:{1},text:{2},ext:{3},url:{4}",result,msg,text,ext,url));
        }
    }
}
