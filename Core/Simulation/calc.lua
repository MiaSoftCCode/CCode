return function(params, default)
    local result, index = #params == 0 and ' 0' or ''

    for i = 1, #params do
        if params[i - 1] and params[i - 1][2] == 's' and params[i - 1][1] == '[' then
            index = UTF8.len(result)
        end

        if params[i][2] == 'n' then
            result = result .. ' ' .. params[i][1]
        elseif params[i][2] == 'c' then
            result = result .. ' JSON.decode(\'' .. params[i][1] .. '\')'
        elseif params[i][2] == 'u' then
            result = result .. ' {}'
        elseif params[i][2] == 'l' then
            result = result .. ' ' .. params[i][1]
        elseif params[i][2] == 'f' then
            result = result .. ' fun[\'' .. params[i][1] .. '\']'
            if params[i][1] == 'unix_time' then result = result .. '()' end
        elseif params[i][2] == 'd' then
            result = result .. ' device[\'' .. params[i][1] .. '\']()'
        elseif params[i][2] == 'sl' then
            result = result .. ' select[\'' .. params[i][1] .. '\']()'
        elseif params[i][2] == 'm' then
            result = result .. ' math[\'' .. params[i][1] .. '\']'
        elseif params[i][2] == 'p' then
            result = result .. ' prop[\'' .. params[i][1] .. '\']'
        elseif params[i][2] == 's' then
            if params[i][1] == '+' and ((params[i - 1] and params[i - 1][2] == 't') or (params[i + 1] and params[i + 1][2] == 't')) then
                result = result .. ' ..'
            else
                if params[i][1] == '[' or params[i][1] == ']' then
                    result = result .. params[i][1]
                else
                    result = result .. ' ' .. params[i][1]
                end
            end
        elseif params[i][2] == 't' then
            params[i][1] = UTF8.gsub(params[i][1], '\'', '\"')
            result = result .. ' \'' .. params[i][1] .. '\''
        elseif params[i][2] == 'tE' then
            result = result .. ' tablesE[\'' .. params[i][1] .. '\']'
        elseif params[i][2] == 'tS' then
            result = result .. ' tablesS[\'' .. params[i][1] .. '\']'
        elseif params[i][2] == 'tP' then
            result = result .. ' tablesP[\'' .. params[i][1] .. '\']'
        elseif params[i][2] == 'vE' then
            result = result .. ' varsE[\'' .. params[i][1] .. '\']'
        elseif params[i][2] == 'vS' then
            result = result .. ' varsS[\'' .. params[i][1] .. '\']'
        elseif params[i][2] == 'vP' then
            result = result .. ' varsP[\'' .. params[i][1] .. '\']'
        elseif params[i][2] == 'fS' then
            result = result .. ' funsS[\'' .. params[i][1] .. '\']'
        elseif params[i][2] == 'fP' then
            result = result .. ' funsP[\'' .. params[i][1] .. '\']'
        end

        if index then
            result, index = UTF8.sub(result, 1, index) .. UTF8.sub(result, index + 2, UTF8.len(result)), nil
        end
    end

    return (#params == 0 and default) and default or UTF8.sub(result, 1, 1) == ' ' and UTF8.sub(result, 2, UTF8.len(result)) or 't' .. result
end
