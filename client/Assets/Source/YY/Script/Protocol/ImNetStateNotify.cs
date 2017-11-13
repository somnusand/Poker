using UnityEngine;
using System;
using System.Collections;
namespace YunvaIM
{
    public class ImNetStateNotify : YunvaMsgBase
    {
        public YvNet netState;
        public ImNetStateNotify(object Parser)
        {
            uint parser = (uint)Parser;
            netState =(YvNet)YunVaImInterface.parser_get_integer(parser, 1, 0);
			YunvaLogPrint.YvDebugLog ("ImNetStateNotify", string.Format ("netState:{0}",netState));
            YunVaImInterface.eventQueue.Enqueue(new InvokeEventClass(ProtocolEnum.IM_NET_STATE_NOTIFY, this));
        }
    }
}
