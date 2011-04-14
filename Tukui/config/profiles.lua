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
   C.datatext.manaregen = 9
   C.unitframes.trikz = true
end   