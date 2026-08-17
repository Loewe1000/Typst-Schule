
(function(){
var api=null,base=null,live=false,q=[],busy=false,pending=null,running={};
function tween(w){
 var from0=w.from==null?api.getValue(w.name):w.from,dur=w.duration||600,t0=null;
 if(running[w.name])cancelAnimationFrame(running[w.name]);
 if(w.from!=null)api.setValue(w.name,w.from);
 function frame(now){
  if(t0===null)t0=now;
  var p=dur>0?Math.min(1,(now-t0)/dur):1;
  var e=w.easing==="linear"?p:(p<0.5?2*p*p:1-Math.pow(-2*p+2,2)/2);
  api.setValue(w.name,from0+(w.to-from0)*e);
  if(p<1)running[w.name]=requestAnimationFrame(frame);else delete running[w.name];
 }
 running[w.name]=requestAnimationFrame(frame);
}
function stopTweens(){for(var n in running)cancelAnimationFrame(running[n]);running={};}
function apply(j,sofort){
 var bad=[];
 if(j.set)for(var k in j.set)api.setValue(k,j.set[k]);
 if(j.cmd)for(var i=0;i<j.cmd.length;i++){if(api.evalCommand(j.cmd[i])===false)bad.push(j.cmd[i]);}
 if(j.view){var v=j.view;
  if(v.coords)api.setCoordSystem(v.coords[0],v.coords[1],v.coords[2],v.coords[3]);
  if(v.grid!=null)api.setGridVisible(v.grid);
  if(v.axes)api.setAxesVisible(v.axes[0],v.axes[1]);}
 if(j.vis)for(var i=0;i<j.vis.objects.length;i++)api.setVisible(j.vis.objects[i],j.vis.on);
 if(j.style){var t=j.style,i,o;
  for(i=0;i<t.objects.length;i++){o=t.objects[i];
   if(t.color)api.setColor(o,t.color[0],t.color[1],t.color[2]);
   if(t.thickness!=null)api.setLineThickness(o,t.thickness);
   if(t.lineStyle!=null)api.setLineStyle(o,t.lineStyle);
   if(t.filling!=null)api.setFilling(o,t.filling);
   if(t.pointSize!=null)api.setPointSize(o,t.pointSize);
   if(t.trace!=null)api.setTrace(o,t.trace);
   if(t.label!=null)api.setLabelVisible(o,t.label);
   if(t.labelMode!=null)api.setLabelStyle(o,t.labelMode);
   if(t.fixed!=null)api.setFixed(o,t.fixed,true);
   if(t.caption!=null)api.setCaption(o,t.caption);
   if(t.layer!=null)api.setLayer(o,t.layer);
   if(t.coords)api.setCoords(o,t.coords[0],t.coords[1]);}}
 if(j.anim){var a=j.anim,i;
  for(i=0;i<a.objects.length;i++){
   if(a.speed!=null)api.setAnimationSpeed(a.objects[i],a.speed);
   api.setAnimating(a.objects[i],a.playing!==false);}
  for(i=0;i<(a.trace||[]).length;i++)api.setTrace(a.trace[i],true);
  if(a.playing===false)api.stopAnimation();else api.startAnimation();}
 if(j.tween){if(sofort)api.setValue(j.tween.name,j.tween.to);else tween(j.tween);}
 if(bad.length)try{parent.postMessage({typstage:1,failed:bad,who:__ID__},"*");}catch(e){}
}
function play(jobs,sofort){for(var i=0;i<(jobs||[]).length;i++)apply(jobs[i],sofort);}
function run(m){
 if(!m||m.typstage!==1)return;
 if(!live){q=[m];return;}
 if(busy){pending=m;return;}
 if(m.stop){stopTweens();try{api.stopAnimation();}catch(e){}return;}
 if(m.reset&&base!=null){
  busy=true;stopTweens();
  try{api.setRepaintingActive(false);}catch(e){}
  api.setBase64(base,function(){
   try{api.setRepaintingActive(false);}catch(e){}
   play(m.jobs,true);
   try{api.setRepaintingActive(true);}catch(e){}
   busy=false;var n=pending;pending=null;if(n)run(n);});
  return;}
 play(m.jobs,false);
}
addEventListener("message",function(e){run(e.data);});
// The applet starts before its frame has a size — when it grows it has to
// recompute, otherwise it stays small inside a large area.
addEventListener("resize",function(){try{api.recalculateEnvironments();}catch(e){}});
var p=__PARAMS__;
p.appletOnLoad=function(a){
 api=a;
 __BOOTVIEW__
 try{a.recalculateEnvironments();}catch(e){}
 a.getBase64(function(b){
  base=b;live=true;
  var r=q;q=[];for(var i=0;i<r.length;i++)run(r[i]);
  try{parent.postMessage({typstage:1,ready:__ID__},"*");}catch(e){}});
};
__CODEBASE__
new GGBApplet(p,true).inject("ts-ggb");
})();
