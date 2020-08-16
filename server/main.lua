Freestyler = {}

Freestyler.SetTarget = function(target)
  TriggerClientEvent("Freestyler:SetTarget",-1,target)
end

RegisterNetEvent("Freestyler:SetTarget")
AddEventHandler("Freestyler:SetTarget",Freestyler.SetTarget)

RegisterCommand('freestyler', function(source,args)
  Freestyler.SetTarget(tonumber(args[1]))
end,true)