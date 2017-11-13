

function showNewUser(){
	$('#new_dlg').dialog('open').dialog('setTitle','New User');
	$('#new_dlg').form('clear');	
}

function editUser() {
	var row = $('#dg').datagrid('getSelected');
	if (row){
		$('#gold_dlg').dialog('open').dialog('setTitle','New User');
//		$('#gold_dlg').form('clear');
		setValue("gold_id",row.id);		
		$('#gold_type').combo('setValue',0);		
		$('#gold_value').numberbox('setValue', 1);
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


function newUser(){
	var data = {
		cmd: "add_daili",
		id: getValue("new_acc_id"),		
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
    			$('#dg').datagrid('appendRow',ret.data);    			
    		}
    	});
}		

function charge(){
	var t = $('#gold_type').combo('getValue');	
	console.log(t);
	
	var gold = getValue("gold_value");	
	if (!(gold>0) ){
		return; 	
	}
	
	var row = $('#dg').datagrid('getSelected');
	if (row){
		var data = {
			cmd : "charge",
			id: row.id,
			type: t,		
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
			}
		});			
	}
}

function destroyUser(){
	var row = $('#dg').datagrid('getSelected');
	if (row){
		$.messager.confirm('消息','你确定要删除这个帐号？',function(r){
			if (r){
				var data = {
				cmd: "del_daili",
				id: row.id,				
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
			    			console.log(row)
			    			var index = $('#dg').datagrid('getRowIndex',row);
			    			console.log("1111")
			    			console.log(index)
			    			$('#dg').datagrid('deleteRow',index);
			    		}
		   		});			
			}
		});
	}
}

function reloadData(data) {
	$('#dg').datagrid({
		data: data
	});
			
	$('#dg').datagrid({columns:[[
	{field:'id',title:'帐号', width:50},		
	{field:'name',title:'名字', width:50},
	{field:'regTime',title:'创建时间', width:80},
	]]});
}

function initData() {	

	console.log('InitData');
	
	var data = {
		cmd: "get_daili_datas"
	}
	jsonMsg(data,function(ret){
    		if ( ret.error ) {
    			alert(ret.error)
    		}
    		else {
    			reloadData(ret.data)
    		}
	})
}
	
	
	
initData();	

