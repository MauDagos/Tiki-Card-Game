--[[
Parecido a lo que hay en enum.lua podemos crear una tabla de manera
	nombre = {nombre, costeUso, costeCompra, turnosReposo}

Es decir, el nombre (índice) de cada ficha sería su nombre
]]

-- require "enum"

-- Tabla de fichas
local fichas = {}

-- Necesario llamar antes de hacer cualquier otra cosa
function crearFichasBD()
	-- Base de datos de fichas
	local fichasBD = {
		{
			nombre = "chaman"
			, costeUso = 3
			, costeCompra = 0
			, turnosReposo = 1
		},
		{
			nombre = "heroe"
			, costeUso = 5
			, costeCompra = 0
			, turnosReposo = 1
		},
		{
			nombre = "jefe"
			, costeUso = 0
			, costeCompra = 0
			, turnosReposo = 0
		},
		{
			nombre = "kahuna"
			, costeUso = 0
			, costeCompra = 0
			, turnosReposo = 0
		},
		{
			nombre = "moai"
			, costeUso = 1		-- de 1 a 2
			, costeCompra = 0
			, turnosReposo = 1
		},
		{
			nombre = "monstruo"
			, costeUso = 3
			, costeCompra = 0
			, turnosReposo = 1
		},
		{
			nombre = "toa"
			, costeUso = 1		-- de 1 a 5
			, costeCompra = 0
			, turnosReposo = 1
		},
		{
			nombre = "generoso"
			, costeUso = 7
			, costeCompra = 10
			, turnosReposo = 2
		},
		{
			nombre = "granchaman"
			, costeUso = 1
			, costeCompra = 18
			, turnosReposo = 0
		},
		{
			nombre = "granmonstruo"
			, costeUso = 10
			, costeCompra = 16
			, turnosReposo = 2
		},
		{
			nombre = "guerrero2"
			, costeUso = 4
			, costeCompra = 8
			, turnosReposo = 1
		},
		{
			nombre = "guerrero"
			, costeUso = 4
			, costeCompra = 8
			, turnosReposo = 1
		},
		{
			nombre = "monstruo2"
			, costeUso = 3
			, costeCompra = 6
			, turnosReposo = 1
		},
		{
			nombre = "necrochaman"
			, costeUso = 3
			, costeCompra = 19
			, turnosReposo = 2
		},
		{
			nombre = "prosperidad"
			, costeUso = 7
			, costeCompra = 12
			, turnosReposo = 2
		},
		{
			nombre = "regenerativo"
			, costeUso = 5
			, costeCompra = 9
			, turnosReposo = 1
		},
		{
			nombre = "vengativo"
			, costeUso = 10
			, costeCompra = 18
			, turnosReposo = 2
		}
	}

	for index, f in pairs(fichasBD) do
		fichas[f.nombre] = f
	end

	-- print("Base de datos de fichas"); for k, v in pairs(fichas) do print(k, v.nombre) end
end

function getFichasPorNombre()
	res = {}

	for k, v in pairs(fichas) do
		table.insert(res, k)
	end

	table.sort(res)

	-- print("Fichas ordenadas por nombre"); for k, v in pairs(res) do print(k, fichas[v].nombre) end

	return res
end

function getFichasPorCosteUso()
	res = {}

	for k, v in pairs(fichas) do
		table.insert(res, k)
	end

	table.sort(res, function(a, b) return fichas[a].costeUso < fichas[b].costeUso end)

	-- print("Fichas ordenadas por coste de uso"); for k, v in pairs(res) do print(k, fichas[v].nombre, fichas[v].costeUso) end

	return res
end

function getFichasPorCosteCompra()
	res = {}

	for k, v in pairs(fichas) do
		table.insert(res, k)
	end

	table.sort(res, function(a, b) return fichas[a].costeCompra < fichas[b].costeCompra end)

	-- print("Fichas ordenadas por coste de compra"); for k, v in pairs(res) do print(k, fichas[v].nombre, fichas[v].costeCompra) end

	return res
end

function getNombre(t)
	return fichas[t].nombre
end

function getCosteUso(t)
	return fichas[t].costeUso
end

function getCosteCompra(t)
	return fichas[t].costeCompra
end