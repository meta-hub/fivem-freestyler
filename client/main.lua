Freestyler = {}

Freestyler.Init = function()
  Freestyler.Player       = PlayerId()
  Freestyler.Start        = GetGameTimer()  
  Freestyler.Volume       = 0.0
  Freestyler.LastVolume   = 0.0

  while 
  not (NetworkIsPlayerActive(Freestyler.Player))
  and (GetGameTimer() - Freestyler.Start) < 5000
  do 
    Wait(0)
  end

  Freestyler.Update()
end

Freestyler.Update = function()
  while true do
    local wait_time = 500

    if Freestyler.Target then
      local _target = Freestyler.Target
      if _target == Freestyler.Player then
        Freestyler.IsTarget()
      else
        Freestyler.CheckTarget(_target)
      end

      Freestyler.CheckVolume()

      wait_time = 0
    end

    Wait(wait_time)
  end
end

Freestyler.RockAMicrophone = function(target)
  local ped = GetPlayerPed(-1)
  local pos = GetEntityCoords(target)
  ShootSingleBulletBetweenCoords(pos.x,pos.y,pos.z + 1.5, pos.x,pos.y,pos.z, 1, false, GetHashKey('WEAPON_STUNGUN'), ped, true, true, 100)

  Freestyler.Target = NetworkGetEntityOwner(target)
  TriggerServerEvent("Freestyler:SetTarget",Freestyler.Target)

  if IsEntityPlayingAnim(ped,'anim@amb@nightclub@mini@dance@dance_solo@female@var_b@','high_center',3) then      
    ClearPedTasks(ped)
  end
end

Freestyler.IsTarget = function()
  local ped = GetPlayerPed(-1)
  local hash = GetHashKey('WEAPON_UNARMED')

  if IsPedInMeleeCombat(ped) then
    local target = GetMeleeTargetForPed(ped)
    if target and target >= 1 then
      if not Freestyler.MeleeTarget or Freestyler.MeleeTarget ~= target then
        Freestyler.MeleeTarget = target
        Freestyler.MeleeTargetHP = GetEntityHealth(target)
        Freestyler.MeleeTargetDamaged = false
        return
      end

      if HasEntityBeenDamagedByEntity(target,ped,1) then
        Freestyler.RockAMicrophone(target)
      end
    end
  else
    if not IsEntityPlayingAnim(ped,'anim@amb@nightclub@mini@dance@dance_solo@female@var_b@','high_center',3) then
      Freestyler.Animate()
      Wait(100)
    end
  end

  Freestyler.Volume = 0.5
end

Freestyler.LoadDict = function(ad)
  RequestAnimDict(ad)
  while not HasAnimDictLoaded(ad) do Wait(0); end
end

Freestyler.Notification = function(msg)
  SetNotificationTextEntry('STRING')
  AddTextComponentSubstringPlayerName(msg)
  DrawNotification(false, true)
end

Freestyler.Animate = function()
  Freestyler.LoadDict('anim@amb@nightclub@mini@dance@dance_solo@female@var_b@')
  TaskPlayAnim(GetPlayerPed(-1),'anim@amb@nightclub@mini@dance@dance_solo@female@var_b@','high_center',8.0,8.0,-1,49,1.0,false,false,false)
end

Freestyler.CheckVolume = function()
  if Freestyler.Volume ~= Freestyler.LastVolume then
    Freestyler.LastVolume = Freestyler.Volume
    SendNUIMessage({
      message = "Volume",
      volume  = Freestyler.Volume
    })
  end
end

Freestyler.CheckTarget = function(target)
  local ped   = GetPlayerPed    (-1)
  local pos   = GetEntityCoords (ped)  
  local tped  = GetPlayerPed    (target)

  if tped and tped >= 1 and DoesEntityExist(tped) then
    local tpos = GetEntityCoords(tped)
    local dist = Vdist(pos,tpos)
    local v = 0.0 + ((100.0 - (math.min(50.0,dist)*2))/200.0)
    Freestyler.Volume = v
  else
    Freestyler.Volume = 0.0
  end
end

Freestyler.Disarm = function()
  local hash = GetHashKey('WEAPON_UNARMED')
  SetWeaponDamageModifier(hash,0.1)
  SetPlayerWeaponDamageModifier(Freestyler.Player,0.1)
  SetPlayerMeleeWeaponDamageModifier(Freestyler.Player,0.1)
end

Freestyler.Rearm = function()
  local hash = GetHashKey('WEAPON_UNARMED')
  SetWeaponDamageModifier(hash,1.0)
  SetPlayerWeaponDamageModifier(Freestyler.Player,1.0)
  SetPlayerMeleeWeaponDamageModifier(Freestyler.Player,1.0)
end

Freestyler.SetTarget = function(target)
  if target == Freestyler.Player then
    Freestyler.Notification("You've become the freestyler.")

    while IsPedInWrithe(GetPlayerPed(-1))             do Wait(0); end
    while IsPedRagdoll(GetPlayerPed(-1))              do Wait(0); end
    while not GetPedConfigFlag(GetPlayerPed(-1),60)   do Wait(0); end
    Wait(2000)

    Freestyler.Animate()
  else
    Freestyler.Rearm()
  end

  Freestyler.Target = target
end

RegisterNetEvent("Freestyler:SetTarget")
AddEventHandler("Freestyler:SetTarget",Freestyler.SetTarget)

Citizen.CreateThread(Freestyler.Init)