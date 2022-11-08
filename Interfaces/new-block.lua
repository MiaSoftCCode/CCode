local BLOCK = require 'Core.Modules.logic-block'
local INFO = require 'Data.info'
local M = {}

local function showTypeScroll(event)
    if event.phase == 'began' then
        display.getCurrentStage():setFocus(event.target)
        event.target.click = true
    elseif event.phase == 'moved' then
        if math.abs(event.x - event.xStart) > 30 or math.abs(event.y - event.yStart) > 30 then
            display.getCurrentStage():setFocus(nil)
            event.target.click = false
        end
    elseif event.phase == 'ended' or event.phase == 'cancelled' then
        display.getCurrentStage():setFocus(nil)
        if event.target.click and M.group.currentIndex ~= event.target.index then
            event.target.click = false
            M.group.types[event.target.index].scroll.isVisible = true
            M.group.types[M.group.currentIndex].scroll.isVisible = false
            M.group[3].isVisible = event.target.index == 1
            M.group[4].isVisible = event.target.index == 1
            M.group.currentIndex = event.target.index
        end
    end

    return true
end

local function newBlockListener(event)
    pcall(function()
        if event.phase == 'began' then
            display.getCurrentStage():setFocus(event.target)
            event.target.click = true
        elseif event.phase == 'moved' then
            if math.abs(event.x - event.xStart) > 30 or math.abs(event.y - event.yStart) > 30 then
                M.group.types[event.target.index[1]].scroll:takeFocus(event)
                event.target.click = false
            end
        elseif event.phase == 'ended' or event.phase == 'cancelled' then
            display.getCurrentStage():setFocus(nil)
            if event.target.click then
                event.target.click = false
                EXITS.new_block()

                local data = GET_GAME_CODE(CURRENT_LINK)
                local scrollY = select(2, BLOCKS.group[8]:getContentPosition())
                local diffY = BLOCKS.group[8].y - BLOCKS.group[8].height / 2
                local targetY = math.abs(scrollY) + diffY + CENTER_Y - 150
                local blockName = INFO.listBlock[INFO.listType[event.target.index[1]]][event.target.index[2]]
                local blockEvent = INFO.getType(blockName) == 'events'
                local blockIndex = #BLOCKS.group.blocks + 1
                local blockParams = {
                    name = blockName, params = {}, event = blockEvent, comment = false,
                    nested = blockEvent and {} or nil, vars = blockEvent and {} or nil, tables = blockEvent and {} or nil
                }

                for i = 1, #INFO.listName[blockName] - 1 do
                    blockParams.params[i] = {}
                end

                for i = 1, #BLOCKS.group.blocks do
                    if BLOCKS.group.blocks[i].y > targetY then
                        blockIndex = i break
                    end
                end

                if not blockEvent and #BLOCKS.group.blocks == 0 then
                    table.insert(data.scripts[CURRENT_SCRIPT].params, 1, {
                        name = 'onStart', params = {{}}, event = true, comment = false,
                        nested = {}, vars = {}, tables = {}
                    }) BLOCKS.new('onStart', 1, true, {{}}, false, {}) blockIndex = 2
                end

                if INFO.listNested[blockName] then
                    blockParams.nested = {}
                    for i = 1, #INFO.listNested[blockName] do
                        table.insert(data.scripts[CURRENT_SCRIPT].params, blockIndex, {
                            name = INFO.listNested[blockName][i], params = {{}}, event = false, comment = false
                        }) BLOCKS.new(INFO.listNested[blockName][i], blockIndex, false, {{}}, false)
                    end
                end

                native.setKeyboardFocus(nil)
                table.insert(data.scripts[CURRENT_SCRIPT].params, blockIndex, blockParams)
                SET_GAME_CODE(CURRENT_LINK, data)
                BLOCKS.new(blockName, blockIndex, blockEvent, COPY_TABLE(blockParams.params), false, blockParams.nested)

                if #BLOCKS.group.blocks > 2 then
                    display.getCurrentStage():setFocus(BLOCKS.group.blocks[blockIndex])
                    BLOCKS.group.blocks[blockIndex].click = true
                    BLOCKS.group.blocks[blockIndex].move = true
                    newMoveLogicBlock({target = BLOCKS.group.blocks[blockIndex]}, BLOCKS.group, BLOCKS.group[8], true)
                end
            end
        end
    end)

    return true
end

local function textListener(event)
    if event.phase == 'editing' then
        M.group.types[1].scroll:removeSelf()
        M.group.types[1].scroll = nil
        M.group.types[1].scroll = WIDGET.newScrollView({
                x = CENTER_X, y = (M.group[3].y + 2 + M.group[2].y) / 2,
                width = DISPLAY_WIDTH, height = M.group[2].y - M.group[3].y + 2,
                hideBackground = true, hideScrollBar = false,
                horizontalScrollDisabled = true, isBounceEnabled = true,
            })
        M.group:insert(M.group.types[1].scroll)

        local lastY = 90
        local scrollHeight = 50

        for j = 1, #INFO.listBlock.everyone do
            if UTF8.find(UTF8.lower(STR['blocks.' .. INFO.listBlock.everyone[j]]), UTF8.lower(event.target.text), 1, true) then
                local event = INFO.getType(INFO.listBlock.everyone[j]) == 'events'

                M.group.types[1].blocks[j] = display.newPolygon(0, 0, BLOCK.getPolygonParams(event, DISPLAY_WIDTH - RIGHT_HEIGHT - 60, event and 102 or 116))
                    M.group.types[1].blocks[j].x = DISPLAY_WIDTH / 2
                    M.group.types[1].blocks[j].y = lastY
                    M.group.types[1].blocks[j]:setFillColor(INFO.getBlockColor(INFO.listBlock.everyone[j]))
                    M.group.types[1].blocks[j]:setStrokeColor(0.3)
                    M.group.types[1].blocks[j].strokeWidth = 4
                    M.group.types[1].blocks[j].index = {1, j}
                    M.group.types[1].blocks[j]:addEventListener('touch', newBlockListener)
                M.group.types[1].scroll:insert(M.group.types[1].blocks[j])

                M.group.types[1].blocks[j].text = display.newText({
                        text = STR['blocks.' .. INFO.listBlock.everyone[j]],
                        x = DISPLAY_WIDTH / 2 - M.group.types[1].blocks[j].width / 2 + 20,
                        y = lastY, width = M.group.types[1].blocks[j].width - 40,
                        height = 40, font = 'ubuntu', fontSize = 32, align = 'left'
                    }) M.group.types[1].blocks[j].text.anchorX = 0
                M.group.types[1].scroll:insert(M.group.types[1].blocks[j].text)

                lastY = lastY + 140
                scrollHeight = scrollHeight + 140
            end
        end

        M.group.types[1].scroll:setScrollHeight(scrollHeight)
    end
end

M.remove = function()
    M.group[4]:removeSelf()
    M.group:removeSelf()
    M.group = nil
end

M.create = function()
    if M.group then
        M.group.isVisible = true
        M.group[3].isVisible = true
        M.group[4].isVisible = true

        if M.group[4].text ~= '' then
            M.group[4].text = ''
            textListener({phase = 'editing', target = M.group[4]})
        end

        if M.group.currentIndex ~= 1 then
            M.group.types[1].scroll.isVisible = true
            M.group.types[M.group.currentIndex].scroll.isVisible = false
            M.group.currentIndex = 1
        end
    else
        M.group = display.newGroup()
        M.group.types = {}
        M.group.currentIndex = 1

        local bg = display.newImage('Sprites/bg.png', CENTER_X, CENTER_Y)
            bg.width = CENTER_X == 640 and DISPLAY_HEIGHT or DISPLAY_WIDTH
            bg.height = CENTER_X == 640 and DISPLAY_WIDTH or DISPLAY_HEIGHT
            bg.rotation = CENTER_X == 640 and 90 or 0
        M.group:insert(bg)

        local line = display.newRect(CENTER_X, MAX_Y - 275, DISPLAY_WIDTH, 2)
            line:setFillColor(0.45)
        M.group:insert(line)

        local find = display.newRect(CENTER_X, ZERO_Y + 80, DISPLAY_WIDTH - RIGHT_HEIGHT - 60, 2)
            find:setFillColor(0.9)
        M.group:insert(find)

        local box = native.newTextField(5000, ZERO_Y + 50, DISPLAY_WIDTH - RIGHT_HEIGHT - 70, system.getInfo 'environment' ~= 'simulator' and 28 or 56)
            timer.performWithDelay(0, function()
                if M.group and M.group.isVisible and box then
                    box.x = CENTER_X
                    box.isEditable = true
                    box.hasBackground = false
                    box.placeholder = STR['button.block.find']
                    box.font = native.newFont('ubuntu', 28)

                    pcall(function() if system.getInfo 'platform' == 'android' and system.getInfo 'environment' ~= 'simulator' and box then
                        box:setTextColor(0.9)
                    else
                        box:setTextColor(0.1)
                    end end)
                end
            end) box:addEventListener('userInput', textListener)
        M.group:insert(box)

        local width = CENTER_X == 360 and DISPLAY_WIDTH / 5 - 24 or DISPLAY_WIDTH / 6
        local x, y = ZERO_X + 20, MAX_Y - 220

        for i = 1, #INFO.listType do
            M.group.types[i] = display.newRoundedRect(x, y, width, 62, 11)
                M.group.types[i].index = i
                M.group.types[i].blocks = {}
                M.group.types[i].anchorX = 0
                M.group.types[i]:setFillColor(INFO.getBlockColor(nil, nil, INFO.listType[i]))
                M.group.types[i]:addEventListener('touch', showTypeScroll)
            M.group:insert(M.group.types[i])

            local text = display.newText({
                text = STR['blocks.' .. INFO.listType[i]],
                x = 0, y = 0, width = width - 2, font = 'sans.ttf', fontSize = 19
            }) local textheight = text.height > 55 and 55 or text.height text:removeSelf()

            M.group.types[i].text = display.newText({
                    text = STR['blocks.' .. INFO.listType[i]],
                    x = x, y = y, width = width - 2, height = textheight,
                    font = 'ubuntu', fontSize = 19, align = 'center'
                }) M.group.types[i].text.anchorX = 0
            M.group:insert(M.group.types[i].text)

            M.group.types[i].scroll = WIDGET.newScrollView({
                    x = CENTER_X, y = ((i == 1 and find.y + 2 or ZERO_Y + 1) + line.y) / 2,
                    width = DISPLAY_WIDTH, height = line.y - (i == 1 and find.y + 2 or ZERO_Y + 1),
                    hideBackground = true, hideScrollBar = false,
                    horizontalScrollDisabled = true, isBounceEnabled = true,
                })
            M.group:insert(M.group.types[i].scroll)

            if i ~= 1 then M.group.types[i].scroll.isVisible = false end
            if i % 5 == 0 then y, x = y + 85, ZERO_X + 20 else x = x + width + 20 end

            local lastY = 90
            local scrollHeight = 50

            if INFO.listType[i] ~= 'none' then
                for j = 1, #INFO.listBlock[INFO.listType[i]] do
                    local name = INFO.listBlock[INFO.listType[i]][j]
                    if UTF8.sub(name, UTF8.len(name) - 2, UTF8.len(name)) ~= 'End' and name ~= 'ifElse' then
                        local event = INFO.getType(INFO.listBlock[INFO.listType[i]][j]) == 'events'

                        M.group.types[i].blocks[j] = display.newPolygon(0, 0, BLOCK.getPolygonParams(event, DISPLAY_WIDTH - LEFT_HEIGHT - RIGHT_HEIGHT - 60, event and 102 or 116))
                            M.group.types[i].blocks[j].x = DISPLAY_WIDTH / 2
                            M.group.types[i].blocks[j].y = lastY
                            M.group.types[i].blocks[j]:setFillColor(INFO.getBlockColor(name))
                            M.group.types[i].blocks[j]:setStrokeColor(0.3)
                            M.group.types[i].blocks[j].strokeWidth = 4
                            M.group.types[i].blocks[j].index = {i, j}
                            M.group.types[i].blocks[j]:addEventListener('touch', newBlockListener)
                        M.group.types[i].scroll:insert(M.group.types[i].blocks[j])

                        M.group.types[i].blocks[j].text = display.newText({
                                text = STR['blocks.' .. name],
                                x = DISPLAY_WIDTH / 2 - M.group.types[i].blocks[j].width / 2 + 20,
                                y = lastY, width = M.group.types[i].blocks[j].width - 40,
                                height = 40, font = 'ubuntu', fontSize = 32, align = 'left'
                            }) M.group.types[i].blocks[j].text.anchorX = 0
                        M.group.types[i].scroll:insert(M.group.types[i].blocks[j].text)

                        lastY = lastY + 140
                        scrollHeight = scrollHeight + 140
                    end
                end
            end

            M.group.types[i].scroll:setScrollHeight(scrollHeight)
        end
    end
end

return M
