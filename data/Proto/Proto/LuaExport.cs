using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Proto
{
    class LuaExport : Export
    {
        public static void ExportClientHead(string path, List<Type> types)
        {
            string file = path + "proto.lua";
            Begin(file);


            Format("");
            Format("local Class ={0}", "{}");          

            Format("function Class.create(net, client)");
            PushTab();
            Format("local obj ={0}", "{}");
            Format("Class.__index = Class");
            Format("setmetatable(obj, Class)");

            for (int i = 0; i < types.Count; i++)
            {
                string name = types[i].Name;               
                Format("obj.{0} = net:create_proto(\"{0}\",client)", LHead(name));
            }


            Format("return obj");

            PopTab();
            Format("end");


            Format("function Class:on_message(data)");
            PushTab();

            for (int i = 0; i < types.Count; i++)
            {
                Format("local n = string.byte(data,1)");
                Format("local mod");
                if ( i == 0 )
                {
                    Format("if (n=={0}) then",i);
                }
                else
                {
                    Format("elseif  (n=={0}) then", i);
                }

                PushTab();

                Format("mod = self.{0}", LHead(types[i].Name));

                PopTab();
            }
            Format("end");

            Format("mod:init_buff(data,2)");
            Format("mod:on_message()");
            

            PopTab();
            Format("end");


            Format("");
            Format("return Class");
            End();
        }

        public static void ExportClient(int modId, string path, string name, Parse p)
        {
            string file = path + LHead(name) + ".lua";
            Begin(file);

            Format("");
            Format("local Class =  {0}", "{}");

            for (int i = 0; i < p.funs.Count; i++)
            {
                TFunction f = p.funs[i];

                if ( f.isClient )
                {
                    continue;
                }

                string paramStr = "";

                for(int j=0; j<f.vars.Length;j++)
                {
                    if (j > 0) paramStr += ",";
                    paramStr += f.vars[j].name;
                }

                Format("");
                Format("function Class:{0}({1})",f.name,paramStr);
                PushTab();
                Format("self:begin_send()");

                Format("self:write_byte({0})", modId);
                Format("self:write_int({0})", f.id );

                for (int j = 0; j < f.vars.Length; j++)
                {
                    TParam param = f.vars[j];

                    if (param.isArray)
                    {
                        Format("self:write_array(Class.write_{0},{1})", param.type.name, param.name);
                    }
                    else
                    {
                        Format("self:write_{0}({1})", param.type.name, param.name);
                    }                    
                }
                Format("self:end_send()");
                PopTab();
                Format("end");                
            }

            for (int i = 0; i < p.types.Count; i++)
            {
               
                TType t = p.types[i];

                if (t.enums != null)
                {
                    Format("");
                    Format("function Class:write_{0}(obj)", t.name);
                    PushTab();

                    for (int j = 0; j < t.enums.Length; j++)
                    {                
                        if (j == 0)
                        {
                            Format("if obj == \"{0}\" then", t.enums[j]);
                        }
                        else
                        {
                            Format("elseif obj == \"{0}\" then", t.enums[j]);
                        }
                       
                        Format("\tself:write_byte({0})", j);
                        
                    }
                    Format("else");
                    Format("\tself:write_byte({0})", -1);
                    Format("end");

                    PopTab();
                    Format("end");
                }
                else if (t.members.Length > 0)
                {
                    Format("");
                    Format("function Class:write_{0}(obj)",t.name);
                    PushTab();                   

                    for (int j = 0; j < t.members.Length; j++)
                    {
                        TParam param = t.members[j];

                        if (param.isArray)
                        {
                            Format("self:write_array(Class.write_{0},obj.{1})", param.type.name, param.name);
                        }
                        else
                        {
                            Format("self:write_{0}(obj.{1})", param.type.name, param.name);
                        }
                    }

                    PopTab();
                    Format("end");
                }
            }

            // client 
            //

            Format("");
            Format("function Class:init()");
            PushTab();

            for (int i = 0; i < p.funs.Count; i++)
            {
                TFunction f = p.funs[i];
                if (f.isClient == false)
                {
                    continue;
                }
                Format("self[{0}] = Class.on_{1}", f.id, f.name);
            }

            //Format("setmetatable(obj,Class)");
            //Format("return obj");
            PopTab();
            Format("end");


            Format("");
            Format("function Class:on_message()");
            PushTab();

            Format("local n = self:read_int()");
            Format("self[n](self)");

            PopTab();
            Format("end");


            for (int i = 0; i < p.funs.Count; i++)
            {
                TFunction f = p.funs[i];
               
                if (f.isClient == false)
                {
                    continue;
                }

                Format("");
                Format("function Class:on_{0}()", f.name);
                PushTab();

                for (int j = 0; j < f.vars.Length; j++)
                {
                    TParam param = f.vars[j];

                    if (param.isArray)
                    {
                        Format("local {0} = self:read_array(Class.read_{1})", param.name, param.type.name);
                    }
                    else
                    {
                        Format("local {0} = self:read_{1}()", param.name, param.type.name);
                    }
                }

                string paramStr = "";

                for (int j = 0; j < f.vars.Length; j++)
                {
                    if (j > 0) paramStr += ",";
                    paramStr += f.vars[j].name;
                }

                Format("self.client:{0}_{1}({2})", LHead(name), f.name, paramStr);
                PopTab();
                Format("end");
            }

            for (int i = 0; i < p.types.Count; i++)
            {

                TType t = p.types[i];

                if (t.enums != null)
                {
                    Format("");
                    Format("function Class:read_{0}(obj)", t.name);
                    PushTab();

                    Format("local n = self:read_byte()");
                    Format("local r");

                    for (int j = 0; j < t.enums.Length; j++)
                    {
                        if ( j == 0 )
                        {
                            Format("if n == {0} then", j);
                        }
                        else
                        {
                            Format("elseif n == {0} then", j);
                        }
                       
                        Format("\tr = \"{0}\"", t.enums[j]);                        
                    }
                    Format("else");
                    Format("\tr = nil");
                    Format("end");

                    Format("return r");

                    PopTab();
                    Format("end");
                }
                else if (t.members.Length > 0)
                {
                    Format("");
                    Format("function Class:read_{0}(obj)", t.name);
                    PushTab();

                    Format("local r = {0}", "{}");

                    for (int j = 0; j < t.members.Length; j++)
                    {
                        TParam param = t.members[j];

                        if (param.isArray)
                        {
                            Format("r.{0} = self:read_array(Class.read_{1})", param.name, param.type.name);
                        }
                        else
                        {
                            Format("r.{0} = self:read_{1}()", param.name, param.type.name);
                        }
                    }

                    Format("return r");

                    PopTab();
                    Format("end");
                }
            }

            Format("");
            Format("return Class");
            End();
        }
    }
}
