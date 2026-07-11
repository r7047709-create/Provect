--[[
    SCRIPT: Sistema de Missões Flutuantes (Ultra Otimizado para FPS)
    ONDE COLOCAR: ServerScriptService
--]]

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local placaOriginal = ServerStorage:FindFirstChild("PlacaMissao")

local tarefas = {
	"Atender na Recepção 📋",
	"Checar Anomalias ⚠️",
	"Dar Remédio ao Paciente 💊",
	"Olhar Câmeras 📹"
}

if not placaOriginal then
	warn("ERRO: Coloque o BillboardGui com o nome 'PlacaMissao' no ServerStorage!")
	return
end

-- Deixa a placa invisível por padrão no armazenamento para economizar memória
placaOriginal.Enabled = true

local function gerenciarMissao(player, textLabel)
	while player and player.Parent and player:IsDescendantOf(Players) do
		-- Só atualiza se o personagem existir e estiver vivo no mapa
		local character = player.Character
		if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
			local missaoSorteada = tarefas[math.random(1, #tarefas)]
			textLabel.Text = missaoSorteada
		end
		task.wait(25) -- Aumentado para 25s para poupar processamento e dar mais FPS
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local head = character:WaitForChild("Head", 5)
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
		
		if head and humanoidRootPart then
			local novaPlaca = placaOriginal:Clone()
			local textLabel = novaPlaca:FindFirstChildOfClass("TextLabel")
			
			-- Otimização gráfica: Reduz a distância que os outros conseguem ver o texto (evita lag)
			novaPlaca.MaxDistance = 60 
			novaPlaca.Adornee = humanoidRootPart
			novaPlaca.Parent = head
			
			if textLabel then
				task.spawn(gerenciarMissao, player, textLabel)
			end
		end
	end
end)
	
