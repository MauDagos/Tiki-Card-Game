require "posicionesBD"
require "fichasBD"
require "imgButton"

--[[
Metaclase Jugador
]]
Jugador = { num = nil, fichas = {}, color = "", aldeanosDisponibles = 0, aldeanosBloqueados = 0, fichasActivas = {} }
Jugador_mt = { __index = Jugador }

-- Crear nuevo jugador
function Jugador:new(num, color)
	print("Creando jugador " .. tostring(num) .. " : " .. color)
	return setmetatable( { num = num, fichas = {}, color = color, aldeanosDisponibles = 0, aldeanosBloqueados = 0, fichasActivas = {} }, Jugador_mt )
end

-- Crear mazo
function Jugador:crearFichas(nombres)
	print("Creando fichas para " .. tostring(self.num) .. " : " .. self.color)

	x, y = nil, nil

	if self.num == 1 then
		x = jugActualFichaPosX
		y = jugActualFichaPosY
	else
		x = jugOtroFichaPosX
		y = jugOtroFichaPosY
	end

	for i, nombre in pairs(nombres) do
		compradaAux = getCosteCompra(nombre) == 0 and true or false		-- miramos en fichasBD
		self.fichas[nombre] = ImgButton:new(nombre, 
											love.graphics.newImage('assets/fichas/' .. (compradaAux and '' or 'b-') .. nombre .. '-' .. self.color .. '.png'),
											x,
											y,
											0,
											compradaAux,
											0,
											false)
		print('assets/fichas/' .. nombres[i] .. '-' .. self.color .. '.png')
		x = x + 70
	end 
end

-- Desbloquea los aldeandos bloqueados
function Jugador:desbloquearAldeanos()
	self.aldeanosDisponibles = self.aldeanosDisponibles + self.aldeanosBloqueados
	self.aldeanosBloqueados = 0
end

-- Bloquea los aldeanos por el uso de alguna ficha
function Jugador:bloquearAldeanos(n)
	self.aldeanosDisponibles = self.aldeanosDisponibles - n
	self.aldeanosBloqueados = self.aldeanosBloqueados + n
end

-- Suma los aldeanos posibles
function Jugador:sumarAldeanos(n)
	if n < aldeanosCantidad then
		self.aldeanosBloqueados = self.aldeanosBloqueados + n
		aldeanosCantidad = aldeanosCantidad - n
	else
		self.aldeanosBloqueados = self.aldeanosBloqueados + aldeanosCantidad
		aldeanosCantidad = 0
	end
end

-- Resta los aldeanos posibles
function Jugador:restarAldeanos(n)
	res = nil

	if n <= self.aldeanosDisponibles then
		res = n

		self.aldeanosDisponibles = self.aldeanosDisponibles - n
		aldeanosCantidad = aldeanosCantidad + n
	else
		res = self.aldeanosDisponibles

		n = n - self.aldeanosDisponibles
		aldeanosCantidad = aldeanosCantidad + self.aldeanosDisponibles
		self.aldeanosDisponibles = 0
		if n <= self.aldeanosBloqueados then
			res = res + n

			self.aldeanosBloqueados = self.aldeanosBloqueados - n
			aldeanosCantidad = aldeanosCantidad + n
		else
			res = res + self.aldeanosBloqueados

			aldeanosCantidad = aldeanosCantidad + self.aldeanosBloqueados
			self.aldeanosBloqueados = 0
		end
	end

	return res
end

--[[ Pasos a seguir:
- Comprobar que tiene aldeanos suficientes
- Desbloquear la ficha y restar los aldeanos
- Actualizar posiciones de las fichas (tienen que seguir ordenadas)
]]
function Jugador:comprar(t)
	if self.aldeanosDisponibles >= getCosteCompra(t) then
		self.fichas[t].comprada = true
		self.fichas[t].turnosEspera = 1
		self:bloquearAldeanos(getCosteCompra(t))

		ordenadas = self:fichasOrdenadas()
		x = jugActualFichaPosX
		for k, v in pairs(ordenadas) do
			self.fichas[v.nombre].posX = x
			x = x + 70
		end
	end
end

--[[ Devolver las fichas en orden:
1 - Primero las compradas ordenadas por coste de uso
2 - Después las que puede comprar ordenadas por coste de compra
]]
function Jugador:fichasOrdenadas()
	res = {}

	fichasCompradas = {}
	fichasParaComprar = {}

	for k, v in pairs(self.fichas) do
		if v.comprada == true then
			table.insert(fichasCompradas, v.nombre)
		else
			table.insert(fichasParaComprar, v.nombre)
		end
	end

	table.sort(fichasCompradas, function(a, b) return getCosteUso(a) < getCosteUso(b) end)					-- miramos en fichasBD
	-- print("Fichas compradas por el jugador " .. 1); for k, v in pairs(fichasCompradas) do print(k, v, getCosteUso(v)) end
	
	table.sort(fichasParaComprar, function (a, b) return getCosteCompra(a) < getCosteCompra(b) end)			-- miramos en fichasBD
	-- print("Fichas para comprar por el jugador " .. 1); for k, v in pairs(fichasParaComprar) do print(k, v, getCosteCompra(v)) end

	for k, v in pairs(fichasCompradas) do
		res[#res + 1] = self.fichas[v]
	end

	for k, v in pairs(fichasParaComprar) do
		res[#res + 1] = self.fichas[v]
	end

	-- print("Fichas ordenadas para el jugador " .. 1); for k, v in pairs(res) do print(k, v.nombre, getCosteUso(v.nombre), getCosteCompra(v.nombre)) end

	return res
end

-- Actualiza las posiciones de las fichas.
function Jugador:actualizarPosiciones(arriba)
	x, y = nil, nil
	if arriba == true then
		x = jugOtroFichaPosX
		y = jugOtroFichaPosY
	else
		x = jugActualFichaPosX
		y = jugActualFichaPosY
	end

	ordenadas = self:fichasOrdenadas()
	for k, v in pairs(ordenadas) do
		self.fichas[v.nombre].posX = x
		self.fichas[v.nombre].posY = y
		x = x + 70
	end
end

-- Activa una ficha. El parámetro "n" corresponde a los aldeanos que se jueguen con el Toa
function Jugador:activarFicha(t, n)
	fichasActivas[t] = { ficha = fichas[t], defensa = n }
end

-- Desactivar fichas al comienzo del turno
function Jugador:desactivarFichas()
	for k, v in pairs(fichasActivas) do
		if v.ficha.nombre ~= "toa" then
			
		end
	end
end