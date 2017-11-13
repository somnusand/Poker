using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Proto
{
    class ElixirExport : Export
    {
        public static void ExportServerHead(string path, List<Type> types)
        {
            string file = path + "proto.ex";
            Begin(file);

            Format("");
            Format("defmodule Proto do");
            PushTab();

            Format("import BaseRead, only: :functions");
            

            Format("def on_message(state,bin) do");
            PushTab();

            Format("{0}n,bin{1} = read_byte(bin)", "{", "}");
            Format("on_message(n,state,bin)");

            PopTab();
            Format("end");
            

            for (int i=0; i< types.Count; i++)
            {
                Format("def on_message({0},state,bin) do",i);
                PushTab();

                Format("Proto.{0}.on_message(state,bin)",types[i].Name);

                PopTab();
                Format("end");    
            }

            PopTab();
            Format("end");
            End();
        }

        public static void ExportServer(int modId, string path, string name, Parse p)
        {
            string file = path + "proto_" + LHead(name) + ".ex";
            Begin(file);

            Format("");
            Format("defmodule Proto.{0} do",name);

            PushTab();

            Format("import BaseWrite, only: :functions");
            Format("import BaseRead, only: :functions");

            for (int i = 0; i < p.funs.Count; i++)
            {
                TFunction f = p.funs[i];
                if (f.isClient == false)
                {
                    continue;
                }

                string paramStr = "";
                string paramStrNull = "";

                for (int j = 0; j < f.vars.Length; j++)
                {
                    if (j > 0) paramStr += ",";
                    paramStr += LHead(f.vars[j].name);

                    if (j > 0) paramStrNull += ",";
                    paramStrNull += "_";
                }

                Format("");
                Format("def {0}({1}) do", f.name, paramStr);
                PushTab();
               
                if (f.vars.Length == 0)
                    Format("send_{0}(self())", f.name);
                else
                    Format("send_{0}(self(),{1})", f.name, paramStr);

                PopTab();
                Format("end");

                Format("");


                if (f.vars.Length == 0)
                    Format("def send_{0}(nil) do", f.name);
                else
                    Format("def send_{0}(nil,{1}) do", f.name, paramStrNull);
                PushTab();
                Format(":ok");
                PopTab();
                Format("end");


                if (f.vars.Length == 0)
                    Format("def send_{0}([]) do", f.name);
                else
                    Format("def send_{0}([],{1}) do", f.name, paramStrNull);
                PushTab();
                Format(":ok");
                PopTab();
                Format("end");

                if (f.vars.Length == 0)
                    Format("def send_{0}(list) when is_list(list) do", f.name);
                else
                    Format("def send_{0}(list,{1}) when is_list(list) do", f.name, paramStr);

                PushTab();
                Format("bin = pack_{0}({1})", f.name, paramStr);
                Format("Enum.each(list,fn(pid)-> send pid,{0}:client,bin{1} end)", "{", "}");
                PopTab();
                Format("end");

                if (f.vars.Length == 0)
                    Format("def send_{0}(pid) do", f.name);
                else
                    Format("def send_{0}(pid,{1}) do", f.name, paramStr);

                PushTab();
                Format("bin = pack_{0}({1})", f.name, paramStr);
                Format("send pid,{0}:client,bin{1}", "{", "}");
                PopTab();
                Format("end");



                Format("def pack_{0}({1}) do", f.name, paramStr);
                PushTab();

                Format("bin = write_byte(<<>>,{0})", modId);
                Format("bin = write_int(bin,{0})", f.id);
                for (int j = 0; j < f.vars.Length; j++)
                {
                    TParam param = f.vars[j];

                    if (param.isArray)
                    {
                        Format("bin = write_array(bin,&write_{0}/2,{1})", param.type.name, LHead(param.name));
                    }
                    else
                    {
                        Format("bin = write_{0}(bin,{1})", param.type.name, LHead(param.name));
                    }
                }
                Format("bin");
                PopTab();
                Format("end");
            }

            for (int i = 0; i < p.types.Count; i++)
            {

                TType t = p.types[i];

                if (t.enums != null)
                {
                    for (int j = 0; j < t.enums.Length; j++)
                    {
                        Format("");
                        Format("def write_{0}(bin,:{1}) do", t.name, t.enums[j]);
                        PushTab();

                        Format("write_byte(bin,{0})",j);

                        PopTab();
                        Format("end");
                    }

                    Format("");
                    Format("def write_{0}(bin,_) do", t.name);
                    PushTab();

                    Format("write_byte(bin,-1)");

                    PopTab();
                    Format("end");
                }
                else if (t.members.Length > 0)
                {
                    Format("");
                    Format("def write_{0}(bin,obj) do", t.name);
                    PushTab();


                    for (int j = 0; j < t.members.Length; j++)
                    {
                        TParam param = t.members[j];

                        if (param.isArray)
                        {
                            Format("bin = write_array(bin,&write_{0}/2,obj.{1})", param.type.name, param.name);
                        }
                        else
                        {
                            Format("bin = write_{0}(bin,obj.{1})", param.type.name, param.name);
                        }
                    }

                    Format("bin");

                    PopTab();
                    Format("end");
                }
            }

            PopTab();



            // server 
            //

            PushTab();
            
            
            
            

            Format("");
            Format("def on_message(state,bin) do");
            PushTab();

            Format("{0}n,bin{1} = read_int(bin)", "{","}");
            Format("on_message(state,n,bin)");

            PopTab();
            Format("end");


            for (int i = 0; i < p.funs.Count; i++)
            {
                TFunction f = p.funs[i];

                if (f.isClient)
                {
                    continue;
                }

                Format("");
                if (f.vars.Length==0)
                    Format("def on_message(state,{0},_bin) do", f.id);
                else
                    Format("def on_message(state,{0},bin) do", f.id);
                PushTab();

                for (int j = 0; j < f.vars.Length; j++)
                {
                    TParam param = f.vars[j];

                    string v = "";
                    if (j == f.vars.Length - 1) v = "_";
                    

                    if (param.isArray)
                    {
                        Format("{2}{0},{4}bin{3}= read_array(bin,&read_{1}/1)", LHead(param.name), param.type.name, "{", "}", v);
                    }
                    else
                    {
                        Format("{2}{0},{4}bin{3} = read_{1}(bin)", LHead(param.name), param.type.name, "{", "}", v);
                    }
                }

                string paramStr = "";

                for (int j = 0; j < f.vars.Length; j++)
                {
                    if (j > 0) paramStr += ",";
                    paramStr += LHead(f.vars[j].name);
                }

                if (f.vars.Length == 0)
                    Format("{0}.{1}(state)", name, f.name);
                else
                    Format("{0}.{1}(state,{2})", name, f.name, paramStr);
                
                PopTab();
                Format("end");
            }

            for (int i = 0; i < p.types.Count; i++)
            {

                TType t = p.types[i];

                if (t.enums != null)
                {
                    Format("");
                    Format("def read_{0}(bin) do", t.name);
                    PushTab();

                    Format("{0}n,bin{1} = read_byte(bin)", "{", "}");
                    Format("r =");
                    Format("case n do");       
                    for (int j = 0; j < t.enums.Length; j++)
                    {                        
                        Format("{0} -> :{1}", j, t.enums[j]);                                            
                    }
                    Format("_ -> nil");
                    Format("end");
                    Format("{0}r,bin{1}", "{", "}");
                    PopTab();
                    Format("end");
                }
                else if (t.members.Length > 0)
                {
                    Format("");
                    Format("def read_{0}(bin) do", t.name);
                    PushTab();

                    for (int j = 0; j < t.members.Length; j++)
                    {
                        TParam param = t.members[j];

                        if (param.isArray)
                        {
                            Format("{2}r_{0},bin{3} = read_array(bin,&read_{1}/1)", param.name, param.type.name,"{", "}");
                        }
                        else
                        {
                            Format("{2}r_{0},bin{3} = read_{1}(bin)", param.name, param.type.name, "{", "}");
                        }
                    }





                    Format("r = %{0}", "{");
                    PushTab();
                    for (int j = 0; j < t.members.Length; j++)
                    {
                        TParam param = t.members[j];
                        Format(":{0} => r_{0},", param.name);
                    }
                    PopTab();
                    Format("{0}", "}");

                    Format("{0}r,bin{1}", "{","}");

                    PopTab();
                    Format("end");
                }
            }

            Format("");
            PopTab();

            Format("end");
            End();
        }
    }
}

