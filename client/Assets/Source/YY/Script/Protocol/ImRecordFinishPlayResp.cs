using UnityEngine;
using System.Collections;
namespace YunvaIM
{
    public class ImRecordFinishPlayResp : YunvaMsgBase
    {
        public uint result;
        public string describe;
        public string ext;
        public ImRecordFinishPlayResp(object Parser)
        {
            uint parser = (uint)Parser;

            result = YunVaImInterface.parser_get_uint32(parser, 1, 0);
            describe = YunVaImInterface.IntPtrToString(YunVaImInterface.parser_get_string(parser, 2, 0));
            ext = YunVaImInterface.IntPtrToString(YunVaImInterface.parser_get_string(parser, 3, 0));

//			ArrayList list = new ArrayList();
//			list.Add(play_result);
//			list.Add(description);
//			list.Add(play_ext);

            //RecordFinishPlayResp resp = new RecordFinishPlayResp() {
            //    result = (int)play_result,
            //    describe = description,
            //    ext = play_ext
            //};

            YunVaImInterface.eventQueue.Enqueue(new InvokeEventClass(ProtocolEnum.IM_RECORD_FINISHPLAY_RESP, this));

			YunvaLogPrint.YvDebugLog ("ImRecordFinishPlayResp", string.Format ("result:{0},describe:{1},ext:{2}",result,describe,ext));
        }
    }
}
