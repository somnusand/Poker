

function goPage(page) {
	var data = {
		cmd: "tuiguang_page",
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
	{field:'user_id',title:'玩家id', width:30},		
	{field:'name',title:'昵称', width:60},
	{field:'value',title:'金豆', width:80},]]
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




function doSearch() {			
	var data = {
		cmd: "tuiguang_info",
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