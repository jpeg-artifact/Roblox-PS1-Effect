local InsertService = game:GetService("InsertService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterGui = game:GetService("StarterGui")

local insertedModel : Model = InsertService:LoadAsset(129499380745272)
local ps1EffectModel : Model = insertedModel:FindFirstChildOfClass("Model")
local tagList : Folder = ps1EffectModel:FindFirstChild("TagList")
local values : Folder = ps1EffectModel:FindFirstChild("Values")
local renderViewScript : Script = ps1EffectModel:FindFirstChild("RenderView")
local ditherScreenGui : ScreenGui = ps1EffectModel:FindFirstChild("DitherScreenGui")
local renderSurfaceGui : ScreenGui = ps1EffectModel:FindFirstChild("RenderSurfaceGui")

-- Add tags to TagList if TagList, else add tags to existing TagList in ServerStorage
if not ServerStorage:FindFirstChild("TagList") then
	tagList.Parent = ServerStorage
else
	for _, tag in tagList:GetChildren() do
		tag.Parent = ServerStorage:FindFirstChild("TagList")
	end
end

-- Add Values to ReplicatedStorage if not found, else add values to existing Values in ReplicatedStorage
if not ReplicatedStorage:FindFirstChild("Values") then
	values.Parent = ReplicatedStorage
else
	for _, value in values:GetChildren() do
		value.Parent = ReplicatedStorage:FindFirstChild("Values")
	end
end

-- Add RenderView to StarterPlayer
renderViewScript.Parent = StarterPlayer

-- Add DitherScreenGui to StarterGui
ditherScreenGui.Parent = StarterGui

-- Add RenderSurfaceGui to StarterGui
renderSurfaceGui.Parent = StarterGui

insertedModel:Destroy()