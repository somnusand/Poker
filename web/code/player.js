

function goPage(page) {
	var data = {
		cmd: "player_page",
		page: page,		
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
    			reloadData(ret.data,ret.page,ret.pageCount,ret.count)   
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
	if ( self.page > 1 ) {
		self.page = self.page - 1
		goPage(self.page)
	}
}




function init() {
	var dg = $('#dg');
			
	self = {
		data: []
	}
			
	dg.datagrid({columns:[[
	{field:'id',title:'玩家id', width:25},		
	{field:'name',title:'昵称', width:40},
	{field:'sex',title:'性别', width:20,
		formatter: function(value,row,index){			
				if (value == 1){
					return "男";
				} else {
					return  "女";
				}
			}
	},
	{field:'online',title:'是否在线', width:30,
		formatter: function(value,row,index){			
				if (value){
					return "在线";
				} else {
					return  "不在线";
				}
			}
	},
	{field:'roomId',title:'所在房间', width:30},
//	{field:'gameType',title:'所在游戏', width:30,
//		formatter: function(value,row,index){		
//				var n = value;
//				if (n>10) {
//					n = n / 10;
//				}
//				if (n==1){
//					return "炸金花";
//				} else if (n==2) {
//					return  "麻将";
//				}
//				else {
//					return "";
//				}
//			}
//	},
	{field:'enable',title:'是否封号', width:30,
		formatter: function(value,row,index){			
				if (value){
					return "正常";
				} else {
					return  "封号";
				}
			}
	 },
	{field:'gem',title:'钻石', width:30},
	//{field:'gold',title:'金币', width:30},
	{field:'regTime',title:'注册时间', width:80},]]
	})
	goPage(1)
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
		
		setValue("pageInfo","页数:" + page + "/" + pageCount + ";共" + count + "条记录。" )
	}
}


function enableUser() {
	var row = $('#dg').datagrid('getSelected');
	if (row){
		var data = {
			cmd : "enableUser",
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
			cmd : "disableUser",
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
		$('#gold_dlg').window('center');
//		$('#gold_dlg').form('clear');
		setValue("gold_id",row.id);		
		$('#gold_type').combo('setValue',0);		
		$('#gold_value').numberbox('setValue', 1);
		setValue("gold_name",row.name);		
		setValue("gold_now",row.gem);		
	}
}

function charge(){	
	
	var gold = getValue("gold_value");	
	var gem = parseInt(gold)
//	if (gold<=0){
//		return; 	
//	}
	
	var row = $('#dg').datagrid('getSelected');
	if (row){
		var data = {
			cmd : "charge",
			id: row.id,
			type: 0,		
			gold: gem,		
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
        				if (self.data[i].id == row.id) {            		
        					self.data[i].gem = self.data[i].gem + gem;      
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
		cmd: "player_info",
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