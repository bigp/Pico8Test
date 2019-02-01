pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function M_createRandomPlayer()
local player=P_create(0)
player.x=rnd(127.0)
player.y=rnd(127.0)
return player
end
function G_update()
G_frame+=1
G_isFrameEven=G_frame%2==0
G_updateMouseStatus()
end
function G_updateMouseStatus()
poke(24365,1)
G_mouseX=stat(32)
G_mouseY=stat(33)
G_mouseButtonMask=stat(34)
G_updateMouseButtonIndex(G_mouseButtonMask,1,0)
G_updateMouseButtonIndex(G_mouseButtonMask,2,1)
G_updateMouseButtonIndex(G_mouseButtonMask,4,2)
end
function G_updateMouseButtonIndex(stat,maskId,i)
if (band(G_mouseButtonMask,maskId))==0 then
if G_mouseTimes[i]>=0 then
G_mouseTimes[i]=-G_frame
end
return
end
if G_mouseTimes[i]>0 then
return
end
G_mouseTimes[i]=G_frame
end
function G_mouseDown(id)
return G_mouseTimes[id]>0
end
function G_mousePressed(id)
return G_mouseTimes[id]==G_frame
end
function G_dist(x1,y1,x2,y2)
local xDiff=x2-x1
local yDiff=y2-y1
return xDiff*xDiff+yDiff*yDiff
end
function P_makeArrow(this)
return {
x=0,y=0,velX=0,velY=0,lifetime=0
}
end
function P_update(this)
if not this.isInit then
this._x=this.x*MOTION_SCALE
this._y=this.y*MOTION_SCALE
this.isInit=true
end
P_healOverTime(this)
P_updateMotion(this)
foreach(this.arrows,P_updateArrow)
end
function P_draw(this)
if not this.isAlive then
return
end
if this.isAiming then
if this.aimCounter==0 then
pal(8,9)
end
P_drawSprite(this,this.spriteIndex+3+P_getWalkCounter(this))
else
P_drawSprite(this,this.spriteIndex+P_getWalkCounter(this))
end
pal()
P_drawHealthBar(this)
foreach(this.arrows,P_drawArrow)
end
function P_healOverTime(this)
if this.health>=this.healthTemp then
return
end
this.health+=1
end
function P_updateMotion(this)
this._x+=this.dirX*this.speed
this._y+=this.dirY*this.speed
if this._x<0 then
this._x=0
this.dirX=0
end
if this._x>MAX_X then
this._x=MAX_X
this.dirX=0
end
if this._y<0 then
this._y=0
this.dirY=0
end
if this._y>MAX_Y then
this._y=MAX_Y
this.dirY=0
end
if this.dirX==0 and this.dirY==0 then
this.walkCounter=0
else
this.walkCounter+=this.speed
end
if this.isAiming then
this.aimCharge=min(AIM_CHARGE_MAX,this.aimCharge+1)
this.aimCounter+=1
this.aimCounter%=AIM_CHARGE_MAX-this.aimCharge+2
else
this.aimCharge=0
this.aimCounter=0
end
this.x=this._x/MOTION_SCALE
this.y=this._y/MOTION_SCALE
end
function P_updateMouse(this)
if not G_mouseDown(1) and this.isShooting then
this.isShooting=false
end
if not this.isShooting then
this.isAiming=G_mouseDown(1)
end
if this.wasAiming!=this.isAiming then
if this.isAiming then
sfx(0)
else
sfx(1)
end
end
this.wasAiming=this.isAiming
if G_mousePressed(0) then
P_shoot(this)
end
end
function P_shoot(this)
this.isAiming=false
this.isShooting=true
local offset=ARROW_OFFSET_FROM+ARROW_OFFSET_TO
local angle=atan2(G_mouseX-this.x,G_mouseY-this.y)
local arrow=this.arrows[this.arrowID+1]
if arrow.lifetime>0 then
sfx(3)
return
end
local speed=ARROW_SPEED_MIN+this.arrowSpeed*this.aimCharge
arrow.x=this.x+ARROW_OFFSET_FROM
arrow.y=this.y+ARROW_OFFSET_FROM
arrow.velX=cos(angle)*speed
arrow.velY=sin(angle)*speed
arrow.lifetime=ARROW_TIME
this.arrowID=(this.arrowID+1)%ARROW_COUNT
sfx(SFX_SHOOT+G_frame%3)
end
function P_checkInputs(this)
P_updateMouse(this)
this.dirX=0
this.dirY=0
if this.isAiming then
this.speed=SPEED_MIN
else
this.speed=SPEED_MAX
end
if btn(0,this.id) then
this.dirX-=1
end
if btn(1,this.id) then
this.dirX+=1
end
if btn(2,this.id) then
this.dirY-=1
end
if btn(3,this.id) then
this.dirY+=1
end
end
function P_getWalkCounter(this)
return this.walkCounter/SPEED_MAX%3
end
function P_drawHealthBar(this)
local barColor=11
if this.health<10 then
barColor=8
end
line(this.x,this.y+9,this.x+this.health/15,this.y+9,barColor)
end
function P_drawSprite(this,id)
spr(id,this.x,this.y)
end
function P_drawMouse(this)
local offset=0
if this.isAiming then
offset=1+G_frame/1.2%3
end
spr(SPRITE_CURSOR+offset,G_mouseX,G_mouseY)
end
function P_updateArrow(this,arrow)
if arrow.lifetime<=0 then
return
end
arrow.lifetime-=1
arrow.x+=arrow.velX
arrow.y+=arrow.velY
foreach(M_players,function(player)
if not player.isAlive or player.id==this.id then
return
end
local distSqr=G_dist(arrow.x,arrow.y,player.x+ARROW_OFFSET_FROM,player.y+ARROW_OFFSET_FROM)
if distSqr<ARROW_PRECISION then
sfx(2)
arrow.lifetime=-1
player.health-=ARROW_DAMAGE*(abs(arrow.velX)+abs(arrow.velY))
if player.health<0 then
player.health=0
player.isAlive=false
sfx(9+flr(rnd(3)))
end
player.healthTemp=player.health
end
end)
if arrow.lifetime==0 then
sfx(8)
end
end
function P_drawArrow(this,arrow)
if arrow.lifetime<=0 then
return
end
pset(arrow.x,arrow.y,7)
end
function P_create(id)
local this={isInit=false,isAlive=true,arrowSpeed=0.3,arrowID=0,healthTemp=0,health=0,numHeals=0,aimY=0,aimX=0,aimCharge=0,spriteIndex=0,aimCounter=0,walkCounter=0,speed=0,id=0,dirY=0,dirX=0,y=0,x=0,_y=0,_x=0,id=id,_x=128,_y=128,x=0,y=0,walkCounter=0,aimCounter=0}
this.spriteIndex=SPRITE_PLAYER
this.isAiming=false
this.wasAiming=false
this.aimCharge=0
this.aimX=0
this.aimY=0
this.numHeals=3
this.health=100
this.healthTemp=100
this.isShooting=false
this.arrowID=0
this.arrows={}
for a=0,ARROW_COUNT-1 do
this.arrows[a+1]=P_makeArrow(this)
end
return this
end
MOTION_SCALE=2
SFX_SHOOT=5
SPRITE_PLAYER=1
SPRITE_CURSOR=7
AIM_CHARGE_MAX=10
SPEED_MIN=1
SPEED_MAX=3
SIZE=16
MAX_X=256-SIZE
MAX_Y=250-SIZE
ARROW_COUNT=2
ARROW_TIME=20
ARROW_SPEED_MIN=2
ARROW_OFFSET_FROM=4
ARROW_OFFSET_TO=4
ARROW_PRECISION=30
ARROW_DAMAGE=5
COLOR_GREEN_DARK=3
G_mouseX=0
G_mouseY=0
G_mouseButtonMask=0
G_mouseTimes={[0]=-1,-1,-1}
G_frame=0
G_isFrameEven=false
player1=P_create(1)
player1.x=80
player1.useMouse=true
M_players={player1,M_createRandomPlayer(),M_createRandomPlayer(),M_createRandomPlayer(),M_createRandomPlayer()}
function _init()
cls()
end
function _update()
cls()
rectfill(0,0,128,128,COLOR_GREEN_DARK)
G_update()
P_checkInputs(player1)
foreach(M_players,function(player3)
P_update(player3)
end)
end
function _draw()
foreach(M_players,function(player4)
P_draw(player4)
end)
P_drawMouse(player1)
end
__gfx__
00000000008880000088800000888000008880000088800000888000000000000007700000077000000770000000000000000000000000000000000000000000
00000000009f9000009f9000009f9000009f9000009f9000009f9000000770000007700000077000000000000000000000000000000000000000000000000000
0000000008f4f80008f4f80008f4f80008ff580008ff580008ff5800000770000007700000000000000000000000000000000000000000000000000000000000
00000000848878808488788084887480085555500855555008555550077007707770077777000077700000070000000000000000000000000000000000000000
0000000080878080f0878080808780f00087f0000087f0000087f000077007707770077777000077700000070000000000000000000000000000000000000000
00000000f07880f0007840f0f0684000007880000078800000788000000770000007700000000000000000000000000000000000000000000000000000000000
00000000008080000080480008408000008080000080480008408000000770000007700000077000000000000000000000000000000000000000000000000000
00000000084048000080000000008000084048000840000000004800000000000007700000077000000770000000000000000000000000000000000000000000
__sfx__
00010000010100200003000010100500005000020200301004000050200501007000080200902009010090200a0200a0100a0200b0200b0100b0200b0100b0000b0100c0200d0100f0000f0100f0201001010010
000200000802005030030200201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001512016110000001010011110111200c13007120011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200003e2103b2003f2003f2103f2003d2003d2003e2003e2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004000002730037400475006740087400b7300f73012720127200f7200c7100a7100771005710037100171001710017100000000000000000000000000000000000000000000000000000000000000000000000
000200001e150261402c1402f13032130331102d1003310036100381003b1003e1003f1003f1003f1003f1003f100331003310000000000000000000000000000000000000000000000000000000000000000000
000200001a150271402b1402f13032130341102d1003310036100381003b1003e1003f1003f1003f1003f1003f100331003310000000000000000000000000000000000000000000000000000000000000000000
000200001f150251402b1402f13031130321102d1003310036100381003b1003e1003f1003f1003f1003f1003f100331003310000000000000000000000000000000000000000000000000000000000000000000
000400000165001600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002332029330303403335037350393503b3503b3503c3403c3403c3403b3403a3403a34039330363303633035330353303433033330333203332032320313203032030310303102f3102f3100000000000
0002000023320293303034035350373503a3503c3503e3503e3403e3403d3403c3403b3403b3403a330393303833038330363303533033330333203332032320313203032030310303102f3102f3100000000000
000200002132026330293402d3503035033350373503835038340383403834039340393403934038330373303533032330313303133032330323202f3202f32030320303202e3102d3102d3102a3102631025310
