using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;


public class IsClient : Attribute
{
}

namespace Proto
{

    class TType
    {
        public int    id;
        public string name;
        public TParam[] members;

        public string[] enums;
    }

    class TParam
    {
        public string name;
        public TType type;
        public bool   isArray;
    }

    class TFunction
    {
        public int    id;
        public string name;

        public bool isClient;

        public TParam[] vars;
        public TParam       ret;
    }

    class Parse
    {
        public List<TType> types;
        public List<TFunction> funs;

        int maxTypeId = 10;
        int maxFunId = 0;

        public Parse(Type t)
        {
            maxTypeId = 0;
            maxFunId = 0;

            types = new List<TType>();
            funs = new List<TFunction>();

            AddBaseType(typeof(string));           
            AddBaseType(typeof(byte));
            AddBaseType(typeof(Int32));
            AddBaseType(typeof(Int16));
            AddBaseType(typeof(Int64));
            AddBaseType(typeof(float));
            AddBaseType(typeof(bool));

            MethodInfo[] infos = t.GetMethods( BindingFlags.Public
                            | BindingFlags.Instance | BindingFlags.DeclaredOnly);

            

            for (int i = 0; i < infos.Length; i++)
            {
                maxFunId++;

                MethodInfo info = infos[i];

                TFunction fun = new TFunction();

                fun.isClient = false;
                foreach (Attribute attr in info.GetCustomAttributes(true))
                {

                    IsClient isClient = attr as IsClient;
                    if (null != isClient)
                    {
                        fun.isClient = true;
                    }
                }

                fun.name = info.Name;
                fun.id = maxFunId;
                fun.ret  = GetParam(info.ReturnType);


                ParameterInfo[] ps = info.GetParameters();
                fun.vars = new TParam[ps.Length];

                for (int j = 0; j < ps.Length; j++)
                {
                    fun.vars[j] = GetParam(ps[j].ParameterType);
                    fun.vars[j].name = ps[j].Name;
                }

                funs.Add(fun);
            }
        }

        public void AddBaseType(Type t)
        {
            string typeName = t.Name;
            typeName = typeName.ToLower();

            maxTypeId++;

            TType newType = new TType();

            newType.id = maxTypeId;
            newType.name = typeName;
            newType.members = new TParam[0];

            types.Add(newType);
        }

        public TParam GetParam(Type t)
        {
            TParam p = new TParam();
            p.isArray = t.IsArray;

            string typeName = t.Name;
            if (t.IsArray)
            {
                typeName = typeName.Substring(0, typeName.Length - 2);
            }

            typeName = typeName.ToLower();

            for (int i=0; i<types.Count; i++)
            {
                if (types[i].name == typeName)
                {
                    p.type = types[i];
                    return p;
                }
            }

            maxTypeId++;           

            TType newType = new TType();

            if (t.IsArray)
            {
                Assembly a = Assembly.GetEntryAssembly();
                string name = t.FullName;
                t = a.GetType(name.Substring(0, name.Length - 2));
            }

            newType.id = maxTypeId;
            newType.name = typeName;
            newType.members = GetMenbers(t);

            if ( t.IsEnum )
            {
                MemberInfo[] m = t.GetMembers(
                    BindingFlags.Public | BindingFlags.Static);
                newType.enums = new string[m.Length];

                for (int i=0; i<m.Length; i++)
                {
                    newType.enums[i] = m[i].Name;
                }
            }

            types.Add(newType);

            p.type= newType;

            return p;
        }

        public TParam[] GetMenbers(Type t)
        {
            FieldInfo[] infos = t.GetFields(BindingFlags.NonPublic
                            | BindingFlags.Public
                            | BindingFlags.Instance | BindingFlags.DeclaredOnly);


            int count = infos.Length;

            TParam[] ret = new TParam[count];

            for (int i = 0; i < infos.Length; i++)
            {
                ret[i] = GetParam(infos[i].FieldType);
                ret[i].name = infos[i].Name;
            }

            return ret;
        }
    }
}
