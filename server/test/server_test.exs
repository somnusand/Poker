require Tools


defmodule ServerTest do
  use ExUnit.Case
  doctest Server


  # test "6" do
  #
  #     assert {3, {3, 2, 1, 0, 1}} == RoomMax3.get5type(1,5,9,13,14)
  # end
  #
  # test "7" do
  #
  #     assert {9,0} == RoomMax3.get5type(1,2,3,4,5)
  # end
  #
  # test "8" do
  #
  #     assert {3, {0, 3, 2, 1, 1}} == RoomMax3.get5type(1,2,8,9,14)
  # end
  #
  # test "9" do
  #
  #     assert {8, 0 } == RoomMax3.get5type(1,2,3,9,10)
  # end
  #
  # test "10" do
  #     assert {10,{4,3,2,1,0,0}} == RoomMax3.get5type(1,5,9,13,17)
  # end
  #
  # test "11" do
  #     assert {10,{4,3,2,1,0,1}} == RoomMax3.get5type(1+1,5+1,9+1,13+1,17+1)
  # end
  #
  # test "12" do
  #     assert {10,{12,3,2,1,0,1}} == RoomMax3.get5type(1+1,5+1,9+1,13+1,49+1)
  # end
  #
  # test "13" do
  #     assert {6,{4,3,2,1,0,1}} == RoomMax3.get5type(1+1,5,9,13,18)
  # end
  #
  #
  test "gun" do
      state = RoomMax3.test_end_cards(
        false,
        [102,103,105,105,106,107,108,110,110,111,112,113,214],
        false,
        [102,103,106,105,106,107,108,111,110,111,112,113,314],
        false,
        [102,103,107,105,106,107,108,112,110,111,112,113,414],
        false,
        [102,103,108,105,106,107,108,113,110,111,112,113,114]
      )
  end
  # test "15" do
  #     state = RoomMax3.test_end_cards(
  #       true,
  #       [102,103,104,105,106,107,108,109,110,111,112,113,114],
  #       true,
  #       [102,103,104,105,106,107,108,109,110,111,112,113,114],
  #       true,
  #       [102,103,104,105,106,107,108,109,110,111,112,113,114]
  #     )
  # end
  #
  #
  # test "supper1" do
  #     cards = RoomMax3.form_test_cards(
  #       [102,103,104,105,106,107,108,109,110,111,112,113,114]
  #     )
  #     assert 26 == RoomMax3.supper_cards_value(cards)
  # end
  #
  # test "supper2" do
  #     cards = RoomMax3.form_test_cards(
  #       [102,103,104,105,106,202,203,204,205,206,109]
  #     )
  #     assert 6 == RoomMax3.supper_cards_value(cards)
  # end
  #
  # test "supper3" do
  #     cards = RoomMax3.form_test_cards(
  #       [102,103,104,202,203,204,205,206,302,303,304,305,314]
  #     )
  #     assert 6 == RoomMax3.supper_cards_value(cards)
  # end
  #
  # test "supper4" do
  #     cards = RoomMax3.form_test_cards(
  #       [102,203,104,202,203,204,205,206,302,303,304,305,314]
  #     )
  #     assert 6 == RoomMax3.supper_cards_value(cards)
  # end

  # test "supper5" do
  #     cards = RoomMax3.form_test_cards(
  #       [102,103,107,202,203,204,205,206,302,303,304,305,314]
  #     )
  #     assert 6 == RoomMax3.supper_cards_value(cards)
  # end
  # test "the truth" do
  #    r = RoomLai_1.get_win_cards(%{lai: 21},[21,22,22,25,26])
  #    Tools.log(r)
  #    true
  # end
  #
  # test "the truth1" do
  #    r = RoomXuan.get_win_cards(%{lai: 21},[21,22,22,25,26])
  #    Tools.log(r)
  #    true
  # end

  # test "the truth" do
  #   assert 1 + 1 == 2
  # end
  #
  # test "pai_1" do
  #     cards = [21,22,22,22,23,41,41,41,42,42,42,43,43,43]
  #     assert RoomLai.test_check_win(0,cards)
  # end
  #
  # test "pai_2" do
  #     cards = [63,21,42,43,44,41,41,41,42,42,42,43,43,43]
  #     assert RoomLai.test_check_win(21,cards) == false
  # end
  #
  # test "pai_3" do
  #     cards = [21,42,42,43,44,41,41,41,42,42,42,43,43,43]
  #     assert RoomLai.test_check_win(0,cards) == false
  # end
  #
  # test "pai_4" do
  #     cards = [23,23,23,41,41,46,47,48,62,63,64,65,66,67]
  #     assert RoomLai.test_check_win(0,cards)
  # end
  #
  # test "pai_5" do
  #     cards = [23,23,23,41,41,46,47,48,62,63,64,65,66,67]
  #     assert RoomLai.test_check_win(62,cards)
  # end
  #
  # test "pai_6" do
  #     cards = [23,24,24,25,25,26, 47,48,49, 61,61,61, 65,62 ]
  #     assert RoomLai.test_check_win(62,cards)
  # end
  #
  # test "pai_7" do
  #     cards = [23,24,24,25,26, 47,48,49, 61,61,61, 65,65, 62 ]
  #     assert RoomLai.test_check_win(62,cards)
  # end
  #
  # test "pai_8" do
  #     cards = [21,21,21, 22,23,24, 25,26,27, 28,29,29,29, 62 ]
  #     assert RoomLai.test_check_win(62,cards)
  # end
  #
  # test "pai_9" do
  #     cards = [21,21,21, 22,23,24, 27, 29, 48,48, 49,49,49, 62 ]
  #     assert RoomLai.test_check_win(62,cards)
  # end
  #
  # test "pai_10" do
  #     cards = [22, 23, 22, 23, 22, 23, 22, 23, 22, 23, 22, 23, 22, 22]
  #     assert RoomLai.test_check_win(62,cards)
  # end
  #
  # test "pai_11" do
  #     cards = [22, 22, 62, 25, 65, 25, 28, 68]
  #     assert RoomXuan.test_check_win(0,cards)
  # end
  #
  # test "pai_x1" do
  #     state = %{
  #         cur_player_id: 1,
  #         players: %{
  #             1 => %{
  #                 cards: [22,22,21,21,22,22,22,22,21,21,22,22],
  #                 hold_cards: []
  #             }
  #         }
  #     }
  #     RoomXuan.get_pai_x(state,1) == 12
  # end
  #
  # test "pai_x2" do
  #     state = %{
  #         cur_player_id: 1,
  #         players: %{
  #             1 => %{
  #                 cards: [22,22,21,21],
  #                 hold_cards: []
  #             }
  #         }
  #     }
  #     RoomXuan.get_pai_x(state,1) == 12
  # end
  #
  # test "ka_1" do
  #     state = %{
  #         cur_player_id: 2,
  #         cur_card: 12,
  #         history: [{0,1,27}],
  #         players: %{
  #             1 => %{
  #                 cards: [22,22,26,28],
  #                 hold_cards: []
  #             }
  #         }
  #     }
  #     assert RoomXuan.is_ka_bian(state,1)
  # end
  #
  # test "ka_2" do
  #     state = %{
  #         cur_player_id: 2,
  #         cur_card: 27,
  #         history: [{0,1,27}],
  #         players: %{
  #             1 => %{
  #                 cards: [22,22,28,29],
  #                 hold_cards: []
  #             }
  #         }
  #     }
  #     assert RoomXuan.is_ka_bian(state,1)
  # end
  #
  # test "ka_3" do
  #     state = %{
  #         cur_player_id: 1,
  #         cur_card: 27,
  #         players: %{
  #             1 => %{
  #                 cards: [22,22,25,26],
  #                 hold_cards: []
  #             }
  #         }
  #     }
  #    assert (RoomXuan.is_ka_bian(state,1) == false)
  # end
  #
  # test "ka_4" do
  #     state = %{
  #         cur_player_id: 2,
  #         cur_card: 63,
  #         history: [{0,1,63}],
  #         players: %{
  #             1 => %{
  #                 cards: [22,22,61,62,],
  #                 hold_cards: []
  #             }
  #         }
  #     }
  #     assert RoomXuan.is_ka_bian(state,1)
  # end
  #
  # test "hu_0" do
  #
  #     cards = [22,23, 41,41,41, 41,42,43, 43,44,45, 61,61 ]
  #     hu_cards = RoomXuan.test_get_hu_card(cards)
  #
  #     assert hu_cards == [21,24]
  # end
  #
  # test "hu_1" do
  #
  #
  #     cards = [26,22,23,24,25, 62,62 ]
  #     hu_cards = RoomXuan.test_get_hu_card(cards)
  #
  #     Enum.each(1..1, fn(n)->
  #         hu_cards_x = RoomXuan.test_get_hu_card(cards)
  #         #Tools.log(hu_cards_x)
  #     end)
  #
  #     assert hu_cards == [21,24,27]
  # end
  #
  # test "to_int1" do
  #     Tools.to_int("dsasdas") == 0
  # end
  #
  # test "to_int2" do
  #     Tools.to_int("12323") == 12323
  # end
  #
  # test "to_int3" do
  #     Tools.to_int("-9999") == -9999
  # end
  #
  # test "cc_history" do
  #   state = %{
  #       players: %{
  #           1 => %{name: "1",head: ""},
  #           2 => %{name: "2",head: ""},
  #           3 => %{name: "3",head: ""},
  #           4 => %{name: "4",head: ""},
  #       },
  #       id: 123456,
  #       room_id: 122,
  #       game_count: 2,
  #       game_max_count: 8,
  #       game_params: %{
  #           base_score: 1,
  #       },
  #       order_list: [1,2,3,4],
  #       results: [
  #           [
  #           %{:type => :gang, 1=>3 , 2 => -1, 3 => -1, 4 => -1  },
  #           %{:type => :an_gang, 1 => 3, 2 => -1, 3 => -1, 4 => -1,  },
  #           %{:type => :hu, 1 => 3, 2 => -3, 3 => 0, 4 => 0,  },
  #           %{:type => :self_hu, 1 => 3, 2 => -1, 3 => -1, 4 => -1,  },
  #           ],
  #           [
  #           %{:type => :gang, 1=>3 , 2 => -1, 3 => -1, 4 => -1  },
  #           %{:type => :an_gang, 1 => 3, 2 => -1, 3 => -1, 4 => -1,  },
  #           %{:type => :hu, 1 => 3, 2 => -3, 3 => 0, 4 => 0,  },
  #           %{:type => :self_hu, 1 => 3, 2 => -1, 3 => -1, 4 => -1,  },
  #           ],
  #       ]
  #   }
  #
  #   d = Room.cc_history(state)
  #   Tools.log(d)
  #   true
  # end
  #
  # test "mas" do
  #   state = %{
  #       players: %{
  #           1 => %{name: "1",head: ""},
  #           2 => %{name: "2",head: ""},
  #           3 => %{name: "3",head: ""},
  #           4 => %{name: "4",head: ""},
  #       },
  #       id: 123456,
  #       room_id: 122,
  #       game_count: 2,
  #       game_max_count: 8,
  #       order_list: [1,2,3,4],
  #       game_params: %{
  #           base_score: 1,
  #       },
  #       cards: [1,3,4,5,6,7,8,9,10,11,12],
  #       result:
  #           [
  #           %{:type => :gang, 1=>3 , 2 => -1, 3 => -1, 4 => -1  },
  #           %{:type => :an_gang, 1 => 3, 2 => -1, 3 => -1, 4 => -1,  },
  #           %{:type => :hu, 1 => 3, 2 => -3, 3 => 0, 4 => 0,  },
  #           %{:type => :self_hu, 1 => 3, 2 => -1, 3 => -1, 4 => -1,  },
  #           ],
  #
  #       results: [
  #           [
  #           %{:type => :gang, 1=>3 , 2 => -1, 3 => -1, 4 => -1  },
  #           %{:type => :an_gang, 1 => 3, 2 => -1, 3 => -1, 4 => -1,  },
  #           %{:type => :hu, 1 => 3, 2 => -3, 3 => 0, 4 => 0,  },
  #           %{:type => :self_hu, 1 => 3, 2 => -1, 3 => -1, 4 => -1,  },
  #           ],
  #           [
  #           %{:type => :gang, 1=>3 , 2 => -1, 3 => -1, 4 => -1  },
  #           %{:type => :an_gang, 1 => 3, 2 => -1, 3 => -1, 4 => -1,  },
  #           %{:type => :hu, 1 => 3, 2 => -3, 3 => 0, 4 => 0,  },
  #           %{:type => :self_hu, 1 => 3, 2 => -1, 3 => -1, 4 => -1,  },
  #           ],
  #       ]
  #   }
  #   mas = RoomXuan.get_ma(state,1,8)
  #   d = RoomXuan.mas_result(state,mas)
  #   Tools.log(mas)
  #   Tools.log(d)
  #   true
  # end
  #
  # test "mas2" do
  #   state = %{
  #       players: %{
  #           1 => %{started: true, pos: 1,name: "1",head: "",passed: false, cards: [11], hold_cards: [] },
  #           2 => %{started: true,pos: 2,name: "2",head: "",passed: false, cards: [61,62,63,22], hold_cards: [] },
  #           3 => %{started: true,pos: 3,name: "3",head: "",passed: false, cards: [11], hold_cards: [] },
  #           4 => %{started: true,pos: 4,name: "4",head: "",passed: false, cards: [11], hold_cards: [] },
  #       },
  #       id: 123456,
  #       room_id: 122,
  #       game_count: 2,
  #       game_max_count: 8,
  #       order_list: [1,2,3,4],
  #       game_params: %{
  #           base_score: 1,
  #           ex_param1: 0,
  #       },
  #       cur_card: 0,
  #       all_scores: [],
  #       pids: [],
  #       round_host_id: 1,
  #       history: [{4,:put_card,22}],
  #       cards: [21,21,21,22,23,24,24,24],
  #       cur_player_id: 4,
  #       replay: %{
  #           cards: [],
  #           card_count: 5,
  #           pi_card: 0,
  #           steps: []
  #       },
  #       result:
  #           [
  #           %{:type => :gang, 3=>3, 1=> -3  },
  #           %{:type => :an_gang, 1 => 6, 2 => -2, 3 => -2, 4 => -2 },
  #           ],
  #
  #       results: [
  #       ]
  #   }
  #   RoomXuan.end_game(state,2,false)
  #   true
  # end
  #
  # test "mas3" do
  #   state = %{
  #       players: %{
  #           1 => %{started: true, pos: 1,name: "1",head: "",passed: false, cards: [11], hold_cards: [] },
  #           2 => %{started: true,pos: 2,name: "2",head: "",passed: false,
  #               cards: [61,61,22,22,62,62,63,63,64,64,65,65,22], hold_cards: [] },
  #           3 => %{started: true,pos: 3,name: "3",head: "",passed: false, cards: [11], hold_cards: [] },
  #           4 => %{started: true,pos: 4,name: "4",head: "",passed: false, cards: [11], hold_cards: [] },
  #       },
  #       id: 123456,
  #       room_id: 122,
  #       game_count: 2,
  #       game_max_count: 8,
  #       order_list: [1,2,3,4],
  #       game_params: %{
  #           base_score: 1,
  #           ex_param1: 0,
  #       },
  #       cur_card: 0,
  #       all_scores: [],
  #       pids: [],
  #       round_host_id: 1,
  #       history: [{4,:put_card,22},{4,:put_gang,42}],
  #       cards: [21,21,21,22,23,24,24,24],
  #       cur_player_id: 4,
  #       replay: %{
  #           cards: [],
  #           card_count: 5,
  #           pi_card: 0,
  #           steps: []
  #       },
  #       result:
  #           [
  #           %{:type => :gang, 4=>3, 1=> -3  },
  #           %{:type => :an_gang, 1 => 6, 2 => -2, 3 => -2, 4 => -2 },
  #           ],
  #
  #       results: [
  #       ]
  #   }
  #   RoomXuan.end_game(state,2,true)
  #   true
  # end

end
