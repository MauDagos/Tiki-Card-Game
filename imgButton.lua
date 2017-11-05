--[[
Metaclase ImgButton
]]
ImgButton = { nombre = "", img = "", posX = 0, posY = 0, rot = 0 }
ImgButton_mt = { __index = ImgButton }

-- Crear nuevo botón
function ImgButton:new(nombre, img, posX, posY, rot, comprada, turnosEspera)
	return setmetatable( { nombre = nombre, img = img, posX = posX, posY = posY, rot = rot, comprada = comprada, turnosEspera = turnosEspera }, ImgButton_mt )
end

-- Comprobar si x e y están dentro del botón
function ImgButton:inScope(x, y)
	width = self.img:getWidth() * escalaFicha
	height = self.img:getHeight() * escalaFicha
	if x >= self.posX - width / 2 and x <= self.posX + width / 2 and y >= self.posY - height / 2 and y <= self.posY + height / 2 then
		return true
	else
		return false
	end
end

-- Devuelve el punto central del botón
function ImgButton:center()
	return self.img:getWidth() / 2, self.img:getHeight() / 2
end