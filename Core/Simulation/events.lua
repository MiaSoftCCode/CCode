local INFO = require 'Data.info'
local M = {BLOCKS = {}}

for i = 3, #INFO.listType - 3 do
    M.BLOCKS = table.merge(M.BLOCKS, require('Core.Simulation.' .. INFO.listType[i]))
end

M.requestNestedBlock = function(nested)
    for i = 1, #nested do
        local name = nested[i].name
        local params = nested[i].params
        pcall(function() M.BLOCKS[name](params) end)
    end
end

M['onStart'] = function(nested, params)
    GAME.lua = GAME.lua .. ' pcall(function() local function event() local varsE, tablesE = {}, {}'
    M.requestNestedBlock(nested) GAME.lua = GAME.lua .. ' end event() end)'
end

M['onFun'] = function(nested, params)
    local name = params[1][1][1]
    local type = params[1][1][2] == 'fS' and 'funsS' or 'funsP'

    GAME.lua = GAME.lua .. ' pcall(function() ' .. type .. '[\'' .. name .. '\'] = function() local varsE, tablesE = {}, {}'
    M.requestNestedBlock(nested) GAME.lua = GAME.lua .. ' end end)'
end

M['onFunParams'] = function(nested, params)
    local nameFun = params[1][1] and params[1][1][1] or '_ccode'
    local nameTable = params[2][1] and params[2][1][1] or '_ccode'
    local typeFun = params[1][1] and params[1][1][2] == 'fS' and 'funsS' or 'funsP'

    GAME.lua = GAME.lua .. ' pcall(function() ' .. typeFun .. '[\'' .. nameFun .. '\'] = function(...) local varsE, tablesE = {},'
    GAME.lua = GAME.lua .. ' {[\'' .. nameTable .. '\'] = COPY_TABLE_FP({...})}'
    M.requestNestedBlock(nested) GAME.lua = GAME.lua .. ' end end)'
end

M['onTouchBegan'] = function(nested, params)
    local nameFun = params[1][1] and params[1][1][1] or '_ccode'
    local nameTable = params[2][1] and params[2][1][1] or '_ccode'
    local typeFun = (params[1][1] and params[1][1][2] == 'fS') and 'funsS' or 'funsP'

    GAME.lua = GAME.lua .. ' pcall(function() ' .. typeFun .. '[\'' .. nameFun .. '\'] = function(p) if p.phase == \'began\' then'
    GAME.lua = GAME.lua .. ' local varsE, tablesE, p = {}, {}, COPY_TABLE(p) tablesE[\'' .. nameTable .. '\'] ='
    GAME.lua = GAME.lua .. ' {name = p.target.name, x = p.x, y = p.y, xStart = p.xStart, yStart = p.yStart,'
    GAME.lua = GAME.lua .. ' id = p.id, xDelta = p.xDelta, yDelta = p.yDelta}'
    M.requestNestedBlock(nested) GAME.lua = GAME.lua .. ' end end end)'
end

M['onTouchEnded'] = function(nested, params)
    local nameFun = params[1][1] and params[1][1][1] or '_ccode'
    local nameTable = params[2][1] and params[2][1][1] or '_ccode'
    local typeFun = params[1][1] and params[1][1][2] == 'fS' and 'funsS' or 'funsP'

    GAME.lua = GAME.lua .. ' pcall(function() ' .. typeFun .. '[\'' .. nameFun .. '\'] = function(p) if p.phase == \'ended\''
    GAME.lua = GAME.lua .. ' or p.phase == \'cancelled\' then local varsE, tablesE, p = {}, {}, COPY_TABLE(p)'
    GAME.lua = GAME.lua .. ' tablesE[\'' .. nameTable .. '\'] = {name = p.target.name, x = p.x, y = p.y,'
    GAME.lua = GAME.lua .. ' xStart = p.xStart, yStart = p.yStart, id = p.id, xDelta = p.xDelta, yDelta = p.yDelta}'
    M.requestNestedBlock(nested) GAME.lua = GAME.lua .. ' end end end)'
end

M['onTouchMoved'] = function(nested, params)
    local nameFun = params[1][1] and params[1][1][1] or '_ccode'
    local nameTable = params[2][1] and params[2][1][1] or '_ccode'
    local typeFun = params[1][1] and params[1][1][2] == 'fS' and 'funsS' or 'funsP'

    GAME.lua = GAME.lua .. ' pcall(function() ' .. typeFun .. '[\'' .. nameFun .. '\'] = function(p) if p.phase == \'moved\' then'
    GAME.lua = GAME.lua .. ' local varsE, tablesE, p = {}, {}, COPY_TABLE(p) tablesE[\'' .. nameTable .. '\'] ='
    GAME.lua = GAME.lua .. ' {name = p.target.name, x = p.x, y = p.y, xStart = p.xStart, yStart = p.yStart,'
    GAME.lua = GAME.lua .. ' id = p.id, xDelta = p.xDelta, yDelta = p.yDelta}'
    M.requestNestedBlock(nested) GAME.lua = GAME.lua .. ' end end end)'
end

return M
