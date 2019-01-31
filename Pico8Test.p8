pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function com_pico8test_Player_update(this)
if this.useMouse then
com_pico8test_Player_updateMouse(this)
end
com_pico8test_Player_healOverTime(this)
com_pico8test_Player_checkInputs(this)
end
function com_pico8test_Player_healOverTime(this)
if this.health>=this.healthTemp then
return
end
this.health+=1
end
function com_pico8test_Player_updateMouse(this)
if not com_pico8test_ZZZ_mouseDown(1) and this.isShooting then
this.isShooting=false
end
if not this.isShooting then
this.isAiming=com_pico8test_ZZZ_mouseDown(1)
end
if this.wasAiming!=this.isAiming then
if this.isAiming then
sfx(0)
else
sfx(1)
end
end
this.wasAiming=this.isAiming
if com_pico8test_ZZZ_mousePressed(0) then
if this.isAiming then
com_pico8test_Player_shoot(this)
elseif not this.isShooting then
com_pico8test_Player_healUp(this)
end
end
end
function com_pico8test_Player_healUp(this)
if this.numHeals==0 then
sfx(2)
return
end
if this.health>=100 then
sfx(3)
return
end
this.numHeals-=1
this.healthTemp=min(100,this.healthTemp+com_pico8test_Player_HEAL_AMOUNT)
this.health=min(this.healthTemp,this.health+com_pico8test_Player_HEAL_AMOUNT/2)
sfx(4)
end
function com_pico8test_Player_shoot(this)
sfx(com_pico8test_Player_SFX_SHOOT+com_pico8test_ZZZ_frame%3)
this.isAiming=false
this.isShooting=true
end
function com_pico8test_Player_checkInputs(this)
this.dirX=0
this.dirY=0
if this.isAiming then
this.speed=com_pico8test_Player_SPEED_MIN
else
this.speed=com_pico8test_Player_SPEED_MAX
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
this.x+=this.dirX*this.speed
this.y+=this.dirY*this.speed
if this.x<0 then
this.x=0
this.dirX=0
end
if this.x>com_pico8test_Player_MAX_X then
this.x=com_pico8test_Player_MAX_X
this.dirX=0
end
if this.y<0 then
this.y=0
this.dirY=0
end
if this.y>com_pico8test_Player_MAX_Y then
this.y=com_pico8test_Player_MAX_Y
this.dirY=0
end
if this.dirX==0 and this.dirY==0 then
this.walkCounter=0
else
this.walkCounter+=this.speed
end
if this.isAiming then
this.aimCharge=min(com_pico8test_Player_AIM_CHARGE_MAX,this.aimCharge+1)
this.aimCounter+=1
this.aimCounter%=com_pico8test_Player_AIM_CHARGE_MAX-this.aimCharge+2
else
this.aimCharge=0
this.aimCounter=0
end
this.xFinal=shr(this.x,1)
this.yFinal=shr(this.y,1)
end
function com_pico8test_Player_getWalkCounter(this)
return this.walkCounter/com_pico8test_Player_SPEED_MAX%3
end
function com_pico8test_Player_draw(this)
if this.isAiming then
if this.aimCounter==0 then
pal(8,9)
end
com_pico8test_Player_drawSprite(this,this.spriteIndex+3+com_pico8test_Player_getWalkCounter(this))
else
com_pico8test_Player_drawSprite(this,this.spriteIndex+com_pico8test_Player_getWalkCounter(this))
end
pal()
if this.useMouse then
local offset=0
if this.isAiming then
offset=1+com_pico8test_ZZZ_frame/1.2%3
end
spr(com_pico8test_Player_SPRITE_CURSOR+offset,com_pico8test_ZZZ_mouseX,com_pico8test_ZZZ_mouseY)
end
com_pico8test_Player_drawHealthBar(this)
end
function com_pico8test_Player_drawHealthBar(this)
local barColor=11
if this.health<10 then
barColor=8
end
line(this.xFinal,this.yFinal+9,this.xFinal+this.health/15,this.yFinal+9,barColor)
end
function com_pico8test_Player_drawSprite(this,id)
spr(id,this.xFinal,this.yFinal)
end
function com_pico8test_Player_create(id,useMouse)
local this={isShooting=false,healthTemp=100,health=100,numHeals=3,aimCharge=0,wasAiming=false,isAiming=false,useMouse=false}
this.spriteIndex=com_pico8test_Player_SPRITE_PLAYER
this.aimCounter=0
this.walkCounter=0
this.dirY=0
this.dirX=0
this.speed=1
this.yFinal=0
this.xFinal=0
this.y=128
this.x=128
this.id=0
this.id=id
this.useMouse=useMouse
return this
end
function com_pico8test_ZZZ_update()
com_pico8test_ZZZ_frame+=1
com_pico8test_ZZZ_isFrameEven=com_pico8test_ZZZ_frame%2==0
com_pico8test_ZZZ_updateMouseStatus()
end
function com_pico8test_ZZZ_updateMouseStatus()
poke(24365,1)
com_pico8test_ZZZ_mouseX=stat(32)
com_pico8test_ZZZ_mouseY=stat(33)
com_pico8test_ZZZ_mouseButtonMask=stat(34)
com_pico8test_ZZZ_updateMouseButtonIndex(com_pico8test_ZZZ_mouseButtonMask,1,0)
com_pico8test_ZZZ_updateMouseButtonIndex(com_pico8test_ZZZ_mouseButtonMask,2,1)
com_pico8test_ZZZ_updateMouseButtonIndex(com_pico8test_ZZZ_mouseButtonMask,4,2)
end
function com_pico8test_ZZZ_updateMouseButtonIndex(stat,maskId,i)
if (band(com_pico8test_ZZZ_mouseButtonMask,maskId))==0 then
if com_pico8test_ZZZ_mouseTimes[i]>=0 then
com_pico8test_ZZZ_mouseTimes[i]=-com_pico8test_ZZZ_frame
end
return
end
if com_pico8test_ZZZ_mouseTimes[i]>0 then
return
end
com_pico8test_ZZZ_mouseTimes[i]=com_pico8test_ZZZ_frame
end
function com_pico8test_ZZZ_mouseDown(id)
return com_pico8test_ZZZ_mouseTimes[id]>0
end
function com_pico8test_ZZZ_mousePressed(id)
return com_pico8test_ZZZ_mouseTimes[id]==com_pico8test_ZZZ_frame
end
com_pico8test_Player_SFX_SHOOT=5
com_pico8test_Player_SPRITE_PLAYER=1
com_pico8test_Player_SPRITE_CURSOR=7
com_pico8test_Player_AIM_CHARGE_MAX=10
com_pico8test_Player_SPEED_MIN=1
com_pico8test_Player_SPEED_MAX=3
com_pico8test_Player_HEAL_AMOUNT=20
com_pico8test_Player_SIZE=16
com_pico8test_Player_MAX_X=256-com_pico8test_Player_SIZE
com_pico8test_Player_MAX_Y=250-com_pico8test_Player_SIZE
com_pico8test_ZZZ_mouseX=0
com_pico8test_ZZZ_mouseY=0
com_pico8test_ZZZ_mouseButtonMask=0
com_pico8test_ZZZ_mouseTimes={[0]=-1,-1,-1}
com_pico8test_ZZZ_frame=0
com_pico8test_ZZZ_isFrameEven=false
players={}
add(players,com_pico8test_Player_create(0,true))
add(players,com_pico8test_Player_create(1))
function _update()
cls()
com_pico8test_ZZZ_update()
local player1=all(players)
while player1.hasNext(player1) do
com_pico8test_Player_update(player1.next(player1))
end
end
function _draw()
local player3=all(players)
while player3.hasNext(player3) do
com_pico8test_Player_draw(player3.next(player3))
end
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
000300001e150261402c1402f13032130331102d1003310036100381003b1003e1003f1003f1003f1003f1003f100331003310000000000000000000000000000000000000000000000000000000000000000000
000300001a150271402b1402f13032130341102d1003310036100381003b1003e1003f1003f1003f1003f1003f100331003310000000000000000000000000000000000000000000000000000000000000000000
000300001f150251402b1402f13031130321102d1003310036100381003b1003e1003f1003f1003f1003f1003f100331003310000000000000000000000000000000000000000000000000000000000000000000
