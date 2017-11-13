using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ProtoDef
{

	struct GoldData
	{
		int type;

		string src;
		int des;
		int gold;

		string time;
	}

    interface Account
    {
        void register(string name, string pwd);
        [IsClient()]
        void register_ok();
        [IsClient()]
        void register_fail(string error);


        void login(string name, string pwd);
       
        [IsClient()]
        void login_ok();
        [IsClient()]
        void login_fail(string error);


		void ver(int id);
		[IsClient()]
		void ver_ack(int type, string url,int[] ver);

		void get_file(byte id,int pos);
		void get_file_ok(byte id, int pos);
		[IsClient()]
		void get_file_ack(byte per,string datas);


		void send_gold(int id,int gold,bool check);
		[IsClient()]
		void send_gold_check_ok(int id, string name, int gold);
		[IsClient()]
		void send_gold_ok();
		[IsClient()]
		void send_gold_fail(string error);


		void get_gold_list(int page,int page_count);
		[IsClient()]
		void get_gold_list_ack(int count, int start_id, GoldData[] list);

    }
}
