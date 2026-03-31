local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local player : Player? = Players.LocalPlayer
local playerGui : PlayerGui = player:WaitForChild("PlayerGui")
local renderSurfaceGui : SurfaceGui = playerGui:WaitForChild("RenderSurfaceGui")
local ditherScreenGui : ScreenGui = playerGui:WaitForChild("DitherScreenGui")
local ditherImageLabel : ImageLabel = ditherScreenGui:WaitForChild("ImageLabel")
local renderViewportFrame : ViewportFrame = renderSurfaceGui:WaitForChild("ViewportFrame")
local renderWorldModel : WorldModel = renderViewportFrame:WaitForChild("WorldModel")

local viewportCamera : Camera = Instance.new("Camera")

local renderViewPart : Part = Instance.new("Part")
renderViewPart.Size = Vector3.new(1, 1, 0.1)
renderViewPart.Transparency = 1
renderViewPart.Anchored = true
renderViewPart.CanCollide = false
renderViewPart.CanTouch = false
renderViewPart.CanQuery = false
renderViewPart.Locked = true
renderViewPart.Parent = workspace

renderSurfaceGui.Adornee = renderViewPart

local renderList : {[PVInstance] : PVInstance} = {}
local distanceFromCameraInStuds : number = 5

renderViewportFrame.CurrentCamera = viewportCamera

local function addObjectToRenderView(physicalObject : PVInstance, worldModel : WorldModel)
	if not physicalObject:IsA("PVInstance") then return end
	
	local renderObject = physicalObject:Clone()
	renderObject:RemoveTag("Render")
	renderObject.Parent = worldModel
	renderList[physicalObject] = renderObject
	
	--if physicalObject:IsA("BasePart") then
	--	physicalObject.Transparency = 1
	--end
	
	physicalObject.Destroying:Once(function()
		renderList[physicalObject] = nil
		renderObject:Destroy()
	end)
end

local function updateObjectsInRenderView()
	local wobbleStrength : Vector3 = ReplicatedStorage.Values.WobbleStrength.Value
	for _, physicalObject : Instance in CollectionService:GetTagged("Render") do
		if renderList[physicalObject] then continue end
		addObjectToRenderView(physicalObject, renderWorldModel)
	end
	
	for physicalObject : PVInstance, renderObject : PVInstance in renderList do
		renderObject:PivotTo(physicalObject:GetPivot() + Vector3.one * wobbleStrength)
		if physicalObject:IsA("BasePart") then
			renderObject.Color = physicalObject.Color
			renderObject.Material = physicalObject.Material
			renderObject.Transparency = physicalObject.Transparency
			renderObject.Reflectance = physicalObject.Reflectance
			renderObject.LocalTransparencyModifier = physicalObject.LocalTransparencyModifier
		end
	end
end

local function updateCamera()
	local wobbleStrength : Vector3 = ReplicatedStorage.Values.WobbleStrength.Value
	viewportCamera.CFrame = workspace.CurrentCamera.CFrame + Vector3.one * wobbleStrength
end

local function updateRenderViewPart()
	local camera : Camera = workspace.CurrentCamera
	local cameraCFrame = camera:GetRenderCFrame()
	local heightInStuds : number = math.tan(math.rad(camera.FieldOfView/2)) * 2  * distanceFromCameraInStuds
	local aspecRatio : number = camera.ViewportSize.X / camera.ViewportSize.Y
	local widthInStuds : number = heightInStuds * aspecRatio
	
	renderViewPart.CFrame = cameraCFrame + cameraCFrame.LookVector * (renderViewPart.Size.Z * 0.5 + distanceFromCameraInStuds)
	renderViewPart.Size = Vector3.new(widthInStuds, heightInStuds, renderViewPart.Size.Z)
end

local function updateSurfaceGuiResolution()
	local verticalResolution : number = ReplicatedStorage.Values.VerticalResolution.Value
	local camera : Camera = workspace.CurrentCamera
	local aspecRatio : number = camera.ViewportSize.X / camera.ViewportSize.Y
	renderSurfaceGui.CanvasSize = Vector2.new(verticalResolution * aspecRatio, verticalResolution)
end

local function updateDitherTileSize()
	local verticalResolution : number = ReplicatedStorage.Values.VerticalResolution.Value
	local camera : Camera = workspace.CurrentCamera
	local aspecRatio : number = camera.ViewportSize.X / camera.ViewportSize.Y
	local downSampleRatio : number = camera.ViewportSize.Y / verticalResolution 
	local tileSizeInPixels : number = 4 * downSampleRatio
	ditherImageLabel.TileSize = UDim2.new(0, tileSizeInPixels, 0, tileSizeInPixels)
end

local function updateRenderView()
	updateRenderViewPart()
	updateSurfaceGuiResolution()
	updateDitherTileSize()
	updateObjectsInRenderView()
	updateCamera()
end

RunService:BindToRenderStep("RenderView", Enum.RenderPriority.Camera.Value + 1, updateRenderView)