using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ProtoDef
{
    struct UserInfo
    {
        public int id;
        public string name;
        public int card_count;
		public string head;
		public byte  sex;
		public string ip;
    }

    interface User
    {
        //for test only
        void enter(int id);

		void wx_login(string info);

		void wx_id_login(string id);
		[IsClient()]
		void wx_id(string id);


        [IsClient()]
        void user_info(UserInfo info);

		[IsClient()]
		void login_error(string error);

		[IsClient()]
		void change_card(int change_count);


		void heart();
		[IsClient()]
		void heart_ack();


		void get_txt(string key);
		[IsClient()]
		void get_txt_ack(string key,string data);

    }
}
