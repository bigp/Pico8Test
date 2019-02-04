pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function UTILS_update()
UTILS_frame+=1
UTILS_isFrameEven=UTILS_frame%2==0
UTILS_updateMouseStatus()
end
function UTILS_updateMouseStatus()
poke(24365,1)
UTILS_mouseX=stat(32)
UTILS_mouseY=stat(33)
UTILS_mouseButtonMask=stat(34)
UTILS_updateMouseButtonIndex(UTILS_mouseButtonMask,1,0)
UTILS_updateMouseButtonIndex(UTILS_mouseButtonMask,2,1)
UTILS_updateMouseButtonIndex(UTILS_mouseButtonMask,4,2)
end
function UTILS_updateMouseButtonIndex(stat,maskId,i)
if (band(UTILS_mouseButtonMask,maskId))==0 then
if UTILS__mouseTimes[i]>=0 then
UTILS__mouseTimes[i]=-UTILS_frame
end
return
end
if UTILS__mouseTimes[i]>0 then
return
end
UTILS__mouseTimes[i]=UTILS_frame
end
function UTILS_mouseDown(id)
return UTILS__mouseTimes[id]>0
end
function UTILS_mousePressed(id)
return UTILS__mouseTimes[id]==UTILS_frame
end
function UTILS_dist(x1,y1,x2,y2)
local xDiff=x2-x1
local yDiff=y2-y1
return xDiff*xDiff+yDiff*yDiff
end
function UTILS_screenChange(scr)
if UTILS__screen!=nil then
UTILS__screen:destroy()
end
UTILS__screen=scr
if UTILS__screen==nil then
return
end
UTILS__screen:init()
end
function UTILS_screenUpdate()
if UTILS__screen==nil then
return
end
UTILS__screen:update()
end
function UTILS_screenDraw()
if UTILS__screen==nil then
return
end
UTILS__screen:draw()
end
function Player_makeArrow(this)
return {
x=0,y=0,velX=0,velY=0,lifetime=0
}
end
function Player_update(this)
if not this.isAlive then
return
end
if not this.isInit then
this.pos._x=this.pos.x*CST_MOTION_SCALE
this.pos._y=this.pos.y*CST_MOTION_SCALE
this.isInit=true
end
Player_healOverTime(this)
Player_checkHealth(this)
Player_updateMotion(this)
Player_updateArrows(this)
end
function Player_draw(this)
if not this.isAlive then
return
end
if this.useMouse then
pal(CST_COLOR_08_RED,CST_COLOR_14_PINK)
end
if this.isAiming then
if this.aimCounter==0 then
pal(CST_COLOR_08_RED,CST_COLOR_07_WHITE)
end
Player_drawSprite(this,this.pos.spriteIndex+3+Player_getWalkCounter(this))
else
Player_drawSprite(this,this.pos.spriteIndex+Player_getWalkCounter(this))
end
pal()
Player_drawHealthBar(this)
Player_drawArrows(this)
end
function Player_healOverTime(this)
if this.health>=this.healthTemp then
return
end
this.health+=1
end
function Player_updateMotion(this)
this.pos._x+=this.pos.dirX*this.pos.speed
this.pos._y+=this.pos.dirY*this.pos.speed
if this.pos._x<0 then
this.pos._x=0
this.pos.dirX=0
end
if this.pos._x>CST_MAX_X then
this.pos._x=CST_MAX_X
this.pos.dirX=0
end
if this.pos._y<0 then
this.pos._y=0
this.pos.dirY=0
end
if this.pos._y>CST_MAX_Y then
this.pos._y=CST_MAX_Y
this.pos.dirY=0
end
if this.pos.dirX==0 and this.pos.dirY==0 then
this.walkCounter=0
else
this.walkCounter+=this.pos.speed
end
if this.isAiming then
this.aimCharge=min(CST_AIM_CHARGE_MAX,this.aimCharge+1)
this.aimCounter+=1
this.aimCounter%=CST_AIM_CHARGE_MAX-this.aimCharge+2
else
this.aimCharge=0
this.aimCounter=0
end
this.pos.x=this.pos._x/CST_MOTION_SCALE
this.pos.y=this.pos._y/CST_MOTION_SCALE
end
function Player_updateMouse(this)
if not UTILS_mouseDown(1) and this.isShooting then
this.isShooting=false
end
if not this.isShooting then
this.isAiming=UTILS_mouseDown(1)
end
if this.wasAiming!=this.isAiming then
if this.isAiming then
sfx(0)
else
sfx(1)
end
end
this.wasAiming=this.isAiming
if UTILS_mousePressed(0) then
Player_shoot(this)
end
end
function Player_shoot(this)
this.isAiming=false
this.isShooting=true
local offset=CST_ARROW_OFFSET_FROM+CST_ARROW_OFFSET_TO
local angle=atan2(UTILS_mouseX-this.pos.x,UTILS_mouseY-this.pos.y)
local arrow=this.arrows[this.arrowID+1]
if arrow.lifetime>0 then
sfx(3)
return
end
local speed=CST_ARROW_SPEED_MIN+this.arrowSpeed*this.aimCharge
arrow.x=this.pos.x+CST_ARROW_OFFSET_FROM
arrow.y=this.pos.y+CST_ARROW_OFFSET_FROM
arrow.velX=cos(angle)*speed
arrow.velY=sin(angle)*speed
arrow.lifetime=CST_ARROW_TIME
this.arrowID=(this.arrowID+1)%CST_ARROW_COUNT
sfx(CST_SFX_SHOOT+UTILS_frame%3)
end
function Player_checkInputs(this)
Player_updateMouse(this)
this.pos.dirX=0
this.pos.dirY=0
if this.isAiming then
this.pos.speed=CST_SPEED_MIN
else
this.pos.speed=CST_SPEED_MAX
end
if btn(0,this.pos.id) then
this.pos.dirX-=1
end
if btn(1,this.pos.id) then
this.pos.dirX+=1
end
if btn(2,this.pos.id) then
this.pos.dirY-=1
end
if btn(3,this.pos.id) then
this.pos.dirY+=1
end
if btnp(4,this.pos.id) then
this.health-=10
this.healthTemp=this.health
end
end
function Player_checkHealth(this)
if this.health<0 then
this.health=0
this.isAlive=false
sfx(9+flr(rnd(3)))
end
end
function Player_getWalkCounter(this)
return this.walkCounter/CST_SPEED_MAX%3
end
function Player_drawHealthBar(this)
local barColor=11
if this.health<10 then
barColor=8
end
line(this.pos.x,this.pos.y+9,this.pos.x+this.health/15,this.pos.y+9,barColor)
end
function Player_drawSprite(this,id)
spr(id,this.pos.x,this.pos.y)
end
function Player_drawMouse(this)
local offset=0
if this.isAiming then
offset=1+this.aimCharge/CST_AIM_CHARGE_MAX*4
end
spr(CST_SPRITE_CURSOR+offset,UTILS_mouseX,UTILS_mouseY)
end
function Player_updateArrows(this)
foreach(this.arrows,function(arrow)
print(arrow.lifetime)
if arrow.lifetime<=0 then
return
end
arrow.lifetime-=1
arrow.x+=arrow.velX
arrow.y+=arrow.velY
foreach(INGAME_players,function(player)
if not player.isAlive or player.pos.id==this.pos.id then
return
end
local distSqr=UTILS_dist(arrow.x,arrow.y,player.pos.x+CST_ARROW_OFFSET_FROM,player.pos.y+CST_ARROW_OFFSET_FROM)
if distSqr<CST_ARROW_PRECISION then
sfx(2)
arrow.lifetime=-1
player.health-=CST_ARROW_DAMAGE*(abs(arrow.velX)+abs(arrow.velY))
Player_checkHealth(player)
player.healthTemp=player.health
end
end)
if arrow.lifetime==0 then
sfx(8)
end
end)
end
function Player_drawArrows(this)
foreach(this.arrows,function(arrow)
if arrow.lifetime<=0 then
return
end
pset(arrow.x,arrow.y,7)
end)
end
function Player_create(id)
local this={isInit=false,arrowSpeed=0.3,arrowID=0,healthTemp=0,health=0,numHeals=0,aimY=0,aimX=0,aimCharge=0,aimCounter=0,walkCounter=0,isAlive=true}
this.pos=comp_Pos_create()
this.pos._x=128
this.pos._y=128
this.pos.x=0
this.pos.y=0
this.pos.id=id
this.pos.spriteIndex=CST_SPRITE_PLAYER
this.isShooting=false
this.isAiming=false
this.wasAiming=false
this.aimCharge=0
this.aimX=0
this.aimY=0
this.aimCounter=0
this.walkCounter=0
this.numHeals=3
this.health=100
this.healthTemp=100
this.arrowID=0
this.arrows={}
for a=0,CST_ARROW_COUNT-1 do
this.arrows[a+1]=Player_makeArrow(this)
end
return this
end
function comp_Pos_create()
return{spriteIndex=0,speed=0,id=0,dirY=0,dirX=0,y=0,x=0,_y=0,_x=0}
end
function MAINMENU_init(this)
cls()
print("Main Menu")
print("PRESS A TO START")
end
function MAINMENU_update(this)
if btnp(0,1) then
UTILS_screenChange(INGAME_create())
end
end
function MAINMENU_draw(this)end
function MAINMENU_destroy(this)end
function MAINMENU_create()
return{init=MAINMENU_init,update=MAINMENU_update,draw=MAINMENU_draw,destroy=MAINMENU_destroy}
end
function INGAME_createRandomPlayer()
local player=Player_create(0)
player.pos.x=rnd(127.0)
player.pos.y=rnd(127.0)
return player
end
function INGAME_init(this)end
function INGAME_update(this)
cls()
rectfill(0,0,128,128,CST_COLOR_03_GREEN_DARK)
UTILS_update()
Player_checkInputs(this.player1)
local numPlayersAlive=0
local playerAlive=nil
foreach(INGAME_players,function(player)
Player_update(player)
if player.isAlive then
numPlayersAlive+=1
playerAlive=player
end
end)
if this.gameOverStatus==nil and numPlayersAlive==1 then
if playerAlive==this.player1 then
this.gameOverStatus="you won!"
sfx(12)
else
this.gameOverStatus="you lost!"
sfx(13)
end
end
if this.gameOverStatus!=nil and btnp(0,1) then
UTILS_screenChange(INGAME_create())
end
end
function INGAME_draw(this)
foreach(INGAME_players,function(player)
Player_draw(player)
end)
if this.gameOverStatus!=nil then
print(this.gameOverStatus,3,65,CST_COLOR_00_BLACK)
print(this.gameOverStatus,2,64,CST_COLOR_07_WHITE)
end
Player_drawMouse(this.player1)
end
function INGAME_destroy(this)end
function INGAME_create()
local this={init=INGAME_init,update=INGAME_update,draw=INGAME_draw,destroy=INGAME_destroy,gameOverStatus=nil}
this.player1=Player_create(1)
this.player1.pos.x=80
this.player1.useMouse=true
INGAME_players={this.player1,INGAME_createRandomPlayer(),INGAME_createRandomPlayer(),INGAME_createRandomPlayer(),INGAME_createRandomPlayer()}
return this
end
CST_MOTION_SCALE=2
CST_SFX_SHOOT=5
CST_SPRITE_PLAYER=1
CST_SPRITE_CURSOR=7
CST_AIM_CHARGE_MAX=10
CST_SPEED_MIN=1
CST_SPEED_MAX=3
CST_SIZE=16
CST_MAX_X=256-CST_SIZE
CST_MAX_Y=250-CST_SIZE
CST_ARROW_COUNT=2
CST_ARROW_TIME=20
CST_ARROW_SPEED_MIN=2
CST_ARROW_OFFSET_FROM=4
CST_ARROW_OFFSET_TO=4
CST_ARROW_PRECISION=20
CST_ARROW_DAMAGE=5
CST_COLOR_00_BLACK=0
CST_COLOR_03_GREEN_DARK=3
CST_COLOR_07_WHITE=7
CST_COLOR_08_RED=8
CST_COLOR_14_PINK=14
UTILS__mouseTimes={[0]=-1,-1,-1}
UTILS_mouseX=0
UTILS_mouseY=0
UTILS_mouseButtonMask=0
UTILS_frame=0
UTILS_isFrameEven=false
mainmenu=MAINMENU_create()
function _init()
UTILS_screenChange(mainmenu)
end
function _update()
UTILS_screenUpdate()
end
function _draw()
UTILS_screenDraw()
end
__gfx__
00000000008880000088800000888000008880000088800000888000000000007777777707777770007777000000000000000000000000000000000000000000
00000000009f9000009f9000009f9000009f9000009f9000009f9000770000777000000707000070007007000077770000777700000000000000000000000000
0000000008f4f80008f4f80008f4f80008ff580008ff580008ff5800700000070770077000777700700000077777777707777770000000000000000000000000
00000000848878808488788084887480085555500855555008555550700770070707707000777700707777077079970707788770000000000000000000000000
0000000080878080f0878080808780f00087f0000087f0000087f000700770070707707000777700707777077079970707788770000000000000000000000000
00000000f07880f0007840f0f0684000007880000078800000788000700000070770077000777700700000077777777707777770000000000000000000000000
00000000008080000080480008408000008080000080480008408000770000777000000707000070007007000077770000777700000000000000000000000000
00000000084048000080000000008000084048000840000000004800000000007777777707777770007777000000000000000000000000000000000000000000
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
0007000015050010001505000000190500000019050000001c050000001c050000002105021050210402103021010210100000000000000000000000000000000000000000000000000000000000000000000000
000a00001505001000110500000010050000000c050000000b0500c00010050010000905009050090400903009010090100000000000000000000000000000000000000000000000000000000000000000000000
