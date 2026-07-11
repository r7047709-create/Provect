--[[
    SCRIPT: Modificador Físico Persistente + Monitor + Anti-Cheat Ativo
    ONDE COLOCAR: ServerScriptService (Script Normal)
--]]

local Players = game:GetService("Players")
local Teams = game:GetService("Teams")

-- Configurações globais (Use variáveis locais fixas para performance)
local VELOCIDADE_PERMITIDA = 20
local FORCA_PULO_PERMITIDA = 70
local MARGEM_ERRO = 6 -- Tolerância para evitar expulsões por lag (ping alto)

-- Função otimizada para listar jogadores e suas respectivas equipes
local function atualizarEmostrarDados()
	print("\n--- 📋 [ATUALIZAÇÃO EM TEMPO REAL] JOGADORES E EQUIPES ---")
	local listaPlayers = Players:GetPlayers()
	
	if #listaPlayers == 0 then
		print("Nenhum jogador no servidor no momento.")
	else
		for _, player in ipairs(listaPlayers) do
			local nomeEquipe = player.Team and player.Team.Name or "Sem Equipe ❌"
			print("👉 Jogador: " .. player.Name .. " | Equipe: " .. nomeEquipe)
		end
	end
	print("---------------------------------------------------------\n")
end

-- Aplica os atributos físicos diretamente no Humanoid
local function aplicarAtributosFisicos(character)
	local humanoid = character:WaitForChild("Humanoid", 5)
	
	if humanoid then
		humanoid.WalkSpeed = VELOCIDADE_PERMITIDA         
		humanoid.UseJumpPower = true   
		humanoid.JumpPower = FORCA_PULO_PERMITIDA         
		humanoid.JumpHeight = 10        
	end
end

-- Monitoramento do lado do servidor para evitar trapaças/exploits de velocidade e pulo
local function iniciarAntiCheat(player, character)
	local humanoid = character:WaitForChild("Humanoid", 5)
	if not humanoid then return end

	task.spawn(function()
		-- O loop roda de forma leve e contínua enquanto o personagem estiver vivo no mapa
		while player and player.Parent and character and character.Parent and humanoid.Health > 0 do
			task.wait(1) -- Varredura a cada 1 segundo (não pesa nada no servidor)
			
			-- Se um executor externo alterar os valores locais, o servidor detecta a diferença física
			if humanoid.WalkSpeed > (VELOCIDADE_PERMITIDA + MARGEM_ERRO) then
				player:Kick("Banido do Servidor: Modificação ilegal de velocidade detectada (SpeedHack).")
				break
			end
			
			if humanoid.JumpPower > (FORCA_PULO_PERMITIDA + MARGEM_ERRO) then
				player:Kick("Banido do Servidor: Modificação ilegal de pulo detectada (JumpHack).")
				break
			end
		end
	end)
end

-- Gerenciamento de eventos de entrada dos jogadores
Players.PlayerAdded:Connect(function(player)
	-- Atualiza a listagem de equipes assim que o jogador entra
	atualizarEmostrarDados()
	
	-- Monitora se o jogador trocar de equipe no meio da partida
	player:GetPropertyChangedSignal("Team"):Connect(atualizarEmostrarDados)
	
	-- Garante que quando o jogador nascer (ou renascer após morrer), os atributos sejam reaplicados
	player.CharacterAdded:Connect(function(character)
		aplicarAtributosFisicos(character)
		iniciarAntiCheat(player, character)
	end)
	
	-- Caso o personagem já tenha carregado antes do script terminar de rodar
	if player.Character then
		task.spawn(aplicarAtributosFisicos, player.Character)
		task.spawn(iniciarAntiCheat, player, player.Character)
	end
end)

-- Atualiza a listagem de equipes quando alguém sai do jogo
Players.PlayerRemoving:Connect(function()
	task.defer(atualizarEmostrarDados)
end)
