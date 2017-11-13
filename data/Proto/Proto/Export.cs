using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Proto
{
    class Export
    {
        static string fileName;
        static string output;
        static string tab;

        static public void Begin(string file)
        {
            fileName = file;
            output = "";
            tab = "";
        }

        static public void End()
        {
            FileStream fs = new FileStream(fileName, FileMode.Create);
            StreamWriter sw = new StreamWriter(fs);
            sw.Write(output);
            sw.Flush();
            sw.Close();
            fs.Close();
        }

        static public void Format(string format,params object[] ps)
        {
            string str = string.Format(format, ps);
            output += tab + str + "\n";
        }

        static public void PushTab()
        {
            tab += "\t";
        }

        static public void PopTab()
        {
            tab = tab.Substring(0, tab.Length - 1);
        }


        static public string UHead(string str)
        {
            string str1 = str.Substring(0, 1);
            string str2 = str.Substring(1, str.Length-1);

            return (str1.ToUpper() + str2);
        }

        static public string LHead(string str)
        {
            string str1 = str.Substring(0, 1);
            string str2 = str.Substring(1, str.Length - 1);

            return (str1.ToLower() + str2);
        }
    }
}
