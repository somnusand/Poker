using UnityEngine;
using System.Collections;
namespace YunvaIM
{
    public class ImRecordVolumeNotify : YunvaMsgBase
    {
        public string v_ext;//扩展字段
        public int v_volume;//音量（1-100）
        public ImRecordVolumeNotify(object Parser)
        {
            uint parser = (uint)Parser;
            v_ext = YunVaImInterface.IntPtrToString(YunVaImInterface.parser_get_string(parser, 1, 0));
            v_volume = YunVaImInterface.parser_get_integer(parser, 2, 0);
			YunvaLogPrint.YvDebugLog ("ImRecordVolumeNotify", string.Format ("v_ext:{0},v_volume:{1}",v_ext,v_volume));
            YunVaImInterface.eventQueue.Enqueue(new InvokeEventClass(ProtocolEnum.IM_RECORD_VOLUME_NOTIFY, this));
        }
        
    }
}
