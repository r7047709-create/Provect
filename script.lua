--[[
    SCRIPT: Sistema de Missões, Velocidade, Guia Visual e Proteção (Completo)
    ONDE COLOCAR: ServerScriptService (Script Normal)
--]]

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

--------------------------------------------------------------------------------
-- 🛡️ CONFIGURAÇÃO DE SEGURANÇA (LISTA NEGRA)
--------------------------------------------------------------------------------
-- Coloque aqui o NOME EXATO dos jogadores que você quer banir do seu mapa
local listaNegra = {
	["NomeDoJogadorBanido1"] = true,
	["NomeDoJogadorBanido2"] = true,
}

--------------------------------------------------------------------------------
-- 📋 CONFIGURAÇÕES DO SISTEMA DE MISSÕES
--------------------------------------------------------------------------------
local placaOriginal = ServerStorage:FindFirstChild("PlacaMissao")
local pastaLocais = Workspace:FindFirstChild("LocaisDasMissoes")

local tarefas = {
	[1] = "Atender na Recepção 📋",
	[2] = "Checar Anomalias ⚠️",
	[3] = "Dar Remédio ao Paciente 💊",
	[4] = "Olhar Câmeras 📹"
}
local totalTarefas = #tarefas

-- Verificação de segurança no arranque do servidor
if not placaOriginal then
	warn("ERRO CRÍTICO: 'PlacaMissao' não foi encontrada no ServerStorage!")
	return
end

if not pastaLocais then
	warn("ERRO CRÍTICO: Pasta 'LocaisDasMissoes' não foi encontrada no Workspace!")
	return
end

--------------------------------------------------------------------------------
-- ⚡ FUNÇÕES DO SISTEMA (MECÂNICAS E OTIMIZAÇÃO)
--------------------------------------------------------------------------------

-- Remove a guia antiga limpando o cache de memória
local function limparGuia(character)
	if not character then return end
	local antigaGuia = character:FindFirstChild("GuiaMissao")
	if antigaGuia then 
		antigaGuia:Destroy() 
	end
end

-- Atualiza o feixe de luz (Beam) em tempo real
local function atualizarGuia(character, localAlvo)
	limparGuia(character)

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp or not localAlvo then return end

	local pastaGuia = Instance.new("Folder")
	pastaGuia.Name = "GuiaMissao"
	
	local attJogador = Instance.new("Attachment")
	attJogador.Name = "PontoJogador"
	attJogador.Parent = hrp

	local attAlvo = Instance.new("Attachment")
	attAlvo.Name = "PontoAlvo"
	attAlvo.Parent = localAlvo

	local beam = Instance.new("Beam")
	beam.Attachment0 = attJogador
	beam.Attachment1 = attAlvo
	beam.Width0 = 0.5
	beam.Width1 = 0.5
	beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 128)) -- Verde Neon de Alta Visibilidade
	beam.LightEmission = 0.8
	beam.FaceCamera = true
	beam.TextureSpeed = 1.5
	beam.Parent = pastaGuia
	
	pastaGuia.Parent = character
end

-- Loop contínuo gerenciador de missões
local function gerenciarMissao(player, textLabel, character)
	local humanoid = character:WaitForChild("Humanoid", 5)
	if not humanoid then return end
	
	local conexaoMorte
	conexaoMorte = humanoid.Died:Connect(function()
		limparGuia(character)
		if conexaoMorte then 
			conexaoMorte:Disconnect() 
			conexaoMorte = nil
		end
	end)

	-- Mantém o sistema rodando de forma ativa e sem janelas/abas
	while player and player.Parent and character and character.Parent and humanoid.Health > 0 do
		local indiceSorteado = math.random(1, totalTarefas)
		local missaoSorteada = tarefas[indiceSorteado]
		
		textLabel.Text = missaoSorteada
		
		local localAlvo = pastaLocais:FindFirstChild(missaoSorteada)
		if localAlvo then
			atualizarGuia(character, localAlvo)
		else
			limparGuia(character)
		end
		
		task.wait(25) -- Tempo de espera entre missões
	end
	
	if conexaoMorte then 
		conexaoMorte:Disconnect() 
		conexaoMorte = nil
	end
end

-- Configura os atributos do boneco (Velocidade e Placa)
local function inicializarPersonagem(player, character)
	local head = character:WaitForChild("Head", 5)
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
	local humanoid = character:WaitForChild("Humanoid", 5)
	
	if head and humanoidRootPart and humanoid then
		humanoid.WalkSpeed = 20 -- Deixa o boneco rápido (Velocidade 20)
		
		local novaPlaca = placaOriginal:Clone()
		local textLabel = novaPlaca:FindFirstChildOfClass("TextLabel")
		
		novaPlaca.MaxDistance = 50 -- Reduzido para economizar renderização e FPS
		novaPlaca.Adornee = humanoidRootPart
		novaPlaca.Parent = head
		
		if textLabel then
			task.spawn(gerenciarMissao, player, textLabel, character)
		end
	end
end

--------------------------------------------------------------------------------
-- 🔌 CONEXÕES GLOBAIS DE ENTRADA DO SERVIDOR
--------------------------------------------------------------------------------
Players.PlayerAdded:Connect(function(player)
	-- 1. PROTEÇÃO CONTRA LISTA NEGRA: Executa o banimento imediatamente na entrada
	if listaNegra[player.Name] then
		player:Kick("Você foi banido permanentemente deste mapa.")
		return
	end

	-- 2. Inicializa o personagem se ele já carregou
	if player.Character then
		task.spawn(inicializarPersonagem, player, player.Character)
	end
	
	-- 3. Configura futuros respawns do jogador
	player.CharacterAdded:Connect(function(character)
		inicializarPersonagem(player, character)
	end)
end)
