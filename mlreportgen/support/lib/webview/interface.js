//>>built
var slwebview=function(){function f(a){var b=a.indexOf(":");return-1===b?{widget:a,obj:null}:{widget:a.substring(0,b),obj:a.substring(b+1)}}var e=require("dijit/registry");return{open:function(a,b){var c=f(a);return e.byId(c.widget).openSys(c.obj,"tab"===b)},close:function(a){a=f(a);return e.byId(a.widget).closeSys(a.obj)},select:function(a,b){var c=f(a),d=e.byId(c.widget);"undefined"===typeof b&&(b=!0);return d.select(c.obj,b)},unselect:function(a){a=f(a);return e.byId(a.widget).unselect()},highlight:function(a,
b,c){a=f(a);var d=e.byId(a.widget);"undefined"===typeof c&&(c=!0);return d.highlight(a.obj,b,c)},unhighlight:function(a){a=f(a);return e.byId(a.widget).unhighlight(a.obj)}}}();require(["dijit/registry","dojo/topic"],function(f,e){function a(a,b){var c=document.getElementById(a+":"+b);c&&c.scrollIntoView(!0)}var b=document.body.getElementsByTagName("div"),c=b.length,d;for(d=0;d<c;d++)"webview/widgets/App"===b[d].getAttribute("data-dojo-type")&&e.subscribe(b[d].id+"/selectHandler",a)});
//# sourceMappingURL=interface.js.map