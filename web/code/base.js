

var ip = '222.187.239.186';


function jsonMsg(data,fun) {
	console.log('call JsonMsg');
    var jsonStr = JSON.stringify( data );
    var url = 'http://' + ip + ':8188/?data=' + jsonStr
            + "&key=" + sessionStorage.getItem('login_key')
            + '&jsoncallback=?';

    $.getJSON(url,function(data){
        fun(data);
    })

}

function makeCmd(cmd) {
	var jsonStr = JSON.stringify( data );
    var url = 'http://' + ip + ':8188/?data=' + jsonStr
            + "&key=" + sessionStorage.getItem('login_key');
    return url;
}


function getValue(field) {
	var a = document.getElementById(field);
	return a.value;
}

function setValue(field,value) {
	var a = document.getElementById(field);
	a.innerHTML = value;
}

function formatterDate(date) {
	var day = date.getDate() > 9 ? date.getDate() : "0" + date.getDate();
	var month = (date.getMonth() + 1) > 9 ? (date.getMonth() + 1) : "0"
	+ (date.getMonth() + 1);
	var r = date.getFullYear() + '-' + month + '-' + day;
	console.log(r);
	return r;
};

function getCurDate() {
	return formatterDate(new Date());
}
