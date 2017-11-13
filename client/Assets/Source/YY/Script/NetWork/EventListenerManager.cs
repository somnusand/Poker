
using System;
using UnityEngine;
using System.Collections.Generic;
using YunvaIM;

namespace YunvaIM
{
    public delegate void Callback<T>(T arg1);
    static public class EventListenerManager
    {
        private static Dictionary<ProtocolEnum, Delegate> mProtocolEventTable = new Dictionary<ProtocolEnum, Delegate>();

        public static void AddListener(ProtocolEnum protocolEnum, Callback<System.Object> kHandler)
        {
            lock (mProtocolEventTable)
            {
                if (!mProtocolEventTable.ContainsKey(protocolEnum))
                {
                    mProtocolEventTable.Add(protocolEnum, null);
                }

                mProtocolEventTable[protocolEnum] = (Callback<System.Object>)mProtocolEventTable[protocolEnum] + kHandler;
            }
        }

        public static void RemoveListener(ProtocolEnum protocolEnum, Callback<System.Object> kHandler)
        {
            lock (mProtocolEventTable)
            {
                if (mProtocolEventTable.ContainsKey(protocolEnum))
                {
                    mProtocolEventTable[protocolEnum] = (Callback<System.Object>)mProtocolEventTable[protocolEnum] - kHandler;

                    if (mProtocolEventTable[protocolEnum] == null)
                    {
                        mProtocolEventTable.Remove(protocolEnum);
                    }
                }
            }
        }

        public static void Invoke(ProtocolEnum protocolEnum, System.Object arg1)
        {
            try
            {
                Delegate kDelegate;
                if (mProtocolEventTable.TryGetValue(protocolEnum, out kDelegate))
                {
                    Callback<System.Object> kHandler = (Callback<System.Object>)kDelegate;

                    if (kHandler != null)
                    {
                        kHandler(arg1);
                    }
                }
            }
            catch (Exception ex)
            {
                Debug.LogException(ex);
            }
        }

        public static void UnInit()
        {
            mProtocolEventTable.Clear();
        }


    }
}
