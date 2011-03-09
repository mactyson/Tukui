local T, C, L = unpack(select(2, ...)) 

-- tank class
if T.myclass == "PALADIN" then
    C.datatext.classcolor = false
	C.chat.classcolortab = false
	C.datatext.mastery = 5
	C.datatext.avd = 4
	C.datatext.dur = 0
	C.datatext.fps_ms = 0
end

if T.myname== "Noshi" then
   C.actionbar.hideshapeshift = true
   C.unitframes.trikz = false
end   