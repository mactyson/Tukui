local T, C, L = unpack(select(2, ...)) 

-- tank class
if T.myclass == "PALADIN" then
    C.datatext.classcolor = false
	C.chat.classcolortab = false
	C.datatext.mastery = 8
	C.datatext.avd = 9
	C.datatext.power = 0
	C.datatext.crit = 0
end

if T.myname== "Noshi" then
   C.actionbar.hideshapeshift = true
   C.unitframes.trikz = false
end   