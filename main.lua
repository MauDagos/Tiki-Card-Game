debug = true

-- Importar
require "enum"
require "imgButton"
require "fichasBD"
require "jugador"
require "posicionesBD"

-- Fichas
crearFichasBD()

-- Escala de las fichas
escalaFicha = 0.00025 * love.graphics.getHeight()

-- Máscaras para las fichas
mascaraComprar = nil

-- Backgrounds
bgImg = nil
bgOscuroImg = nil

-- Iconos de jugadores
iconosImg = {}
iconos = {}
contIcono = 1

-- Botones
botonCancelar = nil
botonComprar = nil
botonJugarCarta = nil
botonPasarTurno = nil
botonSeleccionar = nil

botonesMirar = {}
botonesMirarJug = {}

-- Aldeanos
aldeanoFicha = nil
aldeanaFicha = nil
aldeanosMaxCantidad = 200
aldeanosCantidad = aldeanosMaxCantidad

-- Jugadores
jugadores = { Jugador:new(1, "azul")
				, Jugador:new(2, "amarillo")
				, Jugador:new(3, "verde")
			}
fichasArray = {"kahuna", "jefe", "toa", "moai", "chaman", "monstruo", "heroe", "monstruo2", "generoso", "prosperidad"}
--[[ IMPORTANTE:
Presuponemos que vienen ordenadas:
- Primero las gratuitas según el coste de uso
- Después las comprables por coste de compra
]]

-- Ficha seleccionada
fichaElegida = nil
fichaElegidaJugar = nil
jugable = false
comprable = false

-- Jugador seleccionado para mirar
mirar = nil

-- Turno
turno = nil

--[[ Fase del turno
1 ---->	Para seleccionar qué ficha jugar o comprar
		Pasa a fase 2 cuando se selecciona una carta que precisa seleccionar otro jugador
		Pasa a fase 3 cuando se selecciona Moai o Toa
		También en esta fase es cuando se pasa el turno
2 ---->	Para seleccionar con qué jugador interactúa la ficha seleccionada
		Pasa a fase 1 si se cancela la jugada
3 ----> Para seleccionar con cuántos aldeanos jugar las cartas Moai o Toa
		Pasa a fase 1 si se cancela la jugada
4 ---->	Para seleccionar una ficha en el caso de jugar Moai o Dios Vengativo
		Moai -> Pasa a fase 3 si se cancela la jugada
		Dios Vengativo -> Pasa a fase 1 si se cancela la jugada
]]
fase = 1

function love.load(arg)
	love.graphics.setNewFont("assets/fonts/Tiki Tropic.ttf", 16)

	bgImg = love.graphics.newImage('assets/bg/wood.jpg')
	bgOscuroImg = love.graphics.newImage('assets/bg/fondo-alfa.png')

	mascaraComprar = love.graphics.newImage('assets/mascaras/comprar.png')

	for i = 1, #jugadores do
		iconosImg[i] = love.graphics.newImage('assets/iconosJug/j' .. tostring(i) .. '-' .. jugadores[i].color .. '.png')
	end

	for i = 2, #jugadores do
		iconos[i - 1] = ImgButton:new("icono" .. tostring(i - 1),
										iconosImg[i],
										iconosPosX[i - 1],
										iconosPosY,
										0)

		botonesMirar[i - 1] = ImgButton:new("mirar" .. tostring(i - 1),
											love.graphics.newImage('assets/botones/ojo.png'),
											iconosPosX[i - 1] + 70,
											iconosPosY,
											0)

		botonesMirarJug[i - 1] = i
	end

	botonCancelar = ImgButton:new("cancelar",
									love.graphics.newImage('assets/botones/cancelar.png'),
									love.graphics.getWidth() - 50,
									love.graphics.getHeight() - 50,
									0)
	botonComprar = ImgButton:new("comprar",
									love.graphics.newImage('assets/botones/comprar.png'),
									love.graphics.getWidth() / 2 + 320,
									love.graphics.getHeight() / 2 - 50,
									0)
	botonJugarCarta = ImgButton:new("jugarCarta",
									love.graphics.newImage('assets/botones/jugar.png'),
									love.graphics.getWidth() / 2 + 320,
									love.graphics.getHeight() / 2 - 50,
									0)
	botonPasarTurno = ImgButton:new("pasarTurno",
									love.graphics.newImage('assets/botones/pasar.png'),
									love.graphics.getWidth() - 150,
									love.graphics.getHeight() - 100,
									0)
	botonSeleccionar = ImgButton:new("seleccionar",
									love.graphics.newImage('assets/botones/seleccionar.png'),
									200,
									170,
									0)

	aldeanoFicha = ImgButton:new("aldeano",
								love.graphics.newImage('assets/fichas/aldeano.png'),
								love.graphics:getWidth() / 2 - 80,
								love.graphics:getHeight() / 2,
								0)
	aldeanaFicha = ImgButton:new("aldeana",
								love.graphics.newImage('assets/fichas/aldeana.png'),
								love.graphics:getWidth() / 2 - 10,
								love.graphics:getHeight() / 2,
								0)

	for index, jug in pairs(jugadores) do
		print("Jugador " .. index)
		jug:crearFichas(fichasArray)
	end

	iniciar()
end

-- Al principio del juego todos empiezan con 5 aldeanos. El primero recibe uno por el Jefe de la Tribu
function iniciar()
	for index, jug in pairs(jugadores) do
		jug:sumarAldeanos(30)
		jug:desbloquearAldeanos()
	end
	
	turno = 1
	jugadores[turno]:sumarAldeanos(1)
end

-- Al comienzo de cada turno se desbloquean los aldeanos y se recibe 1 aldeano por el Jefe de la Tribu
function siguiente()
	-- Actualizar posiciones de fichas del jugador actual
	jugadores[turno]:actualizarPosiciones(true)

	-- Actualizar iconos
	iconos[contIcono].img = iconosImg[turno]
	botonesMirarJug[contIcono] = turno
	if contIcono == #jugadores - 1 then
		contIcono = 1
	else
		contIcono = contIcono + 1
	end

	-- Actualizar turno
	if turno == #jugadores then
		turno = 1
	else
		turno = turno + 1
	end

	jugadores[turno]:desbloquearAldeanos()
	jugadores[turno]:sumarAldeanos(1)
	mirar = nil
	fichaElegida = nil
	jugable = false
	comprable = false

	-- Actualizar posiciones de fichas del nuevo jugador
	jugadores[turno]:actualizarPosiciones(false)
end

-- Jugar ficha
function jugar()
	if fichaElegidaJugar.nombre == "chaman" then

		if fase == 1 then
			fase = 2
		elseif fase == 2 then
			jugadores[turno]:bloquearAldeanos(getCosteUso(fichaElegidaJugar.nombre))

			jugadores[turno]:sumarAldeanos(3)
			jugadores[mirar]:sumarAldeanos(1)

			fase = 1
		end

	elseif fichaElegidaJugar.nombre == "generoso" then

		jugadores[turno]:bloquearAldeanos(getCosteUso(fichaElegidaJugar.nombre))

		for i = 1, #jugadores do
			if i ~= turno then
				jugadores[turno]:sumarAldeanos(jugadores[i]:restarAldeanos(3))
			end
		end

	elseif fichaElegidaJugar.nombre == "granchaman" then

		--[[
		]]

	elseif fichaElegidaJugar.nombre == "granmonstruo" then

		if fase == 1 then
			fase = 2
		elseif fase == 2 then
			jugadores[turno]:bloquearAldeanos(getCosteUso(fichaElegidaJugar.nombre))

			jugadores[mirar]:restarAldeanos(10)

			fase = 1
		end

	elseif fichaElegidaJugar.nombre == "guerrero" or fichaElegidaJugar.nombre == "guerrero2" then

		if fase == 1 then
			fase = 2
		elseif fase == 2 then
			jugadores[turno]:bloquearAldeanos(getCosteUso(fichaElegidaJugar.nombre))

			jugadores[mirar]:restarAldeanos(5)

			fase = 1
		end

	elseif fichaElegidaJugar.nombre == "heroe" then

		--[[
		]]

	elseif fichaElegidaJugar.nombre == "kahuna" then

		--[[
		]]

	elseif fichaElegidaJugar.nombre == "moai" then

		if fase == 1 then
			fase = 2
		elseif fase == 3 then

			--[[
			]]

			fase = 1
		end

	elseif fichaElegidaJugar.nombre == "monstruo" or fichaElegidaJugar.nombre == "monstruo2" then

		if fase == 1 then
			fase = 2
		elseif fase == 2 then
			jugadores[turno]:bloquearAldeanos(getCosteUso(fichaElegidaJugar.nombre))

			jugadores[mirar]:restarAldeanos(3)

			fase = 1
		end

	elseif fichaElegidaJugar.nombre == "necrochaman" then

		if fase == 1 then
			fase = 2
		elseif fase == 2 then

			--[[
			]]

			fase = 1
		end

	elseif fichaElegidaJugar.nombre == "prosperidad" then

		if fase == 1 then
			fase = 2
		elseif fase == 2 then
			jugadores[turno]:bloquearAldeanos(getCosteUso(fichaElegidaJugar.nombre))

			jugadores[turno]:sumarAldeanos(5)
			jugadores[mirar]:sumarAldeanos(3)

			fase = 1
		end

	elseif fichaElegidaJugar.nombre == "regenerativo" then

		--[[
		]]

	elseif fichaElegidaJugar.nombre == "toa" then

		if fase == 1 then
			fase = 3
		elseif fase == 3 then
		
			--[[
			]]

			fase = 1
		end

	elseif fichaElegidaJugar.nombre == "vengativo" then
		if fase == 1 then
			fase = 2
		elseif fase == 2 then

			--[[
			]]

			fase = 1
		end
	end
end

-- Comprar ficha
function  comprar()
	jugadores[turno]:comprar(fichaElegida.nombre)
	fichaElegida = nil
	comprable = false
end

function love.mousepressed(x, y, button)
	if(button == 1) then
		-- Comprobar si ha seleccionado mirar las fichas de otro jugador
		for i = 1, #botonesMirar do
			if botonesMirar[i]:inScope(x, y) then
				mirar = botonesMirarJug[i]
				return
			end
		end

		-- Comprobar si ha seleccionado el botón de jugar carta
		if fase == 1 and fichaElegida ~= nil and jugable == true then
			if botonJugarCarta:inScope(x, y) then
				fichaElegidaJugar = fichaElegida
				jugar()
				fichaElegida = nil
				return
			end
		end

		-- Comprobar si ha seleccionado el botón de seleccionar
		if fase == 2 and mirar ~= nil and fichaElegida == nil then		-- por seguridad para el jugador
			if botonSeleccionar:inScope(x, y) then
				jugar()
			end
		end

		-- Comprobar si ha seleccionado el botón de comprar
		if fase == 1 and fichaElegida ~= nil and comprable == true then
			if botonComprar:inScope(x, y) then
				comprar()
				return
			end
		end

		-- Comprobar si ha seleccionado el botón de pasar turno
		if fase == 1 and fichaElegida == nil then		-- por seguridad para el jugador
			if botonPasarTurno:inScope(x, y) then
				siguiente()
				return
			end
		end

		-- Comprobar si ha seleccionado una ficha
		fichaElegida = nil
		if aldeanoFicha:inScope(x, y) then
			fichaElegida = aldeanoFicha
			jugable = false
			comprable = false
		elseif aldeanaFicha:inScope(x, y) then
			fichaElegida = aldeanaFicha
			jugable = false
			comprable = false
		else
			for index, jug in pairs(jugadores) do
				for fichaIndex, ficha in pairs(jug.fichas) do
					if jug.num == turno or jug.num == mirar then
						if ficha:inScope(x, y) then
							print("Click en " .. ficha.nombre .. " " .. jug.color)
							fichaElegida = ficha
							if jug.num == turno and fichaElegida.nombre ~= "jefe" then 
								if fichaElegida.comprada == true then
									jugable = true
									comprable = false
								else
									jugable = false
									comprable = true
								end
							else
								jugable = false
								comprable = false
							end
							break
						end
					end
				end
			end
		end
	end
end

function love.update(dt)

end

function love.draw(dt)
	-- Rellenar fondo
	for j = 0, love.graphics:getHeight(), bgImg:getHeight() do
		for i = 0, love.graphics:getWidth(), bgImg:getWidth() do
			love.graphics.draw(bgImg, i, j)
		end
	end

	-- Mostrar cantidad de aldeanos disponibles en el centro
	originX, originY = aldeanoFicha:center()
	love.graphics.draw(aldeanoFicha.img, aldeanoFicha.posX, aldeanoFicha.posY, 0, escalaFicha, escalaFicha, originX, originY)
	originX, originY = aldeanaFicha:center()
	love.graphics.draw(aldeanaFicha.img, aldeanaFicha.posX, aldeanaFicha.posY, 0, escalaFicha, escalaFicha, originX, originY)
	love.graphics.print("x " .. tostring(aldeanosCantidad), love.graphics:getWidth() / 2 + 40, love.graphics:getHeight() / 2)

	-- Mostrar fichas del jugador actual
	for fichaIndex, ficha in pairs(jugadores[turno].fichas) do
		originX, originY = ficha:center()
		love.graphics.draw(ficha.img, ficha.posX, ficha.posY, ficha.rot, escalaFicha, escalaFicha, originX, originY)

		-- Añadir máscara de comprar en caso de no estar comprada
		if jugadores[turno].fichas[ficha.nombre].comprada == false then
			love.graphics.draw(mascaraComprar, ficha.posX, ficha.posY, ficha.rot, escalaFicha, escalaFicha, originX, originY)
		end
	end

	-- Mostrar cantidad de aldeanos del jugador actual
	love.graphics.print("Disponibles: " .. tostring(jugadores[turno].aldeanosDisponibles), 960, love.graphics:getHeight() - 130)
	love.graphics.print("Bloqueados: " .. tostring(jugadores[turno].aldeanosBloqueados), 960, love.graphics:getHeight() - 100)

	-- Mostrar botón de pasar turno
	if fase == 1 then
		originX, originY = botonPasarTurno:center()
		love.graphics.draw(botonPasarTurno.img, botonPasarTurno.posX, botonPasarTurno.posY, 0, escalaFicha, escalaFicha, originX, originY)
	end

	-- Mostrar en zona superior la posibilidad de ver las fichas de los demás jugadores
	for i = 1, #iconos do
		originX, originY = iconos[i]:center()
		love.graphics.draw(iconos[i].img, iconos[i].posX, iconos[i].posY, 0, escalaFicha, escalaFicha, originX, originY)

		originX, originY = botonesMirar[i]:center()
		love.graphics.draw(botonesMirar[i].img, botonesMirar[i].posX, botonesMirar[i].posY, 0, escalaFicha, escalaFicha, originX, originY)
	end

	-- Mostrar fichas de otro jugador
	if mirar ~= nil then
		for fichaIndex, ficha in pairs(jugadores[mirar].fichas) do
			originX, originY = ficha:center()
			love.graphics.draw(ficha.img, ficha.posX, ficha.posY, ficha.rot, escalaFicha, escalaFicha, originX, originY)

			-- Añadir máscara de comprar en caso de no estar comprada
			if jugadores[mirar].fichas[ficha.nombre].comprada == false then
				love.graphics.draw(mascaraComprar, ficha.posX, ficha.posY, ficha.rot, escalaFicha, escalaFicha, originX, originY)
			end
		end

		love.graphics.print("Disponibles: " .. tostring(jugadores[mirar].aldeanosDisponibles), 960, 130)
		love.graphics.print("Bloqueados: " .. tostring(jugadores[mirar].aldeanosBloqueados), 960, 160)
	end

	-- Mostrar botón de seleccionar
	if fase == 2 and mirar ~= nil then
		originX, originY = botonSeleccionar:center()
		love.graphics.draw(botonSeleccionar.img, botonSeleccionar.posX, botonSeleccionar.posY, 0, escalaFicha, escalaFicha, originX, originY)
	end

	-- Mostrar ficha elegida (si existe)
	if fichaElegida ~= nil then
		-- Oscurecer mesa con fichas
		for j = 0, love.graphics:getHeight(), bgImg:getHeight() do
			for i = 0, love.graphics:getWidth(), bgImg:getWidth() do
				love.graphics.draw(bgOscuroImg, i, j)
			end
		end

		-- Mostrar ficha elegida
		love.graphics.draw(fichaElegida.img, love.graphics.getWidth() / 2 + 100, love.graphics.getHeight() / 2 - 170, 0, escalaFicha * 3, escalaFicha * 3, 0, 0)

		if fase == 1 then
			-- Boton para jugarla
			if jugable == true then
				originX, originY = botonJugarCarta:center()
				love.graphics.draw(botonJugarCarta.img, botonJugarCarta.posX, botonJugarCarta.posY, 0, escalaFicha, escalaFicha, originX, originY)
			end

			-- Boton para comprarla
			if comprable == true then
				originX, originY = botonComprar:center()
				love.graphics.draw(botonComprar.img, botonComprar.posX, botonComprar.posY, 0, escalaFicha, escalaFicha, originX, originY)
			end
		end
	end
end