-- Deobfuscated from Luraph v13.4.6
-- This is a pathfinding/raycasting module for Roblox

local PathfindingModule = {}

-- Configuration
PathfindingModule.interval = 1 -- Distance between nodes
PathfindingModule.maxtime = 5 -- Maximum pathfinding time in seconds
PathfindingModule.ignorelist = {} -- Parts to ignore in raycasting
PathfindingModule.performance = false -- Performance mode toggle

-- Direction vectors for pathfinding
local DirectionVectors = {
    -- Cardinal directions (6 directions)
    space = {
        Vector3.new(1, 0, 0),
        Vector3.new(-1, 0, 0),
        Vector3.new(0, 1, 0),
        Vector3.new(0, -1, 0),
        Vector3.new(0, 0, 1),
        Vector3.new(0, 0, -1)
    },
    
    -- Face diagonal directions (12 directions)
    diagonal = {
        Vector3.new(1, 0, 1),
        Vector3.new(1, 0, -1),
        Vector3.new(-1, 0, 1),
        Vector3.new(-1, 0, -1),
        Vector3.new(1, 1, 0),
        Vector3.new(1, -1, 0),
        Vector3.new(-1, 1, 0),
        Vector3.new(-1, -1, 0),
        Vector3.new(0, 1, 1),
        Vector3.new(0, -1, 1),
        Vector3.new(0, 1, -1),
        Vector3.new(0, -1, -1)
    },
    
    -- Body diagonal directions (8 directions)
    bodydiagonal = {
        Vector3.new(1, 1, 1),
        Vector3.new(1, -1, 1),
        Vector3.new(-1, 1, 1),
        Vector3.new(-1, -1, 1),
        Vector3.new(1, 1, -1),
        Vector3.new(1, -1, -1),
        Vector3.new(-1, 1, -1),
        Vector3.new(-1, -1, -1)
    }
}

-- Get Roblox services
local Workspace = game:GetService("Workspace")

-- Raycast parameters setup
local RaycastParams = RaycastParams.new()
RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist

-- Distance calculation between two Vector3 points
function PathfindingModule:distance(point1, point2)
    local x1, y1, z1 = point1.X, point1.Y, point1.Z
    local x2, y2, z2 = point2.X, point2.Y, point2.Z
    
    return math.sqrt((x1 - x2)^2 + (y1 - y2)^2 + (z1 - z2)^2)
end

-- Raycast to find parts between two points
function PathfindingModule:findpart(startPos, endPos)
    return Workspace:Raycast(startPos, endPos - startPos, RaycastParams)
end

-- Main pathfinding function using A* algorithm
function PathfindingModule:findpath(startPos, endPos, stepSize, minDistanceToEnd)
    -- Cost multipliers for different movement types
    local MovementCosts = {
        space = self.interval,
        diagonal = 1.4142135623730951 * self.interval, -- sqrt(2)
        bodydiagonal = 1.7320508075688772 * self.interval -- sqrt(3)
    }
    
    -- 3D grid for nodes (auto-indexed table)
    local NodeGrid = setmetatable({}, {
        __index = function(t, k)
            if not rawget(t, k) then
                rawset(t, k, setmetatable({}, {
                    __index = function(t2, k2)
                        if not rawget(t2, k2) then
                            rawset(t2, k2, {})
                        end
                        return rawget(t2, k2)
                    end
                }))
            end
            return rawget(t, k)
        end
    })
    
    -- Maximum time for pathfinding
    local maxTime = tick() + self.maxtime
    local startTime = tick()
    
    -- Setup raycasting filter
    RaycastParams.FilterDescendantsInstances = self.ignorelist
    
    -- Initialize starting node
    NodeGrid[0][0][0] = {
        position = startPos,
        offset = Vector3.new(),
        gcost = 0,
        hcost = self:distance(startPos, endPos),
        fcost = nil, -- Will be calculated
        lastnode = nil,
        scanned = false
    }
    NodeGrid[0][0][0].fcost = NodeGrid[0][0][0].hcost
    
    local finalPath, totalCost
    
    -- A* pathfinding loop
    while tick() < maxTime do
        -- Find node with lowest fcost
        local lowestFCost = math.huge
        local currentNode, gridX, gridY, gridZ
        
        for x, xTable in next, NodeGrid do
            for y, yTable in next, xTable do
                for z, node in next, yTable do
                    if not node.scanned and node.fcost < lowestFCost then
                        lowestFCost = node.fcost
                        currentNode = node
                        gridX, gridY, gridZ = x, y, z
                    end
                end
            end
        end
        
        if not currentNode then
            break
        end
        
        -- Check if we can reach the end point
        if self:findpart(currentNode.position, endPos) and 
           currentNode.hcost >= minDistanceToEnd then
            
            -- Explore neighbors
            for directionType, directions in next, DirectionVectors do
                for _, direction in next, directions do
                    direction = direction * MovementCosts.space
                    
                    local neighborNode = NodeGrid[gridX + direction.X][gridY + direction.Y][gridZ + direction.Z]
                    local neighborPos = currentNode.position + direction
                    
                    -- Check if path is clear
                    if not self:findpart(currentNode.position, neighborPos) then
                        if neighborNode then
                            -- Update existing neighbor if we found a better path
                            if neighborNode.gcost > currentNode.gcost + MovementCosts[directionType] then
                                neighborNode.gcost = currentNode.gcost + MovementCosts[directionType]
                                neighborNode.fcost = neighborNode.gcost + neighborNode.hcost
                                neighborNode.lastnode = currentNode
                            end
                        else
                            -- Create new neighbor node
                            NodeGrid[gridX + direction.X][gridY + direction.Y][gridZ + direction.Z] = {
                                position = neighborPos,
                                gcost = currentNode.gcost + MovementCosts[directionType],
                                lastnode = currentNode,
                                scanned = false
                            }
                            
                            local newNode = NodeGrid[gridX + direction.X][gridY + direction.Y][gridZ + direction.Z]
                            newNode.hcost = self:distance(newNode.position, endPos)
                            newNode.fcost = newNode.hcost + newNode.gcost
                        end
                    end
                end
            end
            
            currentNode.scanned = true
            
        else
            -- We reached the end, reconstruct path
            local reachedEnd = currentNode.hcost <= minDistanceToEnd
            finalPath = {}
            
            -- Trace back through lastnode pointers
            while currentNode.lastnode do
                table.insert(finalPath, 1, currentNode.position)
                currentNode = currentNode.lastnode
            end
            table.insert(finalPath, 1, startPos)
            
            currentNode = NodeGrid[gridX][gridY][gridZ]
            
            -- Performance mode - direct interpolation
            if self.performance then
                local direction = (endPos - currentNode.position).Unit * MovementCosts.space
                local distance = self:distance(currentNode.position, endPos)
                totalCost = currentNode.gcost + distance
                
                for i = 1, math.floor(distance / MovementCosts.space) do
                    table.insert(finalPath, currentNode.position + direction * i)
                end
            else
                -- Detailed mode - line of sight optimization
                local optimizedPath = {startPos}
                
                if not reachedEnd then
                    table.insert(finalPath, endPos)
                end
                
                -- Remove unnecessary waypoints using line of sight
                for i = 3, #finalPath do
                    if self:findpart(optimizedPath[#optimizedPath], finalPath[i]) then
                        table.insert(optimizedPath, finalPath[i - 1])
                    end
                end
                
                table.insert(optimizedPath, reachedEnd and finalPath[#finalPath] or endPos)
                
                -- Interpolate between waypoints
                finalPath = {}
                totalCost = 0
                
                for i = 2, #optimizedPath do
                    local from = optimizedPath[i - 1]
                    local to = optimizedPath[i]
                    local direction = (to - from).Unit * stepSize
                    local distance = self:distance(from, to)
                    
                    totalCost = totalCost + distance
                    
                    for step = 1, math.floor(distance / stepSize) do
                        table.insert(finalPath, from + direction * step)
                    end
                    table.insert(finalPath, to)
                end
            end
            
            maxTime = tick()
            break
        end
    end
    
    local elapsedTime = tick() - startTime
    return finalPath, totalCost, elapsedTime
end

return PathfindingModule
