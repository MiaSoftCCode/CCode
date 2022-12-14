local M = {}

if 'Объект' then
    M['obj.touch'] = function(name)
        return GAME.group.objects[name] and GAME.group.objects[name]._touch or false
    end

    M['obj.tag'] = function(name)
        return GAME.group.objects[name] and GAME.group.objects[name]._tag or ''
    end

    M['obj.pos_x'] = function(name)
        return GAME.group.objects[name] and select(1, GAME.group.objects[name]:localToContent(-CENTER_X, -CENTER_Y)) or 0
    end

    M['obj.pos_y'] = function(name)
        return GAME.group.objects[name] and 0 - select(2, GAME.group.objects[name]:localToContent(-CENTER_X, -CENTER_Y)) or 0
    end

    M['obj.width'] = function(name)
        return (GAME.group.objects[name] and GAME.group.objects[name]._radius)
        and (GAME.group.objects[name].radius or 0) or (GAME.group.objects[name] and GAME.group.objects[name].width or 0)
    end

    M['obj.height'] = function(name)
        return (GAME.group.objects[name] and GAME.group.objects[name]._radius)
        and (GAME.group.objects[name].radius or 0) or (GAME.group.objects[name] and GAME.group.objects[name].height or 0)
    end

    M['obj.rotation'] = function(name)
        return GAME.group.objects[name] and GAME.group.objects[name].rotation or 0
    end

    M['obj.alpha'] = function(name)
        return GAME.group.objects[name] and GAME.group.objects[name].alpha * 100 or 1
    end

    M['obj.name_texture'] = function(name)
        return GAME.group.objects[name] and GAME.group.objects[name]._name or ''
    end

    M['obj.velocity_x'] = function(name)
        return GAME.group.objects[name]._body ~= '' and select(1, GAME.group.objects[name]:getLinearVelocity()) or 0
    end

    M['obj.velocity_y'] = function(name)
        return GAME.group.objects[name]._body ~= '' and 0 - select(2, GAME.group.objects[name]:getLinearVelocity()) or 0
    end

    M['obj.angular_velocity'] = function(name)
        return GAME.group.objects[name]._body ~= '' and GAME.group.objects[name].angularVelocity or 0
    end
end

if 'Текст' then
    M['text.tag'] = function(name)
        return GAME.group.texts[name] and GAME.group.texts[name]._tag or ''
    end

    M['text.pos_x'] = function(name)
        return GAME.group.texts[name] and select(1, GAME.group.texts[name]:localToContent(-CENTER_X, -CENTER_Y)) or 0
    end

    M['text.pos_y'] = function(name)
        return GAME.group.texts[name] and 0 - select(2, GAME.group.texts[name]:localToContent(-CENTER_X, -CENTER_Y)) or 0
    end

    M['text.width'] = function(name)
        return GAME.group.texts[name] and GAME.group.texts[name].width or 0
    end

    M['text.height'] = function(name)
        return GAME.group.texts[name] and GAME.group.texts[name].height or 0
    end

    M['text.rotation'] = function(name)
        return GAME.group.texts[name] and GAME.group.texts[name].rotation or 0
    end

    M['text.alpha'] = function(name)
        return GAME.group.texts[name] and GAME.group.texts[name].alpha * 100 or 1
    end
end

if 'Группа' then
    M['group.tag'] = function(name)
        return GAME.group.groups[name] and GAME.group.groups[name]._tag or ''
    end

    M['group.pos_x'] = function(name)
        return GAME.group.groups[name] and select(1, GAME.group.groups[name]:localToContent(-CENTER_X, -CENTER_Y)) or 0
    end

    M['group.pos_y'] = function(name)
        return GAME.group.groups[name] and 0 - select(2, GAME.group.groups[name]:localToContent(-CENTER_X, -CENTER_Y)) or 0
    end

    M['group.width'] = function(name)
        return GAME.group.groups[name] and GAME.group.groups[name].width or 0
    end

    M['group.height'] = function(name)
        return GAME.group.groups[name] and GAME.group.groups[name].height or 0
    end

    M['group.rotation'] = function(name)
        return GAME.group.groups[name] and GAME.group.groups[name].rotation or 0
    end

    M['group.alpha'] = function(name)
        return GAME.group.groups[name] and GAME.group.groups[name].alpha * 100 or 1
    end
end

if 'Виджет' then
    M['widget.tag'] = function(name)
        return GAME.group.widgets[name] and GAME.group.widgets[name]._tag or ''
    end

    M['widget.pos_x'] = function(name)
        return GAME.group.widgets[name] and select(1, GAME.group.widgets[name]:localToContent(-CENTER_X, -CENTER_Y)) or 0
    end

    M['widget.pos_y'] = function(name)
        return GAME.group.widgets[name] and 0 - select(2, GAME.group.widgets[name]:localToContent(-CENTER_X, -CENTER_Y)) or 0
    end

    M['widget.value'] = function(name)
        return GAME.group.widgets[name] and (GAME.group.widgets[name]._type == 'slider' and GAME.group.widgets[name].value or 0) or 50
    end

    M['widget.text'] = function(name)
        return GAME.group.widgets[name] and (GAME.group.widgets[name]._type == 'field' and GAME.group.widgets[name].text or '') or ''
    end

    M['widget.link'] = function(name)
        return GAME.group.widgets[name] and (GAME.group.widgets[name]._type == 'webview' and GAME.group.widgets[name].url or '') or ''
    end
end

return M
