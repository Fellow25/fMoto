ESX = nil

local playerCars = {}

fellow_moto = {
	catemoto = {},
	listecatemoto = {},
}

local derniermotosorti = {}
local sortirmotoacheter = {}
local CurrentAction, CurrentActionMsg, LastZone, currentDisplayVehicle, CurrentVehicleData
local CurrentActionData, Vehicles, Categories = {}, {}, {}

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(10)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

Citizen.CreateThread(function()
if ConcessMoto.jeveuxblips then
        local concessmotomap = AddBlipForCoord(ConcessMoto.pos.blip.position.x, ConcessMoto.pos.blip.position.y, ConcessMoto.pos.blip.position.z)
        SetBlipSprite(concessmotomap, 226)
        SetBlipColour(concessmotomap, 18)
        SetBlipScale(concessmotomap, 0.85)
        SetBlipAsShortRange(concessmotomap, true)

        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString("Concessionnaire | Moto")
        EndTextCommandSetBlipName(concessmotomap)
end
end)

function Menuf6concessmoto()
    local f6concessmoto = RageUI.CreateMenu("Concessionnaire Moto", "Interactions")
    RageUI.Visible(f6concessmoto, not RageUI.Visible(f6concessmoto))
    while f6concessmoto do
        Citizen.Wait(0)
            RageUI.IsVisible(f6concessmoto, true, true, true, function()

                RageUI.Separator("↓ Facture ↓")

                RageUI.ButtonWithStyle("Facture",nil, {RightLabel = "→"}, true, function(_,_,s)
                    local player, distance = ESX.Game.GetClosestPlayer()
                    if s then
                        local raison = ""
                        local montant = 0
                        AddTextEntry("FMMC_MPM_NA", "Objet de la facture")
                        DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "Donnez le motif de la facture :", "", "", "", "", 30)
                        while (UpdateOnscreenKeyboard() == 0) do
                            DisableAllControlActions(0)
                            Wait(0)
                        end
                        if (GetOnscreenKeyboardResult()) then
                            local result = GetOnscreenKeyboardResult()
                            if result then
                                raison = result
                                result = nil
                                AddTextEntry("FMMC_MPM_NA", "Montant de la facture")
                                DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "Indiquez le montant de la facture :", "", "", "", "", 30)
                                while (UpdateOnscreenKeyboard() == 0) do
                                    DisableAllControlActions(0)
                                    Wait(0)
                                end
                                if (GetOnscreenKeyboardResult()) then
                                    result = GetOnscreenKeyboardResult()
                                    if result then
                                        montant = result
                                        result = nil
                                        if player ~= -1 and distance <= 3.0 then
                                            TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), 'society_motodealer', ('Concessionnaire Moto'), montant)
                                            TriggerEvent('esx:showAdvancedNotification', 'Fl~g~ee~s~ca ~g~Bank', 'Facture envoyée : ', 'Vous avez envoyé une facture d\'un montant de : ~g~'..montant.. '$ ~s~pour cette raison : ~b~' ..raison.. '', 'CHAR_BANK_FLEECA', 9)
                                        else
                                            ESX.ShowNotification("~r~Probleme~s~: Aucuns joueurs proche")
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)


                RageUI.Separator("↓ Annonce ↓")



                RageUI.ButtonWithStyle("Annonces d'ouverture",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                    if Selected then       
                        TriggerServerEvent('fConcessMoto:Ouvert')
                    end
                end)
        
                RageUI.ButtonWithStyle("Annonces de fermeture",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                    if Selected then      
                        TriggerServerEvent('fConcessMoto:Fermer')
                    end
                end)

                RageUI.ButtonWithStyle("Personnalisé", nil, {RightLabel = nil}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        local msg = KeyboardInput("Message", "", 100)
                        TriggerServerEvent('fConcessMoto:Perso', msg)
                    end
                end)

                end, function() 
                end)
    
                if not RageUI.Visible(f6concessmoto) then
                    f6concessmoto = RMenu:DeleteType("Concessionnaire Moto", true)
        end
    end
end


Keys.Register('F6', 'ConcessMoto', 'Ouvrir le menu Concessionnaire Moto', function()
	if ESX.PlayerData.job and ESX.PlayerData.job.name == 'motodealer' then
    	Menuf6concessmoto()
	end
end)

function MenuConcessMoto()
    local MConcessMoto = RageUI.CreateMenu("Menu", "Concessionnaire Moto")
    local MConcessMotoSub = RageUI.CreateSubMenu(MConcessMoto, "Menu", "Concessionnaire Moto")
    local MConcessMotoSub1 = RageUI.CreateSubMenu(MConcessMoto, "Menu", "Concessionnaire Moto")
    local MConcessMotoSub2 = RageUI.CreateSubMenu(MConcessMoto, "Menu", "Concessionnaire Moto")
    MConcessMotoSub2.Closed = function()
        supprimervehiculeconcess()
    end
    RageUI.Visible(MConcessMoto, not RageUI.Visible(MConcessMoto))
    while MConcessMoto do
        Wait(0)
            RageUI.IsVisible(MConcessMoto, true, true, true, function()

                RageUI.Separator("~b~"..ESX.PlayerData.job.grade_label.." - "..GetPlayerName(PlayerId()))


                RageUI.Separator("↓ Actions véhicules ↓")

                RageUI.ButtonWithStyle("Liste des véhicules", nil,  {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                end, MConcessMotoSub)

			end, function()
			end)

            	RageUI.IsVisible(MConcessMotoSub, true, true, true, function()
                
					for i = 1, #fellow_moto.catemoto, 1 do
                        RageUI.ButtonWithStyle("Catégorie - "..fellow_moto.catemoto[i].label, nil, {RightLabel = "→→→"},true, function(Hovered, Active, Selected)
                        if (Selected) then
                                nomcategorie = fellow_moto.catemoto[i].label
                                categoriemoto = fellow_moto.catemoto[i].name
                                ESX.TriggerServerCallback('fellow_moto:recupererlistemoto', function(listemoto)
                                        fellow_moto.listecatemoto = listemoto
                                end, categoriemoto)
                            end
                        end, MConcessMotoSub1)
                        end
                        end, function()
                        end)

                RageUI.IsVisible(MConcessMotoSub1, true, true, true, function()
			

                    RageUI.Separator("↓ Catégorie : "..nomcategorie.." ↓")
            
                        for i2 = 1, #fellow_moto.listecatemoto, 1 do
                        RageUI.ButtonWithStyle(fellow_moto.listecatemoto[i2].name, "Pour acheter ce véhicule", {RightLabel = fellow_moto.listecatemoto[i2].price.."$"},true, function(Hovered, Active, Selected)
                        if (Selected) then
                                nommoto = fellow_moto.listecatemoto[i2].name
                                prixmoto = fellow_moto.listecatemoto[i2].price
                                modelemoto = fellow_moto.listecatemoto[i2].model
                                supprimervehiculeconcess()
                                chargementmoto(modelemoto)
            
                                ESX.Game.SpawnVehicle(modelemoto, {x = ConcessMoto.pos.spawnmoto.position.x, y = ConcessMoto.pos.spawnmoto.position.y, z = ConcessMoto.pos.spawnmoto.position.z}, ConcessMoto.pos.spawnmoto.position.h, function (vehicle)
                                table.insert(derniermotosorti, vehicle)
                                FreezeEntityPosition(vehicle, true)
                                TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
                                SetModelAsNoLongerNeeded(modelemoto)
                                end)
                            end
                        end, MConcessMotoSub2)
                        
                        end
                        end, function()
                        end)

                        RageUI.IsVisible(MConcessMotoSub2, true, true, true, function()

                            RageUI.Separator("~r~↓ Vendre le véhicule au joueur le plus proche ↓")

                            RageUI.ButtonWithStyle("Vendre le véhicule", nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                                if (Selected) then    
                                        ESX.TriggerServerCallback('fellow_moto:verifsousmoto', function(suffisantsous)
                                        if suffisantsous then
                        
                                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        
                                        if closestPlayer == -1 or closestDistance > 3.0 then
                                        ESX.ShowNotification('Personne autour')
                                        else
                                        supprimervehiculeconcess()
                                        chargementmoto(modelemoto)
                        
                                        ESX.Game.SpawnVehicle(modelemoto, {x = ConcessMoto.pos.spawnmoto.position.x, y = ConcessMoto.pos.spawnmoto.position.y, z = ConcessMoto.pos.spawnmoto.position.z}, ConcessMoto.pos.spawnmoto.position.h, function (vehicle)
                                        table.insert(sortirmotoacheter, vehicle)
                                        FreezeEntityPosition(vehicle, true)
                                        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
                                        SetModelAsNoLongerNeeded(modelemoto)
                                        local plaque     = GeneratePlate()
                                        local vehicleProps = ESX.Game.GetVehicleProperties(sortirmotoacheter[#sortirmotoacheter])
                                        vehicleProps.plate = plaque
                                        SetVehicleNumberPlateText(sortirmotoacheter[#sortirmotoacheter], plaque)
                                        FreezeEntityPosition(sortirmotoacheter[#sortirmotoacheter], false)
                        
                                        TriggerServerEvent('fellow_moto:vendremotojoueur', GetPlayerServerId(closestPlayer), vehicleProps, prixmoto, nommoto)
                                        ESX.ShowNotification('Le véhicule '..nommoto..' avec la plaque '..vehicleProps.plate..' a été vendu à '..GetPlayerName(closestPlayer))
                                        TriggerServerEvent('esx_vehiclelock:registerkey', vehicleProps.plate, GetPlayerServerId(closestPlayer))
                                        end)
                                        end
                                        else
                                            ESX.ShowNotification('La société n\'as pas assez d\'argent pour ce véhicule!')
                                        end
                        
                                    end, prixmoto)
                                        end
                                    end)

                                    RageUI.Separator("~b~↓ Acheter le véhicule avec l'argent de la societé ↓")

                                    RageUI.ButtonWithStyle("Acheter le véhicule", nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                                        if (Selected) then   
                                            ESX.TriggerServerCallback('fellow_moto:verifsousmoto', function(suffisantsous)
                                            if suffisantsous then
                                            supprimervehiculeconcess()
                                            chargementmoto(modelemoto)
                                            ESX.Game.SpawnVehicle(modelemoto, {x = ConcessMoto.pos.spawnmoto.position.x, y = ConcessMoto.pos.spawnmoto.position.y, z = ConcessMoto.pos.spawnmoto.position.z}, ConcessMoto.pos.spawnmoto.position.h, function (vehicle)
                                            table.insert(sortirmotoacheter, vehicle)
                                            FreezeEntityPosition(vehicle, true)
                                            TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
                                            SetModelAsNoLongerNeeded(modelemoto)
                                            local plaque     = GeneratePlate()
                                            local vehicleProps = ESX.Game.GetVehicleProperties(sortirmotoacheter[#sortirmotoacheter])
                                            vehicleProps.plate = plaque
                                            SetVehicleNumberPlateText(sortirmotoacheter[#sortirmotoacheter], plaque)
                                            FreezeEntityPosition(sortirmotoacheter[#sortirmotoacheter], false)
                        
                                            TriggerServerEvent('shop:moto', vehicleProps, prixmoto, nommoto)
                                            ESX.ShowNotification('Le véhicule '..nommoto..' avec la plaque '..vehicleProps.plate..' a été vendu à '..GetPlayerName(PlayerId()))
                                            TriggerServerEvent('esx_vehiclelock:registerkey', vehicleProps.plate, GetPlayerServerId(closestPlayer))
                                            end)
                        
                                            else
                                                ESX.ShowNotification('La société n\'as pas assez d\'argent pour ce véhicule!')
                                            end
                            
                                        end, prixmoto)
                                            end
                                        end)

                        end, function()
                        end)

              if not RageUI.Visible(MConcessMoto) and not RageUI.Visible(MConcessMotoSub) and not RageUI.Visible(MConcessMotoSub1) and not RageUI.Visible(MConcessMotoSub2) then
              MConcessMoto = RMenu:DeleteType("MConcessMoto", true)
        end
    end
end


Citizen.CreateThread(function()
        while true do
            local Timer = 500
            if ESX.PlayerData.job and ESX.PlayerData.job.name == 'motodealer' or ESX.PlayerData.job2 and ESX.PlayerData.job2.name == 'motodealer' then  
            local plycrdjob = GetEntityCoords(GetPlayerPed(-1), false)
            local jobdist = Vdist(plycrdjob.x, plycrdjob.y, plycrdjob.z, ConcessMoto.pos.menu.position.x, ConcessMoto.pos.menu.position.y, ConcessMoto.pos.menu.position.z)
            if jobdist <= 10.0 and ConcessMoto.jeveuxmarker then
                Timer = 0
                DrawMarker(20, ConcessMoto.pos.menu.position.x, ConcessMoto.pos.menu.position.y, ConcessMoto.pos.menu.position.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 255, 255, 255, 255, 0, 1, 2, 0, nil, nil, 0)
                end
                if jobdist <= 1.0 then
                    Timer = 0
                        RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ pour accéder au menu", time_display = 1 })
                        if IsControlJustPressed(1,51) then
                            ESX.TriggerServerCallback('fellow_moto:recuperercategoriemoto', function(catemoto)
                                fellow_moto.catemoto = catemoto
                            end)
                            MenuConcessMoto()
                    end   
                end
            end 
        Citizen.Wait(Timer)   
    end
end)


function MenuSerrurier()
	local MSerrurier = RageUI.CreateMenu("Menu Serrurier", "Enregistrer des clés")
    ESX.TriggerServerCallback('ddx_vehiclelock:getVehiclesnokey', function(Vehicles2)
        RageUI.Visible(MSerrurier, not RageUI.Visible(MSerrurier))
            while MSerrurier do
            Citizen.Wait(0)
            RageUI.IsVisible(MSerrurier, true, true, true, function()
                RageUI.Separator('~g~Bienvenue '..GetPlayerName(PlayerId()))
                    for i=1, #Vehicles2, 1 do
                        model = Vehicles2[i].model
                        modelname = GetDisplayNameFromVehicleModel(model)
                        Vehicles2[i].model = GetLabelText(modelname)
                    RageUI.ButtonWithStyle(Vehicles2[i].model .. ' [' .. Vehicles2[i].plate .. ']',nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                        if Selected then
                            TriggerServerEvent('ddx_vehiclelockmoto:registerkey', Vehicles2[i].plate, 'no')
                            MenuSerrurier()
                        end
                    end)
                end
                end, function()
                end)
            if not RageUI.Visible(MSerrurier) then
            MSerrurier = RMenu:DeleteType("MSerrurier", true)
        end
    end
end)
end

Citizen.CreateThread(function()
        while true do
            local Timer = 500
            local plycrdjob = GetEntityCoords(GetPlayerPed(-1), false)
            local jobdist = Vdist(plycrdjob.x, plycrdjob.y, plycrdjob.z, ConcessMoto.pos.serrurier.position.x, ConcessMoto.pos.serrurier.position.y, ConcessMoto.pos.serrurier.position.z)
            if jobdist <= 10.0 and ConcessMoto.jeveuxmarker then
                Timer = 0
                DrawMarker(20, ConcessMoto.pos.serrurier.position.x, ConcessMoto.pos.serrurier.position.y, ConcessMoto.pos.serrurier.position.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 255, 255, 255, 255, 0, 1, 2, 0, nil, nil, 0)
                end
                if jobdist <= 1.0 then
                    Timer = 0
                        RageUI.Text({ message = "Appuyer sur ~y~[E]~s~ pour enregistrer des clés.", time_display = 1 })
                        if IsControlJustPressed(1,51) then
                            MenuSerrurier()
                            ESX.TriggerServerCallback('ddx_vehiclelock:getVehiclesnokey', function(Vehicles2)
                            end)
                    end   
                end 
        Citizen.Wait(Timer)   
    end
end)

function supprimervehiculeconcess()
	while #derniermotosorti > 0 do
		local vehicle = derniermotosorti[1]

		ESX.Game.DeleteVehicle(vehicle)
		table.remove(derniermotosorti, 1)
	end
end

function chargementmoto(modelHash)
	modelHash = (type(modelHash) == 'number' and modelHash or GetHashKey(modelHash))

	if not HasModelLoaded(modelHash) then
		RequestModel(modelHash)

		BeginTextCommandBusyString('STRING')
		AddTextComponentSubstringPlayerName('Chargement du véhicule')
		EndTextCommandBusyString(4)

		while not HasModelLoaded(modelHash) do
			Citizen.Wait(1)
			DisableAllControlActions(0)
		end

		RemoveLoadingPrompt()
	end
end

function OpenCloseVehicle()
	local playerPed = GetPlayerPed(-1)
	local coords    = GetEntityCoords(playerPed, true)

	local vehicle = nil

	if IsPedInAnyVehicle(playerPed,  false) then
		vehicle = GetVehiclePedIsIn(playerPed, false)
	else
		vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 7.0, 0, 71)
	end

	ESX.TriggerServerCallback('ddx_vehiclelock:mykey', function(gotkey)

		if gotkey then
			local locked = GetVehicleDoorLockStatus(vehicle)
			if locked == 1 or locked == 0 then -- if unlocked
				SetVehicleDoorsLocked(vehicle, 2)
				PlayVehicleDoorCloseSound(vehicle, 1)
				ESX.ShowNotification("Vous avez ~r~fermé~s~ le véhicule.")
			elseif locked == 2 then -- if locked
				SetVehicleDoorsLocked(vehicle, 1)
				PlayVehicleDoorOpenSound(vehicle, 0)
				ESX.ShowNotification("Vous avez ~g~ouvert~s~ le véhicule.")
			end
		else
			ESX.ShowNotification("~r~Vous n'avez pas les clés de ce véhicule.")
		end
	end, GetVehicleNumberPlateText(vehicle))
end

Citizen.CreateThread(function()
	while true do
		Wait(0)
        if not ConcessMoto.voiture then
		if IsControlJustReleased(0,303) then -- Touche K
			OpenCloseVehicle()
		end
    end
	end
end)

Citizen.CreateThread(function()
    local dict = "anim@mp_player_intmenu@key_fob@"
    
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(100)
    end
    while true do
        Citizen.Wait(0)
        if not ConcessMoto.voiture then
        if IsControlJustPressed(1, 303) then -- When you press "U"
             if not IsPedInAnyVehicle(GetPlayerPed(-1), true) then 
                TaskPlayAnim(GetPlayerPed(-1), dict, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
				StopAnimTask = true
              else
                TriggerEvent("chatMessage", "", { 200, 200, 90 }, "Vous devez être sorti d'un véhicule pour l'utiliser les clés !") -- Shows this message when you are not in a vehicle in the chat
				
             end
            end
        end
    end
end)
