<!--
var message="Function Disabled";    //edit this message to say what you want

function clickIE()
{
if (event.button==0) {/*alert(message);*/ return false;}
}
function clickNS(e)
{
if (document.layers||(document.getElementById&&!document.all))
{
if (e.which==2||e.which==3)
{
/*alert(message);*/return false;
}
}
}

if(window.navigator.appName=="Netscape")
{
document.onmouseup=clickNS;
document.oncontextmenu=clickIE;
document.oncontextmenu=new Function("return false")
}
else if (window.navigator.appName=="Microsoft Internet Explorer")
{
document.oncontextmenu=clickIE;
}
else if (window.navigator.appName=="Opera")
{

}
else if (document.layers)
{
document.captureEvents(Event.MOUSEDOWN);document.onmousedown=clickNS;
}
else
{
document.onmouseup=clickNS;
document.oncontextmenu=clickIE;
}

// --> 
