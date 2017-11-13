


function showNewUser(){
	$('#new_dlg').dialog('open').dialog('setTitle','New User');
	$('#new_dlg').form('clear');
}

function newUser(){

	var op = $('#new_acc_op').combobox('getValue');

	//console.log(op)

	var data = {
		cmd: "add_acc",
		name: getValue("new_acc_id"),
		pwd: getValue("new_acc_pwd"),
		op:  op,
		email:  getValue("new_acc_email"),
	}
	//console.log(data)
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

function destroyUser(){
	var row = $('#dg').datagrid('getSelected');
	if (row){
		$.messager.confirm('消息','你确定要删除这个帐号？',function(r){
			if (r){
				var data = {
				cmd: "del_acc",
				name: row.name,
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
	{field:'name',title:'帐号', width:50},
	{field:'op',title:'User', width:50,
		formatter: function(value,row,index){
			if (value == 0){
				return "超级管理员";
			} else {
				return  "管理员";
			}
		}
	},
	{field:'regTime',title:'创建时间', width:80},
	{field:'email',title:'email', width:80},
	]]});
}

function initData() {

	console.log('InitData');

	var data = {
		cmd: "get_acc_datas"
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
