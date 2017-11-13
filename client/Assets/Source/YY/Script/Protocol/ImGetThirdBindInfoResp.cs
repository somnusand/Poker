using UnityEngine;
using System.Collections;
using YunvaIM;
namespace YunvaIM
{
    public class ImGetThirdBindInfoResp : YunvaMsgBase
    {
        public int result;
        public string msg;
        public int yunvaId;
        public string nickName;
        public string iconUrl;
        public string level;
        public string vip;
        public string ext;
        public ImGetThirdBindInfoResp(object Parser)
        {
            uint parser =(uint)Parser;
            result = YunVaImInterface.parser_get_integer(parser, 1, 0);
            msg = YunVaImInterface.IntPtrToString(YunVaImInterface.parser_get_string(parser, 2, 0));
            yunvaId = YunVaImInterface.parser_get_integer(parser, 3, 0);
            nickName = YunVaImInterface.IntPtrToString(YunVaImInterface.parser_get_string(parser, 4, 0));
            iconUrl = YunVaImInterface.IntPtrToString(YunVaImInterface.parser_get_string(parser, 5, 0));
            level=YunVaImInterface.IntPtrToString(YunVaImInterface.parser_get_string(parser, 6, 0));
            vip=YunVaImInterface.IntPtrToString(YunVaImInterface.parser_get_string(parser, 7, 0));
            ext=YunVaImInterface.IntPtrToString(YunVaImInterface.parser_get_string(parser, 8, 0));
            YunVaImInterface.eventQueue.Enqueue(new InvokeEventClass(ProtocolEnum.IM_GET_THIRDBINDINFO_RESP, this));

			YunvaLogPrint.YvDebugLog ("ImGetThirdBindInfoResp", string.Format ("result:{0},msg:{1},yunvaId:{2},nickName:{3},iconUrl:{4},level,{5},vip:{6},ext:{7}",result,msg,yunvaId,nickName,iconUrl,level,vip,ext));
        }
    }
}
