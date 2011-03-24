local T, C, L = unpack(select(2, ...)) 
-- different config then most of you
-- tank class
if T.myclass == "PALADIN" then
	C.chat.classcolortab = false
	C.datatext.mastery = 8
	C.datatext.avd = 9
	C.datatext.power = 0
	C.datatext.crit = 0
end

if T.myname== "Noshi" then
   C.actionbar.hideshapeshift = true
end   

if T.myname== "Jàsje" then
   C.datatext.classcolor = true
   C.datatext.crit = 0
   C.datatext.haste = 9
   C.unitframeJ.playerX = -117
   C.unitframeJ.playerY = 61
   C.unitframeJ.targetX =  117
   C.unitframeJ.targetY =  61
   C.raidlayout.gridH = 40
   C.raidlayout.gridW = 60
   C.raidlayout.powergridH = 2
   C.raidlayout.powergridW = 50
end   