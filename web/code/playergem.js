



function init() {
	$('#startDate').datebox('setValue', getCurDate());
	$('#endDate').datebox('setValue', getCurDate());
	
	$('#dg').datagrid({columns:[[
	{field:'id',title:'玩家id', width:30},			
	{field:'time',title:'时间', width:60},		
	{field:'type',title:'类型', width:35,
		formatter: function(value,row,index){
			if (value == 4){
				return "注册赠送";
			}
			else if (value == 1){
				return  "充值";
			}
			else if (value == 3){
				return  "赠送";
			}
			else if (value == 6){
				return  "充值";
			}
			else if (value == 5){ 
				return  "消耗";
			}
			else  if (value == 7){ 
				return "系统奖励";
			}
			else {
				return "未知类型";
			}
		}
	},	
	{field:'count',title:'钻石', width:50},
	{field:'op_id',title:'操作员', width:80},
	]]});
}

function doSearch() {	
	var c = $('#startDate').datebox('calendar');
	
	var startDate = $('#startDate').datebox('getValue');	
	var endDate = $('#endDate').datebox('getValue');	

	if ( startDate == "" || endDate == "" ) {
		$.messager.show({
				title: '消息',
				msg: "请输入日期"
			});
		return;
	}
	

	var data = {
		cmd: "search_day_gem",
		id: getValue("playerid"),		
		startDate: startDate,
		endDate: endDate
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
    			$('#dg').datagrid({
				data: ret.data
			});	
    		}
	});			
	
}

