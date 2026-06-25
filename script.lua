-- =============================================
-- i revamped this script and added GUI based ESP with 2d overlay
-- used grok and chatgpt
-- you may use this script however you want as it is unliscensed but dont forget to credit me
-- if you want any enquires hit me up on https://www.lezmoment.com/
-- F1 = Toggle | F12 = Eject
-- =============================================


local killerWeapons = {
    ["CharcoalSteel JS-22"] = true,
    ["Pretty Pink RR-LCP"] = true,
    ["JS2-BondsDerringy"] = true,
    ["JS-2 Derringy"] = true,
    ["GILDED"] = true,
    ["Kamatov"] = true,
    ["JS-22"] = true,
    ["NGO"] = true,
    ["Throwing Dagger"] = true,
    ["SoundMaker"] = true,
    ["SoundMakerSlower"] = true,
    ["RR-LightCompactPistol"] = true,
    ["J9-Meretta"] = true,
    ["RR-LCP"] = true,
    ["Sawn-off"] = true,
    ["Rosen-Obrez"] = true,
    ["K1911"] = true,
    ["WISP"] = true,
    ["Mooser"] = true,
    ["HW-K7"] = true,
    ["ZT-33"] = true,
    ["JSK-44"] = true,
    ["HEARDBALLER"] = true,
    ["THUMPA"] = true,

    ["JS-2 Bonds Derringy"] = true,
    ["JS2-Derringy"] = true,
    ["JS1-Cyclops"] = true,
    ["JS1 Competitor"] = true,

    ["RR-LCP (Silenced)"] = true,
    ["Chromeslide RR-LCP"] = true,
    ["Dual RR-LCPs"] = true,
    ["Kamatov RR-LCP"] = true,

    ["MAC-10"] = true,
    ["MAC10"] = true,
    ["ZZ-90"] = true,
    ["ZZ90"] = true,

    ["DB-12"] = true,
    ["Double Barrel"] = true,
    ["DB Shotgun"] = true,

    ["Throwing Kunai"] = true,
    ["Throwing Tomahawk"] = true,

    ["Molotov"] = true,

    ["Machete"] = true,
    ["Brass Knuckles"] = true,

    ["AA-12"] = true,

    ["Skorpion"] = true,
    ["SKORPION"] = true,
}


local vigilanteWeapons = {
    ["Beagle"] = true,
    ["IZVEKH-412"] = true,
    ["RR-Snubby"] = true,
    ["GG-17"] = true,
    ["J9-Meretta"] = true,
    ["HW-226"] = true,
    ["BUXXBERG-COMPACT"] = true,
    ["R&E Snubby"] = true,
    ["R&E M10"] = true,
    ["GG-26"] = true,

    ["Silver Steel RR-Snubby"] = true,
    ["GILDED RR-Snubby"] = true,
    ["Charcoal Steel IZVEKH-412"] = true,

    ["Mossberg 500"] = true,
    ["Remington 870"] = true,
    ["SPAS-12"] = true,
    ["KSG"] = true,

    ["M4A1"] = true,
    ["M4"] = true,
    ["KAR15"] = true,
    ["KAR-15"] = true,
    ["HK416"] = true,

    ["AKS-74U"] = true,
    ["ANKS-74U"] = true,
    ["RVK-12"] = true,

    ["SKORPION"] = true,
    ["Skorpion"] = true,

    ["ZKZ-Obrez"] = true,
    ["ZKZ-Obrez10"] = true,
}



local ESP_ENABLED = true
local RUNNING = true

local UPDATE_RATE = 0.02
local REFRESH_RATE = 3


local ESP_Data = {}
local NPC_List = {}



print("=== Matcha Role ESP Optimized Loaded ===")



--------------------------------------------------
-- Find weapon
--------------------------------------------------

local function findGun(container)

    if not container then
        return nil
    end


    for _,item in ipairs(container:GetChildren()) do

        if item:FindFirstChild("GUNCHECK") then
            return item.Name
        end

    end

    return nil

end



--------------------------------------------------
-- Find root
--------------------------------------------------

local function findRoot(model)

    local root =
        model:FindFirstChild("HumanoidRootPart")


    if not root then
        root = model.PrimaryPart
    end


    if not root then

        for _,v in ipairs(model:GetChildren()) do

            if v:IsA("BasePart") then
                root = v
                break
            end

        end

    end


    return root

end



--------------------------------------------------
-- Drawing
--------------------------------------------------

local function createESP()

    local box = Drawing.new("Square")

    box.Filled = false
    box.Thickness = 1
    box.Visible = false


    local text = Drawing.new("Text")

    text.Size = 13
    text.Center = true
    text.Outline = true
    text.Visible = false


    return {
        box = box,
        text = text
    }

end




--------------------------------------------------
-- Scan NPC folder
--------------------------------------------------

local function refreshNPCs()

    local playersFolder =
        game:FindFirstChild("Players")


    local npcFolder =
        workspace:FindFirstChild("NPCSFolder")


    if not playersFolder or not npcFolder then
        return
    end



    local found = {}


    for _,npc in ipairs(npcFolder:GetChildren()) do


        if npc:IsA("Model") then


            local player =
                playersFolder:FindFirstChild(npc.Name)



            if player then


                if not ESP_Data[npc] then

                    ESP_Data[npc] = createESP()

                end



                found[npc] = true


                local data = ESP_Data[npc]


                data.root =
                    findRoot(npc)


                data.player =
                    player



                data.gun =
                    findGun(player:FindFirstChild("Backpack"))
                    or findGun(npc)


                table.insert(
                    NPC_List,
                    npc
                )

            end

        end

    end



    -- cleanup

    for npc,data in pairs(ESP_Data) do

        if not found[npc] then

            pcall(function()

                data.box:Remove()
                data.text:Remove()

            end)


            ESP_Data[npc] = nil

        end

    end



    print(
        "NPC Refresh:",
        #NPC_List
    )

end





--------------------------------------------------
-- Role color
--------------------------------------------------

local function getRole(gun)


    if not gun then

        return
        "BYSTANDER",
        Color3.fromRGB(
            0,255,0
        )

    end



    if killerWeapons[gun] then

        return
        "KILLER",
        Color3.fromRGB(
            255,0,0
        )

    end



    if vigilanteWeapons[gun] then

        return
        "SHERIFF",
        Color3.fromRGB(
            0,120,255
        )

    end



    return
    "UNKNOWN",
    Color3.fromRGB(
        255,165,0
    )

end






--------------------------------------------------
-- Refresh thread
--------------------------------------------------

spawn(function()

    while RUNNING do

        refreshNPCs()

        task.wait(
            REFRESH_RATE
        )

    end

end)





--------------------------------------------------
-- ESP renderer
--------------------------------------------------

spawn(function()


    while RUNNING do



        for _,npc in ipairs(NPC_List) do


            local data =
                ESP_Data[npc]


            if data
            and npc.Parent
            and data.root
            and ESP_ENABLED then



                local top,
                visible1 =
                    WorldToScreen(
                        data.root.Position
                        +
                        Vector3.new(
                            0,3,0
                        )
                    )


                local bottom,
                visible2 =
                    WorldToScreen(
                        data.root.Position
                        -
                        Vector3.new(
                            0,3,0
                        )
                    )



                if visible1 and visible2 then


                    local height =
                        math.abs(
                            bottom.Y -
                            top.Y
                        )


                    local width =
                        height * 0.55



                    local role,color =
                        getRole(
                            data.gun
                        )



                    data.box.Size =
                        Vector2.new(
                            width,
                            height
                        )


                    data.box.Position =
                        Vector2.new(
                            top.X-width/2,
                            top.Y
                        )


                    data.box.Color =
                        color


                    data.box.Visible =
                        true




                    data.text.Text =
                        npc.Name
                        ..
                        "\n"
                        ..
                        (
                            data.gun
                            or
                            "No Gun"
                        )
                        ..
                        "\n["
                        ..
                        role
                        ..
                        "]"



                    data.text.Position =
                        Vector2.new(
                            top.X,
                            top.Y-20
                        )


                    data.text.Color =
                        color


                    data.text.Visible =
                        true


                else

                    data.box.Visible = false
                    data.text.Visible = false

                end


            elseif data then

                data.box.Visible = false
                data.text.Visible = false

            end


        end


        task.wait(
            UPDATE_RATE
        )

    end

end)





--------------------------------------------------
-- Keys
--------------------------------------------------

spawn(function()


    while RUNNING do


        task.wait(0.1)



        if iskeypressed(112) then

            ESP_ENABLED =
                not ESP_ENABLED


            print(
                "ESP:",
                ESP_ENABLED
            )


            task.wait(
                0.4
            )

        end




        if iskeypressed(123) then


            RUNNING = false


            for _,data in pairs(ESP_Data) do

                pcall(function()

                    data.box:Remove()
                    data.text:Remove()

                end)

            end



            print(
                "ESP unloaded"
            )


            break

        end


    end


end)
