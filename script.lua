-- [[ DETECTOR DE ANOMALIAS + MISSÕES EM TEMPO REAL (ANTI-LAG) ]]
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- 1. ADICIONAR MARCADOR NOS PACIENTES (ATUALIZAÇÃO INSTANTÂNEA)
local function escaneadorDePacientes(npc)
    if not npc:IsA("Model") or npc == LocalPlayer.Character then return end
    if npc:FindFirstChild("MarcadorHospital") then return end

    local head = npc:WaitForChild("Head", 5)
    if not head then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "MarcadorHospital"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextStrokeTransparency = 0
    label.TextSize = 16
    label.TextFont = Enum.Font.SourceSansBold
    label.Parent = billboard

    -- Verifica e atualiza os dados em tempo real quando algo muda no NPC
    local function atualizarDados()
        if not npc or not npc.Parent then return end
        
        local ehAnomalia = npc:FindFirstChild("Anomaly") or npc:GetAttribute("IsAnomaly") == true or string.find(string.lower(npc.Name), "anom")
        local estaQueimando = npc:FindFirstChildOfClass("Fire") or npc:FindFirstChild("Fire")
        
        if ehAnomalia then
            label.TextColor3 = Color3.fromRGB(255, 0, 0)
            label.Text = "⚠️ ANOMALIA DETECTADA!"
        elseif estaQueimando then
            label.TextColor3 = Color3.fromRGB(255, 100, 0)
            label.Text = "🔥 PACIENTE PEGANDO FOGO!"
        else
            label.TextColor3 = Color3.fromRGB(0, 255, 0)
            label.Text = "✅ PACIENTE NORMAL"
        end
    end

    -- Atualiza na hora e monitora mudanças internas
    atualizarDados()
    npc.ChildAdded:Connect(atualizarDados)
    npc.ChildRemoving:Connect(atualizarDados)
end

-- 2. INTERFACE DE MISSÃO NO TOPO DA TELA
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MissaoGuiRealTime"
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MissionFrame = Instance.new("Frame")
MissionFrame.Size = UDim2.new(0, 260, 0, 45)
MissionFrame.Position = UDim2.new(0.5, -130, 0.02, 0)
MissionFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MissionFrame.BackgroundTransparency = 0.2
MissionFrame.Parent = ScreenGui

local MissionLabel = Instance.new("TextLabel")
MissionLabel.Size = UDim2.new(1, 0, 1, 0)
MissionLabel.BackgroundTransparency = 1
MissionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
MissionLabel.TextSize = 14
MissionLabel.TextFont = Enum.Font.SourceSansBold
MissionLabel.Text = "📋 CARREGANDO MISSÃO ATUAL..."
MissionLabel.Parent = MissionFrame

-- Função para atualizar o texto da Missão
local function atualizarMissao()
    local dadosPlayer = LocalPlayer:FindFirstChild("leaderstats") or LocalPlayer:FindFirstChild("Data")
    local missaoAtual = LocalPlayer:FindFirstChild("CurrentMission") or LocalPlayer:FindFirstChild("Quest")
    
    if missaoAtual then
        MissionLabel.Text = "📋 MISSÃO: " .. tostring(missaoAtual.Value)
    elseif dadosPlayer and dadosPlayer:FindFirstChild("Task") then
        MissionLabel.Text = "📋 MISSÃO: " .. tostring(dadosPlayer.Task.Value)
    else
        MissionLabel.Text = "📋 Verifique o painel do Hospital!"
    end
end

-- Monitora mudanças de valores na sua missão instantaneamente
if LocalPlayer:FindFirstChild("CurrentMission") then LocalPlayer.CurrentMission.Changed:Connect(atualizarMissao) end
if LocalPlayer:FindFirstChild("Quest") then LocalPlayer.Quest.Changed:Connect(atualizarMissao) end

-- 3. ESCANEAMENTO DO WORKSPACE EM TEMPO REAL (EVENTO CONSTANTE)
local function verificarEAdicionar(obj)
    if obj:IsA("Model") and (obj:FindFirstChild("Head") or obj:FindFirstChild("Humanoid")) then
        escaneadorDePacientes(obj)
    end
end

-- Escaneia quem já está no mapa
for _, antigo in ipairs(Workspace:GetDescendants()) do
    pcall(verificarEAdicionar, antigo)
end

-- Monitora instantaneamente novos objetos entrando no jogo sem usar Loops pesados
Workspace.DescendantAdded:Connect(function(novoObjeto)
    pcall(verificarEAdicionar, novoObjeto)
end)

-- Roda uma checagem geral leve a cada 3 segundos apenas por segurança
task.spawn(function()
    while true do
        atualizarMissao()
        task.wait(3)
    end
end)

print("✔️ Modo Tempo Real Ativado! Monitorando tudo sem perder nada.")
