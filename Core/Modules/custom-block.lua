local LOGIC = require 'Core.Modules.logic-list'
local INFO = require 'Data.info'
local M = {}

local function genBlock(params, index)
    M.block = LOGIC.create({name = '', params = params}, 1.0, true)
        M.block.y = M.scroll.height / 2 - M.block.height / 2 < 20 and 20 + M.block.height / 2 or M.scroll.height / 2
        M.block.x = M.scroll.width / 2
    M.scroll:insert(M.block)

    for i = 1, #params do
        local listener = function(e)
            if M.alert then
                if e.phase == 'began' then
                    display.getCurrentStage():setFocus(e.target)
                    M.block.rects[i]:setFillColor(0.8, 0.8, 1)
                    M.block.rects[i].alpha = 0.2
                    e.target.click = true
                elseif e.phase == 'moved' and (math.abs(e.yDelta) > 30 or math.abs(e.xDelta) > 30) then
                    M.scroll:takeFocus(e)
                    M.block.rects[i]:setFillColor(1)
                    M.block.rects[i].alpha = 0.005
                    e.target.click = false
                elseif e.phase == 'ended' or e.phase == 'cancelled' then
                    display.getCurrentStage():setFocus(nil)
                    M.block.rects[i]:setFillColor(1)
                    M.block.rects[i].alpha = 0.005
                    if e.target.click then
                        e.target.click, M.alert = false, false
                        M.scroll:setIsLocked(true, 'vertical')

                        INPUT.new(STR['blocks.entertext'], function(event)
                            if (event.phase == 'ended' or event.phase == 'submitted') and not ALERT then
                                INPUT.remove(true, event.target.text)
                            end
                        end, function(event)
                            ALERT = false
                            M.alert = true
                            M.scroll:setIsLocked(false, 'vertical')
                            if event.input then
                                STR['blocks..params'][i] = event.text .. ':'
                                M.scroll:remove(M.block) M.block:removeSelf()
                                genBlock(params, index)
                            end EXITS.add(M.removeOverlay, index)
                        end, UTF8.sub(M.block.params[i].name.text, 1, UTF8.len(M.block.params[i].name.text) - 1))
                        native.setKeyboardFocus(INPUT.box)
                    end
                end
            end

            return true
        end

        M.block.params[i].name:addEventListener('touch', listener)
        M.block.params[i].rect:addEventListener('touch', listener)
    end

    M.block.text:addEventListener('touch', function(e)
        if M.alert then
            if e.phase == 'began' then
                display.getCurrentStage():setFocus(e.target)
                e.target:setFillColor(0.7)
                e.target.click = true
            elseif e.phase == 'moved' and (math.abs(e.yDelta) > 30 or math.abs(e.xDelta) > 30) then
                M.scroll:takeFocus(e)
                e.target:setFillColor(1)
                e.target.click = false
            elseif e.phase == 'ended' or e.phase == 'cancelled' then
                display.getCurrentStage():setFocus(nil)
                e.target:setFillColor(1)
                if e.target.click then
                    e.target.click, M.alert = false, false
                    M.scroll:setIsLocked(true, 'vertical')

                    INPUT.new(STR['blocks.entertext'], function(event)
                        if (event.phase == 'ended' or event.phase == 'submitted') and not ALERT then
                            INPUT.remove(true, event.target.text)
                        end
                    end, function(event)
                        ALERT = false
                        M.alert = true
                        M.scroll:setIsLocked(false, 'vertical')
                        if event.input then
                            STR['blocks.'] = event.text
                            M.block.text.text = event.text
                        end EXITS.add(M.removeOverlay, index)
                    end, M.block.text.text)
                    native.setKeyboardFocus(INPUT.box)
                end
            end
        end

        return true
    end)
end

M.addBlock = function(params, _index)
    local custom = GET_GAME_CUSTOM()
    local index = _index or tostring(custom.len + 1)

    for i = 1, _index and 0 or custom.len do
        if not custom[tostring(i)] then
            index = tostring(i) break
        end
    end

    if params.string then
        custom.len = custom.len + (_index and 0 or 1)
        custom[index] = {STR['blocks.'], COPY_TABLE(STR['blocks..params']), params.string, os.time()}

        local block = custom[index]
        local typeBlock = 'custom' .. index
        local blockParams = {} for i = 1, #block[2] do blockParams[i] = 'value' end

        STR['blocks.' .. typeBlock] = block[1]
        STR['blocks.' .. typeBlock .. '.params'] = block[2]
        LANG.ru['blocks.' .. typeBlock] = block[1]
        LANG.ru['blocks.' .. typeBlock .. '.params'] = block[2]
        INFO.listName[typeBlock] = {'custom', unpack(blockParams)}

        if _index then
            for id, type in ipairs(INFO.listBlock.custom) do
                if type == typeBlock then
                    table.remove(INFO.listBlock.custom, id)
                    table.insert(INFO.listBlock.custom, 1, typeBlock)
                    break
                end
            end
        else
            table.insert(INFO.listBlock.custom, 1, typeBlock)
            table.insert(INFO.listBlock.everyone, typeBlock)
        end

        SET_GAME_CUSTOM(custom) ALERT = true
        M.scroll:removeSelf() M.group:removeSelf()
        STR['blocks..params'] = {} STR['blocks.'] = STR['blocks.default']

        NEW_BLOCK.remove() NEW_BLOCK.create()
        NEW_BLOCK.group.types[15].scroll.isVisible = true
        NEW_BLOCK.group.types[1].scroll.isVisible = false
        NEW_BLOCK.group[4].isVisible = false
        NEW_BLOCK.group.currentIndex = 15
        for i = 5, 10 do NEW_BLOCK.group[i].isVisible = true end
    else
        local data = GET_GAME_CODE(CURRENT_LINK)
        local block = {STR['blocks.'], COPY_TABLE(STR['blocks..params'])}
        local blockParams = {} for i = 1, #block[2] do blockParams[i] = 'value' end
        local eventParams = {} for i = 1, #block[2] do eventParams[i] = 'localvar' end
        local typeBlock, sandboxScript = 'custom' .. index, (_index and type(custom[index][3]) == 'table') and custom[index][3] or {
            vars = {}, funs = {}, tables = {}, title = STR['scripts.sandbox'], custom = true,
            params = {{vars = {}, tables = {}, nested = {}, name = '_custom', comment = false, event = true,
            params = (function() local t = {} for i = 1, #block[2] do t[i] = {} end return t end)()}}
        }

        STR['blocks.' .. typeBlock] = block[1]
        STR['blocks.' .. typeBlock .. '.params'] = block[2]
        STR['blocks._custom'] = block[1]
        STR['blocks._custom.params'] = block[2]

        LANG.ru['blocks.' .. typeBlock] = block[1]
        LANG.ru['blocks.' .. typeBlock .. '.params'] = block[2]
        LANG.ru['blocks._custom'] = block[1]
        LANG.ru['blocks._custom.params'] = block[2]

        INFO.listName[typeBlock] = {'custom', unpack(blockParams)}
        INFO.listName['_custom'] = {'custom', unpack(eventParams)}
        table.insert(INFO.listBlock.everyone, 1, typeBlock)
        table.insert(data.scripts, 1, sandboxScript)
        SET_GAME_CODE(CURRENT_LINK, data)

        STR['blocks..params'] = {} STR['blocks.'] = STR['blocks.default']
        ALERT = true M.scroll:removeSelf() M.group:removeSelf() NEW_BLOCK.remove()
        BLOCKS.group:removeSelf() BLOCKS.group = nil LAST_CURRENT_SCRIPT, CURRENT_SCRIPT = CURRENT_SCRIPT, 1
        BLOCKS.create({name = block[1], params = COPY_TABLE(block[2]), index = index, isChange = _index})
        BLOCKS.group.isVisible = true
    end
end

M.removeOverlay = function(index)
    if index then
        WINDOW.new(STR['scripts.sandbox.exit'], {STR['scripts.sandbox.not.save'], STR['scripts.sandbox.save']}, function(e)
            if e.index == 2 then
                local custom, data = GET_GAME_CUSTOM(), GET_GAME_CODE(CURRENT_LINK)
                    custom[index][1] = STR['blocks.']
                    custom[index][2] = COPY_TABLE(STR['blocks..params'])
                    custom[index][4] = os.time()
                SET_GAME_CUSTOM(custom)

                STR['blocks.custom' .. index] = STR['blocks.']
                STR['blocks.custom' .. index .. '.params'] = COPY_TABLE(STR['blocks..params'])
                LANG.ru['blocks.custom' .. index] = STR['blocks.']
                LANG.ru['blocks.custom' .. index .. '.params'] = COPY_TABLE(STR['blocks..params'])

                for id, type in ipairs(INFO.listBlock.custom) do
                    if type == 'custom' .. index then
                        table.remove(INFO.listBlock.custom, id)
                        table.insert(INFO.listBlock.custom, 1, type)
                        break
                    end
                end

                for i = 1, #data.scripts do
                    for j = 1, #data.scripts[i].params do
                        if data.scripts[i].params[j].name == 'custom' .. index then
                            local block = custom[index]
                            local typeBlock = 'custom' .. index
                            local blockParams = {} for i = 1, #block[2] do blockParams[i] = 'value' end

                            INFO.listName[typeBlock] = {'custom', unpack(blockParams)}

                            if #data.scripts[i].params[j].params >= #block[2] then
                                for k = #data.scripts[i].params[j].params, #block[2] + 1, -1 do
                                    table.remove(data.scripts[i].params[j].params, k)
                                end
                            else
                                for k = #data.scripts[i].params[j].params + 1, #block[2] do
                                    data.scripts[i].params[j].params[k] = {}
                                end
                            end
                        end
                    end
                end

                SET_GAME_CODE(CURRENT_LINK, data)
                BLOCKS.group:removeSelf() BLOCKS.group = nil
                BLOCKS.create() BLOCKS.custom = nil
                BLOCKS.group.isVisible = false
            end

            if e.index ~= 0 then
                ALERT = true
                M.group:removeSelf()
                M.scroll:removeSelf()
                STR['blocks..params'] = {}
                STR['blocks.'] = STR['blocks.default']

                NEW_BLOCK.remove() NEW_BLOCK.create()
                NEW_BLOCK.group.types[15].scroll.isVisible = true
                NEW_BLOCK.group.types[1].scroll.isVisible = false
                NEW_BLOCK.group[4].isVisible = false
                for i = 5, 10 do NEW_BLOCK.group[i].isVisible = true end
                NEW_BLOCK.group.currentIndex = 15
            end
        end, 4)
    else
        ALERT = true
        M.group:removeSelf()
        M.scroll:removeSelf()
        STR['blocks..params'] = {}
        STR['blocks.'] = STR['blocks.default']
    end
end

M.newBlock = function(name, params, str, index)
    M.group = display.newGroup()
        ALERT = false
    M.alert = true

    local shadow = display.newRect(CENTER_X, CENTER_Y, DISPLAY_WIDTH * 2, DISPLAY_HEIGHT * 2)
        shadow:setFillColor(0.15, 0.15, 0.17, 1)
        shadow:addEventListener('touch', function(e) return true end)
    M.group:insert(shadow)

    local title = display.newText(STR['blocks.create.block'], ZERO_X + 10, ZERO_Y + 10, 'ubuntu', 32)
        title.anchorX = 0
        title.anchorY = 0
    M.group:insert(title)

    M.scroll = WIDGET.newScrollView({
            x = CENTER_X, y = title.y + 80,
            width = DISPLAY_WIDTH, height = MAX_Y - title.y - 300,
            hideBackground = true, hideScrollBar = true,
            horizontalScrollDisabled = true, isBounceEnabled = true
        }) M.scroll.anchorY = 0
    M.group:insert(M.scroll)

    local params = params or {}
        for i = 1, str and #str or 0 do
            STR['blocks..params'][i] = str[i]
            params[i] = {{'hello world', 't'}}
        end
    genBlock(params, index)

    if name then
        STR['blocks.'] = name
        M.block.text.text = name
    end

    local completeImportLua = function(import)
        if import and import.done == 'ok' then
            M.addBlock({string = READ_FILE(DOC_DIR .. '/custom.lua')}, index)
        end
    end

    local onPaste = function(e)
        if e.string then
            M.addBlock({string = e.string}, index)
        end
    end

    local buttonListeners = function(e)
        if M.alert then
            if e.phase == 'began' then
                display.getCurrentStage():setFocus(e.target)
                if e.target.tag == 'exit'
                then e.target:setFillColor(0.7)
                else e.target.alpha = 0.1 end
                e.target.click = true
            elseif e.phase == 'moved' and (math.abs(e.xDelta) > 30 or math.abs(e.yDelta) > 30) then
                display.getCurrentStage():setFocus(nil)
                if e.target.tag == 'exit'
                then e.target:setFillColor(1)
                else e.target.alpha = 0.005 end
                e.target.click = false
            elseif e.phase == 'ended' or e.phase == 'cancelled' then
                display.getCurrentStage():setFocus(nil)
                if e.target.tag == 'exit'
                then e.target:setFillColor(1)
                else e.target.alpha = 0.005 end
                if e.target.click then
                    e.target.click = false

                    if e.target.tag == 'plus' and #params < 100 then
                        table.insert(params, {{'hello world', 't'}})
                        table.insert(STR['blocks..params'], STR['blocks.params'] .. (#params - 1) .. ':')
                        M.scroll:remove(M.block) M.block:removeSelf() genBlock(params, index)

                        if M.block.y + M.block.height / 2 + 20 > M.scroll.height then
                            M.scroll:scrollToPosition({time = 200, y = -(M.block.y + M.block.height / 2 + 20 - M.scroll.height)})
                        end
                    elseif e.target.tag == 'minus' and #params > 0 then
                        table.remove(params, #params)
                        table.remove(STR['blocks..params'], #params + 1)
                        M.scroll:remove(M.block) M.block:removeSelf() genBlock(params, index)

                        if M.block.y + M.block.height / 2 + 20 > M.scroll.height then
                            M.scroll:scrollToPosition({time = 200, y = -(M.block.y + M.block.height / 2 + 20 - M.scroll.height)})
                        end
                    elseif e.target.tag == 'exit' then
                        M.removeOverlay(index)
                    elseif e.target.tag == 'lua' then
                        M.scroll:setIsLocked(true, 'vertical') M.alert = false
                        WINDOW.new(STR['blocks.create.block.save.lua.title'],
                            {STR['button.pasteFromClipboard'], STR['button.importLuaFile']}, function(e)
                                if e.index == 1 then
                                    if not IS_SIM and not IS_WIN then
                                        PASTEBOARD.paste(onPaste)
                                    end
                                elseif e.index == 2 then
                                    FILE.pickFile(DOC_DIR, completeImportLua, 'custom.lua', '', 'text/x-lua', nil, nil, nil)
                                end

                                if e.index == 0 then
                                    ALERT = false
                                    M.alert = true
                                    M.scroll:setIsLocked(false, 'vertical')
                                end

                                EXITS.add(M.removeOverlay, index)
                        end, 4)
                    elseif e.target.tag == 'sandbox' then
                        M.addBlock({}, index)
                    end
                end
            end
        end

        return true
    end

    local buttonHeight = 100
    local buttonWidth = DISPLAY_WIDTH / 2
    local buttonX = CENTER_X - buttonWidth / 2
    local buttonY = MAX_Y - buttonHeight * 1.5

    local buttonPlus = display.newRect(buttonX, buttonY, buttonWidth, buttonHeight)
        buttonPlus.alpha = 0.005
        buttonPlus.tag = 'plus'
    M.group:insert(buttonPlus)

    local textPlus = display.newText(STR['blocks.params.add'], buttonPlus.x, buttonPlus.y, 'ubuntu', 28)
        buttonPlus:addEventListener('touch', buttonListeners)
    M.group:insert(textPlus)

    local buttonMinus = display.newRect(buttonX, buttonY + buttonHeight, buttonWidth, buttonHeight)
        buttonMinus.alpha = 0.005
        buttonMinus.tag = 'minus'
    M.group:insert(buttonMinus)

    local textMinus = display.newText(STR['blocks.params.remove'], buttonMinus.x, buttonMinus.y, 'ubuntu', 28)
        buttonMinus:addEventListener('touch', buttonListeners)
    M.group:insert(textMinus)

    local buttonLua = display.newRect(buttonX + buttonWidth, buttonY, buttonWidth, buttonHeight)
        buttonLua.alpha = 0.005
        buttonLua.tag = 'lua'
    M.group:insert(buttonLua)

    local textLua = display.newText(STR['blocks.create.block.save.lua'], buttonLua.x, buttonLua.y, 'ubuntu', 28)
        buttonLua:addEventListener('touch', buttonListeners)
    M.group:insert(textLua)

    local buttonSandbox = display.newRect(buttonX + buttonWidth, buttonY + buttonHeight, buttonWidth, buttonHeight)
        buttonSandbox.alpha = 0.005
        buttonSandbox.tag = 'sandbox'
    M.group:insert(buttonSandbox)

    local textSandbox = display.newText(STR['blocks.create.block.save.sandbox'], buttonSandbox.x, buttonSandbox.y, 'ubuntu', 28)
        buttonSandbox:addEventListener('touch', buttonListeners)
    M.group:insert(textSandbox)

    title.tag = 'exit' EXITS.add(M.removeOverlay, index)
    title:addEventListener('touch', buttonListeners)
end

M.getBlocks = function()
    local custom, ids = GET_GAME_CUSTOM(), {}

    for index, block in pairs(custom) do
        if tonumber(index) then
            table.insert(ids, {block[4], tonumber(index)})
        end
    end table.sort(ids, function(a, b) return (a[1] == b[1]) and (a[2] > b[2]) or (a[1] > b[1]) end)

    for _, index in ipairs(ids) do
        local index = tostring(index[2])
        local block = custom[index]
        local typeBlock = 'custom' .. index
        local blockParams = {} for i = 1, #block[2] do blockParams[i] = 'value' end

        STR['blocks.' .. typeBlock] = block[1]
        STR['blocks.' .. typeBlock .. '.params'] = block[2]
        LANG.ru['blocks.' .. typeBlock] = block[1]
        LANG.ru['blocks.' .. typeBlock .. '.params'] = block[2]

        INFO.listName[typeBlock] = {'custom', unpack(blockParams)}
        table.insert(INFO.listBlock.custom, typeBlock)
        table.insert(INFO.listBlock.everyone, typeBlock)
    end
end

return M
