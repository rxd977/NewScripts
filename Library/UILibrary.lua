local Trove = loadstring(game:HttpGet("https://raw.githubusercontent.com/rxd977/Scripts/refs/heads/main/Trove.lua"))()

local Library = {}
Library.Trove = Trove.new()

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local HiddenUI = gethui and gethui() or game:GetService("CoreGui")

local GuiInset = GuiService:GetGuiInset()

-- Utility Functions
local function Tween(object, properties, duration)
    duration = duration or 0.2
    local tween = TweenService:Create(object, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties)
    tween:Play()
    return tween
end

local function MakeDraggable(frame, handle, trove)
    local dragging, dragInput, dragStart, startPos
    
    trove:Connect(handle.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            trove:Connect(input.Changed, function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    trove:Connect(handle.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    trove:Connect(UserInputService.InputChanged, function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Main Library Functions
function Library:CreateWindow(title, icon, size)
    local Window = {}
    Window.Tabs = {}
    Window.CurrentTab = nil
    Window.Trove = Trove.new()
    Library.Trove:Add(Window.Trove)

    -- Create ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "UILibrary"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.OnTopOfCoreBlur = true 
    ScreenGui.DisplayOrder = 999
    ScreenGui.Parent = HiddenUI

    Window.Trove:Add(ScreenGui)
    
    -- Main Container
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.BorderSizePixel = 0
    Container.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
    Container.Size = size
    Container.AnchorPoint = Vector2.new(0.5, 0.5)
    Container.Position = UDim2.new(0.5, 0, 0.5, 0)
    Container.Parent = ScreenGui
        
    local ContainerCorner = Instance.new("UICorner", Container)
    
    -- Side Panel
    local Side = Instance.new("Frame")
    Side.Name = "Side"
    Side.BorderSizePixel = 0
    Side.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Side.ClipsDescendants = true
    Side.Size = UDim2.new(0, 71, 1, 0)
    Side.Parent = Container
    
    local SideStroke = Instance.new("UIStroke", Side)
    SideStroke.Thickness = 1.5
    SideStroke.Color = Color3.fromRGB(70, 70, 70)
    
    -- Icon Container
    local IconContainer = Instance.new("Frame")
    IconContainer.Name = "IconContainer"
    IconContainer.BorderSizePixel = 0
    IconContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    IconContainer.BackgroundTransparency = 1
    IconContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    IconContainer.Size = UDim2.new(0, 71, 0, 70)
    IconContainer.Position = UDim2.new(0.5, 0, 0, 35)
    IconContainer.Parent = Side
    
    local IconStroke = Instance.new("UIStroke", IconContainer)
    IconStroke.Thickness = 1.5
    IconStroke.Color = Color3.fromRGB(70, 70, 70)
    
    local Icon = Instance.new("ImageLabel")
    Icon.Name = "Icon"
    Icon.BorderSizePixel = 0
    Icon.BackgroundTransparency = 1
    Icon.AnchorPoint = Vector2.new(0.5, 0.5)
    Icon.Image = Library.AssetManager:GetAsset(icon)
    Icon.Size = UDim2.new(1, 0, 1, 0)
    Icon.Position = UDim2.new(0.5, 0, 0.5, 0)
    Icon.Parent = IconContainer
    
    -- Tabs Container
    local TabsContainer = Instance.new("Frame")
    TabsContainer.Name = "Tabs"
    TabsContainer.BorderSizePixel = 0
    TabsContainer.BackgroundTransparency = 1
    TabsContainer.Size = UDim2.new(0, 72, 1, 0)
    TabsContainer.Parent = Side
    
    local TabsList = Instance.new("UIListLayout")
    TabsList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabsList.Padding = UDim.new(0, 10)
    TabsList.SortOrder = Enum.SortOrder.LayoutOrder
    TabsList.Parent = TabsContainer
    
    local TabsPadding = Instance.new("UIPadding", TabsContainer)
    TabsPadding.PaddingTop = UDim.new(0, 85)
    
    -- Main Content Area
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.BorderSizePixel = 0
    Main.BackgroundTransparency = 1
    Main.ClipsDescendants = true
    Main.Size = UDim2.new(1, 0, 1, 0)
    Main.Parent = Container
    
    local MainPadding = Instance.new("UIPadding", Main)
    MainPadding.PaddingTop = UDim.new(0, 10)
    MainPadding.PaddingLeft = UDim.new(0, 90)
    MainPadding.PaddingBottom = UDim.new(0, 10)
    
    local MainLayout = Instance.new("UIListLayout", Main)
    MainLayout.Padding = UDim.new(0, 20)
    MainLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    MainLayout.SortOrder = Enum.SortOrder.LayoutOrder
    MainLayout.FillDirection = Enum.FillDirection.Horizontal
    
    -- Top Bar
    local Top = Instance.new("Frame")
    Top.Name = "Top"
    Top.BorderSizePixel = 0
    Top.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Top.ClipsDescendants = true
    Top.Size = UDim2.new(1, -73, 0, 25)
    Top.Position = UDim2.new(0, 72, 0, 0)
    Top.Parent = Container
    
    local TopStroke = Instance.new("UIStroke", Top)
    TopStroke.Thickness = 1.5
    TopStroke.Color = Color3.fromRGB(70, 70, 70)
    
    -- Bottom Bar
    local Bottom = Instance.new("Frame")
    Bottom.Name = "Bottom"
    Bottom.BorderSizePixel = 0
    Bottom.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Bottom.ClipsDescendants = true
    Bottom.Size = UDim2.new(1, -73, 0, 25)
    Bottom.Position = UDim2.new(0, 72, 1, -25)
    Bottom.Parent = Container
    
    local BottomStroke = Instance.new("UIStroke", Bottom)
    BottomStroke.Thickness = 1.5
    BottomStroke.Color = Color3.fromRGB(70, 70, 70)
    
    -- Make draggable
    MakeDraggable(Container, Top, Window.Trove)
    
    -- Tab Functions
    function Window:CreateTab(name, icon)
        local Tab = {}
        Tab.Sections = {}
        Tab.Name = name
        Tab.Trove = Trove.new()
        
        -- Tab Button (change Frame to ImageButton)
        local TabButton = Instance.new("ImageButton")
        TabButton.Name = name
        TabButton.BorderSizePixel = 0
        TabButton.BackgroundTransparency = 1
        TabButton.Size = UDim2.new(0, 62, 0, 70)
        TabButton.AutoButtonColor = false  -- Disable default button color changes
        TabButton.Parent = TabsContainer

        local TabIcon = Instance.new("ImageLabel")
        TabIcon.BorderSizePixel = 0
        TabIcon.BackgroundTransparency = 1
        TabIcon.ImageColor3 = Color3.fromRGB(96, 96, 96)
        TabIcon.AnchorPoint = Vector2.new(0.5, 0.5)
        TabIcon.Image = Library.AssetManager:GetAsset(icon)
        TabIcon.Size = UDim2.new(0, 35, 0, 35)
        TabIcon.Position = UDim2.new(0.5, 0, 0, 19)
        TabIcon.Parent = TabButton

        local TabLabel = Instance.new("TextLabel")
        TabLabel.TextWrapped = true
        TabLabel.BorderSizePixel = 0
        TabLabel.TextSize = 14
        TabLabel.TextScaled = true
        TabLabel.BackgroundTransparency = 1
        TabLabel.FontFace = Font.new("rbxasset://fonts/families/Bangers.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        TabLabel.TextColor3 = Color3.fromRGB(96, 96, 96)
        TabLabel.AnchorPoint = Vector2.new(0.5, 0.5)
        TabLabel.Size = UDim2.new(0, 61, 0, 18)
        TabLabel.Text = string.upper(name)
        TabLabel.Position = UDim2.new(0.5, 0, 0, 54)
        TabLabel.Parent = TabButton
        
        -- Tab Content Container
        local TabContent = Instance.new("Frame")
        TabContent.Name = name .. "Content"
        TabContent.Visible = false
        TabContent.BorderSizePixel = 0
        TabContent.BackgroundTransparency = 1
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.Parent = Main
        
        local ContentLayout = Instance.new("UIListLayout", TabContent)
        ContentLayout.Padding = UDim.new(0, 20)
        ContentLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.FillDirection = Enum.FillDirection.Horizontal
        
        -- Tab Selection Logic
        local function SelectTab()
            for _, tab in pairs(Window.Tabs) do
                tab.Content.Visible = false
                Tween(tab.Icon, {ImageColor3 = Color3.fromRGB(96, 96, 96)})
                Tween(tab.Label, {TextColor3 = Color3.fromRGB(96, 96, 96)})
            end
            
            TabContent.Visible = true
            Window.CurrentTab = Tab
            Tween(TabIcon, {ImageColor3 = Color3.fromRGB(208, 208, 208)})
            Tween(TabLabel, {TextColor3 = Color3.fromRGB(208, 208, 208)})
        end
        
        Tab.Trove:Connect(TabButton.MouseButton1Click, SelectTab)
        
        -- Section Functions
        function Tab:CreateSection(name)
            local Section = {}
            Section.Components = {}
            Section.Trove = Trove.new()
            
            -- Section Container
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = name
            SectionFrame.BorderSizePixel = 0
            SectionFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            SectionFrame.Size = UDim2.new(0, 200, 0, 377)
            SectionFrame.Parent = TabContent
            
            local SectionCorner = Instance.new("UICorner", SectionFrame)
            SectionCorner.CornerRadius = UDim.new(0, 5)
            
            local SectionStroke = Instance.new("UIStroke", SectionFrame)
            SectionStroke.Thickness = 1.5
            SectionStroke.Color = Color3.fromRGB(70, 70, 70)
            
            local SectionScroll = Instance.new("ScrollingFrame")
            SectionScroll.Active = true
            SectionScroll.BorderSizePixel = 0
            SectionScroll.BackgroundTransparency = 1
            SectionScroll.Size = UDim2.new(1, 0, 1, 0)
            SectionScroll.ScrollBarImageColor3 = Color3.fromRGB(96, 96, 96)
            SectionScroll.ScrollBarThickness = 2
            SectionScroll.Parent = SectionFrame
            
            local SectionList = Instance.new("UIListLayout", SectionScroll)
            SectionList.HorizontalAlignment = Enum.HorizontalAlignment.Center
            SectionList.SortOrder = Enum.SortOrder.LayoutOrder
            
            local SectionPadding = Instance.new("UIPadding", SectionScroll)
            SectionPadding.PaddingTop = UDim.new(0, 10)
            
            -- Auto-resize ScrollingFrame
            Section.Trove:Connect(SectionList:GetPropertyChangedSignal("AbsoluteContentSize"), function()
                SectionScroll.CanvasSize = UDim2.new(0, 0, 0, SectionList.AbsoluteContentSize.Y + 20)
            end)

            
            local function SetScrollingEnabled(bool)
                SectionScroll.ScrollingEnabled = bool
            end

            -- Title Component
            function Section:CreateTitle(text)
                local TitleFrame = Instance.new("Frame")
                TitleFrame.Name = "Title"
                TitleFrame.BorderSizePixel = 0
                TitleFrame.BackgroundTransparency = 1
                TitleFrame.Size = UDim2.new(0, 190, 0, 30)
                TitleFrame.Parent = SectionScroll
                
                local Title = Instance.new("TextLabel")
                Title.BorderSizePixel = 0
                Title.TextSize = 19
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.BackgroundTransparency = 1
                Title.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
                Title.TextColor3 = Color3.fromRGB(96, 96, 96)
                Title.Size = UDim2.new(0, 180, 0, 25)
                Title.Position = UDim2.new(0, 10, 0, 0)
                Title.Text = text:upper()
                Title.Parent = TitleFrame
                
                return {
                    SetText = function(newText)
                        Title.Text = newText
                    end
                }
            end
            
            -- Toggle Component
            function Section:CreateToggle(flag, name, description, default, callback)
                local toggled = default or false
                callback = callback or function() end
                local ComponentTrove = Trove.new()
                
                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Name = name
                ToggleFrame.BorderSizePixel = 0
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.Size = UDim2.new(0, 190, 0, 44)
                ToggleFrame.Parent = SectionScroll
                
                ComponentTrove:Add(ToggleFrame)
                
                local DisplayName = Instance.new("TextLabel")
                DisplayName.Name = "DisplayName"
                DisplayName.TextWrapped = true
                DisplayName.BorderSizePixel = 0
                DisplayName.TextSize = 14
                DisplayName.TextXAlignment = Enum.TextXAlignment.Left
                DisplayName.TextScaled = true
                DisplayName.BackgroundTransparency = 1
                DisplayName.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
                DisplayName.TextColor3 = Color3.fromRGB(188, 188, 188)
                DisplayName.Size = UDim2.new(0, 128, 0, 16)
                DisplayName.Text = name
                DisplayName.Position = UDim2.new(0, 10, 0, 0)
                DisplayName.Parent = ToggleFrame
                
                if description and description ~= "" then
                    local Desc = Instance.new("TextLabel")
                    Desc.Name = "Desc"
                    Desc.TextWrapped = true
                    Desc.BorderSizePixel = 0
                    Desc.TextSize = 14
                    Desc.TextXAlignment = Enum.TextXAlignment.Left
                    Desc.TextScaled = true
                    Desc.BackgroundTransparency = 1
                    Desc.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
                    Desc.TextColor3 = Color3.fromRGB(96, 96, 96)
                    Desc.Size = UDim2.new(0, 128, 0, 14)
                    Desc.Text = description
                    Desc.Position = UDim2.new(0, 10, 0, 20)
                    Desc.Parent = ToggleFrame
                end
                
                local ToggleButton = Instance.new("Frame")
                ToggleButton.Name = "Toggle"
                ToggleButton.BorderSizePixel = 0
                ToggleButton.BackgroundColor3 = toggled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(81, 81, 81)
                ToggleButton.Size = UDim2.new(0, 39, 0, 23)
                ToggleButton.Position = UDim2.new(0, 145, 0, 5)
                ToggleButton.Parent = ToggleFrame
                
                local ToggleCorner = Instance.new("UICorner", ToggleButton)
                ToggleCorner.CornerRadius = UDim.new(0, 20)
                
                local ToggleGradient = Instance.new("UIGradient", ToggleButton)
                ToggleGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 255)),
                    ColorSequenceKeypoint.new(0.3, Color3.fromRGB(180, 80, 255)),
                    ColorSequenceKeypoint.new(0.6, Color3.fromRGB(80, 180, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 255))
                }
                ToggleGradient.Enabled = toggled
                
                local Circle = Instance.new("Frame")
                Circle.Name = "Circle"
                Circle.BorderSizePixel = 0
                Circle.BackgroundColor3 = toggled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(175, 175, 175)
                Circle.Size = UDim2.new(0, 18, 0, 18)
                Circle.Position = toggled and UDim2.new(0, 18, 0, 2) or UDim2.new(0, 2, 0, 2)
                Circle.Parent = ToggleButton
                
                local CircleCorner = Instance.new("UICorner", Circle)
                CircleCorner.CornerRadius = UDim.new(0, 20)
                
                local function Toggle()
                    toggled = not toggled
                    
                    if toggled then
                        Tween(Circle, {
                            Position = UDim2.new(0, 18, 0, 2),
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        }, 0.35) 
                        ToggleGradient.Enabled = true
                    else
                        Tween(Circle, {
                            Position = UDim2.new(0, 2, 0, 2),
                            BackgroundColor3 = Color3.fromRGB(175, 175, 175)
                        }, 0.35)
                        ToggleGradient.Enabled = false
                        Tween(ToggleButton, {BackgroundColor3 = Color3.fromRGB(81, 81, 81)}, 0.35)
                    end
                    
                    callback(toggled)
                end
                                
                ComponentTrove:Connect(ToggleButton.InputBegan, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Toggle()
                    end
                end)

                Library:RegisterComponent(flag, "Toggle",
                    function() return toggled end,
                    function(value) 
                        if value ~= toggled then
                            Toggle()
                        end
                    end
                )
                
                Section.Trove:Add(ComponentTrove)
                
                return {
                    SetValue = function(value)
                        if value ~= toggled then
                            Toggle()
                        end
                    end,
                    Destroy = function()
                        ComponentTrove:Destroy()
                    end
                }
            end
            
            -- Slider Component
            function Section:CreateSlider(flag, name, min, max, default, callback)
                local value = default or min
                callback = callback or function() end

                local ComponentTrove = Trove.new()
                
                local SliderFrame = Instance.new("Frame")
                SliderFrame.Name = name
                SliderFrame.BorderSizePixel = 0
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.Size = UDim2.new(0, 190, 0, 44)
                SliderFrame.Parent = SectionScroll
                ComponentTrove:Add(SliderFrame)
                
                local DisplayName = Instance.new("TextLabel")
                DisplayName.TextWrapped = true
                DisplayName.BorderSizePixel = 0
                DisplayName.TextSize = 14
                DisplayName.TextXAlignment = Enum.TextXAlignment.Left
                DisplayName.TextScaled = true
                DisplayName.BackgroundTransparency = 1
                DisplayName.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
                DisplayName.TextColor3 = Color3.fromRGB(188, 188, 188)
                DisplayName.Size = UDim2.new(0, 145, 0, 16)
                DisplayName.Text = name
                DisplayName.Position = UDim2.new(0, 10, 0, 4)
                DisplayName.Parent = SliderFrame
                
                local Amount = Instance.new("TextLabel")
                Amount.TextWrapped = true
                Amount.BorderSizePixel = 0
                Amount.TextSize = 15
                Amount.TextXAlignment = Enum.TextXAlignment.Left
                Amount.BackgroundTransparency = 1
                Amount.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
                Amount.TextColor3 = Color3.fromRGB(188, 188, 188)
                Amount.Size = UDim2.new(0, 25, 0, 16)
                Amount.Text = tostring(value)
                Amount.Position = UDim2.new(0, 160, 0, 4)
                Amount.Parent = SliderFrame
                
                local BG = Instance.new("Frame")
                BG.Name = "BG"
                BG.BorderSizePixel = 0
                BG.Size = UDim2.new(0, 160, 0, 7)
                BG.Position = UDim2.new(0, 10, 0, 29)
                BG.Parent = SliderFrame

                local BGCorner = Instance.new("UICorner", BG)
                BGCorner.CornerRadius = UDim.new(0, 5)
                
                local Top = Instance.new("Frame")
                Top.Name = "Top"
                Top.BorderSizePixel = 0
                Top.Size = UDim2.new(0, 0, 1, 0)
                Top.Position = UDim2.new(0, 0, 0, 0)
                Top.Parent = BG

                local TopCorner = Instance.new("UICorner", Top)
                TopCorner.CornerRadius = UDim.new(0, 5)

                local TopGradient = Instance.new("UIGradient", Top)
                TopGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(210, 26, 255)),
                    ColorSequenceKeypoint.new(0.4, Color3.fromRGB(124, 0, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 202, 255))
                }
                
                local Circle = Instance.new("Frame")
                Circle.Name = "Circle"
                Circle.BorderSizePixel = 0
                Circle.Size = UDim2.new(0, 15, 0, 15)
                Circle.Position = UDim2.new(0, -7.5, 0, -4)
                Circle.Parent = BG
                
                local CircleCorner = Instance.new("UICorner", Circle)
                CircleCorner.CornerRadius = UDim.new(0, 20)
                
                local CircleGradient = Instance.new("UIGradient", Circle)
                CircleGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(210, 26, 255)),
                    ColorSequenceKeypoint.new(0.4, Color3.fromRGB(124, 0, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 202, 255))
                }
                
                local dragging = false
                local targetPixelWidth = 0
                local currentPixelWidth = 0
                local renderConnection
                
                local function UpdateSlider(input)
                    local pos = math.clamp(((input.Position.X) - BG.AbsolutePosition.X) / BG.AbsoluteSize.X, 0, 1)
                    value = math.floor(min + (max - min) * pos)
                    Amount.Text = tostring(value)
                    
                    targetPixelWidth = pos * BG.AbsoluteSize.X
                    
                    callback(value)
                end
                
                ComponentTrove:Connect(RunService.RenderStepped, function()
                    if math.abs(targetPixelWidth - currentPixelWidth) > 0.1 then
                        currentPixelWidth = math.lerp(currentPixelWidth, targetPixelWidth, 0.2)
                        Top.Size = UDim2.new(0, currentPixelWidth, 1, 0)
                        Circle.Position = UDim2.new(0, currentPixelWidth - 7.5, 0, -4)
                    else
                        currentPixelWidth = targetPixelWidth
                        Top.Size = UDim2.new(0, currentPixelWidth, 1, 0)
                        Circle.Position = UDim2.new(0, currentPixelWidth - 7.5, 0, -4)
                    end
                end)
                
                ComponentTrove:Connect(Circle.InputBegan, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                    end
                end)
                
                ComponentTrove:Connect(UserInputService.InputEnded, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                ComponentTrove:Connect(UserInputService.InputChanged, function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateSlider(input)
                    end
                end)
                
                local initialPos = (value - min) / (max - min)
                local initialPixels = initialPos * 160
                targetPixelWidth = initialPixels
                currentPixelWidth = initialPixels
                Top.Size = UDim2.new(0, initialPixels, 1, 0)
                Circle.Position = UDim2.new(0, initialPixels - 7.5, 0, -4)

                Library:RegisterComponent(flag, "Slider",
                    function() return value end,
                    function(val)
                        value = math.clamp(val, min, max)
                        Amount.Text = tostring(value)
                        local pos = (value - min) / (max - min)
                        targetPixelWidth = pos * 160
                        callback(value)
                    end
                )

                Section.Trove:Add(ComponentTrove)
                
                return {
                    SetValue = function(val)
                        value = math.clamp(val, min, max)
                        Amount.Text = tostring(value)
                        local pos = (value - min) / (max - min)
                        targetPixelWidth = pos * 160
                        callback(value)
                    end,
                    Destroy = function()
                        ComponentTrove:Destroy()
                    end
                }
            end
                                                
            -- Dropdown Component
            function Section:CreateDropdown(flag, name, options, default, callback)
                local selected = default or options[1]
                local opened = false
                callback = callback or function() end

                local ComponentTrove = Trove.new()
                
                local DropdownFrame = Instance.new("Frame")
                DropdownFrame.Name = name
                DropdownFrame.BorderSizePixel = 0
                DropdownFrame.BackgroundTransparency = 1
                DropdownFrame.Size = UDim2.new(0, 190, 0, 56)
                DropdownFrame.Parent = SectionScroll

                ComponentTrove:Add(DropdownFrame)
                
                local DisplayName = Instance.new("TextLabel")
                DisplayName.TextWrapped = true
                DisplayName.BorderSizePixel = 0
                DisplayName.TextSize = 14
                DisplayName.TextXAlignment = Enum.TextXAlignment.Left
                DisplayName.TextScaled = true
                DisplayName.BackgroundTransparency = 1
                DisplayName.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
                DisplayName.TextColor3 = Color3.fromRGB(188, 188, 188)
                DisplayName.Size = UDim2.new(0, 120, 0, 16)
                DisplayName.Text = name
                DisplayName.Position = UDim2.new(0, 10, 0, 4)
                DisplayName.Parent = DropdownFrame
                
                local DropdownButton = Instance.new("Frame")
                DropdownButton.Name = "Button"
                DropdownButton.BorderSizePixel = 0
                DropdownButton.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
                DropdownButton.Size = UDim2.new(0, 170, 0, 23)
                DropdownButton.Position = UDim2.new(0, 10, 0, 26)
                DropdownButton.Parent = DropdownFrame
                
                local ButtonCorner = Instance.new("UICorner", DropdownButton)
                ButtonCorner.CornerRadius = UDim.new(0, 4)
                
                local ButtonStroke = Instance.new("UIStroke", DropdownButton)
                ButtonStroke.Thickness = 1.5
                ButtonStroke.Color = Color3.fromRGB(70, 70, 70)
                
                local SelectedText = Instance.new("TextLabel")
                SelectedText.BorderSizePixel = 0
                SelectedText.TextSize = 12
                SelectedText.TextXAlignment = Enum.TextXAlignment.Left
                SelectedText.BackgroundTransparency = 1
                SelectedText.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
                SelectedText.TextColor3 = Color3.fromRGB(188, 188, 188)
                SelectedText.Size = UDim2.new(0, 140, 0, 20)
                SelectedText.Text = selected or "None"
                SelectedText.Position = UDim2.new(0, 8, 0, 1)
                SelectedText.Parent = DropdownButton
                
                local Arrow = Instance.new("TextLabel")
                Arrow.BorderSizePixel = 0
                Arrow.TextSize = 16
                Arrow.BackgroundTransparency = 1
                Arrow.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
                Arrow.TextColor3 = Color3.fromRGB(188, 188, 188)
                Arrow.Size = UDim2.new(0, 20, 0, 20)
                Arrow.Text = "▼"
                Arrow.Position = UDim2.new(1, -25, 0, 1)
                Arrow.Parent = DropdownButton
                
                local DropdownList = Instance.new("Frame")
                DropdownList.Name = "List_" .. name
                DropdownList.Visible = false
                DropdownList.ZIndex = 100
                DropdownList.BorderSizePixel = 0
                DropdownList.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                DropdownList.Size = UDim2.new(0, 170, 0, math.min(#options * 27 + 10, 120))
                DropdownList.Parent = ScreenGui
                
                local ListCorner = Instance.new("UICorner", DropdownList)
                ListCorner.CornerRadius = UDim.new(0, 5)
                
                local ListStroke = Instance.new("UIStroke", DropdownList)
                ListStroke.Thickness = 1.5
                ListStroke.Color = Color3.fromRGB(70, 70, 70)
                
                local ListScroll = Instance.new("ScrollingFrame")
                ListScroll.Active = true
                ListScroll.BorderSizePixel = 0
                ListScroll.BackgroundTransparency = 1
                ListScroll.Size = UDim2.new(1, -10, 1, -10)
                ListScroll.Position = UDim2.new(0, 5, 0, 5)
                ListScroll.ScrollBarImageColor3 = Color3.fromRGB(96, 96, 96)
                ListScroll.ScrollBarThickness = 2
                ListScroll.ZIndex = 101
                ListScroll.Parent = DropdownList
                
                local ListLayout = Instance.new("UIListLayout", ListScroll)
                ListLayout.Padding = UDim.new(0, 2)
                ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                
                -- Function to update dropdown list position
                local function UpdateDropdownPosition()
                    if DropdownButton and DropdownButton.Parent then
                        local buttonPos = DropdownButton.AbsolutePosition
                        local buttonSize = DropdownButton.AbsoluteSize
                        
                        -- Position the list below the button with a small gap
                        DropdownList.Position = UDim2.new(
                            0, buttonPos.X,
                            0, buttonPos.Y + buttonSize.Y + 2
                        )
                    end
                end
                
                ComponentTrove:Connect(RunService.RenderStepped, function()
                    if opened and DropdownList.Visible then
                        UpdateDropdownPosition()
                    end
                end)
                
                ComponentTrove:Connect(DropdownButton:GetPropertyChangedSignal("AbsolutePosition"), function()
                    if opened and DropdownList.Visible then
                        UpdateDropdownPosition()
                    end
                end)
                
                for _, option in ipairs(options) do
                    local OptionButton = Instance.new("TextButton")
                    OptionButton.Name = option
                    OptionButton.BorderSizePixel = 0
                    OptionButton.TextXAlignment = Enum.TextXAlignment.Left
                    OptionButton.TextSize = 12
                    OptionButton.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
                    OptionButton.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
                    OptionButton.TextColor3 = Color3.fromRGB(188, 188, 188)
                    OptionButton.Size = UDim2.new(1, -5, 0, 25)
                    OptionButton.Text = "  " .. option
                    OptionButton.ZIndex = 102
                    OptionButton.AutoButtonColor = false
                    OptionButton.Parent = ListScroll
                    
                    local OptionCorner = Instance.new("UICorner", OptionButton)
                    OptionCorner.CornerRadius = UDim.new(0, 3)
                    
                    OptionButton.MouseEnter:Connect(function()
                        Tween(OptionButton, {BackgroundColor3 = Color3.fromRGB(70, 70, 70)})
                    end)
                    
                    OptionButton.MouseLeave:Connect(function()
                        Tween(OptionButton, {BackgroundColor3 = Color3.fromRGB(37, 37, 37)})
                    end)
                
                    OptionButton.MouseButton1Click:Connect(function()
                        selected = option
                        SelectedText.Text = option
                        opened = false
                        DropdownList.Visible = false
                        SetScrollingEnabled(true)
                        Tween(Arrow, {Rotation = 0}, 0.15)
                        callback(option)
                    end)
                end
                
                ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    ListScroll.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
                end)
                
                DropdownButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        opened = not opened
                        DropdownList.Visible = opened
                        SetScrollingEnabled(not opened)
                        if opened then
                            UpdateDropdownPosition()
                        end
                        Tween(Arrow, {Rotation = opened and 180 or 0}, 0.15)
                    end
                end)

                ComponentTrove:Connect(UserInputService.InputBegan, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and opened then
                        local mousePos = UserInputService:GetMouseLocation() - GuiInset
                        local dropdownPos = DropdownList.AbsolutePosition
                        local dropdownSize = DropdownList.AbsoluteSize
                        local buttonPos = DropdownButton.AbsolutePosition
                        local buttonSize = DropdownButton.AbsoluteSize
                        
                        local outsideList = mousePos.X < dropdownPos.X or mousePos.X > dropdownPos.X + dropdownSize.X or
                                        mousePos.Y < dropdownPos.Y or mousePos.Y > dropdownPos.Y + dropdownSize.Y
                        local outsideButton = mousePos.X < buttonPos.X or mousePos.X > buttonPos.X + buttonSize.X or
                                            mousePos.Y < buttonPos.Y or mousePos.Y > buttonPos.Y + buttonSize.Y
                        
                        if outsideList and outsideButton then
                            opened = false
                            DropdownList.Visible = false
                            SetScrollingEnabled(true)
                            Tween(Arrow, {Rotation = 0}, 0.15)
                        end
                    end
                end)

                Library:RegisterComponent(flag, "Dropdown",
                    function() return selected end,
                    function(option)
                        if table.find(options, option) then
                            selected = option
                            SelectedText.Text = option
                            callback(option)
                        else
                            selected = nil
                            SelectedText.Text = "None"
                        end
                    end
                )
                
                Section.Trove:Add(ComponentTrove)
                
                return {
                    GetValue = function()
                        return selected
                    end,
                    SetValue = function(option)
                        if table.find(options, option) then
                            selected = option
                            SelectedText.Text = option
                            callback(option) 
                        else  
                            selected = nil 
                            SelectedText.Text = "None"
                        end
                    end,
                    Refresh = function(newOptions)
                        options = newOptions
                        for _, child in ipairs(ListScroll:GetChildren()) do
                            if child:IsA("TextButton") then
                                child:Destroy()
                            end
                        end
                        
                        for _, option in ipairs(options) do
                            local OptionButton = Instance.new("TextButton")
                            OptionButton.Name = option
                            OptionButton.BorderSizePixel = 0
                            OptionButton.TextXAlignment = Enum.TextXAlignment.Left
                            OptionButton.TextSize = 12
                            OptionButton.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
                            OptionButton.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
                            OptionButton.TextColor3 = Color3.fromRGB(188, 188, 188)
                            OptionButton.Size = UDim2.new(1, -5, 0, 25)
                            OptionButton.Text = "  " .. option
                            OptionButton.ZIndex = 102
                            OptionButton.AutoButtonColor = false
                            OptionButton.Parent = ListScroll
                            
                            local OptionCorner = Instance.new("UICorner", OptionButton)
                            OptionCorner.CornerRadius = UDim.new(0, 3)
                            
                            OptionButton.MouseEnter:Connect(function()
                                Tween(OptionButton, {BackgroundColor3 = Color3.fromRGB(70, 70, 70)})
                            end)
                            
                            OptionButton.MouseLeave:Connect(function()
                                Tween(OptionButton, {BackgroundColor3 = Color3.fromRGB(37, 37, 37)})
                            end)
                            
                            OptionButton.MouseButton1Click:Connect(function()
                                selected = option
                                SelectedText.Text = option
                                opened = false
                                DropdownList.Visible = false
                                SetScrollingEnabled(true)
                                Tween(Arrow, {Rotation = 0}, 0.15)
                                callback(option)
                            end)
                        end
                        
                        DropdownList.Size = UDim2.new(0, 170, 0, math.min(#options * 27 + 10, 120))
                    end,
                    Destroy = function()
                        ComponentTrove:Clean()
                    end
                }
            end

            function Section:CreateMultiDropdown(flag, name, options, defaults, callback)
                local selected = defaults or {}
                local opened = false
                callback = callback or function() end

                local ComponentTrove = Trove.new()
                
                local DropdownFrame = Instance.new("Frame")
                DropdownFrame.Name = name
                DropdownFrame.BorderSizePixel = 0
                DropdownFrame.BackgroundTransparency = 1
                DropdownFrame.Size = UDim2.new(0, 190, 0, 56)
                DropdownFrame.Parent = SectionScroll

                ComponentTrove:Add(DropdownFrame)
                
                local DisplayName = Instance.new("TextLabel")
                DisplayName.TextWrapped = true
                DisplayName.BorderSizePixel = 0
                DisplayName.TextSize = 14
                DisplayName.TextXAlignment = Enum.TextXAlignment.Left
                DisplayName.TextScaled = true
                DisplayName.BackgroundTransparency = 1
                DisplayName.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
                DisplayName.TextColor3 = Color3.fromRGB(188, 188, 188)
                DisplayName.Size = UDim2.new(0, 120, 0, 16)
                DisplayName.Text = name
                DisplayName.Position = UDim2.new(0, 10, 0, 4)
                DisplayName.Parent = DropdownFrame
                
                local DropdownButton = Instance.new("Frame")
                DropdownButton.Name = "Button"
                DropdownButton.BorderSizePixel = 0
                DropdownButton.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
                DropdownButton.Size = UDim2.new(0, 170, 0, 23)
                DropdownButton.Position = UDim2.new(0, 10, 0, 26)
                DropdownButton.Parent = DropdownFrame
                
                local ButtonCorner = Instance.new("UICorner", DropdownButton)
                ButtonCorner.CornerRadius = UDim.new(0, 4)
                
                local ButtonStroke = Instance.new("UIStroke", DropdownButton)
                ButtonStroke.Thickness = 1.5
                ButtonStroke.Color = Color3.fromRGB(70, 70, 70)

                local SelectedText = Instance.new("TextLabel")
                SelectedText.BorderSizePixel = 0
                SelectedText.TextSize = 12
                SelectedText.TextScaled = false
                SelectedText.TextWrapped = true
                SelectedText.TextXAlignment = Enum.TextXAlignment.Left
                SelectedText.BackgroundTransparency = 1
                SelectedText.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
                SelectedText.TextColor3 = Color3.fromRGB(188, 188, 188)
                SelectedText.Size = UDim2.new(0, 140, 1, -2)
                SelectedText.Text = #selected == 0 and "None" or table.concat(selected, ", ")
                SelectedText.Position = UDim2.new(0, 8, 0, 1)
                SelectedText.Parent = DropdownButton
                                            
                local function UpdateSelectedText()
                    if #selected == 0 then
                        SelectedText.Text = "None"
                        SelectedText.TextSize = 12
                    else
                        SelectedText.Text = table.concat(selected, ", ")
                        local textLength = #SelectedText.Text
                        if textLength > 50 then
                            SelectedText.TextSize = 8
                        elseif textLength > 35 then
                            SelectedText.TextSize = 9
                        elseif textLength > 25 then
                            SelectedText.TextSize = 10
                        elseif textLength > 18 then
                            SelectedText.TextSize = 11
                        else
                            SelectedText.TextSize = 12
                        end
                    end
                end
                
                local Arrow = Instance.new("TextLabel")
                Arrow.BorderSizePixel = 0
                Arrow.TextSize = 16
                Arrow.BackgroundTransparency = 1
                Arrow.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
                Arrow.TextColor3 = Color3.fromRGB(188, 188, 188)
                Arrow.Size = UDim2.new(0, 20, 0, 20)
                Arrow.Text = "▼"
                Arrow.Position = UDim2.new(1, -25, 0, 1)
                Arrow.Parent = DropdownButton
                
                local DropdownList = Instance.new("ImageButton")
                DropdownList.Name = "MultiList_" .. name
                DropdownList.Visible = false
                DropdownList.ZIndex = 100
                DropdownList.BorderSizePixel = 0
                DropdownList.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                DropdownList.Size = UDim2.new(0, 170, 0, math.min(#options * 27, 120))
                DropdownList.AutoButtonColor = false
                DropdownList.Active = true
                DropdownList.Parent = ScreenGui
                
                local ListCorner = Instance.new("UICorner", DropdownList)
                ListCorner.CornerRadius = UDim.new(0, 5)
                
                local ListStroke = Instance.new("UIStroke", DropdownList)
                ListStroke.Thickness = 1.5
                ListStroke.Color = Color3.fromRGB(70, 70, 70)
                
                local ListScroll = Instance.new("ScrollingFrame")
                ListScroll.Active = true
                ListScroll.BorderSizePixel = 0
                ListScroll.BackgroundTransparency = 1
                ListScroll.Size = UDim2.new(1, -10, 1, -10)
                ListScroll.Position = UDim2.new(0, 5, 0, 5)
                ListScroll.ScrollBarImageColor3 = Color3.fromRGB(96, 96, 96)
                ListScroll.ScrollBarThickness = 2
                ListScroll.ZIndex = 101
                ListScroll.Parent = DropdownList
                
                local ListLayout = Instance.new("UIListLayout", ListScroll)
                ListLayout.Padding = UDim.new(0, 2)
                ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                
                local function UpdateDropdownPosition()
                    if DropdownButton and DropdownButton.Parent then
                        local buttonPos = DropdownButton.AbsolutePosition
                        local buttonSize = DropdownButton.AbsoluteSize
                        
                        DropdownList.Position = UDim2.new(
                            0, buttonPos.X,
                            0, buttonPos.Y + buttonSize.Y + 2
                        )
                    end
                end
                
                ComponentTrove:Connect(RunService.RenderStepped, function()
                    if opened and DropdownList.Visible then
                        UpdateDropdownPosition()
                    end
                end)
                
                DropdownButton:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
                    if opened and DropdownList.Visible then
                        UpdateDropdownPosition()
                    end
                end)
                
                for _, option in options do
                    local OptionButton = Instance.new("TextButton")
                    OptionButton.Name = option
                    OptionButton.BorderSizePixel = 0
                    OptionButton.TextXAlignment = Enum.TextXAlignment.Left
                    OptionButton.TextSize = 12
                    OptionButton.BackgroundColor3 = table.find(selected, option) and Color3.fromRGB(70, 70, 70) or Color3.fromRGB(37, 37, 37)
                    OptionButton.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
                    OptionButton.TextColor3 = Color3.fromRGB(188, 188, 188)
                    OptionButton.Size = UDim2.new(1, -5, 0, 25)
                    OptionButton.ZIndex = 102
                    OptionButton.AutoButtonColor = false
                    OptionButton.Parent = ListScroll
                    
                    local OptionCorner = Instance.new("UICorner", OptionButton)
                    OptionCorner.CornerRadius = UDim.new(0, 3)
                    
                    OptionButton.Text = "     " .. option
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        local index = table.find(selected, option)
                        if index then
                            table.remove(selected, index)
                            Tween(OptionButton, {BackgroundColor3 = Color3.fromRGB(37, 37, 37)})
                        else
                            table.insert(selected, option)
                            Tween(OptionButton, {BackgroundColor3 = Color3.fromRGB(70, 70, 70)})
                        end
                        
                        UpdateSelectedText()
                        callback(selected)
                    end)
                end
                
                ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    ListScroll.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
                end)
                
                DropdownButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        opened = not opened
                        DropdownList.Visible = opened
                        SetScrollingEnabled(not opened)
                        if opened then
                            UpdateDropdownPosition()
                        end
                        Tween(Arrow, {Rotation = opened and 180 or 0}, 0.15)
                    end
                end)

                ComponentTrove:Connect(UserInputService.InputBegan, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and opened then
                        local mousePos = UserInputService:GetMouseLocation() - GuiInset
                        local dropdownPos = DropdownList.AbsolutePosition
                        local dropdownSize = DropdownList.AbsoluteSize
                        local buttonPos = DropdownButton.AbsolutePosition
                        local buttonSize = DropdownButton.AbsoluteSize
                        
                        local outsideList = mousePos.X < dropdownPos.X or mousePos.X > dropdownPos.X + dropdownSize.X or
                                        mousePos.Y < dropdownPos.Y or mousePos.Y > dropdownPos.Y + dropdownSize.Y
                        local outsideButton = mousePos.X < buttonPos.X or mousePos.X > buttonPos.X + buttonSize.X or
                                            mousePos.Y < buttonPos.Y or mousePos.Y > buttonPos.Y + buttonSize.Y
                        
                        if outsideList and outsideButton then
                            opened = false
                            DropdownList.Visible = false
                            SetScrollingEnabled(true)
                            Tween(Arrow, {Rotation = 0}, 0.15)
                        end
                    end
                end)
                
                UpdateSelectedText()

                Library:RegisterComponent(flag, "MultiDropdown",
                    function() return selected end,
                    function(newSelected)
                        selected = newSelected
                        UpdateSelectedText()
                        
                        for _, child in ipairs(ListScroll:GetChildren()) do
                            if child:IsA("TextButton") then
                                child.BackgroundColor3 = table.find(selected, child.Name) and Color3.fromRGB(70, 70, 70) or Color3.fromRGB(37, 37, 37)
                            end
                        end
                        
                        callback(selected)
                    end
                )

                Section.Trove:Add(ComponentTrove)
                
                return {
                    SetValue = function(newSelected)
                        selected = newSelected
                        UpdateSelectedText()
                        
                        for _, child in ipairs(ListScroll:GetChildren()) do
                            if child:IsA("TextButton") then
                                local check = child:FindFirstChild("Check")
                                if check then
                                    check.BackgroundColor3 = table.find(selected, child.Name) and Color3.fromRGB(124, 0, 255) or Color3.fromRGB(70, 70, 70)
                                end
                            end
                        end
                        
                        callback(selected)
                    end,
                    GetValue = function()
                        return selected
                    end,
                    Refresh = function(newOptions)
                        options = newOptions
                        for _, child in ipairs(ListScroll:GetChildren()) do
                            if child:IsA("TextButton") then
                                child:Destroy()
                            end
                        end
                        
                        for _, option in ipairs(options) do
                            local OptionButton = Instance.new("TextButton")
                            OptionButton.Name = option
                            OptionButton.BorderSizePixel = 0
                            OptionButton.TextXAlignment = Enum.TextXAlignment.Left
                            OptionButton.TextSize = 12
                            OptionButton.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
                            OptionButton.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
                            OptionButton.TextColor3 = Color3.fromRGB(188, 188, 188)
                            OptionButton.Size = UDim2.new(1, -5, 0, 25)
                            OptionButton.ZIndex = 102
                            OptionButton.AutoButtonColor = false
                            OptionButton.Parent = ListScroll
                            
                            local OptionCorner = Instance.new("UICorner", OptionButton)
                            OptionCorner.CornerRadius = UDim.new(0, 3)
                            
                            local Checkmark = Instance.new("Frame")
                            Checkmark.Name = "Check"
                            Checkmark.BorderSizePixel = 0
                            Checkmark.BackgroundColor3 = table.find(selected, option) and Color3.fromRGB(124, 0, 255) or Color3.fromRGB(70, 70, 70)
                            Checkmark.Size = UDim2.new(0, 12, 0, 12)
                            Checkmark.Position = UDim2.new(0, 5, 0.5, -6)
                            Checkmark.ZIndex = 103
                            Checkmark.Parent = OptionButton
                            
                            local CheckmarkCorner = Instance.new("UICorner", Checkmark)
                            CheckmarkCorner.CornerRadius = UDim.new(1, 0)
                            
                            OptionButton.Text = "     " .. option
                            
                            OptionButton.MouseButton1Click:Connect(function()
                                local index = table.find(selected, option)
                                if index then
                                    table.remove(selected, index)
                                    Checkmark.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                                else
                                    table.insert(selected, option)
                                    Checkmark.BackgroundColor3 = Color3.fromRGB(124, 0, 255)
                                end
                                
                                UpdateSelectedText()
                                callback(selected)
                            end)
                        end
                        
                        DropdownList.Size = UDim2.new(0, 170, 0, math.min(#options * 27, 120))
                    end,
                    Destroy = function()
                        ComponentTrove:Clean()
                    end
                }
            end

            function Section:CreateColorPicker(flag, name, default, callback)
                local color = default or Color3.fromRGB(255, 0, 0)
                local opened = false
                callback = callback or function() end

                local ComponentTrove = Trove.new()
                
                -- HSV values
                local hue, sat, vib = color:ToHSV()
                
                -- Lerp variables
                local targetSat, targetVib = sat, vib
                local currentSat, currentVib = sat, vib
                local targetHue = hue
                local currentHue = hue
                
                local ColorPickerFrame = Instance.new("Frame")
                ColorPickerFrame.Name = name
                ColorPickerFrame.BorderSizePixel = 0
                ColorPickerFrame.BackgroundTransparency = 1
                ColorPickerFrame.Size = UDim2.new(0, 190, 0, 30)
                ColorPickerFrame.Parent = SectionScroll
                
                local DisplayName = Instance.new("TextLabel")
                DisplayName.TextWrapped = true
                DisplayName.BorderSizePixel = 0
                DisplayName.TextSize = 14
                DisplayName.TextXAlignment = Enum.TextXAlignment.Left
                DisplayName.TextScaled = true
                DisplayName.BackgroundTransparency = 1
                DisplayName.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
                DisplayName.TextColor3 = Color3.fromRGB(188, 188, 188)
                DisplayName.Size = UDim2.new(0, 120, 0, 16)
                DisplayName.Text = name
                DisplayName.Position = UDim2.new(0, 10, 0, 4)
                DisplayName.Parent = ColorPickerFrame
                
                local ColorDisplay = Instance.new("Frame")
                ColorDisplay.Name = "Display"
                ColorDisplay.BorderSizePixel = 0
                ColorDisplay.BackgroundColor3 = color
                ColorDisplay.Size = UDim2.new(0, 20, 0, 20)
                ColorDisplay.Position = UDim2.new(0, 157, 0, 5)
                ColorDisplay.Parent = ColorPickerFrame
                
                local DisplayCorner = Instance.new("UICorner", ColorDisplay)
                DisplayCorner.CornerRadius = UDim.new(0, 4)
                
                local DisplayStroke = Instance.new("UIStroke", ColorDisplay)
                DisplayStroke.Thickness = 1.5
                DisplayStroke.Color = Color3.fromRGB(70, 70, 70)
                
                -- Main Picker Frame
                local PickerFrame = Instance.new("Frame")
                PickerFrame.Name = "Picker_" .. name
                PickerFrame.Visible = false
                PickerFrame.ZIndex = 100
                PickerFrame.BorderSizePixel = 0
                PickerFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                PickerFrame.Size = UDim2.new(0, 250, 0, 250)
                PickerFrame.Parent = ScreenGui

                local PickerCorner = Instance.new("UICorner", PickerFrame)
                PickerCorner.CornerRadius = UDim.new(0, 5)
                
                local PickerStroke = Instance.new("UIStroke", PickerFrame)
                PickerStroke.Thickness = 1.5
                PickerStroke.Color = Color3.fromRGB(70, 70, 70)
                
                local PickerPadding = Instance.new("UIPadding", PickerFrame)
                PickerPadding.PaddingTop = UDim.new(0, 10)
                PickerPadding.PaddingLeft = UDim.new(0, 10)
                PickerPadding.PaddingRight = UDim.new(0, 10)
                PickerPadding.PaddingBottom = UDim.new(0, 10)
                
                -- Saturation/Vibrance Map
                local SatVibMap = Instance.new("ImageButton")
                SatVibMap.Name = "SatVibMap"
                SatVibMap.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                SatVibMap.BorderSizePixel = 0
                SatVibMap.Size = UDim2.new(0, 190, 0, 190)
                SatVibMap.Position = UDim2.new(0, 0, 0, 0)
                SatVibMap.ZIndex = 101
                SatVibMap.AutoButtonColor = false
                SatVibMap.Parent = PickerFrame
                
                local SatVibCorner = Instance.new("UICorner", SatVibMap)
                SatVibCorner.CornerRadius = UDim.new(0, 3)
                
                -- Saturation gradient
                local SaturationGradient = Instance.new("UIGradient", SatVibMap)
                SaturationGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
                }
                SaturationGradient.Transparency = NumberSequence.new{
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1)
                }
                
                -- Vibrance overlay
                local VibFrame = Instance.new("Frame")
                VibFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                VibFrame.BorderSizePixel = 0
                VibFrame.Size = UDim2.new(1, 0, 1, 0)
                VibFrame.ZIndex = 101
                VibFrame.Active = false
                VibFrame.Parent = SatVibMap
                
                local VibCorner = Instance.new("UICorner", VibFrame)
                VibCorner.CornerRadius = UDim.new(0, 3)
                
                local VibGradient = Instance.new("UIGradient", VibFrame)
                VibGradient.Rotation = 90
                VibGradient.Transparency = NumberSequence.new{
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0)
                }
                
                -- Cursor for Sat/Vib map
                local SatVibCursor = Instance.new("Frame")
                SatVibCursor.Name = "Cursor"
                SatVibCursor.AnchorPoint = Vector2.new(0.5, 0.5)
                SatVibCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SatVibCursor.BorderColor3 = Color3.fromRGB(0, 0, 0)
                SatVibCursor.BorderSizePixel = 2
                SatVibCursor.Size = UDim2.new(0, 8, 0, 8)
                SatVibCursor.Position = UDim2.new(sat, 0, 1 - vib, 0)
                SatVibCursor.ZIndex = 103
                SatVibCursor.Parent = SatVibMap
                
                local CursorCorner = Instance.new("UICorner", SatVibCursor)
                CursorCorner.CornerRadius = UDim.new(1, 0)
                
                -- Hue Selector
                local HueSelector = Instance.new("ImageButton")
                HueSelector.Name = "HueSelector"
                HueSelector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                HueSelector.BorderSizePixel = 0
                HueSelector.Size = UDim2.new(0, 20, 0, 190)
                HueSelector.Position = UDim2.new(0, 205, 0, 0)
                HueSelector.ZIndex = 101
                HueSelector.AutoButtonColor = false
                HueSelector.Parent = PickerFrame
                
                local HueCorner = Instance.new("UICorner", HueSelector)
                HueCorner.CornerRadius = UDim.new(0, 3)
                
                local HueGradient = Instance.new("UIGradient", HueSelector)
                HueGradient.Rotation = 90
                HueGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                }
                
                -- Hue Cursor
                local HueCursor = Instance.new("Frame")
                HueCursor.Name = "HueCursor"
                HueCursor.AnchorPoint = Vector2.new(0.5, 0.5)
                HueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                HueCursor.BorderColor3 = Color3.fromRGB(0, 0, 0)
                HueCursor.BorderSizePixel = 2
                HueCursor.Position = UDim2.new(0.5, 0, hue, 0)
                HueCursor.Size = UDim2.new(1, 4, 0, 2)
                HueCursor.ZIndex = 102
                HueCursor.Parent = HueSelector
                
                -- Input Boxes Container
                local InputContainer = Instance.new("Frame")
                InputContainer.BackgroundTransparency = 1
                InputContainer.Position = UDim2.new(0, 0, 0, 200)
                InputContainer.Size = UDim2.new(1, 0, 0, 25)
                InputContainer.Parent = PickerFrame
                
                local InputLayout = Instance.new("UIListLayout", InputContainer)
                InputLayout.FillDirection = Enum.FillDirection.Horizontal
                InputLayout.Padding = UDim.new(0, 8)
                
                -- Hex Input
                local HexInput = Instance.new("TextBox")
                HexInput.Name = "HexInput"
                HexInput.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
                HexInput.BorderSizePixel = 0
                HexInput.Size = UDim2.new(0.48, 0, 1, 0)
                HexInput.Font = Enum.Font.FredokaOne
                HexInput.PlaceholderText = "#FFFFFF"
                HexInput.Text = "#" .. color:ToHex()
                HexInput.TextColor3 = Color3.fromRGB(188, 188, 188)
                HexInput.TextSize = 12
                HexInput.ZIndex = 101
                HexInput.ClearTextOnFocus = false
                HexInput.Parent = InputContainer
                
                local HexCorner = Instance.new("UICorner", HexInput)
                HexCorner.CornerRadius = UDim.new(0, 3)
                
                local HexStroke = Instance.new("UIStroke", HexInput)
                HexStroke.Color = Color3.fromRGB(70, 70, 70)
                HexStroke.Thickness = 1
                
                -- RGB Input
                local RGBInput = Instance.new("TextBox")
                RGBInput.Name = "RGBInput"
                RGBInput.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
                RGBInput.BorderSizePixel = 0
                RGBInput.Size = UDim2.new(0.48, 0, 1, 0)
                RGBInput.Font = Enum.Font.FredokaOne
                RGBInput.PlaceholderText = "255, 255, 255"
                RGBInput.Text = string.format("%d, %d, %d", 
                    math.floor(color.R * 255),
                    math.floor(color.G * 255),
                    math.floor(color.B * 255)
                )
                RGBInput.TextColor3 = Color3.fromRGB(188, 188, 188)
                RGBInput.TextSize = 12
                RGBInput.ZIndex = 101
                RGBInput.ClearTextOnFocus = false
                RGBInput.Parent = InputContainer
                
                local RGBCorner = Instance.new("UICorner", RGBInput)
                RGBCorner.CornerRadius = UDim.new(0, 3)
                
                local RGBStroke = Instance.new("UIStroke", RGBInput)
                RGBStroke.Color = Color3.fromRGB(70, 70, 70)
                RGBStroke.Thickness = 1
                
                -- Lerp Render Connection
                ComponentTrove:Connect(RunService.RenderStepped, function()
                    -- Lerp Sat/Vib cursor
                    if math.abs(targetSat - currentSat) > 0.001 or math.abs(targetVib - currentVib) > 0.001 then
                        currentSat = currentSat + (targetSat - currentSat) * 0.2
                        currentVib = currentVib + (targetVib - currentVib) * 0.2
                        SatVibCursor.Position = UDim2.new(currentSat, 0, 1 - currentVib, 0)
                    else
                        currentSat = targetSat
                        currentVib = targetVib
                    end
                    
                    -- Lerp Hue cursor
                    if math.abs(targetHue - currentHue) > 0.001 then
                        currentHue = currentHue + (targetHue - currentHue) * 0.2
                        HueCursor.Position = UDim2.new(0.5, 0, currentHue, 0)
                    else
                        currentHue = targetHue
                    end
                end)
                
                -- Update Display Function
                local function UpdateDisplay()
                    color = Color3.fromHSV(hue, sat, vib)
                    
                    ColorDisplay.BackgroundColor3 = color
                    SatVibMap.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                    
                    -- Set target positions for lerping
                    targetSat = sat
                    targetVib = vib
                    targetHue = hue
                    
                    HexInput.Text = "#" .. color:ToHex()
                    RGBInput.Text = string.format("%d, %d, %d",
                        math.floor(color.R * 255),
                        math.floor(color.G * 255),
                        math.floor(color.B * 255)
                    )
                    
                    callback(color)
                end
                
                -- Position picker
                local function UpdatePickerPosition()
                    if ColorDisplay and ColorDisplay.Parent then
                        local displayPos = ColorDisplay.AbsolutePosition
                        local displaySize = ColorDisplay.AbsoluteSize
                        
                        PickerFrame.Position = UDim2.new(
                            0, displayPos.X - 115,
                            0, displayPos.Y + displaySize.Y + 5
                        )
                    end
                end
                
                ComponentTrove:Connect(RunService.RenderStepped, function()
                    if opened and PickerFrame.Visible then
                        UpdatePickerPosition()
                    end
                end)
                
                ColorDisplay:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
                    if opened and PickerFrame.Visible then
                        UpdatePickerPosition()
                    end
                end)
                
                -- Sat/Vib Map Dragging
                local satVibDragging = false
                
                local function UpdateSatVib()
                    local mousePos = UserInputService:GetMouseLocation() - GuiInset
                    local relativePos = mousePos - SatVibMap.AbsolutePosition
                    
                    sat = math.clamp(relativePos.X / SatVibMap.AbsoluteSize.X, 0, 1)
                    vib = math.clamp(1 - (relativePos.Y / SatVibMap.AbsoluteSize.Y), 0, 1)
                    
                    UpdateDisplay()
                end
                
                SatVibMap.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        satVibDragging = true
                        UpdateSatVib()
                    end
                end)
                
                SatVibMap.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement and satVibDragging then
                        UpdateSatVib()
                    end
                end)
                
                ComponentTrove:Connect(UserInputService.InputEnded, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        satVibDragging = false
                    end
                end)
                
                -- Hue Selector Dragging
                local hueDragging = false
                
                local function UpdateHue()
                    local mousePos = UserInputService:GetMouseLocation() - GuiInset
                    local relativeY = mousePos.Y - HueSelector.AbsolutePosition.Y
                    
                    hue = math.clamp(relativeY / HueSelector.AbsoluteSize.Y, 0, 1)
                    
                    UpdateDisplay()
                end
                
                HueSelector.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        hueDragging = true
                        UpdateHue()
                    end
                end)
                
                HueSelector.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement and hueDragging then
                        UpdateHue()
                    end
                end)
                
                ComponentTrove:Connect(UserInputService.InputEnded, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        hueDragging = false
                    end
                end)
                
                -- Hex Input
                HexInput.FocusLost:Connect(function(enterPressed)
                    if enterPressed then
                        local hex = HexInput.Text:gsub("#", "")
                        local success, result = pcall(function()
                            return Color3.fromHex(hex)
                        end)
                        
                        if success then
                            color = result
                            hue, sat, vib = color:ToHSV()
                            UpdateDisplay()
                        else
                            UpdateDisplay()
                        end
                    end
                end)
                
                -- RGB Input
                RGBInput.FocusLost:Connect(function(enterPressed)
                    if enterPressed then
                        local r, g, b = RGBInput.Text:match("(%d+),%s*(%d+),%s*(%d+)")
                        if r and g and b then
                            r, g, b = tonumber(r), tonumber(g), tonumber(b)
                            if r and g and b then
                                color = Color3.fromRGB(r, g, b)
                                hue, sat, vib = color:ToHSV()
                                UpdateDisplay()
                            end
                        else
                            UpdateDisplay()
                        end
                    end
                end)
                
                -- Toggle picker
                ColorDisplay.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        opened = not opened
                        PickerFrame.Visible = opened
                        SetScrollingEnabled(not opened)
                        if opened then
                            UpdatePickerPosition()
                        end
                    end
                end)
                
                -- Close picker when clicking outside
                ComponentTrove:Connect(UserInputService.InputBegan, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and opened then
                        local mousePos = UserInputService:GetMouseLocation() - GuiInset
                        local pickerPos = PickerFrame.AbsolutePosition
                        local pickerSize = PickerFrame.AbsoluteSize
                        local displayPos = ColorDisplay.AbsolutePosition
                        local displaySize = ColorDisplay.AbsoluteSize
                        
                        local outsidePicker = mousePos.X < pickerPos.X or mousePos.X > pickerPos.X + pickerSize.X or
                                            mousePos.Y < pickerPos.Y or mousePos.Y > pickerPos.Y + pickerSize.Y
                        local outsideDisplay = mousePos.X < displayPos.X or mousePos.X > displayPos.X + displaySize.X or
                                            mousePos.Y < displayPos.Y or mousePos.Y > displayPos.Y + displaySize.Y
                        
                        if outsidePicker and outsideDisplay then
                            opened = false
                            PickerFrame.Visible = false
                            SetScrollingEnabled(true)
                        end
                    end
                end)
                
                UpdateDisplay()

                Library:RegisterComponent(flag, "ColorPicker",
                    function() return color end,
                    function(newColor)
                        color = newColor
                        hue, sat, vib = color:ToHSV()
                        currentSat, currentVib = sat, vib
                        targetSat, targetVib = sat, vib
                        currentHue = hue
                        targetHue = hue
                        UpdateDisplay()
                    end
                )

                Section.Trove:Add(ComponentTrove)
                
                return {
                    SetValue = function(newColor)
                        color = newColor
                        hue, sat, vib = color:ToHSV()
                        currentSat, currentVib = sat, vib
                        targetSat, targetVib = sat, vib
                        currentHue = hue
                        targetHue = hue
                        UpdateDisplay()
                    end,
                    Destroy = function()
                        ComponentTrove:Clean()
                    end
                }
            end
            function Section:CreateButton(name, callback)
                callback = callback or function() end
                
                local ComponentTrove = Trove.new()
                
                local ButtonFrame = Instance.new("Frame")
                ButtonFrame.Name = name
                ButtonFrame.BorderSizePixel = 0
                ButtonFrame.BackgroundTransparency = 1
                ButtonFrame.Size = UDim2.new(0, 190, 0, 35)
                ButtonFrame.Parent = SectionScroll

                ComponentTrove:Add(ButtonFrame)

                local Button = Instance.new("TextButton")
                Button.Name = "Button"
                Button.BorderSizePixel = 0
                Button.TextSize = 14
                Button.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
                Button.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
                Button.TextColor3 = Color3.fromRGB(188, 188, 188)
                Button.Size = UDim2.new(0, 170, 0, 30)
                Button.Position = UDim2.new(0, 10, 0, 2)
                Button.Text = name
                Button.AutoButtonColor = false
                Button.Parent = ButtonFrame
                
                local ButtonCorner = Instance.new("UICorner", Button)
                ButtonCorner.CornerRadius = UDim.new(0, 5)
                
                Button.MouseEnter:Connect(function()
                    Tween(Button, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)})
                end)
                
                Button.MouseLeave:Connect(function()
                    Tween(Button, {BackgroundColor3 = Color3.fromRGB(37, 37, 37)})
                end)
                
                Button.MouseButton1Click:Connect(function()
                    callback()
                end)

                Section.Trove:Add(ComponentTrove)

                return {
                    Destroy = function() 
                        ComponentTrove:Clean()
                    end
                }
            end
            
            function Section:CreateLabel(text)
                local ComponentTrove = Trove.new()

                local LabelFrame = Instance.new("Frame")
                LabelFrame.Name = "Label"
                LabelFrame.BorderSizePixel = 0
                LabelFrame.BackgroundTransparency = 1
                LabelFrame.Size = UDim2.new(0, 190, 0, 25)
                LabelFrame.Parent = SectionScroll

                ComponentTrove:Add(LabelFrame)
                
                local Label = Instance.new("TextLabel")
                Label.BorderSizePixel = 0
                Label.TextSize = 14
                Label.TextXAlignment = Enum.TextXAlignment.Center
                Label.TextWrapped = true
                Label.BackgroundTransparency = 1
                Label.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
                Label.TextColor3 = Color3.fromRGB(96, 96, 96)
                Label.Size = UDim2.new(1, -20, 1, 0)
                Label.Position = UDim2.new(0, 10, 0, 0)
                Label.Text = text
                Label.Parent = LabelFrame

                Section.Trove:Add(ComponentTrove)
                
                return {
                    SetText = function(newText)
                        Label.Text = newText
                    end,
                    Destroy = function()
                        ComponentTrove:Clean()
                    end
                }
            end

            function Section:CreateTextbox(flag, name, placeholder, default, callback)
                local value = default or ""
                callback = callback or function() end

                local ComponentTrove = Trove.new()
                
                local TextboxFrame = Instance.new("Frame")
                TextboxFrame.Name = name
                TextboxFrame.BorderSizePixel = 0
                TextboxFrame.BackgroundTransparency = 1
                TextboxFrame.Size = UDim2.new(0, 190, 0, 56)
                TextboxFrame.Parent = SectionScroll
                --[[
                Button.Size = UDim2.new(0, 180, 0, 30)
                Button.Position = UDim2.new(0, 10, 0, 2)
                ]]
                local DisplayName = Instance.new("TextLabel")
                DisplayName.TextWrapped = true
                DisplayName.BorderSizePixel = 0
                DisplayName.TextSize = 14
                DisplayName.TextXAlignment = Enum.TextXAlignment.Left
                DisplayName.TextScaled = true
                DisplayName.BackgroundTransparency = 1
                DisplayName.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
                DisplayName.TextColor3 = Color3.fromRGB(188, 188, 188)
                DisplayName.Size = UDim2.new(0, 170, 0, 16)
                DisplayName.Text = name
                DisplayName.Position = UDim2.new(0, 10, 0, 4)
                DisplayName.Parent = TextboxFrame
                
                local TextboxInput = Instance.new("TextBox")
                TextboxInput.Name = "Input"
                TextboxInput.BorderSizePixel = 0
                TextboxInput.TextSize = 14
                TextboxInput.TextXAlignment = Enum.TextXAlignment.Left
                TextboxInput.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
                TextboxInput.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
                TextboxInput.TextColor3 = Color3.fromRGB(188, 188, 188)
                TextboxInput.PlaceholderText = placeholder or "Enter text..."
                TextboxInput.PlaceholderColor3 = Color3.fromRGB(96, 96, 96)
                TextboxInput.Text = value
                TextboxInput.ClearTextOnFocus = false
                TextboxInput.Size = UDim2.new(0, 170, 0, 28)
                TextboxInput.Position = UDim2.new(0, 10, 0, 24)
                TextboxInput.Parent = TextboxFrame
                
                local TextboxCorner = Instance.new("UICorner", TextboxInput)
                TextboxCorner.CornerRadius = UDim.new(0, 4)
                
                local TextboxPadding = Instance.new("UIPadding", TextboxInput)
                TextboxPadding.PaddingLeft = UDim.new(0, 8)
                TextboxPadding.PaddingRight = UDim.new(0, 8)
                
                TextboxInput.FocusLost:Connect(function(enterPressed)
                    value = TextboxInput.Text
                    callback(value, enterPressed)
                end)

                Library:RegisterComponent(flag, "Textbox",
                    function() return TextboxInput.Text end,
                    function(newValue)
                        value = newValue
                        TextboxInput.Text = newValue
                    end
                )

                Section.Trove:Add(ComponentTrove)
                
                return {
                    SetValue = function(newValue)
                        value = newValue
                        TextboxInput.Text = newValue
                    end,
                    GetValue = function()
                        return TextboxInput.Text
                    end,
                    Destroy = function() 
                        ComponentTrove:Clean()
                    end
                }
            end

            -- Divider Component
            function Section:CreateDivider()
                local ComponentTrove = Trove.new()

                local DividerFrame = Instance.new("Frame")
                DividerFrame.Name = "Divider"
                DividerFrame.BorderSizePixel = 0
                DividerFrame.BackgroundTransparency = 1
                DividerFrame.Size = UDim2.new(0, 190, 0, 20)
                DividerFrame.Parent = SectionScroll
                
                ComponentTrove:Add(DividerFrame)

                local Line = Instance.new("Frame")
                Line.Name = "Line"
                Line.BorderSizePixel = 0
                Line.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                Line.Size = UDim2.new(0, 170, 0, 1)
                Line.Position = UDim2.new(0.5, -85, 0.5, 0)
                Line.Parent = DividerFrame

                Section.Trove:Add(ComponentTrove)

                return {
                    Destroy = function() 
                        ComponentTrove:Clean()
                    end
                }
            end

            function Section:CreateKeybind(flag, name, default, callback)
                local key = default or "None"
                local mode = "Toggle"
                local toggled = false
                local picking = false
                callback = callback or function() end

                local ComponentTrove = Trove.new()

                -- Special Keys
                local SpecialKeys = {
                    ["MB1"] = Enum.UserInputType.MouseButton1,
                    ["MB2"] = Enum.UserInputType.MouseButton2,
                }
                
                local SpecialKeysInput = {
                    [Enum.UserInputType.MouseButton1] = "MB1",
                    [Enum.UserInputType.MouseButton2] = "MB2",
                }
                
                local KeybindFrame = Instance.new("Frame")
                KeybindFrame.Name = name
                KeybindFrame.BorderSizePixel = 0
                KeybindFrame.BackgroundTransparency = 1
                KeybindFrame.Size = UDim2.new(0, 190, 0, 30)
                KeybindFrame.Parent = SectionScroll

                ComponentTrove:Add(KeybindFrame)
                
                local DisplayName = Instance.new("TextLabel")
                DisplayName.TextWrapped = true
                DisplayName.BorderSizePixel = 0
                DisplayName.TextSize = 14
                DisplayName.TextXAlignment = Enum.TextXAlignment.Left
                DisplayName.TextScaled = true
                DisplayName.BackgroundTransparency = 1
                DisplayName.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
                DisplayName.TextColor3 = Color3.fromRGB(188, 188, 188)
                DisplayName.Size = UDim2.new(0, 120, 0, 16)
                DisplayName.Text = name
                DisplayName.Position = UDim2.new(0, 10, 0, 4)
                DisplayName.Parent = KeybindFrame
                
                local KeyButton = Instance.new("TextButton")
                KeyButton.Name = "KeyButton"
                KeyButton.BorderSizePixel = 0
                KeyButton.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
                KeyButton.Size = UDim2.new(0, 50, 0, 20)
                KeyButton.Position = UDim2.new(0, 130, 0, 5)
                KeyButton.Text = key
                KeyButton.TextSize = 12
                KeyButton.Font = Enum.Font.FredokaOne
                KeyButton.TextColor3 = Color3.fromRGB(188, 188, 188)
                KeyButton.AutoButtonColor = false
                KeyButton.Parent = KeybindFrame
                
                local ButtonCorner = Instance.new("UICorner", KeyButton)
                ButtonCorner.CornerRadius = UDim.new(0, 4)
                
                local ModeMenu = Instance.new("Frame")
                ModeMenu.Name = "ModeMenu"
                ModeMenu.Visible = false
                ModeMenu.ZIndex = 100
                ModeMenu.BorderSizePixel = 0
                ModeMenu.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                ModeMenu.Size = UDim2.new(0, 80, 0, 90)
                ModeMenu.Parent = ScreenGui
                
                local MenuCorner = Instance.new("UICorner", ModeMenu)
                MenuCorner.CornerRadius = UDim.new(0, 5)
                
                local MenuStroke = Instance.new("UIStroke", ModeMenu)
                MenuStroke.Thickness = 1.5
                MenuStroke.Color = Color3.fromRGB(70, 70, 70)
                
                local MenuLayout = Instance.new("UIListLayout", ModeMenu)
                MenuLayout.Padding = UDim.new(0, 2)
                MenuLayout.SortOrder = Enum.SortOrder.LayoutOrder
                
                local MenuPadding = Instance.new("UIPadding", ModeMenu)
                MenuPadding.PaddingTop = UDim.new(0, 5)
                MenuPadding.PaddingBottom = UDim.new(0, 5)
                MenuPadding.PaddingLeft = UDim.new(0, 5)
                MenuPadding.PaddingRight = UDim.new(0, 5)
                
                -- Mode buttons
                local modes = {"Toggle", "Hold", "Always"}
                local modeButtons = {}
                
                for _, modeName in ipairs(modes) do
                    local ModeButton = Instance.new("TextButton")
                    ModeButton.Name = modeName
                    ModeButton.BorderSizePixel = 0
                    ModeButton.BackgroundColor3 = mode == modeName and Color3.fromRGB(70, 70, 70) or Color3.fromRGB(37, 37, 37)
                    ModeButton.Size = UDim2.new(1, -5, 0, 23)
                    ModeButton.Text = modeName
                    ModeButton.TextSize = 12
                    ModeButton.Font = Enum.Font.FredokaOne
                    ModeButton.TextColor3 = Color3.fromRGB(188, 188, 188)
                    ModeButton.AutoButtonColor = false
                    ModeButton.ZIndex = 101
                    ModeButton.Parent = ModeMenu
                    
                    local ModeCorner = Instance.new("UICorner", ModeButton)
                    ModeCorner.CornerRadius = UDim.new(0, 3)
                    
                    ModeButton.MouseButton1Click:Connect(function()
                        mode = modeName
                        for _, btn in pairs(modeButtons) do
                            btn.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
                        end
                        ModeButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                        ModeMenu.Visible = false
                    end)
                    
                    modeButtons[modeName] = ModeButton
                end
                
                -- Update menu position
                local function UpdateMenuPosition()
                    if KeyButton and KeyButton.Parent then
                        local buttonPos = KeyButton.AbsolutePosition
                        local buttonSize = KeyButton.AbsoluteSize
                        
                        ModeMenu.Position = UDim2.new(
                            0, buttonPos.X,
                            0, buttonPos.Y + buttonSize.Y + 2
                        )
                    end
                end
                
                ComponentTrove:Connect(RunService.RenderStepped, function()
                    if ModeMenu.Visible then
                        UpdateMenuPosition()
                    end
                end)
                
                -- Get state function
                local function GetState()
                    if mode == "Always" then
                        return true
                    elseif mode == "Hold" then
                        if key == "None" then
                            return false
                        end
                        
                        if SpecialKeys[key] then
                            return UserInputService:IsMouseButtonPressed(SpecialKeys[key]) and not UserInputService:GetFocusedTextBox()
                        else
                            local success = pcall(function()
                                return UserInputService:IsKeyDown(Enum.KeyCode[key]) and not UserInputService:GetFocusedTextBox()
                            end)
                            return success and UserInputService:IsKeyDown(Enum.KeyCode[key]) and not UserInputService:GetFocusedTextBox() or false
                        end
                    else
                        return toggled
                    end
                end
                
                -- Key picking
                KeyButton.MouseButton1Click:Connect(function()
                    if picking then return end
                    
                    picking = true
                    KeyButton.Text = "..."
                    
                    local input = UserInputService.InputBegan:Wait()
                    
                    if UserInputService:GetFocusedTextBox() then
                        picking = false
                        KeyButton.Text = key
                        return
                    end
                    
                    local newKey = "Unknown"
                    
                    if input.KeyCode == Enum.KeyCode.Escape then
                        newKey = "None"
                    elseif SpecialKeysInput[input.UserInputType] then
                        newKey = SpecialKeysInput[input.UserInputType]
                    elseif input.UserInputType == Enum.UserInputType.Keyboard then
                        newKey = input.KeyCode.Name
                    end
                    
                    key = newKey
                    KeyButton.Text = key
                    
                    toggled = false
                    
                    -- Wait for key release
                    repeat
                        task.wait()
                    until not (
                        (SpecialKeys[key] and UserInputService:IsMouseButtonPressed(SpecialKeys[key]))
                        or (not SpecialKeys[key] and pcall(function() return UserInputService:IsKeyDown(Enum.KeyCode[key]) end) and UserInputService:IsKeyDown(Enum.KeyCode[key]))
                    ) or UserInputService:GetFocusedTextBox()
                    
                    picking = false
                end)
                
                -- Right click for mode menu
                KeyButton.MouseButton2Click:Connect(function()
                    ModeMenu.Visible = not ModeMenu.Visible
                    SetScrollingEnabled(not ModeMenu.Visible)
                    if ModeMenu.Visible then
                        UpdateMenuPosition()
                    end
                end)
                
                -- Close menu when clicking outside
                ComponentTrove:Connect(UserInputService.InputBegan, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and ModeMenu.Visible then
                        local mousePos = UserInputService:GetMouseLocation() - GuiInset
                        local menuPos = ModeMenu.AbsolutePosition
                        local menuSize = ModeMenu.AbsoluteSize
                        local buttonPos = KeyButton.AbsolutePosition
                        local buttonSize = KeyButton.AbsoluteSize
                        
                        local outsideMenu = mousePos.X < menuPos.X or mousePos.X > menuPos.X + menuSize.X or
                                        mousePos.Y < menuPos.Y or mousePos.Y > menuPos.Y + menuSize.Y
                        local outsideButton = mousePos.X < buttonPos.X or mousePos.X > buttonPos.X + buttonSize.X or
                                            mousePos.Y < buttonPos.Y or mousePos.Y > buttonPos.Y + buttonSize.Y
                        
                        if outsideMenu and outsideButton then
                            ModeMenu.Visible = false
                            SetScrollingEnabled(true)
                        end
                    end
                end)
                
                -- Input handling
                ComponentTrove:Connect(UserInputService.InputBegan, function(input)
                    if mode == "Always" or key == "Unknown" or key == "None" or picking or UserInputService:GetFocusedTextBox() then
                        return
                    end
                    
                    local keyPressed = false
                    
                    if SpecialKeysInput[input.UserInputType] == key then
                        keyPressed = true
                    elseif input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == key then
                        keyPressed = true
                    end
                    
                    if keyPressed then
                        if mode == "Toggle" then
                            toggled = not toggled
                            callback(toggled)
                        elseif mode == "Hold" then
                            callback(true)
                        end
                    end
                end)
                
                ComponentTrove:Connect(UserInputService.InputEnded, function(input)
                    if mode ~= "Hold" or key == "Unknown" or key == "None" or picking or UserInputService:GetFocusedTextBox() then
                        return
                    end
                    
                    local keyReleased = false
                    
                    if SpecialKeysInput[input.UserInputType] == key then
                        keyReleased = true
                    elseif input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == key then
                        keyReleased = true
                    end
                    
                    if keyReleased then
                        callback(false)
                    end
                end)

                Library:RegisterComponent(flag, "Keybind", 
                    function()
                        return {key, mode, toggled}
                    end,
                    function(value)
                        if type(value) == "table" then
                            key = value[1] or "None"
                            mode = value[2] or "Toggle"
                            toggled = value[3] or false
                            KeyButton.Text = key
                            
                            for _, btn in pairs(modeButtons) do
                                btn.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
                            end
                            if modeButtons[mode] then
                                modeButtons[mode].BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                            end
                        end
                    end
                )

                Section.Trove:Add(ComponentTrove)
                            
                return {
                    SetValue = function(value)
                        if type(value) == "table" then
                            key = value[1] or "None"
                            mode = value[2] or "Toggle"
                            toggled = value[3] or false
                            KeyButton.Text = key
                            
                            for _, btn in pairs(modeButtons) do
                                btn.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
                            end
                            if modeButtons[mode] then
                                modeButtons[mode].BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                            end
                        end
                    end,
                    GetValue = function()
                        return {key, mode, toggled}
                    end,
                    GetState = GetState,
                    Destroy = function()
                        ComponentTrove:Clean()
                    end
                }
            end
            
            table.insert(Tab.Sections, Section)

            Tab.Trove:Add(Section.Trove)

            return Section
        end
        
        Tab.Button = TabButton
        Tab.Icon = TabIcon
        Tab.Label = TabLabel
        Tab.Content = TabContent
        
        table.insert(Window.Tabs, Tab)

        Window.Trove:Add(Tab.Trove)
        
        if #Window.Tabs == 1 then
            TabContent.Visible = true
            Window.CurrentTab = Tab
            Tween(TabIcon, {ImageColor3 = Color3.fromRGB(208, 208, 208)})
            Tween(TabLabel, {TextColor3 = Color3.fromRGB(208, 208, 208)})
        end
        
        return Tab
    end
    
    function Window:Destroy()
        ScreenGui:Destroy()
    end

    Window.Container = Container
    Window.ScreenGui = ScreenGui
    Library.Window = Window
    
    return Window
end

Library.SaveManager = {
    Folder = "Astrix/Configs",
    Ignore = {},
    SavedComponents = {}
}

function Library.SaveManager:Save(name)
    if not name or name:gsub(" ", "") == "" then
        return false, "Invalid config name"
    end
    
    local fullPath = self.Folder .. "/" .. name .. ".json"
    
    if not isfolder(self.Folder) then
        makefolder(self.Folder)
    end
    
    local data = {
        components = {}
    }
    
    for idx, component in pairs(self.SavedComponents) do
        if not self.Ignore[idx] then
            local componentData = {
                id = idx,
                type = component.Type,
                value = component.GetValue()
            }
            table.insert(data.components, componentData)
        end
    end
    
    local success, encoded = pcall(function()
        return game:GetService("HttpService"):JSONEncode(data)
    end)
    
    if not success then
        return false, "Failed to encode data"
    end
    
    writefile(fullPath, encoded)
    return true
end

function Library.SaveManager:Load(name)
    if not name or name:gsub(" ", "") == "" then
        return false, "Invalid config name"
    end
    
    local fullPath = self.Folder .. "/" .. name .. ".json"
    
    if not isfile(fullPath) then
        return false, "Config file not found"
    end
    
    local success, decoded = pcall(function()
        return game:GetService("HttpService"):JSONDecode(readfile(fullPath))
    end)
    
    if not success then
        return false, "Failed to decode config"
    end
    
    for _, componentData in pairs(decoded.components) do
        local component = self.SavedComponents[componentData.id]
        if component and not self.Ignore[componentData.id] then
            task.spawn(function()
                pcall(function()
                    component.SetValue(componentData.value)
                end)
            end)
        end
    end
    
    return true
end

function Library.SaveManager:Delete(name)
    if not name or name:gsub(" ", "") == "" then
        return false, "Invalid config name"
    end
    
    local fullPath = self.Folder .. "/" .. name .. ".json"
    
    if not isfile(fullPath) then
        return false, "Config file not found"
    end
    
    local success = pcall(function()
        delfile(fullPath)
    end)
    
    if not success then
        return false, "Failed to delete config"
    end
    
    return true
end

function Library.SaveManager:GetConfigList()
    if not isfolder(self.Folder) then
        makefolder(self.Folder)
        return {}
    end
    
    local configs = {}
    local files = listfiles(self.Folder)
    
    for _, file in pairs(files) do
        if file:sub(-5) == ".json" then
            local name = file:match("([^/\\]+)%.json$")
            if name then
                table.insert(configs, name)
            end
        end
    end
    
    return configs
end

function Library.SaveManager:GetAutoload()
    local autoloadPath = self.Folder .. "/autoload.txt"
    
    if isfile(autoloadPath) then
        local success, content = pcall(readfile, autoloadPath)
        if success and content ~= "" then
            return content
        end
    end
    
    return "None"
end

function Library.SaveManager:SetAutoload(name)
    if not isfolder(self.Folder) then
        makefolder(self.Folder)
    end
    
    local autoloadPath = self.Folder .. "/autoload.txt"
    
    local success = pcall(function()
        writefile(autoloadPath, name)
    end)
    
    return success
end

function Library.SaveManager:ClearAutoload()
    local autoloadPath = self.Folder .. "/autoload.txt"
    
    if isfile(autoloadPath) then
        local success = pcall(function()
            delfile(autoloadPath)
        end)
        return success
    end
    
    return true
end

function Library.SaveManager:LoadAutoload()
    local autoload = self:GetAutoload()
    if autoload ~= "None" then
        return self:Load(autoload)
    end
    return false, "No autoload config set"
end

function Library.SaveManager:Register(id, component, getValue, setValue)
    self.SavedComponents[id] = {
        Type = component,
        GetValue = getValue,
        SetValue = setValue
    }
end

function Library:CreateSettingsTab(window)
    local SettingsTab = window:CreateTab("Settings", "Settings")
    
    local ConfigSection = SettingsTab:CreateSection("Configuration")
    
    ConfigSection:CreateTitle("CONFIG")

    local configDropdown
    
    local configNameBox = ConfigSection:CreateTextbox(
        "Config Name",
        "Enter name...",
        "",
        function(value, enterPressed)
        end
    )
    
    ConfigSection:CreateButton("Create Config", function()
        local name = configNameBox.GetValue()
        
        if name:gsub(" ", "") == "" then
            print("[Library] Invalid config name (empty)")
            return
        end
        
        local success, err = self.SaveManager:Save(name)
        if success then
            print("[Library] Created config: " .. name)
            local newList = self.SaveManager:GetConfigList()
            if configDropdown then
                configDropdown.Refresh(newList)
            end

            Library:Notify({
                Title = "Config Created",
                Message = "Created config: " .. name,
                Color = Color3.fromRGB(0, 255, 150)
            })
        else
            print("[Library] Failed to create config: " .. tostring(err))

            Library:Notify({
                Title = "Create Failed",
                Message = tostring(err),
                Color = Color3.fromRGB(255, 50, 50)
            })
        end
    end)
    
    ConfigSection:CreateDivider()
  
    configDropdown = ConfigSection:CreateDropdown(
        "Select Config",
        self.SaveManager:GetConfigList(),
        nil,
        function(value)
        end
    )
    
    ConfigSection:CreateButton("Load Config", function()
        local selectedConfig = configDropdown.GetValue and configDropdown.GetValue() or nil
        
        if not selectedConfig then
            Library:Notify({
                Title = "No config selected",
                Message = "Please select a config",
                Color = Color3.fromRGB(255, 50, 50)
            })
            return
        end
        
        local success, err = self.SaveManager:Load(selectedConfig)
        if success then
            Library:Notify({
                Title = "Config Loaded",
                Message = "Loaded: " .. selectedConfig,
                Color = Color3.fromRGB(0, 255, 150)
            })
        else
            Library:Notify({
                Title = "Load Failed",
                Message = tostring(err),
                Color = Color3.fromRGB(255, 50, 50)
            })
        end
    end)
    
    ConfigSection:CreateButton("Overwrite Config", function()
        local selectedConfig = configDropdown.GetValue and configDropdown.GetValue() or nil
        
        if not selectedConfig then
            Library:Notify({
                Title = "No config selected",
                Message = "Please select a config",
                Color = Color3.fromRGB(255, 50, 50)
            })
            return
        end
        
        local success, err = self.SaveManager:Save(selectedConfig)
        if success then
            Library:Notify({
                Title = "Config Saved",
                Message = "Overwrote: " .. selectedConfig,
                Color = Color3.fromRGB(0, 255, 150)
            })
        else
            Library:Notify({
                Title = "Save Failed",
                Message = tostring(err),
                Color = Color3.fromRGB(255, 50, 50)
            })
        end
    end)
    
    ConfigSection:CreateButton("Delete Config", function()
        local selectedConfig = configDropdown.GetValue and configDropdown.GetValue() or nil
        
        if not selectedConfig then
            Library:Notify({
                Title = "No config selected",
                Message = "Please select a config",
                Color = Color3.fromRGB(255, 50, 50)
            })
            return
        end
        
        local success, err = self.SaveManager:Delete(selectedConfig)
        if success then
            local newList = self.SaveManager:GetConfigList()
            configDropdown.Refresh(newList)
            configDropdown.SetValue(nil)

            Library:Notify({
                Title = "Config Deleted",
                Message = "Deleted: " .. selectedConfig,
                Color = Color3.fromRGB(255, 100, 100)
            })
        else
            Library:Notify({
                Title = "Delete Failed",
                Message = tostring(err),
                Color = Color3.fromRGB(255, 50, 50)
            })
        end
    end)
    
    ConfigSection:CreateButton("Refresh List", function()
        local newList = self.SaveManager:GetConfigList()
        configDropdown.Refresh(newList)
        Library:Notify({
            Title = "Refreshed",
            Message = "Config list updated.",
            Color = Color3.fromRGB(0, 200, 255)
        })
    end)

    ConfigSection:CreateDivider()
        
    local autoloadLabel = ConfigSection:CreateLabel("Current: " .. self.SaveManager:GetAutoload())
    
    ConfigSection:CreateButton("Set as Autoload", function()
        local selectedConfig = configDropdown.GetValue and configDropdown.GetValue() or nil
        
        if not selectedConfig then
            Library:Notify({
                Title = "No config selected",
                Message = "Please select a config",
                Color = Color3.fromRGB(255, 50, 50)
            })
            return  
        end
        
        local success = self.SaveManager:SetAutoload(selectedConfig)
        if success then
            autoloadLabel.SetText("Current: " .. selectedConfig)
            Library:Notify({
                Title = "Autoload Updated",
                Message = "Autoload set to: " .. selectedConfig,
                Color = Color3.fromRGB(0, 255, 150)
            })
        else
            Library:Notify({
                Title = "Autoload Failed",
                Message = "Could not update autoload.",
                Color = Color3.fromRGB(255, 50, 50)
            })
        end
    end)
    
    ConfigSection:CreateButton("Clear Autoload", function()
        local success = self.SaveManager:ClearAutoload()
        if success then
            autoloadLabel.SetText("Current: None")
            Library:Notify({
                Title = "Autoload Cleared",
                Message = "Autoload reset to None.",
                Color = Color3.fromRGB(0, 200, 255)
            })
        else
            Library:Notify({
                Title = "Clear Failed",
                Message = "Could not clear autoload.",
                Color = Color3.fromRGB(255, 50, 50)
            })
        end
    end)
    
    self.SaveManager.Ignore["Config Name"] = true
    self.SaveManager.Ignore["Select Config"] = true
    self.SaveManager.Ignore["Theme Selector"] = true
    self.SaveManager.Ignore["Theme Name"] = true
    self.SaveManager.Ignore["Background Color"] = true
    self.SaveManager.Ignore["Main Color"] = true
    self.SaveManager.Ignore["Accent Color"] = true
    self.SaveManager.Ignore["Side Color"] = true
    self.SaveManager.Ignore["Text Color"] = true
    self.SaveManager.Ignore["Sub Text Color"] = true
    self.SaveManager.Ignore["Stroke Color"] = true
    
    task.delay(1, function()
        local success, err = self.SaveManager:LoadAutoload()
        if success then
            Library:Notify({
                Title = "Config Auto Loaded",
                Message = "Auto loaded config " .. self.SaveManager:GetAutoload(),
                Color = Color3.fromRGB(0, 255, 150)
            })
        end
    end)

    -- THEME SECTION FIRST
    local ThemeSection = SettingsTab:CreateSection("Theme Manager")
    ThemeSection:CreateTitle("THEMES")
    
    -- Color Pickers for customization
    ThemeSection:CreateLabel("Customize Colors:")
    
        -- Background Color
    local bgPicker = ThemeSection:CreateColorPicker(
        "Background Color",
        Library.ThemeManager.CurrentColors.BackgroundColor,
        function(color)
            Library.ThemeManager.CurrentColors.BackgroundColor = color
            Library.ThemeManager:RefreshUI()  -- Changed from ApplyTheme
        end
    )

    -- Main Color
    local mainPicker = ThemeSection:CreateColorPicker(
        "Main Color",
        Library.ThemeManager.CurrentColors.MainColor,
        function(color)
            Library.ThemeManager.CurrentColors.MainColor = color
            Library.ThemeManager:RefreshUI()  -- Changed from ApplyTheme
        end
    )

    -- Accent Color
    local accentPicker = ThemeSection:CreateColorPicker(
        "Accent Color",
        Library.ThemeManager.CurrentColors.AccentColor,
        function(color)
            Library.ThemeManager.CurrentColors.AccentColor = color
            Library.ThemeManager:RefreshUI()  -- Changed from ApplyTheme
        end
    )

    -- Side Color
    local sidePicker = ThemeSection:CreateColorPicker(
        "Side Color",
        Library.ThemeManager.CurrentColors.SideColor,
        function(color)
            Library.ThemeManager.CurrentColors.SideColor = color
            Library.ThemeManager:RefreshUI()  -- Changed from ApplyTheme
        end
    )

    -- Text Color
    local textPicker = ThemeSection:CreateColorPicker(
        "Text Color",
        Library.ThemeManager.CurrentColors.TextColor,
        function(color)
            Library.ThemeManager.CurrentColors.TextColor = color
            Library.ThemeManager:RefreshUI()  -- Changed from ApplyTheme
        end
    )

    -- Sub Text Color
    local subTextPicker = ThemeSection:CreateColorPicker(
        "Sub Text Color",
        Library.ThemeManager.CurrentColors.SubTextColor,
        function(color)
            Library.ThemeManager.CurrentColors.SubTextColor = color
            Library.ThemeManager:RefreshUI()  -- Changed from ApplyTheme
        end
    )

    -- Stroke Color
    local strokePicker = ThemeSection:CreateColorPicker(
        "Stroke Color",
        Library.ThemeManager.CurrentColors.StrokeColor,
        function(color)  -- ✅ Fixed
            Library.ThemeManager.CurrentColors.StrokeColor = color
            Library.ThemeManager:RefreshUI()
        end
    )

        ThemeSection:CreateDivider()

    local themeDropdown = ThemeSection:CreateDropdown(
        "Theme Selector",
        Library.ThemeManager:GetThemeList(),
        Library.ThemeManager:GetDefault(),
        function(theme)
            Library.ThemeManager:ApplyTheme(theme)
            
            -- Get the ORIGINAL theme colors (not CurrentColors)
            local originalTheme
            local isCustom = theme:match(" %(Custom%)$")
            if isCustom then
                originalTheme = Library.ThemeManager:GetCustomTheme(theme:gsub(" %(Custom%)$", ""))
            else
                originalTheme = Library.ThemeManager.BuiltInThemes[theme]
            end
            
            -- Update all color pickers to original theme colors
            if originalTheme then
                bgPicker.SetValue(originalTheme.BackgroundColor)
                mainPicker.SetValue(originalTheme.MainColor)
                accentPicker.SetValue(originalTheme.AccentColor)
                sidePicker.SetValue(originalTheme.SideColor)
                textPicker.SetValue(originalTheme.TextColor)
                subTextPicker.SetValue(originalTheme.SubTextColor)
                strokePicker.SetValue(originalTheme.StrokeColor)
            end
            
            Library:Notify({
                Title = "Theme Applied",
                Message = theme,
                Color = Color3.fromRGB(0, 255, 150)
            })
        end
    )
    
    ThemeSection:CreateButton("Set as Default", function()
        local selected = themeDropdown.GetValue()
        if selected then
            Library.ThemeManager:SaveDefault(selected)
            Library:Notify({
                Title = "Default Set",
                Message = selected,
                Color = Color3.fromRGB(0, 255, 150)
            })
        end
    end)

    ThemeSection:CreateDivider()

    -- Custom Theme Saving
    local customName = ThemeSection:CreateTextbox("Theme Name", "Enter name...", "", function() end)

    ThemeSection:CreateButton("Save Current Theme", function()
        local name = customName.GetValue()
        if Library.ThemeManager:SaveCustomTheme(name) then
            themeDropdown.Refresh(Library.ThemeManager:GetThemeList())
            Library:Notify({Title = "Saved", Message = name, Color = Color3.fromRGB(0, 255, 150)})
        end
    end)

    ThemeSection:CreateButton("Delete Theme", function()
        local selected = themeDropdown.GetValue()
        
        -- Check if a custom theme is selected
        if not selected or not selected:match(" %(Custom%)$") then
            Library:Notify({
                Title = "Cannot Delete",
                Message = "Can only delete custom themes",
                Color = Color3.fromRGB(255, 50, 50)
            })
            return
        end
        
        local themeName = selected:gsub(" %(Custom%)$", "")
        
        -- Check if this is the currently active theme
        local isCurrentTheme = (Library.ThemeManager.CurrentTheme == selected)
        
        -- Check if this is the default (autoload) theme
        local isDefaultTheme = (Library.ThemeManager:GetDefault() == selected)
        
        -- Delete the theme file
        local success = Library.ThemeManager:DeleteTheme(themeName)
        
        if success then
            -- Refresh the dropdown list
            themeDropdown.Refresh(Library.ThemeManager:GetThemeList())
            
            -- If this was the default theme, reset to "Default"
            if isDefaultTheme then
                Library.ThemeManager:SaveDefault("Default")
                if autoloadLabel then
                    autoloadLabel.SetText("Current: Default")
                end
            end
            
            -- If we just deleted the active theme, switch to default
            if isCurrentTheme then
                local defaultTheme = "Default"
                
                -- Apply default theme
                Library.ThemeManager:ApplyTheme(defaultTheme)
                
                -- Update the dropdown to show default
                themeDropdown.SetValue(defaultTheme)
                
                -- Update all color pickers to match default theme
                local defaultColors = Library.ThemeManager.BuiltInThemes[defaultTheme]
                bgPicker.SetValue(defaultColors.BackgroundColor)
                mainPicker.SetValue(defaultColors.MainColor)
                accentPicker.SetValue(defaultColors.AccentColor)
                sidePicker.SetValue(defaultColors.SideColor)
                textPicker.SetValue(defaultColors.TextColor)
                subTextPicker.SetValue(defaultColors.SubTextColor)
                strokePicker.SetValue(defaultColors.StrokeColor)
                
                Library:Notify({
                    Title = "Theme Deleted",
                    Message = "Switched to Default theme",
                    Color = Color3.fromRGB(255, 150, 50)
                })
            else
                -- Not the current theme, just clear selection
                themeDropdown.SetValue(nil)
                
                Library:Notify({
                    Title = "Theme Deleted",
                    Message = themeName,
                    Color = Color3.fromRGB(255, 100, 100)
                })
            end
        else
            Library:Notify({
                Title = "Delete Failed",
                Message = "Could not delete theme",
                Color = Color3.fromRGB(255, 50, 50)
            })
        end
    end)

    ThemeSection:CreateButton("Refresh List", function()
        themeDropdown.Refresh(Library.ThemeManager:GetThemeList())
    end)

    -- Load default theme and update color pickers
    task.delay(0.5, function()
        Library.ThemeManager:ApplyTheme(Library.ThemeManager:GetDefault())
        local colors = Library.ThemeManager.CurrentColors
        bgPicker.SetValue(colors.BackgroundColor)
        mainPicker.SetValue(colors.MainColor)
        accentPicker.SetValue(colors.AccentColor)
        sidePicker.SetValue(colors.SideColor)
        textPicker.SetValue(colors.TextColor)
        subTextPicker.SetValue(colors.SubTextColor)
        strokePicker.SetValue(colors.StrokeColor)
    end)

    local MiscSection = SettingsTab:CreateSection("Miscellaneous")
    MiscSection:CreateTitle("MISC")
    
    MiscSection:CreateButton("Unload", function()
        Library.Trove:Clean()        
    end)

    MiscSection:CreateKeybind("Hide Menu", "RightShift", function()
        Library.Window.ScreenGui.Enabled = not Library.Window.ScreenGui.Enabled
    end)
        
    return SettingsTab
end

function Library:RegisterComponent(id, componentType, getValue, setValue)
    self.SaveManager:Register(id, componentType, getValue, setValue)
end

Library.Notifications = {
    Queue = {},
    Active = {},
    MaxActive = math.huge,
    NotificationContainer = nil
}

function Library.Notifications:Initialize(screenGui)
    if self.NotificationContainer then return end
    
    self.NotificationContainer = Instance.new("Frame")
    self.NotificationContainer.Name = "NotificationContainer"
    self.NotificationContainer.BackgroundTransparency = 1
    self.NotificationContainer.Size = UDim2.new(0, 300, 1, -20)
    self.NotificationContainer.Position = UDim2.new(1, -320, 1, -20)
    self.NotificationContainer.AnchorPoint = Vector2.new(0, 1)
    self.NotificationContainer.Parent = screenGui
    
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 10)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    Layout.Parent = self.NotificationContainer
end

function Library.Notifications:ProcessQueue()
    while #self.Active < self.MaxActive and #self.Queue > 0 do
        local notification = table.remove(self.Queue, 1)
        self:ShowNotification(notification)
    end
end

function Library.Notifications:ShowNotification(data)
    table.insert(self.Active, data)
    
    local NotificationFrame = Instance.new("Frame")
    NotificationFrame.Name = "Notification"
    NotificationFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    NotificationFrame.BorderSizePixel = 0
    NotificationFrame.Size = UDim2.new(1, 0, 0, 0)
    NotificationFrame.ClipsDescendants = true
    NotificationFrame.Parent = self.NotificationContainer
    
    local Corner = Instance.new("UICorner", NotificationFrame)
    Corner.CornerRadius = UDim.new(0, 8)
    
    local Stroke = Instance.new("UIStroke", NotificationFrame)
    Stroke.Thickness = 2
    Stroke.Color = data.Color or Color3.fromRGB(124, 0, 255)
    
    local Gradient = Instance.new("UIGradient", Stroke)
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, data.Color or Color3.fromRGB(210, 26, 255)),
        ColorSequenceKeypoint.new(0.5, data.Color or Color3.fromRGB(124, 0, 255)),
        ColorSequenceKeypoint.new(1, data.Color or Color3.fromRGB(0, 202, 255))
    }
    
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "Content"
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Size = UDim2.new(1, -20, 1, -20)
    ContentFrame.Position = UDim2.new(0, 10, 0, 10)
    ContentFrame.Parent = NotificationFrame
    
    local Icon = Instance.new("ImageLabel")
    Icon.Name = "Icon"
    Icon.BackgroundTransparency = 1
    Icon.Size = UDim2.new(0, 24, 0, 24)
    Icon.Position = UDim2.new(0, 0, 0, 0)
    Icon.Image = data.Icon or Library.AssetManager:GetAsset("MainIcon")
    Icon.ImageColor3 = data.Color or Color3.fromRGB(124, 0, 255)
    Icon.Parent = ContentFrame
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, -34, 0, 20)
    Title.Position = UDim2.new(0, 34, 0, 0)
    Title.Font = Enum.Font.FredokaOne
    Title.TextSize = 16
    Title.TextColor3 = Color3.fromRGB(220, 220, 220)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Text = data.Title or "Notification"
    Title.Parent = ContentFrame
    
    local Message = Instance.new("TextLabel")
    Message.Name = "Message"
    Message.BackgroundTransparency = 1
    Message.Size = UDim2.new(1, -34, 1, -25)
    Message.Position = UDim2.new(0, 34, 0, 25)
    Message.Font = Enum.Font.FredokaOne
    Message.TextSize = 13
    Message.TextColor3 = Color3.fromRGB(160, 160, 160)
    Message.TextXAlignment = Enum.TextXAlignment.Left
    Message.TextYAlignment = Enum.TextYAlignment.Top
    Message.TextWrapped = true
    Message.Text = data.Message or ""
    Message.Parent = ContentFrame
    
    local textHeight = game:GetService("TextService"):GetTextSize(
        data.Message or "",
        13,
        Enum.Font.FredokaOne,
        Vector2.new(246, math.huge)
    ).Y
    
    local finalHeight = math.max(60, math.min(textHeight + 50, 150))
    
    NotificationFrame.Size = UDim2.new(1, 0, 0, 0)
    NotificationFrame.BackgroundTransparency = 1
    Icon.ImageTransparency = 1
    Title.TextTransparency = 1
    Message.TextTransparency = 1
    Stroke.Transparency = 1
    
    local tweenIn = TweenService:Create(NotificationFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, 0, 0, finalHeight),
        BackgroundTransparency = 0
    })
    
    tweenIn:Play()
    
    task.wait(0.1)
    
    Tween(Icon, {ImageTransparency = 0}, 0.3)
    Tween(Title, {TextTransparency = 0}, 0.3)
    Tween(Message, {TextTransparency = 0}, 0.3)
    Tween(Stroke, {Transparency = 0}, 0.3)
    
    local ProgressBar = Instance.new("Frame")
    ProgressBar.Name = "Progress"
    ProgressBar.BackgroundColor3 = data.Color or Color3.fromRGB(124, 0, 255)
    ProgressBar.BorderSizePixel = 0
    ProgressBar.Size = UDim2.new(1, -4, 0, 3)
    ProgressBar.Position = UDim2.new(0, 2, 1, -3)
    ProgressBar.Parent = NotificationFrame

    local ProgressCorner = Instance.new("UICorner", ProgressBar)
    ProgressCorner.CornerRadius = UDim.new(0, 2)
    
    local ProgressGradient = Instance.new("UIGradient", ProgressBar)
    ProgressGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, data.Color or Color3.fromRGB(210, 26, 255)),
        ColorSequenceKeypoint.new(0.5, data.Color or Color3.fromRGB(124, 0, 255)),
        ColorSequenceKeypoint.new(1, data.Color or Color3.fromRGB(0, 202, 255))
    }
    
    local duration = data.Duration or 5
    local progressTween = TweenService:Create(ProgressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 0, 3)
    })
    progressTween:Play()
    
    task.delay(duration, function()
        Tween(NotificationFrame, {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1
        }, 0.3)
        Tween(Icon, {ImageTransparency = 1}, 0.3)
        Tween(Title, {TextTransparency = 1}, 0.3)
        Tween(Message, {TextTransparency = 1}, 0.3)
        Tween(Stroke, {Transparency = 1}, 0.3)
        
        task.wait(0.3)
        NotificationFrame:Destroy()
        
        for i, notif in ipairs(self.Active) do
            if notif == data then
                table.remove(self.Active, i)
                break
            end
        end
        
        self:ProcessQueue()
    end)
end

function Library:Notify(options)
    if not self.Notifications.NotificationContainer then
        self.Notifications:Initialize(HiddenUI:FindFirstChild("UILibrary") or game:GetService("CoreGui"):FindFirstChild("UILibrary"))
    end
    
    local data = {
        Title = options.Title or "Notification",
        Message = options.Message or "",
        Duration = options.Duration or 5,
        Icon = options.Icon,
        Color = options.Color
    }
    
    table.insert(self.Notifications.Queue, data)
    
    self.Notifications:ProcessQueue()
end

Library.AssetManager = {
    AssetDirectory = "Astrix/Assets",
    AssetUrl = "https://raw.githubusercontent.com/rxd977/NewScripts/refs/heads/main/Assets/",
    GitHubAPI = "https://api.github.com/repos/rxd977/NewScripts/contents/Assets?ref=main",
    Assets = {}, 
    AssetList = {
        "MainIcon.png",
        "Settings.png",
        "Skull.png",
    }
}

function Library.AssetManager:Initialize()
    if not isfolder(self.AssetDirectory) then
        makefolder(self.AssetDirectory)
    end
    
    self:LoadAssets()
end

function Library.AssetManager:DownloadAsset(AssetName)
    local fullPath = self.AssetDirectory .. "/" .. AssetName
    
    if isfile(fullPath) then
        return true, "Asset already exists"
    end
    
    local success, result = pcall(function()
        local Request = request({
            Url = self.AssetUrl .. AssetName,
            Method = "GET",
        })

        if Request.StatusCode == 200 then 
            writefile(fullPath, Request.Body)
            return true, "Downloaded successfully"
        else
            return false, "Status code: " .. Request.StatusCode
        end
    end)
    
    if not success then
        warn("[AssetManager] Error downloading " .. AssetName .. ": " .. tostring(result))
        return false, result
    end
    
    return result
end

function Library.AssetManager:LoadAssets()
    local downloaded = 0
    local failed = 0
    local skipped = 0
    
    for _, assetName in ipairs(self.AssetList) do
        local success, message = self:DownloadAsset(assetName)
        
        if success then
            if message == "Asset already exists" then
                skipped = skipped + 1
            else
                downloaded = downloaded + 1
            end
            self.Assets[assetName] = true
        else
            failed = failed + 1
        end
    end
    
    if downloaded > 0 or failed > 0 then
        print(string.format("[AssetManager] Downloaded: %d, Skipped: %d, Failed: %d", downloaded, skipped, failed))
    end
end

function Library.AssetManager:GetAsset(AssetName)
    local fullPath = self.AssetDirectory .. "/" .. AssetName .. ".png"
    
    if not isfile(fullPath) then
        local success = self:DownloadAsset(AssetName)
        if not success then
            warn("[AssetManager] Asset not found: " .. AssetName)
            return nil
        end
    end
    
    local success, assetUrl = pcall(function()
        return getcustomasset(fullPath)
    end)
    
    if success then
        self.Assets[AssetName] = true
        return assetUrl
    else
        warn("[AssetManager] Failed to load custom asset: " .. AssetName)
        return nil
    end
end

function Library.AssetManager:FetchAssetListFromGitHub()
    print("[AssetManager] Fetching asset list from GitHub...")
    
    local success, result = pcall(function()
        local Request = request({
            Url = self.GitHubAPI,
            Method = "GET",
            Headers = {
                ["User-Agent"] = "Roblox/AssetManager"
            }
        })

        if Request.StatusCode == 200 then
            local HttpService = game:GetService("HttpService")
            local data = HttpService:JSONDecode(Request.Body)
            
            local assetList = {}
            for _, file in ipairs(data) do
                if file.type == "file" then
                    table.insert(assetList, '"' .. file.name .. '",')
                end
            end
            
            print("[AssetManager] Copy this to AssetList:")
            print(table.concat(assetList, "\n"))
            
            return assetList
        end
    end)
    
    if not success then
        warn("[AssetManager] Error: " .. tostring(result))
    end
end

function Library.AssetManager:ClearCache()
    if isfolder(self.AssetDirectory) then
        for assetName, _ in pairs(self.Assets) do
            local fullPath = self.AssetDirectory .. "/" .. assetName
            if isfile(fullPath) then
                delfile(fullPath)
            end
        end
        self.Assets = {}
    end
end

function Library.AssetManager:AssetExists(AssetName)
    local fullPath = self.AssetDirectory .. "/" .. AssetName
    return isfile(fullPath)
end

Library.ThemeManager = {
    Folder = "Astrix/Themes",
    DefaultTheme = "Default",
    CurrentTheme = nil,
    CurrentColors = nil,
    Windows = {}, -- Track all windows
    RainbowConnection = nil,  -- Add this
    RainbowHue = 0,           -- Add this
    BuiltInThemes = {
        ["Default"] = {
            BackgroundColor = Color3.fromRGB(37, 37, 37),
            MainColor = Color3.fromRGB(45, 45, 45),
            AccentColor = Color3.fromRGB(124, 0, 255),
            SideColor = Color3.fromRGB(45, 45, 45),
            TextColor = Color3.fromRGB(188, 188, 188),
            SubTextColor = Color3.fromRGB(96, 96, 96),
            StrokeColor = Color3.fromRGB(70, 70, 70),
        },
        ["Nord"] = {
            BackgroundColor = Color3.fromRGB(46, 52, 64),
            MainColor = Color3.fromRGB(59, 66, 82),
            AccentColor = Color3.fromRGB(136, 192, 208),
            SideColor = Color3.fromRGB(59, 66, 82),
            TextColor = Color3.fromRGB(236, 239, 244),
            SubTextColor = Color3.fromRGB(76, 86, 106),
            StrokeColor = Color3.fromRGB(76, 86, 106),
        },
        ["Dracula"] = {
            BackgroundColor = Color3.fromRGB(40, 42, 54),
            MainColor = Color3.fromRGB(68, 71, 90),
            AccentColor = Color3.fromRGB(255, 121, 198),
            SideColor = Color3.fromRGB(68, 71, 90),
            TextColor = Color3.fromRGB(248, 248, 242),
            SubTextColor = Color3.fromRGB(98, 114, 164),
            StrokeColor = Color3.fromRGB(98, 114, 164),
        },
        ["Monokai"] = {
            BackgroundColor = Color3.fromRGB(30, 31, 28),
            MainColor = Color3.fromRGB(39, 40, 34),
            AccentColor = Color3.fromRGB(249, 38, 114),
            SideColor = Color3.fromRGB(39, 40, 34),
            TextColor = Color3.fromRGB(248, 248, 242),
            SubTextColor = Color3.fromRGB(73, 72, 62),
            StrokeColor = Color3.fromRGB(73, 72, 62),
        },
        ["Catppuccin"] = {
            BackgroundColor = Color3.fromRGB(30, 30, 46),
            MainColor = Color3.fromRGB(48, 45, 65),
            AccentColor = Color3.fromRGB(245, 194, 231),
            SideColor = Color3.fromRGB(48, 45, 65),
            TextColor = Color3.fromRGB(217, 224, 238),
            SubTextColor = Color3.fromRGB(87, 82, 104),
            StrokeColor = Color3.fromRGB(87, 82, 104),
        },
        ["Rainbow"] = {
            BackgroundColor = Color3.fromRGB(37, 37, 37),
            MainColor = Color3.fromRGB(45, 45, 45),
            AccentColor = Color3.fromRGB(255, 0, 0),
            SideColor = Color3.fromRGB(45, 45, 45),
            TextColor = Color3.fromRGB(188, 188, 188),
            SubTextColor = Color3.fromRGB(96, 96, 96),
            StrokeColor = Color3.fromRGB(255, 0, 0),
        },
    }
}

function Library.ThemeManager:Initialize()
    if not isfolder(self.Folder) then
        makefolder(self.Folder)
    end
    self.CurrentColors = self.BuiltInThemes[self.DefaultTheme]
end

function Library.ThemeManager:GetCustomTheme(name)
    local path = self.Folder .. "/" .. name .. ".json"
    if not isfile(path) then
        return nil
    end
    
    local success, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(readfile(path))
    end)
    
    if not success then
        return nil
    end
    
    local theme = {}
    for key, value in pairs(data) do
        theme[key] = Color3.fromHex(value)
    end
    
    return theme
end

function Library.ThemeManager:SaveCustomTheme(name)
    if name:gsub(" ", "") == "" then
        return false
    end
    
    local saveData = {}
    for key, color in pairs(self.CurrentColors) do
        saveData[key] = color:ToHex()
    end
    
    writefile(self.Folder .. "/" .. name .. ".json", game:GetService("HttpService"):JSONEncode(saveData))
    return true
end

function Library.ThemeManager:DeleteTheme(name)
    local path = self.Folder .. "/" .. name .. ".json"
    if not isfile(path) then
        return false
    end
    delfile(path)
    return true
end

function Library.ThemeManager:GetThemeList()
    local themes = {}
    
    for name, _ in pairs(self.BuiltInThemes) do
        table.insert(themes, name)
    end
    
    if isfolder(self.Folder) then
        for _, file in pairs(listfiles(self.Folder)) do
            if file:sub(-5) == ".json" then
                local name = file:match("([^/\\]+)%.json$")
                if name then
                    table.insert(themes, name .. " (Custom)")
                end
            end
        end
    end
    
    return themes
end

function Library.ThemeManager:ApplyTheme(themeName)
    if self.RainbowConnection then
        self.RainbowConnection:Disconnect()
        self.RainbowConnection = nil
    end
    
    local theme
    local isCustom = themeName:match(" %(Custom%)$")
    
    if isCustom then
        theme = self:GetCustomTheme(themeName:gsub(" %(Custom%)$", ""))
    else
        theme = self.BuiltInThemes[themeName]
    end
    
    if not theme then return false end
    
    self.CurrentTheme = themeName
    
    self.CurrentColors = {}
    for key, color in pairs(theme) do
        self.CurrentColors[key] = color
    end
    
    if themeName == "Rainbow" then
        self:StartRainbowAnimation()
    else
        self:UpdateWindow(Library.Window, self.CurrentColors)
    end
    
    return true
end

function Library.ThemeManager:StartRainbowAnimation()
    self.RainbowHue = 0
    
    self.RainbowConnection = Library.Trove:Connect(RunService.RenderStepped, function(delta)
        self.RainbowHue = (self.RainbowHue + delta * 0.5) % 1
        
        self.CurrentColors.AccentColor = Color3.fromHSV(self.RainbowHue, 1, 1)
        self.CurrentColors.StrokeColor = Color3.fromHSV((self.RainbowHue + 0.1) % 1, 0.8, 0.9)
        
        self:UpdateWindow(Library.Window, self.CurrentColors)
    end)
end

function Library.ThemeManager:UpdateWindow(window, theme)
    local container = window.Container
    if not container then return end
    
    container.BackgroundColor3 = theme.BackgroundColor
    
    local side = container:FindFirstChild("Side")
    if side then
        side.BackgroundColor3 = theme.SideColor
        local stroke = side:FindFirstChild("UIStroke")
        if stroke then stroke.Color = theme.StrokeColor end
    end
    
    for _, barName in pairs({"Top", "Bottom"}) do
        local bar = container:FindFirstChild(barName)
        if bar then
            bar.BackgroundColor3 = theme.SideColor
            local stroke = bar:FindFirstChild("UIStroke")
            if stroke then stroke.Color = theme.StrokeColor end
        end
    end
    
    for _, obj in pairs(container:GetDescendants()) do
        if obj:IsA("Frame") then
            if obj.Parent and obj.Parent.Name:match("Content$") then
                obj.BackgroundColor3 = theme.MainColor
                local stroke = obj:FindFirstChild("UIStroke")
                if stroke then stroke.Color = theme.StrokeColor end
            end
            
            if obj.Name == "Toggle" or obj.Name == "Button" or obj.Name == "Input" then
                if obj.Name == "Toggle" then
                else
                    obj.BackgroundColor3 = theme.BackgroundColor
                end
            end
            
            if obj.Name == "BG" then
                obj.BackgroundColor3 = theme.StrokeColor
            end
            
            if obj.Name == "Top" or obj.Name == "Circle" then
                local gradient = obj:FindFirstChildOfClass("UIGradient")
                if gradient and gradient.Color then
                    gradient.Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, theme.AccentColor),
                        ColorSequenceKeypoint.new(0.4, theme.AccentColor),
                        ColorSequenceKeypoint.new(1, theme.AccentColor)
                    }
                end
            end
            
        elseif obj:IsA("TextLabel") then
            if obj.Name == "DisplayName" or obj.Name == "Title" then
                obj.TextColor3 = theme.TextColor
            elseif obj.Name == "Desc" or obj.Name == "TabLabel" then
                obj.TextColor3 = theme.SubTextColor
            elseif obj.Name == "Amount" or obj.Name == "SelectedText" then
                obj.TextColor3 = theme.TextColor
            end
            
        elseif obj:IsA("TextButton") then
            if obj.Parent and obj.Parent.Parent and obj.Parent.Parent.Name:match("List_") then
                obj.BackgroundColor3 = theme.BackgroundColor
                obj.TextColor3 = theme.TextColor
            elseif obj.Name:match("Content$") == nil then
                obj.TextColor3 = theme.TextColor
            end
            
        elseif obj:IsA("TextBox") then
            obj.BackgroundColor3 = theme.BackgroundColor
            obj.TextColor3 = theme.TextColor
            obj.PlaceholderColor3 = theme.SubTextColor
            
        elseif obj:IsA("ImageLabel") and obj.Name == "TabIcon" then
            obj.ImageColor3 = theme.SubTextColor
            
        elseif obj:IsA("UIStroke") then
            obj.Color = theme.StrokeColor
            
        elseif obj:IsA("ScrollingFrame") then
            obj.ScrollBarImageColor3 = theme.SubTextColor
            
        elseif obj:IsA("UIGradient") then
            -- Update toggle gradients with accent color
            if obj.Parent and obj.Parent.Name == "Toggle" then
                obj.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, theme.AccentColor),
                    ColorSequenceKeypoint.new(0.5, theme.AccentColor),
                    ColorSequenceKeypoint.new(1, theme.AccentColor)
                }
            end
        end
    end
end
function Library.ThemeManager:SaveDefault(themeName)
    writefile(self.Folder .. "/default.txt", themeName)
end

function Library.ThemeManager:RefreshUI()
    self:UpdateWindow(Library.Window, self.CurrentColors)
end

function Library.ThemeManager:GetDefault()
    local path = self.Folder .. "/default.txt"
    if isfile(path) then
        return readfile(path)
    end
    return self.DefaultTheme
end

return Library
