using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ProtoDef
{

	enum PlayState
	{
		not_play,
		playing,
		give_up,
	}

	struct PlayInfo
	{
		public int id;
		public int gold;
		public PlayState state;
		public bool showed;
		public byte[] put_count;
	}

	enum PayType
	{
		host,
		all,
	}

	struct PlayerInfo
	{
		public string name;
		public int id;
		public byte sex;
		public string head;
		public string ip;
		public bool started;
		public bool offline;

		public int gold;

		public byte pos;
	}


	enum PutType
	{
		put_peng,
		put_gang,
		put_win,
		put_self_gang,
		put_card,
		put_pass,


		give_up,
		put_gold,
		check,

		show_card,
	}

	struct RoomParams
	{
		byte type;
		byte round_count;
		byte player_count;
		int base_score;
		int ex_param1;
		int ex_param2;
		int ex_param3;
	}


	struct PlayerCards
	{
		int id;

		byte[] cards;

		bool giveup;
		bool showed;

		int gold;
		int ex_gold;
	}


	struct HistoryScore
	{
		int id;
		string name;

		int score;
		byte[] values;
	}

	struct History
	{
		int game_id;
		string time;
		int round;
		int max_count;
		int room_id;
		HistoryScore[] data;
	}

	struct HistoryEx
	{
		int game_id;
		string time;
		int round;
		int max_count;
		int room_id;
		string[] names;
		int[] scores;
	}


	struct EndPlayerCards
	{
		byte[] cur;
		byte[] hold;
	}


	struct EndInfo
	{
		int type;
		int cur_turn;

		int[] ids;
		string[] names;
		int[] hu_scores;
		int[] cur_scores;
		int[] all_scores;

		byte[] mas;
		byte[] macards;

		EndPlayerCards[] cards;
	}

	struct Cards
	{
		byte[] datas;
	}

	struct GameData
	{
		Cards[] cards;
		int card_count;
		byte pi_card;
		byte[] steps;
	}

	struct ReplayData
	{
		PlayerInfo[] players;
		RoomParams room_params;
		int[] order;
		int game_count;
	}


	struct HuCards
	{
		byte card;
		byte[] hus;
	}

	struct TurnPlayerData {
		byte[] cards;
		int id;
		bool played;
		int score;
		int all_score;

		int[] shots;
		bool shot_all;

		byte[] daos;
	}

	struct TurnData
	{
		TurnPlayerData[] datas;

	}

    interface Room
    {
        void create_room(RoomParams p);

        [IsClient()]
        void create_ack(int room_id);
        [IsClient()]
        void create_error(string error);


		void get_room();
		[IsClient()]
		void get_room_ack(int id);

        void enter(int room_id);



        [IsClient()]
        void enter_ack(int host_id,int rounds, int round_host, PlayerInfo[] players,RoomParams p);
        [IsClient()]
        void enter_error(string error);

        [IsClient()]
        void enter_player(PlayerInfo player);
        [IsClient()]
        void quit_player(int id);
		[IsClient()]
		void offline_player(int id);
		[IsClient()]
		void online_player(int id,string ip);


		void player_ready();
		[IsClient()]
		void player_ready_ack(int id);	

        void quit();
        [IsClient()]
        void quit_room();

		[IsClient()]
		void quit_voto(float time, int[] ids);
		[IsClient()]
		void quit_voto_end(bool yes);
		[IsClient()]
		void quit_voto_time(float time);

		void quit_vote_yes();
		void quit_vote_no();

        void start();

		[IsClient()]
		void game_start_error(string err);
        [IsClient()]
        void game_start(int[] order);
		[IsClient()]
		void game_order(int[] order,History his);

		[IsClient()]
		void saizhi(int id, byte s1, byte s2);

    


        [IsClient()]
        void get_lai(int id,int card);


        [IsClient()]
        void turn(int id, int time, int pai, int[] gangs, HuCards[] hus );

        [IsClient()]
        void put_card(int id,int pai);

        [IsClient()]
        void get_pi(int id, int pai);

        [IsClient()]
        void wait_action(bool peng,bool gang,bool hu);

        [IsClient()]
        void gang(int id,int card,int count);

        [IsClient()]
        void peng(int id,int card);	

		[IsClient()]
		void score(int id, int otherId,int score);

        [IsClient()]
        void hu(int[] id,Cards[] cards);

		[IsClient()]
		void end_game(EndInfo info,History his);


		void get_history();
		[IsClient()]
		void show_history_ex(HistoryEx[] datas);
		[IsClient()]
		void show_history(History his);


		void cancel_tuoguan();
		[IsClient()]
		void tuoguan();

        void put_cmd(PutType cmd, int[] cards);




		void show_emotion(int em);
		[IsClient()]
		void show_emotion_ack(int id,int em);

		void voice(string url);
		[IsClient()]
		void voice_ack(int id, string url);

		void show_replay(int id);
		[IsClient()]
		void show_replay_ack(ReplayData data);
		[IsClient()]
		void show_replay_error(string str);

		void get_replay_data(int game_id, int index);
		[IsClient()]
		void get_replay_data_ack(int index,GameData data);


		void show_txt_msg(string str);
		[IsClient()]
		void show_txt_msg_ack(int id,string str);


		void get_user_info(int id);
		[IsClient()]
		void get_user_info_ack(int id,string name,string note,int roundCount,int winCount, int sex,string head,string code);



		void power_up();
		[IsClient()]
		void power_up_ack(int[] ids,byte[] power);



		// for max3

		[IsClient()]
		void put_gold(int id,int gold);
		[IsClient()]
		void show_card_ack(int id);
		[IsClient()]
		void show_card_value(byte[] cards);
		[IsClient()]
		void giveup_ack(int id);
		[IsClient()]
		void check_result(int id, int other,bool win);
		[IsClient()]
		void win_id(int[] id,PlayerCards[] datas);	
		[IsClient()]
		void turn_id(int id,int time,int round);
		[IsClient()]
		void play_info(int round, int base_gold, PlayInfo[] infos,byte[] cards);	
		[IsClient()]
		void end_games(History his);

		// add for 13
		void put_cards(byte[] cards,bool supper); //1-3 4-8 9-13

		[IsClient()]
		void put_cards_ok(int id);

		[IsClient()]
		void end_turn(TurnData data);

    }
}
