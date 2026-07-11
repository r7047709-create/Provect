-- [[ SCRIPT CORRIGIDO: Modificador Físico Local Persistente ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Configurações dos Atributos Físicos
local VELOCIDADE_DESEJADA = 20
local FORCA_PULO_DESEJADA = 70
local ALTURA_PULO_DESEJADA = 10

-- Função interna para aplicar e travar os atributos no seu Humanoid
local function gerenciarAtributosLocais(character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    if not humanoid then return end

    -- Aplica as configurações iniciais
    humanoid.WalkSpeed = VELOCIDADE_DESEJADA
    humanoid.UseJumpPower = true
    humanoid.JumpPower = FORCA_PULO_DESEJADA
    humanoid.JumpHeight = ALTURA_PULO_DESEJADA

    -- Conexão contínua: Impede que o jogo resete sua velocidade nativamente
    local conexao
    conexao = RunService.RenderStepped:Connect(function()
        -- Se o personagem morrer ou sumir, desliga esta conexão para não dar lag
        if not character or not character.Parent or not humanoid or humanoid.Health <= 0 then
            conexao:Disconnect()
            return
        end
        
        -- Força os valores a ficarem fixos no que você escolheu
        if humanoid.WalkSpeed ~= VELOCIDADE_DESEJADA then
            humanoid.WalkSpeed = VELOCIDADE_DESEJADA
        end
        if humanoid.JumpPower ~= FORCA_PULO_DESEJADA then
            humanoid.JumpPower = FORCA_PULO_DESEJADA
        end
    end)
end

-- Monitora quando você nasce ou renasce no jogo
LocalPlayer.CharacterAdded:Connect(function(novoPersonagem)
    gerenciarAtributosLocais(novoPersonagem)
end)

-- Executa imediatamente caso você já tenha spawnado no mapa
if LocalPlayer.Character then
    task.spawn(gerenciarAtributosLocais, LocalPlayer.Character)
end

print("✔️ [Modificador Local]: Script ativado com sucesso para " .. LocalPlayer.Name)
