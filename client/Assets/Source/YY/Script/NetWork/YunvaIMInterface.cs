using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Runtime.InteropServices;
using YunvaIM;
using AOT;

namespace YunvaIM
{
    public enum CmdChannel
    {
        IM_LOGIN = 1,
        IM_FRIEND = 2,
        IM_GROUPS = 3,
        IM_CHAT = 4,
        IM_CLOUND = 5,
        IM_CHANNEL = 6,
        IM_TROOPS = 7,
		IM_LBS = 8,
        IM_TOOLS = 9,
    };
    public class InvokeEventClass
    {
        public ProtocolEnum eventType;
        public object dataObj;

        public InvokeEventClass(ProtocolEnum EventType, object DataObj)
        {

            eventType = EventType;
            dataObj = DataObj;
        }
    }
    public delegate void YvCallBack(CmdChannel type, uint cmdid, uint parser, uint context);

    [StructLayout(LayoutKind.Sequential)]
    public class YunVaImInterface : MonoSingleton<YunVaImInterface>
    {
        public override void Init()
        {
            base.Init();
            if (yvCallBack == null)
            {
                yvCallBack = new YvCallBack(CallBack);
            }
            DontDestroyOnLoad(this);
        }
        private YvCallBack yvCallBack;

		#region used by yunva callback

		public static uint yvpacket_get_nested_parser(uint parser){
			return yvpacket_get_parser_object(parser);
		}

        public static int parser_get_integer(uint parser, int cmdId, int index = 0)
        {
            return parser_get_integer(parser, (byte)cmdId, index);
        }

        public static IntPtr parser_get_string(uint parser, int cmdId, int index = 0)
        {
            return parser_get_string(parser, (byte)cmdId, index);
        }

        public static bool parser_is_empty(uint parser, int cmdId, int index = 0)
        {
            return parser_is_empty(parser, (byte)cmdId, index);
        }

        public static void parser_get_object(uint parser, int cmdId, uint obj, int index = 0)
        {
            parser_get_object(parser, (byte)cmdId, obj, index);
        }

        public static byte parser_get_uint8(uint parser, int cmdId, int index = 0)
        {
            return parser_get_uint8(parser, (byte)cmdId, index);
        }

        public static uint parser_get_uint32(uint parser, int cmdId, int index = 0)
        {
            return (uint)parser_get_integer(parser, (byte)cmdId, index);
        }

		#endregion

        public static MyQueue eventQueue = new MyQueue();

        public class MyQueue
        {

            private Queue<InvokeEventClass> myQueue;

            private object _lock;

            public MyQueue()
            {
                myQueue = new Queue<InvokeEventClass>();
                _lock = new object();
            }

            public void Enqueue(InvokeEventClass item)
            {
                lock (_lock)
                {
                    myQueue.Enqueue(item);
                }
            }

            public bool GetData(Queue<InvokeEventClass> outQ)
            {
                lock (_lock)
                {
                    int count = myQueue.Count;
                    if (count == 0)
                    {
                        return false;
                    }

                    for (int i = 0; i < count; i++)
                    {
                        InvokeEventClass obj = myQueue.Dequeue();
                        outQ.Enqueue(obj);
                    }

                    return true;
                }
            }
        }

        #region 接口调用

        public int InitSDK(uint context, uint appid, string path, bool isTest, bool oversea)
        {
            return YVIM_Init(CallBack, context, appid, path, isTest, oversea);
        }

        public void ReleaseSDK()
        {
            YVIM_Release();
        }

        public int YV_SendCmd(CmdChannel type, uint cmdid, uint parser)
        {
            return YVIM_SendCmd(type, cmdid, parser);
        }

        public uint YVpacket_get_parser()
        {
            return yvpacket_get_parser();
        }

//        private uint YVpacket_get_parser_object(uint parser)
//        {
//            return yvpacket_get_parser_object(parser);
//        }

        public void YVparser_set_object(uint parser, byte cmdId, uint value)
        {
            parser_set_object(parser, cmdId, value);
        }

        public void YVparser_set_uint8(uint parser, byte cmdId, int value)
        {
            parser_set_uint8(parser, cmdId, value);
        }

        public void YVparser_set_integer(uint parser, byte cmdId, int value)
        {
            parser_set_integer(parser, cmdId, value);
        }

        public void YVparser_set_string(uint parser, byte cmdId, string value)
        {
            parser_set_string(parser, cmdId, value);
        }

#if UNITY_ANDROID
	public void YVparser_set_string(uint parser, byte cmdId, IntPtr value)
	{
		parser_set_string (parser, cmdId, value);
	}
#elif UNITY_EDITOR_WIN
        public void YVparser_set_string(uint parser, byte cmdId, IntPtr value)
        {
            parser_set_string(parser, cmdId, value);
        }
#endif

        public void YVparser_set_buffer(uint parser, byte cmdId, IntPtr value, int len)
        {
            parser_set_buffer(parser, cmdId, value, len);
        }

//        public void YVparser_get_object(uint parser, byte cmdId, uint obj, int index)
//        {
//            parser_get_object(parser, cmdId, obj, index);
//        }
//
//        public byte YVparser_get_uint8(uint parser, byte cmdId, int index)
//        {
//            return parser_get_uint8(parser, cmdId, index);
//        }
//
//        public int YVparser_get_integer(uint parser, byte cmdId, int index)
//        {
//            return parser_get_integer(parser, cmdId, index);
//        }
//
//        public IntPtr YVparser_get_string(uint parser, byte cmdId, int index)
//        {
//            return parser_get_string(parser, cmdId, index);
//        }
//
//        public bool YVparser_is_empty(uint parser, byte cmdId, int index)
//        {
//            return parser_is_empty(parser, cmdId, index);
//        }

        #endregion

//#if UNITY_IOS
	[MonoPInvokeCallback(typeof(YvCallBack))]
//#endif
        public static void CallBack(CmdChannel type, uint cmdid, uint parser, uint context)
        {
            ArrayList list = new ArrayList();
			string tatal = type.ToString() + "; " + (ProtocolEnum)cmdid; //0x" + cmdid.ToString("x"); // + ";" + parser.ToString () + ";" + context.ToString ();
            Debug.Log("====Unity==== callback:" + tatal);
            YunvaMsgBase.GetMsg(cmdid, (object)parser);
    
        }

        public static string IntPtrToString(IntPtr intptr, bool isVR = false)
        {
            int len = 0;
            while (true)
            {
                byte ch = Marshal.ReadByte(intptr, len);
                len++;
                if (ch == 0)
                {
                    break;
                }
            }

            byte[] test = new byte[len - 1];
            Marshal.Copy(intptr, test, 0, len - 1);

//#if UNITY_EDITOR
//            if (isVR)
//            {
//                return Encoding.UTF8.GetString(test);
//            }
//            else
//            {
//                return Encoding.Default.GetString(test);
//            }
//#endif

            return Encoding.UTF8.GetString(test);
        }

//        public static string IntPtrToString2(IntPtr intPtr)
//        {
//#if UNITY_IOS
//            return Marshal.PtrToStringAnsi(intPtr);
//#elif UNITY_ANDROID
//            return Marshal.PtrToStringAnsi(intPtr);
//#else
//
//            int elementSize = 1;  //Marshal.SizeOf(typeof(char));
//            int size = 0;
//            while (true)
//            {
//                if (Marshal.ReadByte(intPtr, size * elementSize) == 0)
//                    break;
//                size++;
//            }
//            if (size == 0)
//                return "";
//            Byte[] bytes = new Byte[size];
//            Marshal.Copy(intPtr, bytes, 0, size);
//            return System.Text.Encoding.Default.GetString(bytes);
//#endif
//        }

        private Queue<InvokeEventClass> tmpQ = new Queue<InvokeEventClass>();

        void Update()
        {
            if (eventQueue.GetData(tmpQ))
            {
                while (tmpQ.Count > 0)
                {
                    InvokeEventClass obj = tmpQ.Dequeue();
                    EventListenerManager.Invoke(obj.eventType, obj.dataObj);
                }
            }
        }

        void OnApplicationQuit()
        {	
            //YunVaImSDK.instance.YunVaLogOut();
            //YunVaImInterface.instance.ReleaseSDK();
        }


#region imsdk
#if UNITY_IOS
	[DllImport("__Internal")]
#elif UNITY_ANDROID
	[DllImport("YvImSdk")]
#else
        [DllImport("LoginSDK.dll", EntryPoint = "YVIM_Init", CallingConvention = CallingConvention.Cdecl)]
#endif
        private static extern int YVIM_Init(YvCallBack callback, uint context, uint appid, string path, bool test,bool oversea);

#if UNITY_IOS
	[DllImport("__Internal")]
#elif UNITY_ANDROID
	[DllImport("YvImSdk")]
#else
        [DllImport("LoginSDK.dll", EntryPoint = "YVIM_Release", CallingConvention = CallingConvention.Cdecl)]
#endif
        private static extern void YVIM_Release();

#if UNITY_IOS
	[DllImport("__Internal")]
#elif UNITY_ANDROID
	[DllImport("YvImSdk")]
#else
        [DllImport("LoginSDK.dll", EntryPoint = "YVIM_SendCmd", CallingConvention = CallingConvention.Cdecl)]
#endif
		private static extern int YVIM_SendCmd(CmdChannel type, uint cmdid, uint parser);

        //packet
#if UNITY_IOS
	[DllImport("__Internal")]
#elif UNITY_ANDROID
	[DllImport("YvImSdk")]
#else
        [DllImport("yvpacket.dll", EntryPoint = "yvpacket_get_parser", CallingConvention = CallingConvention.Cdecl)]
#endif
		private static extern uint yvpacket_get_parser();

#if UNITY_IOS
	[DllImport("__Internal")]
#elif UNITY_ANDROID
	[DllImport("YvImSdk")]
#else
        [DllImport("yvpacket.dll", EntryPoint = "yvpacket_get_parser_object", CallingConvention = CallingConvention.Cdecl)]
#endif
		private static extern uint yvpacket_get_parser_object(uint parser);

#if UNITY_IOS
	[DllImport("__Internal")]
#elif UNITY_ANDROID
	[DllImport("YvImSdk")]
#else
        [DllImport("yvpacket.dll", EntryPoint = "parser_set_object", CallingConvention = CallingConvention.Cdecl)]
#endif
		private static extern void parser_set_object(uint parser, byte cmdId, uint value);

#if UNITY_IOS
	[DllImport("__Internal")]
#elif UNITY_ANDROID
	[DllImport("YvImSdk")]
#else
        [DllImport("yvpacket.dll", EntryPoint = "parser_set_uint8", CallingConvention = CallingConvention.Cdecl)]
#endif
		private static extern void parser_set_uint8(uint parser, byte cmdId, int value);

#if UNITY_IOS
	[DllImport("__Internal")]
#elif UNITY_ANDROID
	[DllImport("YvImSdk")]
#else
        [DllImport("yvpacket.dll", EntryPoint = "parser_set_integer", CallingConvention = CallingConvention.Cdecl)]
#endif
		private static extern void parser_set_integer(uint parser, byte cmdId, int value);

#if UNITY_IOS
	[DllImport("__Internal")]
#elif UNITY_ANDROID
	[DllImport("YvImSdk")]
#else
        [DllImport("yvpacket.dll", EntryPoint = "parser_set_string", CallingConvention = CallingConvention.Cdecl)]
#endif
		private static extern void parser_set_string(uint parser, byte cmdId, string value);

#if UNITY_ANDROID
	[DllImport("YvImSdk")]
	public static extern void parser_set_string(uint parser, byte cmdId, IntPtr value);
#elif UNITY_EDITOR_WIN
        [DllImport("yvpacket.dll", EntryPoint = "parser_set_string", CallingConvention = CallingConvention.Cdecl)]
		private static extern void parser_set_string(uint parser, byte cmdId, IntPtr value);
#endif


#if UNITY_IOS
	[DllImport("__Internal")]
#elif UNITY_ANDROID
	[DllImport("YvImSdk")]
#else
        [DllImport("yvpacket.dll", EntryPoint = "parser_set_buffer", CallingConvention = CallingConvention.Cdecl)]
#endif
		private static extern void parser_set_buffer(uint parser, byte cmdId, IntPtr value, int len);

#if UNITY_IOS
	[DllImport("__Internal")]
#elif UNITY_ANDROID
	[DllImport("YvImSdk")]
#else
        [DllImport("yvpacket.dll", EntryPoint = "parser_get_object", CallingConvention = CallingConvention.Cdecl)]
#endif
		private static extern void parser_get_object(uint parser, byte cmdId, uint obj, int index);

#if UNITY_IOS
	[DllImport("__Internal")]
#elif UNITY_ANDROID
	[DllImport("YvImSdk")]
#else
        [DllImport("yvpacket.dll", EntryPoint = "parser_get_uint8", CallingConvention = CallingConvention.Cdecl)]
#endif
		private static extern byte parser_get_uint8(uint parser, byte cmdId, int index);

#if UNITY_IOS
	[DllImport("__Internal")]
#elif UNITY_ANDROID
	[DllImport("YvImSdk")]
#else
        [DllImport("yvpacket.dll", EntryPoint = "parser_get_integer", CallingConvention = CallingConvention.Cdecl)]
#endif
		private static extern int parser_get_integer(uint parser, byte cmdId, int index);

#if UNITY_IOS
	[DllImport("__Internal")]
#elif UNITY_ANDROID
	[DllImport("YvImSdk")]
#else
        [DllImport("yvpacket.dll", EntryPoint = "parser_get_string", CallingConvention = CallingConvention.Cdecl)]
#endif
		private static extern IntPtr parser_get_string(uint parser, byte cmdId, int index);

#if UNITY_IOS
	[DllImport("__Internal")]
#elif UNITY_ANDROID
	[DllImport("YvImSdk")]
#else
        [DllImport("yvpacket.dll", EntryPoint = "parser_is_empty", CallingConvention = CallingConvention.Cdecl)]
#endif
		private static extern bool parser_is_empty(uint parser, byte cmdId, int index);
    }
#endregion
}
