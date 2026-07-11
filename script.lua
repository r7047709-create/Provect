--[[
    SCRIPT: Gerador de Anomalias Aleatórias
    ONDE COLOCAR: ServerScriptService
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Configure aqui os objetos que podem virar anomalias (coloque-os em uma pasta na Workspace chamada "ObjetosDoHospital")
local pastaObjetos = workspace:FindFirstChild("ObjetosDoHospital")

-- Tempo em segundos entre as tentativas de gerar uma anomalia
local TEMPO_CHECAGEM = 15 
-- Chance de acontecer uma anomalia (0 a 100)
local CHANCE_ANOMALIA = 60 

if not pastaObjetos then
	warn("AVISO: Crie uma pasta chamada 'ObjetosDoHospital' na Workspace e coloque os objetos dentro!")
	return
end

local objetosDisponiveis = pastaObjetos:GetChildren()

-- Função para fazer um objeto sumir (Anomalia do Tipo: Sumiço)
local function sumirObjeto(objeto)
	if objeto:IsA("BasePart") then
		objeto.Transparency = 1
		objeto.CanCollide = false
	elseif objeto:IsA("Model") then
		for _, filho in ipairs(objeto:GetDescendants()) do
			if filho:IsA("BasePart") then
				filho.Transparency = 1
				filho.CanCollide = false
			end
		end
	end
	objeto:SetAttribute("AnomaliaAtiva", true)
	objeto:SetAttribute("TipoAnomalia", "Sumico")
	print("Anomalia: Um objeto sumiu no hospital! -> " .. objeto.Name)
end

-- Função para fazer o objeto crescer (Anomalia do Tipo: Tamanho)
local function crescerObjeto(objeto)
	if objeto:IsA("BasePart") then
		local novaEscala = objeto.Size * 2
		local tween = TweenService:Create(objeto, TweenInfo.new(1), {Size = novaEscala})
		tween:Play()
	elseif objeto:IsA("Model") then
		-- Para modelos inteiros, altera a escala do Model
		objeto:ScaleTo(objeto:GetScale() * 2)
	end
	objeto:SetAttribute("AnomaliaAtiva", true)
	objeto:SetAttribute("TipoAnomalia", "Tamanho")
	print("Anomalia: Um objeto cresceu misteriosamente! -> " .. objeto.Name)
end

-- Loop principal que gera o mistério no mapa
while true do
	task.wait(TEMPO_CHECAGEM)
	
	-- Sorteia se vai acontecer uma anomalia nesta rodada
	if math.random(1, 100) <= CHANCE_ANOMALIA then
		-- Filtra objetos que já não estejam bugados
		local possiveisAlvos = {}
		for _, obj in ipairs(objetosDisponiveis) do
			if not obj:GetAttribute("AnomaliaAtiva") then
				table.insert(possiveisAlvos, obj)
			end
		end
		
		-- Se tiver algum objeto normal, escolhe um e aplica o susto
		if #possiveisAlvos > 0 then
			local objetoEscolhido = possiveisAlvos[math.random(1, #possiveisAlvos)]
			local tipoSorteado = math.random(1, 2)
			
			if tipoSorteado == 1 then
				sumirObjeto(objetoEscolhido)
			else
				crescerObjeto(objetoEscolhido)
			end
		end
	end
end
