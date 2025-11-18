--[[
    3D A* Pathfinding Module
    
    A clean, efficient pathfinding module that works in 3D space using A* algorithm.
    Perfect for FPS games, NPC movement, and player guidance with full vertical navigation.
    
    Usage:
        local Pathfinder = require(path.to.module)
        local pathfinder = Pathfinder.new()
        
        local path = pathfinder:FindPath(startPos, endPos, {
            resolution = 5,        -- Grid size (smaller = more accurate but slower)
            testSize = 4,          -- Collision detection size
            maxIterations = 10000,
            allowVertical = true,  -- Allow vertical movement (climbing/falling)
            maxClimbHeight = 10,   -- Maximum height character can climb
            maxFallHeight = 30,    -- Maximum height character can fall
            filtered = {...},      -- Instances to ignore during collision detection
            cullPath = true,       -- Remove unnecessary waypoints
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
local DEFAULT_MAX_CLIMB = 10
local DEFAULT_MAX_FALL = 30

-- 3D Directions: horizontal + vertical
local HORIZONTAL_DIRECTIONS = {
    Vector3.new(1, 0, 0),   -- Right
    Vector3.new(-1, 0, 0),  -- Left
    Vector3.new(0, 0, 1),   -- Forward
    Vector3.new(0, 0, -1),  -- Back
}

local VERTICAL_DIRECTIONS = {
    Vector3.new(0, 1, 0),   -- Up
    Vector3.new(0, -1, 0),  -- Down
}

-- Cache for terrain voxels (optional optimization)
local discoveredTerrainVoxels = {}

--[[
    Snaps position to grid in all 3 dimensions
]]
local function GridVector(pos, resolution)
    return Vector3.new(
        math.round(pos.X/resolution)*resolution, 
        math.round(pos.Y/resolution)*resolution,
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
    
    -- Check for parts in the area (with proper filtering)
    local parts = workspace:GetPartBoundsInBox(CFrame.new(pos), Vector3.new(size, size, size), params)
    
    -- Count only parts that aren't filtered and are solid obstacles
    local hasObstacle = false
    for _, part in ipairs(parts) do
        -- Check if part can collide and is a real obstacle
        if part.CanCollide then
            hasObstacle = true
            break
        end
    end
    
    if hasObstacle then
        return true
    end
    
    -- Check terrain
    if not terrainEmpty then
        local regionsize = Vector3.new(size, size, size)/2
        local success, mat, occ = pcall(function()
            return workspace.Terrain:ReadVoxels(Region3.new(pos - regionsize, pos + regionsize), 4)
        end)
        
        if not success then
            -- If terrain read fails, assume no collision
            return false
        end
        
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
local function cullPath(path, waterMode, rayParams)
    if #path <= 2 then return path end
    
    local newPath = {path[1]}
    local previous = path[1]
    local goal = path[#path]
    
    for x, i in pairs(path) do
        if x <= 1 then continue end
        
        local results = workspace:Raycast(previous, (i - previous).Unit * (i-previous).Magnitude, rayParams)
        local water = false
        
        if results and results.Material == Enum.Material.Water then
            water = true
            rayParams.IgnoreWater = true
            results = workspace:Raycast(previous, (i - previous).Unit * (i-previous).Magnitude, rayParams)
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
    Finds a path from start to goal using A* algorithm in 3D space
    
    Parameters:
        start (Vector3): Starting position
        goal (Vector3): Target position
        options (table): Optional configuration
            - resolution (number): Grid size, default 5
            - testSize (number): Collision test size, default = resolution
            - maxIterations (number): Max pathfinding iterations, default 10000
            - allowVertical (boolean): Enable vertical movement, default true
            - maxClimbHeight (number): Max height to climb, default 10
            - maxFallHeight (number): Max height to fall, default 30
            - filtered (table): Array of instances to ignore
            - useStaticTerrain (boolean): Cache terrain checks, default false
            - waterMode (string): "ignore", "only", or "excluding", default "ignore"
            - cullPath (boolean): Remove unnecessary waypoints, default true
            - skipValidation (boolean): Skip start/goal collision checks, default false
            
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
    local allowVertical = options.allowVertical ~= false
    local maxClimbHeight = options.maxClimbHeight or DEFAULT_MAX_CLIMB
    local maxFallHeight = options.maxFallHeight or DEFAULT_MAX_FALL
    local skipValidation = options.skipValidation or false
    
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
    
    -- Validate start and goal (skip if requested)
    if not skipValidation then
        if checkCollision(start, testSize, overParams, waterMode, useStaticTerrain) then 
            warn("[Pathfinder] Start position is blocked!")
            return nil 
        end
        
        if checkCollision(goal, testSize, overParams, waterMode, useStaticTerrain) then 
            warn("[Pathfinder] Goal position is blocked!")
            return nil 
        end
    end
    
    -- Build direction table based on settings
    local directions = {}
    for _, dir in ipairs(HORIZONTAL_DIRECTIONS) do
        table.insert(directions, dir)
    end
    
    if allowVertical then
        for _, dir in ipairs(VERTICAL_DIRECTIONS) do
            table.insert(directions, dir)
        end
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
        for _, i in pairs(directions) do
            local dir = i * resolution
            local tile = S + dir
            
            -- Check vertical movement constraints
            if allowVertical then
                local heightDiff = tile.Y - S.Y
                
                -- Block if climbing too high
                if heightDiff > 0 and heightDiff > maxClimbHeight then
                    continue
                end
                
                -- Block if falling too far
                if heightDiff < 0 and math.abs(heightDiff) > maxFallHeight then
                    continue
                end
            end
            
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
                
                -- Calculate movement cost (higher cost for vertical movement)
                local moveCost = resolution
                if math.abs(dir.Y) > 0 then
                    moveCost = moveCost * 1.5 -- Vertical movement costs more
                end
                
                -- Add to open set
                open[tile] = {
                    G = Sdata.G + moveCost,
                    H = (tile - goal).Magnitude,
                    P = S
                }
                continue
            end
            
            -- Update if better path found
            local moveCost = resolution
            if math.abs(dir.Y) > 0 then
                moveCost = moveCost * 1.5
            end
            
            local sDist = Sdata.G + moveCost
            local prevDist = open[tile].G
            if sDist < prevDist then
                open[tile] = {
                    G = Sdata.G + moveCost,
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
            path = cullPath(path, waterMode, rayParams)
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
