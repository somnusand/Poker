
console.log("test")
sessionStorage.setItem('login_name',null);
sessionStorage.setItem('login_key',null);    
    
function clickLogin() {
	console.log('ClickLogin');

    var name = document.getElementById("name");
    var pwd = document.getElementById("pwd");
 
    if ( name && pwd )
    { 	
    		
    		
        var data =  {
            cmd: "login",
            name: name.value,
            pwd:  pwd.value,
        }
        console.log('do JsonMsg');
        jsonMsg(data,function(ret){
            if ( ret.key ) {
            		sessionStorage.setItem('login_name',name.value);
                sessionStorage.setItem('login_key',ret.key);
                sessionStorage.setItem('login_type',ret.type);    
                
                sessionStorage.setItem('login_id',ret.id);
                	
                if ( ret.type == 1 ) {
                		window.location.href="main1.html"; 
                }
                else if ( ret.type == 2 ) {
                		window.location.href="main2.html"; 
                }
                else if ( ret.type == 3 ) {
                		window.location.href="main2.html"; 
                }
                else if ( ret.type == 4 ) {
                		window.location.href="main3.html"; 
                }
                else {                
                		window.location.href="main.html"; 
                }
            }
            else {
            		alert("登录失败");
            }
        })        
    }
}