

function goPage(page) {
	var data;
	if (page == 0 ) {
		data = {
			cmd: "search_page_init",
		}
	}
	else {
		data = {
			cmd: "search_page",
			page: page,
		}
	}


	console.log(data)
	jsonMsg(data,function(ret){
		console.log(ret)
    		if ( ret.error ) {
    			$.messager.show({
				title: '消息',
				msg: ret.error
			});
    		}
    		else {
    			reloadData(ret.data,ret.page,Math.ceil(ret.count/10),ret.count)
    			setValue("pageIndex",ret.page)
    		}
	});
}

function doRefreshPage() {
	var page = getValue("pageIndex")
	goPage(page)
}

function doNextPage() {
	if ( self.page < self.pageCount ) {
		self.page = self.page + 1
		goPage(self.page)
	}
}

function doLastPage() {
	console.log( self.page )
	if ( self.page > 1 ) {
		self.page = self.page - 1
		goPage(self.page)
	}
}




function init() {
	var dg = $('#dg');

	self = {
		data: [],
		page: 1,
		pageCount: 1,
		count: 0,
	}

	dg.datagrid({columns:[[
	{field:'id',title:'id', width:30},
	{field:'type',title:'用户类型', width:30,
		formatter: function(value,row,index){
				if (value==0){
					return "代理";
				} else {
					return  "玩家";
				}
			}
	 },
	{field:'name',title:'名称', width:60},
	{field:'gold',title:'钻石', width:30},
	{field:'time',title:'时间', width:80},]]
	})
	goPage(0)
}

function reloadData(data,page,pageCount,count) {
	var dg = $('#dg');
	dg.datagrid({
	 	data: data
	});

	self.data = data

	console.log(page)
	if (page) {
		self.page = page
		self.pageCount = pageCount
		self.count = count

		setValue("pageInfo","页数:" + page + "/" + pageCount + ";共" + count + "条记录。" )
	}
}


function enableUser() {
	var row = $('#dg').datagrid('getSelected');
	if (row){
		var data = {
			cmd : "dacc_enable",
			id: row.id
		}
		jsonMsg(data,function(ret){
			console.log(ret)
			if ( ret.error ) {
				$.messager.show({
					title: '消息',
					msg: ret.error
				});
			}
			else {
				$.messager.show({
					title: '消息',
					msg: "解封成功"
				});
				for (var i = 0; i < self.data.length; i++) {
        				if (self.data[i].id == row.id) {
        					self.data[i].enable = true;
        					reloadData(self.data)
        					break;
        				}
    				}
			}
		});
	}
}

function disableUser() {
	var row = $('#dg').datagrid('getSelected');
	if (row){
		var data = {
			cmd : "dacc_disable",
			id: row.id
		}
		jsonMsg(data,function(ret){
			console.log(ret)
			if ( ret.error ) {
				$.messager.show({
					title: '消息',
					msg: ret.error
				});
			}
			else {
				$.messager.show({
					title: '消息',
					msg: "封号成功"
				});
				for (var i = 0; i < self.data.length; i++) {
        				if (self.data[i].id == row.id) {
        					self.data[i].enable = false;
        					reloadData(self.data)
        					break;
        				}
    				}
			}
		});
	}
}


function addGold() {
	var row = $('#dg').datagrid('getSelected');
	if (row){
		$('#gold_dlg').dialog('open').dialog('setTitle','充值');
//		$('#gold_dlg').form('clear');
		setValue("gold_id",row.id);
		$('#gold_type').combo('setValue',0);
		$('#gold_value').numberbox('setValue', 1);
	}
}

function charge(){

	var gold = getValue("gold_value");
	gold = parseInt(gold)
//	if (gold<=0){
//		return;
//	}

	var row = $('#dg').datagrid('getSelected');
	if (row){
		var data = {
			cmd : "dacc_charge",
			id: row.id,
			type: 0,
			gold: gold,
		}
		jsonMsg(data,function(ret){
			console.log(ret)
			$('#gold_dlg').dialog('close');
			if ( ret.error ) {
				$.messager.show({
					title: '消息',
					msg: ret.error
				});
			}
			else {
				$.messager.show({
					title: '消息',
					msg: "充值成功"
				});

				for (var i = 0; i < self.data.length; i++) {
        				if (self.data[i].id == data.id) {
        					self.data[i].gold = self.data[i].gold + data.gold;
        					reloadData(self.data)
        					break;
        				}
    				}
			}
		});
	}
}

function doSearch() {
	var data = {
		cmd: "dacc_info",
		id: getValue("playerid"),
	}

	console.log(data)
	jsonMsg(data,function(ret){
		console.log(ret)
    		if ( ret.error ) {
    			$.messager.show({
				title: '消息',
				msg: ret.error
			});
    		}
    		else {
    			reloadData([ret.data])
    		}
	});
}



function showNewUser(){
	$('#new_dlg').dialog('open').dialog('setTitle','New User');
	$('#new_dlg').form('clear');
}

function newUser(){
	var data = {
		cmd: "dacc_add",
		name: getValue("new_acc_id"),
		pwd: getValue("new_acc_pwd"),
		email:  "",
		type: 0,
	}
	console.log(data)
	jsonMsg(data,function(ret){
		$('#new_dlg').dialog('close');
		console.log(ret)
    		if ( ret.error ) {
    			$.messager.show({
				title: '消息',
				msg: ret.error
			});
    		}
    		else {
    			self.count = self.count + 1
			self.pageCount = Math.floor((self.count+9) / 10)

			setValue("pageInfo","页数:" + self.page + "/" + self.pageCount + ";共" + self.count + "条记录。" )

			if ( self.pageCount  == self.page )
			{
    				$('#dg').datagrid('appendRow',ret.data);
    			}
    		}
    	});
}



function showResetPwd() {
	var row = $('#dg').datagrid('getSelected');
	if (row){
		$('#reset_dlg').dialog('open').dialog('setTitle','重置密码');
//		$('#gold_dlg').form('clear');
		setValue("reset_name",row.name);
		setValue("reset_pwd", "123456");
	}
}

function resetPwd(){



	var row = $('#dg').datagrid('getSelected');
	if (row){
		var data = {
			cmd : "dacc_reset",
			id: row.id,
			pwd: getValue("reset_pwd")
		}
		jsonMsg(data,function(ret){
			console.log(ret)
			$('#gold_dlg').dialog('close');
			if ( ret.error ) {
				$.messager.show({
					title: '消息',
					msg: ret.error
				});
			}
			else {
				$.messager.show({
					title: '消息',
					msg: "重置成功"
				});
			}
		});
	}
}
