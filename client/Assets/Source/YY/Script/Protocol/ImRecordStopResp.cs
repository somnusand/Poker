using UnityEngine;
using System.Collections;
namespace YunvaIM
{
    public class ImRecordStopResp : YunvaMsgBase
    {
        public uint time;
        public string strfilepath;
		public string ext;
		public int result;
		public string msg;
        public ImRecordStopResp(object Parser)
        {
            uint parser = (uint)Parser;

            time = YunVaImInterface.parser_get_uint32(parser, 1, 0);
            strfilepath = YunVaImInterface.IntPtrToString(YunVaImInterface.parser_get_string(parser, 2, 0));
			ext = YunVaImInterface.IntPtrToString(YunVaImInterface.parser_get_string(parser, 3, 0));
			result=YunVaImInterface.parser_get_integer(parser, 4, 0);
			msg = YunVaImInterface.IntPtrToString(YunVaImInterface.parser_get_string(parser, 5, 0));

//			ArrayList list = new ArrayList();
//			list.Add(voiceDurationTime);
//			list.Add(filePath);

            //RecordStopResp resp = new RecordStopResp(){
            //    time = voiceDurationTime,
            //    strfilepath = filePath
            //};

            YunVaImInterface.eventQueue.Enqueue(new InvokeEventClass(ProtocolEnum.IM_RECORD_STOP_RESP, this));

			YunvaLogPrint.YvDebugLog ("ImRecordStopResp", string.Format ("time:{0},strfilepath:{1},ext:{2},result:{3},msg:{4}",time,strfilepath,ext,result,msg));
        }
       
    }
}
