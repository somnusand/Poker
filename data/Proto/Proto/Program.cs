using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace Proto
{
    class Program
    {
        static void Main(string[] args)
        {
            string curPath = System.IO.Directory.GetCurrentDirectory();

			while ( curPath.IndexOf("data") > 0 )
            {
                System.IO.Directory.SetCurrentDirectory("..");
                curPath = System.IO.Directory.GetCurrentDirectory();
            }

            Console.WriteLine(curPath);

            string ClientPath = "client/Assets/Lua/proto/";
            string ServerPath = "server/lib/proto/";


            // server
            List<Type> types = GetClasses("ProtoDef");

            for (int i = 0; i < types.Count; i++)
            {
                Type t = types[i];                

                Parse p = new Parse(t);

                LuaExport.ExportClient(i,ClientPath,   t.Name, p);
                ElixirExport.ExportServer(i,ServerPath, t.Name, p);    
            }

            LuaExport.ExportClientHead(ClientPath, types);
            ElixirExport.ExportServerHead(ServerPath, types);

			Console.WriteLine("export ok.");
        }

        static List<Type> GetClasses(string nameSpace)
        {
            Assembly asm = Assembly.GetExecutingAssembly();

            List<Type> classlist = new List<Type>();

            foreach (Type type in asm.GetTypes())
            {
                if (type.IsEnum) continue;

                if ( type.IsInterface
                    && (type.Namespace == nameSpace) 
                    && (type.DeclaringType == null))
                {
                    classlist.Add(type);
                }
            }

            return classlist;
        }
    }
}
