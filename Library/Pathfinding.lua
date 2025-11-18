--[[
    2D A* Pathfinding Module
    
    A clean, efficient pathfinding module that works in 2D space using A* algorithm.
    Perfect for maze navigation, NPC movement, and player guidance.
    
    Usage:
        local Pathfinder = require(path.to.module)
        local pathfinder = Pathfinder.new()
        
        local path = pathfinder:FindPath(startPos, endPos, {
            resolution = 5,      -- Grid size (smaller = more accurate but slower)
            testSize = 4,        -- Collision detection size
            maxIterations = 10000,
            filtered = {...},    -- Instances to ignore during collision detection
        })
        
        if path then
            for _, waypoint in ipairs(path) do
                print(waypoint)
            end
        end
]]

local Pathfinder = {}
Pathfinder.__index = Pathfinder

-- Constants
local DEFAULT_RESOLUTION = 5
local DEFAULT_MAX_ITERATIONS = 10000

-- Only horizontal directions (prevents flying over walls)
local DIRECTIONS = {
    Vector3.xAxis,      -- Right
    -Vector3.xAxis,     -- Left
    Vector3.zAxis,      -- Forward
    -Vector3.zAxis,     -- Back
}

-- Cache for terrain voxels (optional optimization)
local discoveredTerrainVoxels = {}

--[[
    Snaps position to grid while maintaining Y coordinate
]]
local function GridVector(pos, resolution)
    return Vector3.new(
        math.round(pos.X/resolution)*resolution, 
        pos.Y,
        math.round(pos.Z/resolution)*resolution
    )
end

--[[
    Checks if a position has collision
]]
local colCount = 0
local function checkCollision(pos, size, params, waterMode, useStaticTerrain)
    -- Throttle checks for performance
    if colCount > 25 then
        task.wait()
        colCount = 0
    else
        colCount += 1
    end
    
    local terrainEmpty = nil
    if useStaticTerrain then
        local entry = discoveredTerrainVoxels[pos]
        if entry and entry[size] then
            entry = entry[size]
            terrainEmpty = true
            if entry.full then return true end
            if entry.water then
                if waterMode == "excluding" then return true end
            else
                if waterMode == "only" then return true end
            end
        end
    end
    
    -- Check for parts in the area
    local parts = workspace:GetPartBoundsInBox(CFrame.new(pos), Vector3.new(size, size, size), params)
    
    if #parts > 0 then
        return true
    end
    
    -- Check terrain
    if not terrainEmpty then
        local regionsize = Vector3.new(size, size, size)/2
        local mat, occ = workspace.Terrain:ReadVoxels(Region3.new(pos - regionsize, pos + regionsize), 4)
        local foundMaterials = {}
        local readsize = mat.Size
        
        for x = 1, readsize.X, 1 do
            for y = 1, readsize.Y, 1 do
                for z = 1, readsize.Z, 1 do
                    foundMaterials[#foundMaterials+1] = mat[x][y][z].Name
                end
            end
        end
        
        local full = false
        local water = false
        for _, i in pairs(foundMaterials) do
            if i == "Air" then continue end
            if i == "Water" then
                water = true
            else
                full = true
            end
        end
        
        -- Cache terrain data
        if useStaticTerrain then
            local entry = discoveredTerrainVoxels[pos]
            if entry then
                discoveredTerrainVoxels[pos][size] = {
                    full = full,
                    water = water
                }
            else
                entry = {}
                entry[size] = {
                    full = full,
                    water = water,
                }
                discoveredTerrainVoxels[pos] = entry
            end
        end
        
        if water then
            if waterMode == "excluding" then return true end
        else
            if waterMode == "only" then return true end
        end
        if full then return true end
    end
    
    return false
end

--[[
    Removes unnecessary waypoints using line-of-sight optimization
]]
local function cullPath(path, waterMode)
    if #path <= 2 then return path end
    
    local newPath = {path[1]}
    local previous = path[1]
    local goal = path[#path]
    local params = RaycastParams.new()
    
    for x, i in pairs(path) do
        if x <= 1 then continue end
        
        local results = workspace:Raycast(previous, (i - previous).Unit * (i-previous).Magnitude, params)
        local water = false
        
        if results and results.Material == Enum.Material.Water then
            water = true
            params.IgnoreWater = true
            results = workspace:Raycast(previous, (i - previous).Unit * (i-previous).Magnitude, params)
        end
        
        if results or (waterMode == "only" and water == false) or (waterMode == "excluding" and water) then
            table.insert(newPath, path[x-1])
            previous = path[x-1]
        end
        
        if i == goal then
            newPath[#newPath+1] = goal
        end
    end
    
    return newPath
end

--[[
    Creates a new Pathfinder instance
]]
function Pathfinder.new()
    local self = setmetatable({}, Pathfinder)
    return self
end

--[[
    Finds a path from start to goal using A* algorithm
    
    Parameters:
        start (Vector3): Starting position
        goal (Vector3): Target position
        options (table): Optional configuration
            - resolution (number): Grid size, default 5
            - testSize (number): Collision test size, default = resolution
            - maxIterations (number): Max pathfinding iterations, default 10000
            - filtered (table): Array of instances to ignore
            - useStaticTerrain (boolean): Cache terrain checks, default false
            - waterMode (string): "ignore", "only", or "excluding", default "ignore"
            - cullPath (boolean): Remove unnecessary waypoints, default true
            
    Returns:
        table: Array of Vector3 waypoints, or nil if no path found
]]
function Pathfinder:FindPath(start, goal, options)
    options = options or {}
    
    local waterMode = options.waterMode or "ignore"
    local useStaticTerrain = options.useStaticTerrain or false
    local filtered = options.filtered or {}
    local resolution = math.max(options.resolution or DEFAULT_RESOLUTION, 0.1)
    local testSize = math.max(options.testSize or resolution, 0.1)
    local maxIterations = options.maxIterations or DEFAULT_MAX_ITERATIONS
    local shouldCullPath = options.cullPath ~= false
    
    local rayParams = RaycastParams.new()
    local overParams = OverlapParams.new()
    
    -- Snap to grid
    start = GridVector(start, resolution)
    goal = GridVector(goal, resolution)
    
    -- Setup filters
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = filtered
    overParams.FilterType = Enum.RaycastFilterType.Exclude
    overParams.FilterDescendantsInstances = filtered
    
    -- Validate start and goal
    if checkCollision(start, testSize, overParams, waterMode, useStaticTerrain) then 
        warn("[Pathfinder] Start position is blocked!")
        return nil 
    end
    
    if checkCollision(goal, testSize, overParams, waterMode, useStaticTerrain) then 
        warn("[Pathfinder] Goal position is blocked!")
        return nil 
    end
    
    -- A* Algorithm
    local open = {}
    local closed = {}
    local path = nil
    
    local function algorithm()
        -- Find node with lowest F score
        local lowestScore = math.huge
        local S = nil
        for v, i in pairs(open) do
            if (i.G + i.H) < lowestScore then
                S = v
                lowestScore = i.G + i.H
            end
        end
        
        -- Move to closed set
        local Sdata = open[S]
        open[S] = nil
        closed[S] = Sdata
        
        -- Check all neighbors
        for _, i in pairs(DIRECTIONS) do
            local dir = i * resolution
            local tile = S + dir
            
            -- Check if reached goal
            local distToGoal = (tile - goal).Magnitude
            if distToGoal < resolution * 1.5 then
                path = {}
                local currentTile = S
                table.insert(path, 1, goal)
                table.insert(path, 1, tile)
                while currentTile do
                    table.insert(path, 1, currentTile)
                    currentTile = closed[currentTile].P
                end
                return
            end
            
            -- Skip if already closed
            if closed[tile] then continue end
            
            -- Check if tile is new
            if not open[tile] then
                -- Check collision
                local found = checkCollision(tile, testSize, overParams, waterMode, useStaticTerrain)
                if found then 
                    closed[tile] = true 
                    continue 
                end
                
                -- Check line of sight
                local raycast = workspace:Raycast(S, dir, rayParams)
                if raycast and raycast.Material ~= Enum.Material.Water then 
                    continue 
                end
                
                -- Add to open set
                open[tile] = {
                    G = Sdata.G + resolution,
                    H = (tile - goal).Magnitude,
                    P = S
                }
                continue
            end
            
            -- Update if better path found
            local sDist = Sdata.G + resolution
            local prevDist = open[tile].G
            if sDist < prevDist then
                open[tile] = {
                    G = Sdata.G + resolution,
                    H = (tile - goal).Magnitude,
                    P = S
                }
            end
        end
    end
    
    -- Initialize
    open[start] = {
        G = 0,
        H = (start - goal).Magnitude
    }
    
    -- Main loop
    local run = true
    local iterations = 0
    
    while run and iterations < maxIterations do
        iterations += 1
        run = false
        algorithm()
        
        if path ~= nil then break end
        
        for _, i in pairs(open) do
            run = true
            break
        end
    end
    
    -- Process result
    if path then
        if shouldCullPath then
            path = cullPath(path, waterMode)
        end
        return path
    else
        warn("[Pathfinder] No path found after " .. iterations .. " iterations")
        return nil
    end
end

--[[
    Clears the terrain voxel cache
    Call this if terrain changes during runtime
]]
function Pathfinder:ClearTerrainCache()
    discoveredTerrainVoxels = {}
end

return Pathfinder
