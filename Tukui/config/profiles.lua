local T, C, L = unpack(select(2, ...)) 

-- tank class
if T.myclass == "PALADIN" then
    C.datatext.classcolor = false
	C.chat.classcolortab = false
	C.datatext.mastery = 5
	C.datatext.avd = 4
	C.datatext.crit = 0
	C.datatext.power = 0
end
