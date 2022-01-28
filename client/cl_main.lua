local Prompts = {}

local function createPrompt(name, coords, key, text, options)
    if (Prompts[name] == nil) then
        Prompts[name] = {}
        Prompts[name].name = name
        Prompts[name].coords = coords
        Prompts[name].key = key
        Prompts[name].text = text
        Prompts[name].options = options
        Prompts[name].active = false
        Prompts[name].prompt = nil
        print('[qbr-prompts] Prompt with name ' .. name .. ' registered!')
    else
        print('[qbr-prompts]  Prompt with name ' .. name .. ' already exists!')
    end
end

local function executeOptions(options)
    if (options.type == 'client') then
        if (options.args == nil) then
            TriggerEvent(options.event)
        else
            TriggerEvent(options.event, table.unpack(options.args))
        end
    else
        if (options.args == nil) then
            TriggerServerEvent(options.event)
        else
            TriggerServerEvent(options.event, table.unpack(options.args))
        end
    end
end

local function setupPrompt(prompt)
    local str = prompt.text
    prompt.prompt = Citizen.InvokeNative(0x04F97DE45A519419)
    Citizen.InvokeNative(0xB5352B7494A08258, prompt.prompt, prompt.key)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    Citizen.InvokeNative(0x5DD02A8318420DD7, prompt.prompt, str)
    Citizen.InvokeNative(0x8A0FB4D03A630D21, prompt.prompt, false)
    Citizen.InvokeNative(0x71215ACCFDE075EE, prompt.prompt, false)
    Citizen.InvokeNative(0x94073D5CA3F16B7B, prompt.prompt, true)
    Citizen.InvokeNative(0xF7AA2696A22AD8B9, prompt.prompt)
end

AddEventHandler('onResourceStop', function()
    for k,v in pairs(Prompts) do
        Citizen.InvokeNative(0x8A0FB4D03A630D21, Prompts[k].prompt, false)
        Citizen.InvokeNative(0x71215ACCFDE075EE, Prompts[k].prompt, false)
        Prompts[k].prompt = nil
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000
        if (next(Prompts) ~= nil) then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped, true)
            for k,v in pairs(Prompts) do
                local distance = #(coords - v.coords)
                if (distance < 1.5) then
                    sleep = 1
                    if (Prompts[k].prompt == nil) then
                        setupPrompt(Prompts[k])
                    end
                    if (not Prompts[k].active) then
                        Citizen.InvokeNative(0x8A0FB4D03A630D21, Prompts[k].prompt, true)
                        Citizen.InvokeNative(0x71215ACCFDE075EE, Prompts[k].prompt, true)
                        Prompts[k].active = true
                        print('[qbr-prompts] Prompt with name ' .. Prompts[k].name .. ' activated!')
                    end
                    if (Citizen.InvokeNative(0xE0F65F0640EF0617, Prompts[k].prompt)) then
                        executeOptions(Prompts[k].options)
                        Citizen.InvokeNative(0x8A0FB4D03A630D21, Prompts[k].prompt, false)
                        Citizen.InvokeNative(0x71215ACCFDE075EE, Prompts[k].prompt, false)
                        Prompts[k].prompt = nil
                        Prompts[k].active = false
                    end
                else
                    if (Prompts[k].active) then
                        Citizen.InvokeNative(0x8A0FB4D03A630D21, Prompts[k].prompt, false)
                        Citizen.InvokeNative(0x71215ACCFDE075EE, Prompts[k].prompt, false)
                        Prompts[k].prompt = nil
                        Prompts[k].active = false
                        print('[qbr-prompts] Prompt with name ' .. Prompts[k].name .. ' removed!')
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

exports('createPrompt', createPrompt)
