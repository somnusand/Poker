using UnityEngine;
using System.Collections;
using System.Collections.Generic;
namespace YunvaIM
{
    public class ImChannelLoginResp : YunvaMsgBase
    {
        public int result;
        public string msg;
        public List<string> wildCard;
        public string announcement;
        public ImChannelLoginResp(object Parser)
        {
            uint parser=(uint)Parser;
            
            wildCard=new List<string>();
            result = YunVaImInterface.parser_get_integer(parser, 1, 0);
            msg = YunVaImInterface.IntPtrToString(YunVaImInterface.parser_get_string(parser, 2, 0));
            announcement = YunVaImInterface.IntPtrToString(YunVaImInterface.parser_get_string(parser, 4, 0));
            for (int i = 0; ; i++)
            {
                if (YunVaImInterface.parser_is_empty(parser, 3, i))
                    break;

                wildCard.Add(YunVaImInterface.IntPtrToString(YunVaImInterface.parser_get_string(parser, 3, i)));
				YunvaLogPrint.YvDebugLog ("ImChannelLoginResp", string.Format ("wildCard:{0}", wildCard[i]));
            }
            
			YunvaLogPrint.YvDebugLog ("ImChannelLoginResp", string.Format ("result:{0},msg:{1},announcement:{2}",result,msg, announcement));

            YunVaImInterface.eventQueue.Enqueue(new InvokeEventClass(ProtocolEnum.IM_CHANNEL_LOGIN_RESP, this));
        }
        
    }
}
