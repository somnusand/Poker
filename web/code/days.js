



function init() {
	$('#startDate').datebox('setValue', getCurDate());
	$('#endDate').datebox('setValue', getCurDate());
	
	$('#dg').datagrid({columns:[[		
		{field:'date',title:'日期', width:50},			
		{field:'game',title:'游戏局数', width:50},		
		{field:'new_count',title:'新增人数', width:50,},
		{field:'act_count',title:'活跃人数', width:50},	
		{field:'gem',title:'充值总数', width:50},
		{field:'gold',title:'消耗总数', width:50},
		{field:'gem_people',title:'充值人数', width:50},
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
		cmd: "search_day_info",
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

