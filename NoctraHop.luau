local genv = getgenv()

genv.__CyborgCodexSource = [=[if not LPH_OBFUSCATED then
	LPH_ATTRIBUTES = function(...) end
	VM = function(...) end
	PRESET = function(...) end
	TRANSFORM = function(...) end
	NONE = "NONE"
	FAST = "FAST"
	OPAL = "OPAL"
	ONYX = "ONYX"
	SECURE = "SECURE"

	LPH_NO_VIRTUALIZE = function(f) return f end
	LPH_JIT_MAX = function(f) return f end
	LPH_JIT = function(f) return f end
end

local env = getgenv()
local explicitFlags = {
	cyborgrace = type(env.cyborgrace) == "boolean",
	autosoulguitar = type(env.autosoulguitar) == "boolean",
	autoghoulrace = type(env.autoghoulrace) == "boolean",
	autottk = type(env.autottk) == "boolean",
	autoyama = type(env.autoyama) == "boolean",
	autotushita = type(env.autotushita) == "boolean",
	autocdk = type(env.autocdk) == "boolean",
	autohakilegendary = type(env.autohakilegendary) == "boolean",
	AutoPullLevel = type(env.AutoPullLevel) == "boolean",
	autofarmboss = type(env.autofarmboss) == "boolean",
	autofarmbosshop = type(env.autofarmbosshop) == "boolean",
	autofactoryhop = type(env.autofactoryhop) == "boolean",
	autopirateraidhop = type(env.autopirateraidhop) == "boolean",
	autofruithop = type(env.autofruithop) == "boolean",
	autoberryhop = type(env.autoberryhop) == "boolean",
	AutoRandomFruit = type(env.AutoRandomFruit) == "boolean",
	AutoStoreFruit = type(env.AutoStoreFruit) == "boolean",
	TeleportMirageIsland = type(env.TeleportMirageIsland) == "boolean",
	TeleportVolcanicIsland = type(env.TeleportVolcanicIsland) == "boolean",
	TeleportKitsuneIsland = type(env.TeleportKitsuneIsland) == "boolean",
	selectedboss = type(env.selectedboss) == "string",
	SelectedWeapon = type(env.SelectedWeapon) == "string",
	Team = env.Team == "Pirates" or env.Team == "Marines",
	AutoBuso = true,
	TurnOnRaceV3 = type(env.TurnOnRaceV3) == "boolean",
	TurnOnRaceV4 = type(env.TurnOnRaceV4) == "boolean",
	TurnOnObservationHaki = type(env.TurnOnObservationHaki) == "boolean",
}
if env.cyborgrace == nil then env.cyborgrace = false end
if env.autosoulguitar == nil then env.autosoulguitar = false end
if env.autoghoulrace == nil then env.autoghoulrace = false end
if env.autottk == nil then env.autottk = false end
if env.autoyama == nil then env.autoyama = false end
if env.autotushita == nil then env.autotushita = false end
if env.autocdk == nil then env.autocdk = false end
if env.autohakilegendary == nil then env.autohakilegendary = false end
if env.AutoPullLevel == nil then env.AutoPullLevel = false end
if env.autofarmboss == nil then env.autofarmboss = false end
if env.autofarmbosshop == nil then env.autofarmbosshop = false end
if env.autofactoryhop == nil then env.autofactoryhop = false end
if env.autopirateraidhop == nil then env.autopirateraidhop = false end
if env.autofruithop == nil then env.autofruithop = false end
if env.autoberryhop == nil then env.autoberryhop = false end
if env.AutoRandomFruit == nil then env.AutoRandomFruit = false end
if env.AutoStoreFruit == nil then env.AutoStoreFruit = false end
if env.TeleportMirageIsland == nil then env.TeleportMirageIsland = false end
if env.TeleportVolcanicIsland == nil then env.TeleportVolcanicIsland = false end
if env.TeleportKitsuneIsland == nil then env.TeleportKitsuneIsland = false end
if env.selectedboss == nil then env.selectedboss = "Rip Indra" end
if env.SelectedWeapon == nil then env.SelectedWeapon = "Melee" end
env.AutoBuso = true
if env.TurnOnRaceV3 == nil then env.TurnOnRaceV3 = false end
if env.TurnOnRaceV4 == nil then env.TurnOnRaceV4 = false end
if env.TurnOnObservationHaki == nil then env.TurnOnObservationHaki = false end
local previousController = env.CyborgCodex
if previousController and type(previousController.Shutdown) == "function" then
	previousController.Shutdown()
elseif previousController and type(previousController.Stop) == "function" then
	previousController.Stop()
end
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
repeat task.wait() until game:IsLoaded() and game:GetService("Players") and game.Players.LocalPlayer and game.Players.LocalPlayer:FindFirstChild("PlayerGui")
local player = Players.LocalPlayer
if not explicitFlags.Team then
	local ok, saved = pcall(function()
		local exists, read = env.isfile or isfile, env.readfile or readfile
		local path = "CyborgCodex/ConfigMain/" .. player.Name .. ".json"
		if type(exists) == "function" and type(read) == "function" and exists(path) then
			return HttpService:JSONDecode(read(path))
		end
	end)
	local team = ok and type(saved) == "table" and type(saved.Setting) == "table" and saved.Setting.Team
	env.Team = (team == "Pirates" or team == "Marines") and team or "Marines"
end
local utilFolder = ReplicatedStorage:WaitForChild("Util", 120)
local seatUtilModule = utilFolder and utilFolder:WaitForChild("SeatUtil", 120)
assert(seatUtilModule and seatUtilModule:IsA("ModuleScript"), "ReplicatedStorage.Util.SeatUtil is unavailable")
local SeatUtil = require(seatUtilModule)
assert(type(SeatUtil.isSeated) == "function", "SeatUtil.isSeated is unavailable")
assert(type(SeatUtil.unseat) == "function", "SeatUtil.unseat is unavailable")

local Config = {
	Team = env.Team == "Pirates" and "Pirates" or "Marines",
	ChestLimit = 50,
	MinLawFragments = 1000,
	MinCyborgFragments = 2500,
	MinSoulGuitarFragments = 5000,
	MinSoulGuitarLevel = 2300,
	GhoulEctoplasmTarget = 100,
	TweenSpeed = 150,
	OrderOffset = Vector3.new(7, 18, 0),
	ActionDelay = 0.35,
}

local Ghoul = {
	NPC = CFrame.new(918.615234, 122.202454, 33454.3789),
	RewardGrace = 5,
}

local TTK = {
	Swords = { "Shizu", "Saishi", "Oroshi" },
	BonesMobs = { "Reborn Skeleton", "Living Zombie", "Demonic Soul", "Posessed Mummy" },
	Aliases = { Shizu = "Shizu", Shisui = "Shizu", Saishi = "Saishi", Saddi = "Saishi", Oroshi = "Oroshi", Wando = "Oroshi" },
	SwordPrice = 2000000, CraftPrice = 2000000, RequiredMastery = 300,
	Epoch = 0, Status = "Idle", ItemNames = {},
}

local Haki = {
	Names = { "Pure Red", "Winter Sky", "Snow White" },
	Price = 7500, Epoch = 0, Status = "Idle",
	Target = env.__CyborgCodexHakiTarget,
	BerryIgnored = setmetatable({}, { __mode = "k" }),
}

local ServerPanel = { Labels = {}, Servers = {}, Choices = {}, Input = "", Started = os.clock() }
local PullLever = {
	Epoch = 0, Status = "Idle", Calls = {},
	Tree = CFrame.new(3032.780029296875, 2280.85107421875, -7325.47802734375),
	Temple = CFrame.new(28282.5703125, 14896.8505859375, 105.1042709350586),
	Tiki = CFrame.new(-16204.0810546875, 9.0863618850708, 479.2259521484375),
	LeverClosedZ = 75.469101,
}
local GameEvents = {
	States = {
		Factory = { Flag = "autofactoryhop", Title = "Auto Factory [Hop]", Sea = 2, Slug = "factory", Epoch = 0 },
		Pirate = { Flag = "autopirateraidhop", Title = "Auto Pirate Raid [Hop]", Sea = 3, Slug = "castleraid", Epoch = 0 },
		Fruit = { Flag = "autofruithop", Title = "Auto Fruit [Hop]", Slug = "fruit", Epoch = 0, Hint = env.__CyborgCodexFruitHint },
		Berry = { Flag = "autoberryhop", Title = "Auto Berry [Hop]", Slug = "berry", Epoch = 0 },
		Mirage = { Flag = "TeleportMirageIsland", Title = "Teleport Mirage Island", Island = "MysticIsland", Location = "Mirage Island", NPC = "Advanced Fruit Dealer", Epoch = 0 },
		Volcanic = { Flag = "TeleportVolcanicIsland", Title = "Teleport Vocalnic Island", Island = "PrehistoricIsland", Location = "Prehistoric Island", NPC = "Fossil Expert", Epoch = 0 },
		Kitsune = { Flag = "TeleportKitsuneIsland", Title = "Teleport Kitsune Island", Island = "KitsuneIsland", Location = "Kitsune Island", Epoch = 0 },
	},
	Castle = CFrame.new(-5581.2353515625, 313.76556396484375, -3064.094970703125),
	Factory = CFrame.new(448, 199, -441),
	StoreRetry = setmetatable({}, { __mode = "k" }),
	FruitIgnored = setmetatable({}, { __mode = "k" }),
	BerryIgnored = setmetatable({}, { __mode = "k" }),
}

local SwordGet = {
	States = {
		Yama = { Flag = "autoyama", Status = "Idle", Epoch = 0 },
		Tushita = { Flag = "autotushita", Status = "Idle", Epoch = 0,
			HydraReady = env.__CyborgCodexTushitaHydraReady == true },
		CDK = { Flag = "autocdk", InventoryKey = "Cursed Dual Katana", Status = "Idle", Epoch = 0,
			Training = env.__CyborgCodexCDKTraining },
	},
	Elites = { "Deandre", "Urban", "Diablo" },
	HydraGate = CFrame.new(5713.53759765625, 38.38311767578125, 255.2017059326172),
	YamaRoom = CFrame.new(5251.900390625, 17.18115234375, 453.6025390625),
	LongmaRoom = CFrame.new(-10156.22265625, 337.77801513671875, -9445.865234375),
	PartCache = {},
	CDK = {
		Swords = { "Tushita", "Yama" }, RequiredMastery = 350,
		Manor = CFrame.new(-12133.0283203125, 576.9030151367188, -6707.39892578125),
		Room = CFrame.new(-12396.498046875, 603.3455810546875, -6502.42529296875),
		BossRoom = CFrame.new(-12341.66796875, 603.3455810546875, -6550.6064453125),
		Castle = CFrame.new(-5543.5327148438, 313.80062866211, -2964.2585449219),
		PainSpawn = CFrame.new(-2138.746826171875, 69.98304748535156, -12322.69140625),
		QueenSpawn = CFrame.new(-821, 66, -10965),
		Summoner = CFrame.new(-8932.322265625, 146.83154296875, 6062.55078125),
		BoatSpawns = {
			Vector3.new(-369.507, 6.730, 5190.749), Vector3.new(-9530.968, 7.219, -8375.256),
			Vector3.new(-6126.134, 16.508, -2251.773), Vector3.new(3234.833, 9.432, 1602.182),
			Vector3.new(-9549.828, 21.105, 4685.521), Vector3.new(-963.313, 7.768, -10813.180),
			Vector3.new(-1933.908, 8.049, -11475.199), Vector3.new(2222.733, 5.336, -6261.203),
		},
	},
	Torches = {
		CFrame.new(-10752.7861328125, 413.9829406738281, -9367.361328125),
		CFrame.new(-11671.5146484375, 334.0489196777344, -9474.318359375),
		CFrame.new(-12131.79296875, 520.3677368164062, -10655.0419921875),
		CFrame.new(-13335.0869140625, 485.4693298339844, -6985.51953125),
		CFrame.new(-13488.1171875, 335.7599792480469, -7923.94970703125),
	},
}

local BossFarm = {
	List = { "Rip Indra", "Dough King", "Tyrant of the Skies", "Darkbeard", "Cursed Captain", "Cake Prince", "Soul Reaper" },
	Definitions = {
		["Rip Indra"] = { Sea = 3, Slug = "ripindra", Names = { "rip_indra True Form", "rip_indra", "Rip Indra" } },
		["Dough King"] = { Sea = 3, Slug = "doughking", Names = { "Dough King" }, Mirror = true },
		["Tyrant of the Skies"] = { Sea = 3, Slug = "tyrant", Names = { "Tyrant of the Skies" } },
		["Darkbeard"] = { Sea = 2, Slug = "darkbeard", Names = { "Darkbeard" } },
		["Cursed Captain"] = { Sea = 2, Slug = "cursedcaptain", Names = { "Cursed Captain" } },
		["Cake Prince"] = { Sea = 3, Slug = "cakeprince", Names = { "Cake Prince" }, Mirror = true },
		["Soul Reaper"] = { Sea = 3, Slug = "soulreaper", Names = { "Soul Reaper" } },
	},
	ApiBase = "http://162.4.177.49:8080/jobid/",
	MissingGrace = 8,
	RetrySeconds = 15,
	TeleportTimeout = 25,
	VisitedSeconds = 600,
}
if not BossFarm.Definitions[env.selectedboss] then env.selectedboss = BossFarm.List[1] end

do
	local AES_SECRET_KEY = "VyZubu@MasterAES2026#SecureKey!!"
	local PREFIX = "diepvyaes|"
	local DECOY_A = "x9KqW1mZpL8vNbRt7yUj"
	local DECOY_B = "5cFgH2jK4sD6aQ8wE0rT"

	local b32 = bit32 or bit
	local bxor = b32.bxor
	local band = b32.band
	local bor = b32.bor
	local lshift = b32.lshift
	local rshift = b32.rshift
	local rrotate = b32.rrotate or function(x, n)
	    n = n % 32
	    return bor(rshift(x, n), lshift(x, 32 - n))
	end

	local SBOX = {
	    0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
	    0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
	    0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
	    0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
	    0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,
	    0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
	    0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
	    0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,
	    0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
	    0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,
	    0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
	    0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
	    0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,
	    0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
	    0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
	    0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16
	}

	local RCON = { 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36 }

	local T1 = {
	    0xc66363a5, 0xf87c7c84, 0xee777799, 0xf67b7b8d, 0xfff2f20d, 0xd66b6bbd, 0xde6f6fb1, 0x91c5c554,
	    0x60303050, 0x02010103, 0xce6767a9, 0x562b2b7d, 0xe7fefe19, 0xb5d7d762, 0x4dababe6, 0xec76769a,
	    0x8fcaca45, 0x1f82829d, 0x89c9c940, 0xfa7d7d87, 0xeffafa15, 0xb25959eb, 0x8e4747c9, 0xfbf0f00b,
	    0x41adadec, 0xb3d4d467, 0x5fa2a2fd, 0x45afafea, 0x239c9cbf, 0x53a4a4f7, 0xe4727296, 0x9bc0c05b,
	    0x75b7b7c2, 0xe1fdfd1c, 0x3d9393ae, 0x4c26266a, 0x6c36365a, 0x7e3f3f41, 0xf5f7f702, 0x83cccc4f,
	    0x6834345c, 0x51a5a5f4, 0xd1e5e534, 0xf9f1f108, 0xe2717193, 0xabd8d873, 0x62313153, 0x2a15153f,
	    0x0804040c, 0x95c7c752, 0x46232365, 0x9dc3c35e, 0x30181828, 0x379696a1, 0x0a05050f, 0x2f9a9ab5,
	    0x0e070709, 0x24121236, 0x1b80809b, 0xdfe2e23d, 0xcdebeb26, 0x4e272769, 0x7fb2b2cd, 0xea75759f,
	    0x1209091b, 0x1d83839e, 0x582c2c74, 0x341a1a2e, 0x361b1b2d, 0xdc6e6eb2, 0xb45a5aee, 0x5ba0a0fb,
	    0xa45252f6, 0x763b3b4d, 0xb7d6d661, 0x7db3b3ce, 0x5229297b, 0xdde3e33e, 0x5e2f2f71, 0x13848497,
	    0xa65353f5, 0xb9d1d168, 0x00000000, 0xc1eded2c, 0x40202060, 0xe3fcfc1f, 0x79b1b1c8, 0xb65b5bed,
	    0xd46a6abe, 0x8dcbcb46, 0x67bebed9, 0x7239394b, 0x944a4ade, 0x984c4cd4, 0xb05858e8, 0x85cfcf4a,
	    0xbbd0d06b, 0xc5efef2a, 0x4faaaae5, 0xedfbfb16, 0x864343c5, 0x9a4d4dd7, 0x66333355, 0x11858594,
	    0x8a4545cf, 0xe9f9f910, 0x04020206, 0xfe7f7f81, 0xa05050f0, 0x783c3c44, 0x259f9fba, 0x4ba8a8e3,
	    0xa25151f3, 0x5da3a3fe, 0x804040c0, 0x058f8f8a, 0x3f9292ad, 0x219d9dbc, 0x70383848, 0xf1f5f504,
	    0x63bcbcdf, 0x77b6b6c1, 0xafdada75, 0x42212163, 0x20101030, 0xe5ffff1a, 0xfdf3f30e, 0xbfd2d26d,
	    0x81cdcd4c, 0x180c0c14, 0x26131335, 0xc3ecec2f, 0xbe5f5fe1, 0x359797a2, 0x884444cc, 0x2e171739,
	    0x93c4c457, 0x55a7a7f2, 0xfc7e7e82, 0x7a3d3d47, 0xc86464ac, 0xba5d5de7, 0x3219192b, 0xe6737395,
	    0xc06060a0, 0x19818198, 0x9e4f4fd1, 0xa3dcdc7f, 0x44222266, 0x542a2a7e, 0x3b9090ab, 0x0b888883,
	    0x8c4646ca, 0xc7eeee29, 0x6bb8b8d3, 0x2814143c, 0xa7dede79, 0xbc5e5ee2, 0x160b0b1d, 0xaddbdb76,
	    0xdbe0e03b, 0x64323256, 0x743a3a4e, 0x140a0a1e, 0x924949db, 0x0c06060a, 0x4824246c, 0xb85c5ce4,
	    0x9fc2c25d, 0xbdd3d36e, 0x43acacef, 0xc46262a6, 0x399191a8, 0x319595a4, 0xd3e4e437, 0xf279798b,
	    0xd5e7e732, 0x8bc8c843, 0x6e373759, 0xda6d6db7, 0x018d8d8c, 0xb1d5d564, 0x9c4e4ed2, 0x49a9a9e0,
	    0xd86c6cb4, 0xac5656fa, 0xf3f4f407, 0xcfeaea25, 0xca6565af, 0xf47a7a8e, 0x47aeaee9, 0x10080818,
	    0x6fbabad5, 0xf0787888, 0x4a25256f, 0x5c2e2e72, 0x381c1c24, 0x57a6a6f1, 0x73b4b4c7, 0x97c6c651,
	    0xcbe8e823, 0xa1dddd7c, 0xe874749c, 0x3e1f1f21, 0x964b4bdd, 0x61bdbddc, 0x0d8b8b86, 0x0f8a8a85,
	    0xe0707090, 0x7c3e3e42, 0x71b5b5c4, 0xcc6666aa, 0x904848d8, 0x06030305, 0xf7f6f601, 0x1c0e0e12,
	    0xc26161a3, 0x6a35355f, 0xae5757f9, 0x69b9b9d0, 0x17868691, 0x99c1c158, 0x3a1d1d27, 0x279e9eb9,
	    0xd9e1e138, 0xebf8f813, 0x2b9898b3, 0x22111133, 0xd26969bb, 0xa9d9d970, 0x078e8e89, 0x339494a7,
	    0x2d9b9bb6, 0x3c1e1e22, 0x15878792, 0xc9e9e920, 0x87cece49, 0xaa5555ff, 0x50282878, 0xa5dfdf7a,
	    0x038c8c8f, 0x59a1a1f8, 0x09898980, 0x1a0d0d17, 0x65bfbfda, 0xd7e6e631, 0x844242c6, 0xd06868b8,
	    0x824141c3, 0x299999b0, 0x5a2d2d77, 0x1e0f0f11, 0x7bb0b0cb, 0xa85454fc, 0x6dbbbbd6, 0x2c16163a
	}

	local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	local b64lookup = {}
	for i = 1, #b64chars do b64lookup[string.byte(b64chars, i)] = i - 1 end

	local function Base64Decode(data)
	    local out = {}
	    local len = #data
	    local i = 1
	    while i <= len do
	        local c1 = b64lookup[string.byte(data, i)]
	        local c2 = b64lookup[string.byte(data, i + 1)]
	        local c3 = b64lookup[string.byte(data, i + 2)]
	        local c4 = b64lookup[string.byte(data, i + 3)]
	        if not c1 or not c2 then break end

	        local triple = bor(lshift(c1, 18), lshift(c2, 12), lshift(c3 or 0, 6), (c4 or 0))
	        out[#out + 1] = band(rshift(triple, 16), 0xff)
	        if c3 ~= nil then out[#out + 1] = band(rshift(triple, 8), 0xff) end
	        if c4 ~= nil then out[#out + 1] = band(triple, 0xff) end
	        i = i + 4
	    end
	    return out
	end

	local function ExpandKey(keyBytes)
	    local rounds = 14
	    local roundKeyCount = (rounds + 1) * 4
	    local KC = 8

	    local tk = {}
	    for i = 0, KC - 1 do
	        local b0 = keyBytes[i * 4 + 1]
	        local b1 = keyBytes[i * 4 + 2]
	        local b2 = keyBytes[i * 4 + 3]
	        local b3 = keyBytes[i * 4 + 4]
	        tk[i] = bor(lshift(b0, 24), lshift(b1, 16), lshift(b2, 8), b3)
	    end

	    local Ke = {}
	    for r = 0, rounds do Ke[r] = {0, 0, 0, 0} end
	    for i = 0, KC - 1 do Ke[math.floor(i / 4)][i % 4] = tk[i] end

	    local rconptr = 1
	    local t = KC
	    while t < roundKeyCount do
	        local tt = tk[KC - 1]
	        local subtt = bor(
	            lshift(SBOX[band(rshift(tt, 16), 0xff) + 1], 24),
	            lshift(SBOX[band(rshift(tt, 8), 0xff) + 1], 16),
	            lshift(SBOX[band(tt, 0xff) + 1], 8),
	            SBOX[band(rshift(tt, 24), 0xff) + 1]
	        )
	        tk[0] = bxor(tk[0], subtt, lshift(RCON[rconptr], 24))
	        rconptr = rconptr + 1

	        for i = 1, 3 do tk[i] = bxor(tk[i], tk[i - 1]) end

	        tt = tk[3]
	        local subtt2 = bor(
	            lshift(SBOX[band(rshift(tt, 24), 0xff) + 1], 24),
	            lshift(SBOX[band(rshift(tt, 16), 0xff) + 1], 16),
	            lshift(SBOX[band(rshift(tt, 8), 0xff) + 1], 8),
	            SBOX[band(tt, 0xff) + 1]
	        )
	        tk[4] = bxor(tk[4], subtt2)

	        for i = 5, 7 do tk[i] = bxor(tk[i], tk[i - 1]) end

	        local j = 0
	        while j < KC and t < roundKeyCount do
	            Ke[math.floor(t / 4)][t % 4] = tk[j]
	            j = j + 1
	            t = t + 1
	        end
	    end
	    return Ke
	end

	local function EncryptBlock(ptBytes, Ke)
	    local t0 = bxor(bor(lshift(ptBytes[1], 24), lshift(ptBytes[2], 16), lshift(ptBytes[3], 8), ptBytes[4]), Ke[0][0])
	    local t1 = bxor(bor(lshift(ptBytes[5], 24), lshift(ptBytes[6], 16), lshift(ptBytes[7], 8), ptBytes[8]), Ke[0][1])
	    local t2 = bxor(bor(lshift(ptBytes[9], 24), lshift(ptBytes[10], 16), lshift(ptBytes[11], 8), ptBytes[12]), Ke[0][2])
	    local t3 = bxor(bor(lshift(ptBytes[13], 24), lshift(ptBytes[14], 16), lshift(ptBytes[15], 8), ptBytes[16]), Ke[0][3])

	    local a0, a1, a2, a3
	    for r = 1, 13 do
	        local kr = Ke[r]
	        a0 = bxor(
	            T1[band(rshift(t0, 24), 0xff) + 1],
	            rrotate(T1[band(rshift(t1, 16), 0xff) + 1], 8),
	            rrotate(T1[band(rshift(t2, 8), 0xff) + 1], 16),
	            rrotate(T1[band(t3, 0xff) + 1], 24),
	            kr[0]
	        )
	        a1 = bxor(
	            T1[band(rshift(t1, 24), 0xff) + 1],
	            rrotate(T1[band(rshift(t2, 16), 0xff) + 1], 8),
	            rrotate(T1[band(rshift(t3, 8), 0xff) + 1], 16),
	            rrotate(T1[band(t0, 0xff) + 1], 24),
	            kr[1]
	        )
	        a2 = bxor(
	            T1[band(rshift(t2, 24), 0xff) + 1],
	            rrotate(T1[band(rshift(t3, 16), 0xff) + 1], 8),
	            rrotate(T1[band(rshift(t0, 8), 0xff) + 1], 16),
	            rrotate(T1[band(t1, 0xff) + 1], 24),
	            kr[2]
	        )
	        a3 = bxor(
	            T1[band(rshift(t3, 24), 0xff) + 1],
	            rrotate(T1[band(rshift(t0, 16), 0xff) + 1], 8),
	            rrotate(T1[band(rshift(t1, 8), 0xff) + 1], 16),
	            rrotate(T1[band(t2, 0xff) + 1], 24),
	            kr[3]
	        )
	        t0, t1, t2, t3 = a0, a1, a2, a3
	    end

	    local k14 = Ke[14]
	    return {
	        band(bxor(SBOX[band(rshift(t0, 24), 0xff) + 1], band(rshift(k14[0], 24), 0xff)), 0xff),
	        band(bxor(SBOX[band(rshift(t1, 16), 0xff) + 1], band(rshift(k14[0], 16), 0xff)), 0xff),
	        band(bxor(SBOX[band(rshift(t2, 8), 0xff) + 1], band(rshift(k14[0], 8), 0xff)), 0xff),
	        band(bxor(SBOX[band(t3, 0xff) + 1], band(k14[0], 0xff)), 0xff),

	        band(bxor(SBOX[band(rshift(t1, 24), 0xff) + 1], band(rshift(k14[1], 24), 0xff)), 0xff),
	        band(bxor(SBOX[band(rshift(t2, 16), 0xff) + 1], band(rshift(k14[1], 16), 0xff)), 0xff),
	        band(bxor(SBOX[band(rshift(t3, 8), 0xff) + 1], band(rshift(k14[1], 8), 0xff)), 0xff),
	        band(bxor(SBOX[band(t0, 0xff) + 1], band(k14[1], 0xff)), 0xff),

	        band(bxor(SBOX[band(rshift(t2, 24), 0xff) + 1], band(rshift(k14[2], 24), 0xff)), 0xff),
	        band(bxor(SBOX[band(rshift(t3, 16), 0xff) + 1], band(rshift(k14[2], 16), 0xff)), 0xff),
	        band(bxor(SBOX[band(rshift(t0, 8), 0xff) + 1], band(rshift(k14[2], 8), 0xff)), 0xff),
	        band(bxor(SBOX[band(t1, 0xff) + 1], band(k14[2], 0xff)), 0xff),

	        band(bxor(SBOX[band(rshift(t3, 24), 0xff) + 1], band(rshift(k14[3], 24), 0xff)), 0xff),
	        band(bxor(SBOX[band(rshift(t0, 16), 0xff) + 1], band(rshift(k14[3], 16), 0xff)), 0xff),
	        band(bxor(SBOX[band(rshift(t1, 8), 0xff) + 1], band(rshift(k14[3], 8), 0xff)), 0xff),
	        band(bxor(SBOX[band(t2, 0xff) + 1], band(k14[3], 0xff)), 0xff)
	    }
	end

	local cachedKe = nil
	local function AesCtrDecrypt(dataBytes, nonceBytes, keyStr)
	    if not cachedKe then
	        local keyBytes = {}
	        for i = 1, #keyStr do keyBytes[i] = string.byte(keyStr, i) end
	        cachedKe = ExpandKey(keyBytes)
	    end

	    local counter = {}
	    for i = 1, 16 do counter[i] = nonceBytes[i] end

	    local out = {}
	    local len = #dataBytes
	    local offset = 1

	    while offset <= len do
	        local keystream = EncryptBlock(counter, cachedKe)
	        local blockLen = math.min(16, len - offset + 1)
	        for i = 1, blockLen do
	            out[offset + i - 1] = bxor(dataBytes[offset + i - 1], keystream[i])
	        end
	        offset = offset + 16

	        for i = 16, 1, -1 do
	            counter[i] = (counter[i] + 1) % 256
	            if counter[i] ~= 0 then break end
	        end
	    end

	    local chars = {}
	    for i = 1, #out do chars[i] = string.char(out[i]) end
	    return table.concat(chars)
	end

	local function DecodeAesJobId(token)
	    if not token or type(token) ~= "string" then return nil end
	    local s = token
	    if s:sub(1, #PREFIX) == PREFIX then s = s:sub(#PREFIX + 1) end
	    s = s:gsub(DECOY_A, "")
	    s = s:gsub(DECOY_B, "")

	    local rawBytes = Base64Decode(s)
	    if #rawBytes < 17 then return nil end

	    local nonce = {}
	    for i = 1, 16 do nonce[i] = rawBytes[i] end

	    local ct = {}
	    for i = 17, #rawBytes do ct[#ct + 1] = rawBytes[i] end

	    return AesCtrDecrypt(ct, nonce, AES_SECRET_KEY)
	end

	function BossFarm.IsJobId(value)
		if type(value) ~= "string" or #value ~= 36 then return false end
		local a, b, c, d, e = value:match("^(%x+)%-(%x+)%-(%x+)%-(%x+)%-(%x+)$")
		return a ~= nil and #a == 8 and #b == 4 and #c == 4 and #d == 4 and #e == 12
	end

	function BossFarm.DecodeJobId(token)
		if BossFarm.IsJobId(token) then return token end
		if type(token) ~= "string" or #token > 512 or token:sub(1, #PREFIX) ~= PREFIX then return nil end
		local payload = token:sub(#PREFIX + 1):gsub(DECOY_A, ""):gsub(DECOY_B, "")
		if #payload % 4 ~= 0 or payload:find("[^%w+/=]") then return nil end
		local ok, jobId = pcall(DecodeAesJobId, token)
		if ok and BossFarm.IsJobId(jobId) then return jobId end
		return nil
	end
end

local SeaByPlaceId = {
	[85211729168715] = 1,
	[2753915549] = 1,
	[4442272183] = 2,
	[79091703265657] = 2,
	[7449423635] = 3,
	[100117331123089] = 3,
}

local state = env.__CyborgCodexState or {}
env.__CyborgCodexState = state
state.JobId = state.JobId or game.JobId
state.ChestCount = state.ChestCount or 0
state.SeenChests = state.SeenChests or {}
state.NextAction = 0
state.LastNotice = state.LastNotice or {}
state.LastRemote = state.LastRemote or {}
state.LastRemote.FistCheck = nil
state.Busy = false
state.Enabled = false
state.HopPending = false
state.FistSubmitted = false
state.FistSubmissionJob = nil
state.Generation = (state.Generation or 0) + 1
local generation = state.Generation
state.Worker = false
state.FastAttackWorker = false
state.FastAttackTarget = nil
state.FastAttackTargets = nil
state.ActiveWorkflow = nil
state.Connections = {}
state.BossSelection = nil
state.BossRequest = nil
state.BossStatus = "Idle"
state.GhoulStatus = "Idle"
state.GhoulPhase = "Idle"
state.GhoulExchangeAwaiting = nil
state.GhoulTarget = nil
state.GhoulRewardUntil = nil
state.GhoulCount = nil
state.GhoulUnlocked = nil
state.GhoulChangeAttempted = false
state.TTKCompleted = false
state.TTKWeapon = nil
state.LastRemote.GhoulCheck = nil
state.LastRemote.GhoulExchange = nil
state.BossVisited = type(env.__CyborgCodexBossVisited) == "table" and env.__CyborgCodexBossVisited
	 or (type(state.BossVisited) == "table" and state.BossVisited or {})
env.__CyborgCodexBossVisited = nil

if state.JobId ~= game.JobId then
	state.JobId = game.JobId
	state.ChestCount = 0
	state.SeenChests = {}
	state.HopPending = false
	state.FistSubmitted = false
	state.Enabled = false
	state.Worker = false
	state.CurrentChest = nil
	state.CurrentChestSince = nil
end

local function log(message)
	warn("[Teddy Hub] " .. tostring(message))
end

local function reportControllerError(err, workflow, phase)
	workflow = workflow or state.ActiveWorkflow or "Controller"
	phase = phase or (workflow == "Ghoul" and state.GhoulPhase) or state.Stage or "Unknown"
	local now = os.clock()
	local previous = state.LastControllerError
	local trace = tostring(err)
	state.LastControllerError = { Workflow = workflow, Phase = phase, Traceback = trace, Time = now }
	if not previous or previous.Traceback ~= trace or previous.Phase ~= phase
		or now - (state.LastControllerErrorPrint or -math.huge) >= 5 then
		state.LastControllerErrorPrint = now
		print("[Teddy Hub][ERROR][" .. workflow .. "][" .. phase .. "]\n" .. trace)
	end
end

local workflowActive = LPH_JIT_MAX(function(name)
	return state.Generation == generation and state.Enabled and state.ActiveWorkflow == name
		and ((name == "Cyborg" and env.cyborgrace == true)
			or (name == "SoulGuitar" and env.autosoulguitar == true)
			or (name == "Ghoul" and env.autoghoulrace == true)
			or (name == "TTK" and env.autottk == true and not state.TTKCompleted)
			or (name == "Haki" and env.autohakilegendary == true and not Haki.Completed)
			or (name == "PullLever" and env.AutoPullLevel == true and not PullLever.Completed)
			or (GameEvents.States[name] and env[GameEvents.States[name].Flag] == true)
			or (SwordGet.States[name] and env[SwordGet.States[name].Flag] == true and not SwordGet.States[name].Completed)
			or (name == "Boss" and env.autofarmboss == true and state.BossSelection == env.selectedboss))
end)

local attackActive = LPH_JIT_MAX(function()
	return workflowActive("Cyborg") or workflowActive("SoulGuitar") or workflowActive("Boss") or workflowActive("Ghoul")
		or workflowActive("TTK") or workflowActive("Yama") or workflowActive("Tushita") or workflowActive("CDK") or workflowActive("Haki")
		or workflowActive("Factory") or workflowActive("Pirate") or workflowActive("Fruit") or workflowActive("Berry")
		or workflowActive("Mirage") or workflowActive("Volcanic")
		or workflowActive("Kitsune")
		or workflowActive("PullLever")
end)

local chooseWorkflow = LPH_JIT_MAX(function(cyborgEnabled, soulEnabled, cyborgOwned, bossEnabled, ghoulEnabled, ttkEnabled, yamaEnabled, tushitaEnabled, cdkEnabled, hakiEnabled)
	if env.AutoPullLevel == true and not PullLever.Completed then return "PullLever" end
	for _, name in ipairs({ "Mirage", "Volcanic", "Kitsune" }) do
		if env[GameEvents.States[name].Flag] == true and GameEvents.FindIsland(name) then return name end
	end
	if tushitaEnabled and not SwordGet.States.Tushita.Completed then return "Tushita" end
	if yamaEnabled and not SwordGet.States.Yama.Completed then return "Yama" end
	if cdkEnabled and not SwordGet.States.CDK.Completed then return "CDK" end
	if ttkEnabled and not state.TTKCompleted then return "TTK" end
	if bossEnabled then return "Boss" end
	if ghoulEnabled then return "Ghoul" end
	if hakiEnabled and not Haki.Completed then return "Haki" end
	if cyborgEnabled and not cyborgOwned then return "Cyborg" end
	if soulEnabled then return "SoulGuitar" end
	for _, name in ipairs({ "Factory", "Pirate", "Fruit", "Berry" }) do
		if env[GameEvents.States[name].Flag] == true then return name end
	end
	for _, name in ipairs({ "Mirage", "Volcanic", "Kitsune" }) do
		if env[GameEvents.States[name].Flag] == true then return name end
	end
	return nil
end)

local function setStage(stage)
	if state.Stage ~= stage then
		state.FastAttackTarget = nil
		state.FastAttackTargets = nil
		state.ZombieBatch = nil
		state.Stage = stage
		log("Stage: " .. stage)
	end
end

local function notify(message, key, interval)
	local now = os.clock()
	if key and state.LastNotice[key] and now - state.LastNotice[key] < (interval or 5) then
		return
	end
	if key then
		state.LastNotice[key] = now
	end
	local notification = ReplicatedStorage:FindFirstChild("Notification")
	if notification then
		local ok, err = pcall(function()
			require(notification).new("<Color=Red>Teddy Hub: " .. message .. "<Color=/>"):Display()
		end)
		if ok then
			return
		end
		log("Notification unavailable: " .. tostring(err))
	end
	log(message)
end

local function getCommF()
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	local remote = remotes and remotes:FindFirstChild("CommF_")
	assert(remote and remote:IsA("RemoteFunction"), "ReplicatedStorage.Remotes.CommF_ is unavailable")
	return remote
end

local function invokeCommF(...)
	local args = { ... }
	local command = args[1]
	local mutation = command == "Buso" or command == "SetTeam" or command == "TravelDressrosa"
		or command == "TravelZou" or command == "requestEntrance" or command == "BlackbeardReward"
		or command == "gravestoneEvent" or (command == "CyborgTrainer" and args[2] == "Buy")
		or command == "LoadItem" or command == "StartQuest" or command == "AbandonQuest"
		or (command == "LegendarySwordDealer" and args[2] == "2") or (command == "MysteriousMan" and args[2] == "2")
		or (command == "ColorsDealer" and args[2] == "2")
		or (command == "EliteHunter" and args[2] ~= "Progress") or (command == "TushitaProgress" and args[2] == "Torch")
		or (command == "CDKQuest" and args[2] ~= "Progress") or (command == "Bones" and args[2] == "Buy")
		or (command == "soulGuitarBuy" and args[2] ~= true)
		or (command == "GuitarPuzzleProgress" and args[2] ~= "Check")
		or (command == "Ectoplasm" and (args[2] == "Buy" or args[2] == "Change"))
	if mutation and not attackActive() and not (command == "Buso" and env.AutoBuso == true) then return nil end
	return getCommF():InvokeServer(...)
end

local function hasItem(name)
	local character = player.Character
	local backpack = player:FindFirstChild("Backpack")
	return (character and character:FindFirstChild(name) ~= nil)
		or (backpack and backpack:FindFirstChild(name) ~= nil)
		or false
end

local function equipItem(name)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local backpack = player:FindFirstChild("Backpack")
	local tool = (character and character:FindFirstChild(name)) or (backpack and backpack:FindFirstChild(name))
	if not (humanoid and tool and tool:IsA("Tool")) then
		return false
	end
	if tool.Parent == backpack then
		humanoid:EquipTool(tool)
	end
	return true
end

local function checkRace()
	local data = player:FindFirstChild("Data")
	local race = data and data:FindFirstChild("Race")
	local owned = race ~= nil and race.Value == "Cyborg"
	if owned then
		state.LastRaceCheck = os.clock()
		state.LastRaceCheckOk = true
		state.LastRaceCheckError = nil
		state.LastRaceOwned = true
		state.LastCoreBrainSubmitted = state.LastCoreBrainSubmitted or false
		return true, state.LastCoreBrainSubmitted
	end
	if os.clock() - (state.LastRaceCheck or 0) < 2 then
		if state.LastRaceCheckOk then
			return state.LastRaceOwned, state.LastCoreBrainSubmitted
		end
		error(state.LastRaceCheckError or "CyborgTrainer Check failed")
	end
	state.LastRaceCheck = os.clock()
	state.LastRaceCheckOk = false
	local ok, result = pcall(invokeCommF, "CyborgTrainer", "Check")
	if not ok then
		state.LastRaceCheckError = tostring(result)
		error("CyborgTrainer Check failed: " .. tostring(result))
	end
	state.LastRaceCheckOk = true
	state.LastRaceCheckError = nil
	state.LastRaceValue = result
	state.LastRaceOwned = false
	state.LastCoreBrainSubmitted = result == true
	return false, state.LastCoreBrainSubmitted
end

local function requestCyborgBuy()
	if os.clock() - (state.LastRemote.BuyRace or 0) < 5 then
		return false
	end
	state.LastRemote.BuyRace = os.clock()
	local ok, result = pcall(invokeCommF, "CyborgTrainer", "Buy")
	state.LastRaceCheck = -math.huge
	state.LastRaceCheckOk = false
	if not ok then
		error("CyborgTrainer Buy failed: " .. tostring(result))
	end
	log("CyborgTrainer Buy response: " .. tostring(result))
	return true
end

local ensureTeam = LPH_JIT(function()
	if state.Generation ~= generation then return false end
	Config.Team = env.Team == "Pirates" and "Pirates" or "Marines"
	if player.Team and player.Team.Name == Config.Team then
		return true
	end
	local now = os.clock()
	if state.LastRemote.Team and now - state.LastRemote.Team < 3 then return false end
	state.LastRemote.Team = now
	local ok, err = pcall(function()
		return getCommF():InvokeServer("SetTeam", Config.Team)
	end)
	if state.Generation ~= generation then return false end
	if not ok and (not state.LastTeamError or now - state.LastTeamError >= 5) then
		state.LastTeamError = now
		log("Team join failed: " .. tostring(err))
	end
	return player.Team ~= nil and player.Team.Name == Config.Team
end)

local function currentSea()
	if SeaByPlaceId[game.PlaceId] then return SeaByPlaceId[game.PlaceId] end
	if type(env.CheckPlaceId) == "number" then SeaByPlaceId[env.CheckPlaceId] = 1 end
	if type(env.CheckPlaceId2) == "number" then SeaByPlaceId[env.CheckPlaceId2] = 2 end
	if type(env.CheckPlaceId3) == "number" then SeaByPlaceId[env.CheckPlaceId3] = 3 end
	return SeaByPlaceId[game.PlaceId]
end

local queueResume

local function travelToSea2()
	local sea = currentSea()
	if sea == 2 then
		return true
	end
	if sea ~= 1 and sea ~= 3 then
		setStage("unsupported place")
		notify("Unsupported PlaceId " .. tostring(game.PlaceId) .. "; cannot determine sea.", "place", 15)
		return false
	end
	setStage("travel to Sea 2")
	if os.clock() - (state.LastRemote.Travel or 0) >= 10 then
		state.LastRemote.Travel = os.clock()
		queueResume()
		invokeCommF("TravelDressrosa")
	end
	return false
end

local function travelToSea3()
	if currentSea() == 3 then return true end
	if not currentSea() then
		notify("Cannot determine sea for this PlaceId.", "place", 5)
		return false
	end
	setStage("travel to Sea 3")
	if os.clock() - (state.LastRemote.Travel or 0) >= 10 then
		state.LastRemote.Travel = os.clock()
		queueResume()
		invokeCommF("TravelZou")
	end
	return false
end

local getRoot = LPH_JIT_MAX(function()
	local character = player.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end)

local uprightCFrame = LPH_JIT_MAX(function(cf)
	local facing = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z)
	if facing.Magnitude < 0.001 then facing = Vector3.new(0, 0, -1) end
	return CFrame.lookAt(cf.Position, cf.Position + facing, Vector3.yAxis)
end)

local function releaseUpright()
	local hold = state.UprightHold
	state.UprightHold = nil
	if not hold then return end
	if hold.Connection then hold.Connection:Disconnect() end
	if hold.Humanoid.Parent then hold.Humanoid.AutoRotate = hold.AutoRotate end
	hold.Alignment:Destroy()
	hold.Attachment:Destroy()
end

local function holdUpright(root)
	if state.UprightHold and state.UprightHold.Root == root then return end
	releaseUpright()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	local attachment = Instance.new("Attachment")
	attachment.Name = "CyborgCodexUprightAttachment"
	attachment.Parent = root
	local alignment = Instance.new("AlignOrientation")
	alignment.Name = "CyborgCodexUpright"
	alignment.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignment.Attachment0 = attachment
	alignment.MaxTorque = 10000000
	alignment.MaxAngularVelocity = 30
	alignment.Responsiveness = 40
	alignment.RigidityEnabled = false
	root.CFrame = uprightCFrame(root.CFrame)
	root.AssemblyAngularVelocity = Vector3.zero
	alignment.CFrame = root.CFrame
	alignment.Parent = root
	local hold = { Root = root, Humanoid = humanoid, AutoRotate = humanoid.AutoRotate,
		Alignment = alignment, Attachment = attachment }
	state.UprightHold = hold
	humanoid.AutoRotate = false
	hold.Connection = RunService.Stepped:Connect(function()
		if state.UprightHold ~= hold then return end
		if not attackActive() or getRoot() ~= root or humanoid.Health <= 0 then releaseUpright(); return end
		alignment.CFrame = uprightCFrame(root.CFrame)
		root.AssemblyAngularVelocity = Vector3.zero
	end)
end

local function setFloat(enabled)
	local root = getRoot()
	if state.FloatRoot and (not enabled or state.FloatRoot ~= root) then
		local oldForce = state.FloatRoot:FindFirstChild("CyborgCodexFloat")
		if oldForce then oldForce:Destroy() end
		state.FloatRoot = nil
	end
	if not enabled then releaseUpright() end
	if not root then
		releaseUpright()
		return
	end
	local force = root:FindFirstChild("CyborgCodexFloat")
	if enabled then
		holdUpright(root)
		state.FloatRoot = root
		if not force then
			force = Instance.new("BodyVelocity")
			force.Name = "CyborgCodexFloat"
			force.Velocity = Vector3.zero
			force.MaxForce = Vector3.new(100000, 100000, 100000)
			force.P = 10000
			force.Parent = root
		end
	elseif force then
		force:Destroy()
	end
end

local function setNoClip(enabled)
	state.NoClipEnabled = enabled
	if enabled then
		if state.NoClipConnection then
			return
		end
		state.SavedCollision = setmetatable({}, { __mode = "k" })
		state.NoClipConnection = RunService.Stepped:Connect(function()
			local character = player.Character
			if not character then return end
			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") and part.Name ~= "CyborgCodexFloat" then
					if state.SavedCollision[part] == nil then
						state.SavedCollision[part] = part.CanCollide
					end
					part.CanCollide = false
				end
			end
		end)
		return
	end
	if state.NoClipConnection then
		state.NoClipConnection:Disconnect()
		state.NoClipConnection = nil
	end
	for part, canCollide in pairs(state.SavedCollision or {}) do
		if part.Parent then
			part.CanCollide = canCollide
		end
	end
	state.SavedCollision = nil
end

local function cancelMovement()
	if state.Tween then
		state.Tween:Cancel()
		state.Tween = nil
	end
	state.TweenGoal = nil
end

local moveTo = LPH_JIT(function(target, combat, arrivalRadius)
	if not combat then state.CombatFollow = nil end
	if not attackActive() then return false end
	local root = getRoot()
	assert(root, "Character HumanoidRootPart is unavailable")
	assert(typeof(target) == "CFrame", "moveTo target must be a CFrame")
	target = uprightCFrame(target)
	local portal
	if currentSea() == 2 then
		local ship = Vector3.new(923.2125244140625, 126.97600555419922, 32852.83203125)
		local fromShip = (root.Position - ship).Magnitude
		local toShip = (target.Position - ship).Magnitude
		if (fromShip >= 3000) ~= (toShip >= 3000) then
			local map = workspace:FindFirstChild("Map")
			local model = map and map:FindFirstChild(fromShip >= 3000 and "GhostShip" or "GhostShipInterior")
			portal = model and model:FindFirstChild("Teleport")
			assert(portal and portal:IsA("BasePart") and portal:FindFirstChild("TouchInterest"),
				"Cursed Ship Teleport/TouchInterest is unavailable; waiting for map replication")
			target = uprightCFrame(portal.CFrame)
		end
	end
	local distance = (root.Position - target.Position).Magnitude
	if distance <= (portal and 3 or arrivalRadius or 8) then
		cancelMovement()
		setNoClip(false)
		setFloat(false)
		if portal then
			local touch = env.firetouchinterest or firetouchinterest
			if type(touch) == "function" and os.clock() - (state.LastRemote.ShipTouch or -math.huge) >= 2 then
				state.LastRemote.ShipTouch = os.clock()
				local owner = state.ActiveWorkflow
				local ok, err = xpcall(function()
					if not attackActive() or getRoot() ~= root then return end
					touch(root, portal, 0)
					task.wait()
				end, debug.traceback)
				local ended, endError = pcall(touch, root, portal, 1)
				if not ok then error(err) end
				if not ended then error(endError) end
				if not attackActive() or getRoot() ~= root or state.ActiveWorkflow ~= owner then return false end
			end
			return false
		end
		return true
	end
	if state.Tween and state.Tween.PlaybackState == Enum.PlaybackState.Playing
		and state.TweenGoal and (state.TweenGoal.Position - target.Position).Magnitude < 8 then
		return false
	end
	cancelMovement()
	setNoClip(true)
	setFloat(true)
	local duration = math.max(distance / Config.TweenSpeed, 0.15)
	local tween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), { CFrame = target })
	state.Tween = tween
	state.TweenGoal = target
	tween:Play()
	tween.Completed:Once(function()
		if state.Tween == tween then
			state.Tween = nil
			state.TweenGoal = nil
		end
	end)
	return false
end)

local function cleanupMovement()
	state.CombatFollow = nil
	cancelMovement()
	setNoClip(false)
	setFloat(false)
end

local function requestJump(humanoid)
	if not humanoid or os.clock() - (state.LastJumpRequest or 0) < 0.8 then
		return
	end
	state.LastJumpRequest = os.clock()
	local ok, err = pcall(function()
		humanoid.Jump = true
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end)
	if not ok then
		log("Humanoid jump request failed: " .. tostring(err))
	end
end

local function escapeSeatWhileCollecting()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		state.SeatStuckSince = nil
		return false
	end
	local ok, seated = pcall(SeatUtil.isSeated, humanoid)
	if not ok then
		if os.clock() - (state.LastSeatUtilWarning or 0) >= 5 then
			state.LastSeatUtilWarning = os.clock()
			log("SeatUtil.isSeated failed: " .. tostring(seated))
		end
		seated = false
	end
	seated = seated == true or humanoid.Sit or humanoid.SeatPart ~= nil
	if not seated then
		state.SeatStuckSince = nil
		return false
	end

	cancelMovement()
	setNoClip(false)
	setFloat(false)
	local now = os.clock()
	state.SeatStuckSince = state.SeatStuckSince or now
	if now - state.SeatStuckSince < 0.4 or now - (state.LastSeatEscape or 0) < 1.5 then
		return true
	end
	state.LastSeatEscape = now
	local unseatOk, unseatError = pcall(SeatUtil.unseat, humanoid)
	if not unseatOk then
		log("SeatUtil.unseat failed: " .. tostring(unseatError))
	end
	humanoid.Sit = false
	requestJump(humanoid)
	local root = character:FindFirstChild("HumanoidRootPart")
	if root then
		root.CFrame = root.CFrame * CFrame.new(0, 10, 0)
	end
	return true
end

local function getRaidButton()
	local map = workspace:FindFirstChild("Map")
	local island = map and map:FindFirstChild("CircleIsland")
	local summon = island and island:FindFirstChild("RaidSummon")
	local button = summon and summon:FindFirstChild("Button")
	return button and button:FindFirstChild("Main")
end

local RaidButtonCFrame = CFrame.new(-5570.052734375, 332.41363525391, -5965.91015625)

local function clickPart(part)
	if not attackActive() then return false end
	local detector = part and part:FindFirstChildOfClass("ClickDetector")
	assert(detector, "RaidSummon ClickDetector is unavailable")
	local click = env.fireclickdetector or _G.fireclickdetector
	assert(type(click) == "function", "Executor fireclickdetector is unavailable")
	click(detector)
end

local function isRaidUnlocked()
	if not workflowActive("Cyborg") then return false end
	if state.FistSubmitted == true and state.FistSubmissionJob == game.JobId then
		return true
	end
	if os.clock() - (state.LastRemote.FistCheck or -math.huge) < 2 then return false end
	state.LastRemote.FistCheck = os.clock()
	local jobId = game.JobId
	local ok, result = pcall(invokeCommF, "CheckBlockPart")
	if not workflowActive("Cyborg") or game.JobId ~= jobId then return false end
	if ok and result == true then
		state.FistSubmitted = true
		state.FistSubmissionJob = jobId
		return true
	end
	return false
end

local function interactWithRaidButton(button, hadFist)
	if not workflowActive("Cyborg") or not hadFist or not hasItem("Fist of Darkness") then return false end
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = getRoot()
	local jobId = game.JobId
	local fist = character and character:FindFirstChild("Fist of Darkness")
	if not humanoid or humanoid.Health <= 0 or not root
		or not fist or not fist:IsA("Tool")
		or (root.Position - RaidButtonCFrame.Position).Magnitude > 14 then return false end
	local ok, err = pcall(clickPart, button)
	if ok then
		task.wait(0.5)
	end
	if not ok then
		error(err)
	end
	if not workflowActive("Cyborg") or game.JobId ~= jobId or player.Character ~= character
		or humanoid.Health <= 0 or getRoot() ~= root then return false end
	state.LastRemote.Submit = os.clock()
	if not hasItem("Fist of Darkness") then
		state.FistSubmitted = true
		state.FistSubmissionJob = jobId
		log("RaidSummon confirmed the Fist of Darkness submission.")
		return true
	end
	state.LastRemote.FistCheck = nil
	if isRaidUnlocked() then return true end
	log("RaidSummon did not confirm Fist submission; will verify again before resuming chest farming.")
	return false
end

local function submitItem(name)
	local button = getRaidButton()
	assert(button, "Map.CircleIsland.RaidSummon.Button.Main is unavailable")
	local root = getRoot()
	assert(root, "Character HumanoidRootPart is unavailable")
	if (root.Position - RaidButtonCFrame.Position).Magnitude > 14 then
		moveTo(RaidButtonCFrame)
		return false
	end
	if not equipItem(name) then
		return false
	end
	task.wait(0.3)
	if not workflowActive("Cyborg") then return false end
	clickPart(button)
	state.LastRemote.Submit = os.clock()
	return true
end

local function getChestPosition(chest)
	if chest:IsA("BasePart") then return chest.CFrame end
	if chest:IsA("Model") then return chest:GetPivot() end
	return nil
end

local function isChestAvailable(chest)
	return chest and chest.Parent and not chest:GetAttribute("IsDisabled")
		and not chest:FindFirstChild("Ignored") and CollectionService:HasTag(chest, "_ChestTagged")
end

local function nearestChest()
	local root = getRoot()
	if not root then return nil end
	local nearest, nearestDistance
	for _, chest in ipairs(CollectionService:GetTagged("_ChestTagged")) do
		if isChestAvailable(chest) and not state.SeenChests[chest] then
			local cf = getChestPosition(chest)
			if cf then
				local distance = (root.Position - cf.Position).Magnitude
				if not nearestDistance or distance < nearestDistance then
					nearest, nearestDistance = chest, distance
				end
			end
		end
	end
	return nearest
end

local function findChestSpawn()
	local origin = workspace:FindFirstChild("_WorldOrigin")
	local spawns = origin and origin:FindFirstChild("PlayerSpawns")
	local pirates = spawns and spawns:FindFirstChild("Pirates")
	local root = getRoot()
	local best, bestDistance
	if not (pirates and root) then return nil end
	state.SeenChestSpawns = state.SeenChestSpawns or {}
	for _, spawn in ipairs(pirates:GetChildren()) do
		local part = spawn:FindFirstChild("Part")	
		if part and not spawn:FindFirstChild("Ignored") and not state.SeenChestSpawns[part] then
			local distance = (root.Position - part.Position).Magnitude
			if not bestDistance or distance < bestDistance then
				best, bestDistance = part, distance
			end
		end
	end
	if not best and os.clock() - (state.LastChestSpawnReset or 0) > 30 then
		state.SeenChestSpawns = {}
		state.SeenChests = {}
		state.LastChestSpawnReset = os.clock()
	end
	return best
end

queueResume = function(manual)
	assert(manual == true or attackActive(), "No enabled workflow owns this teleport")
	local source = env.__CyborgCodexSource
	assert(type(source) == "string", "Standalone resume source is unavailable")
	local queue = env.queue_on_teleport or _G.queue_on_teleport
	if env.syn and type(env.syn.queue_on_teleport) == "function" then
		queue = env.syn.queue_on_teleport
	end
	assert(type(queue) == "function", "Executor queue_on_teleport is unavailable; cannot resume after teleport")
	local payload = "local e=getgenv(); e.cyborgrace=" .. tostring(env.cyborgrace == true)
		.. "; e.Team=" .. string.format("%q", env.Team or "Marines")
		.. "; e.autosoulguitar=" .. tostring(env.autosoulguitar == true)
		.. "; e.autoghoulrace=" .. tostring(env.autoghoulrace == true)
		.. "; e.autottk=" .. tostring(env.autottk == true)
		.. "; e.autoyama=" .. tostring(env.autoyama == true)
		.. "; e.autotushita=" .. tostring(env.autotushita == true)
		.. "; e.autocdk=" .. tostring(env.autocdk == true)
		.. "; e.autohakilegendary=" .. tostring(env.autohakilegendary == true)
		.. "; e.AutoPullLevel=" .. tostring(env.AutoPullLevel == true)
		.. "; e.autofactoryhop=" .. tostring(env.autofactoryhop == true)
		.. "; e.autopirateraidhop=" .. tostring(env.autopirateraidhop == true)
		.. "; e.autofruithop=" .. tostring(env.autofruithop == true)
		.. "; e.autoberryhop=" .. tostring(env.autoberryhop == true)
		.. "; e.AutoRandomFruit=" .. tostring(env.AutoRandomFruit == true)
		.. "; e.AutoStoreFruit=" .. tostring(env.AutoStoreFruit == true)
		.. "; e.TeleportMirageIsland=" .. tostring(env.TeleportMirageIsland == true)
		.. "; e.TeleportVolcanicIsland=" .. tostring(env.TeleportVolcanicIsland == true)
		.. "; e.TeleportKitsuneIsland=" .. tostring(env.TeleportKitsuneIsland == true)
		.. "; e.__CyborgCodexFruitHint=game:GetService('HttpService'):JSONDecode(" .. string.format("%q", HttpService:JSONEncode(GameEvents.States.Fruit.Hint or {})) .. ")"
		.. "; e.__CyborgCodexHakiTarget=" .. string.format("%q", Haki.Target or "")
		.. "; e.__CyborgCodexCDKTraining=" .. string.format("%q", SwordGet.States.CDK.Training or "")
		.. "; e.__CyborgCodexTushitaHydraReady=" .. tostring(SwordGet.States.Tushita.HydraReady == true)
		.. "; e.SelectedWeapon=" .. string.format("%q", env.SelectedWeapon or "Melee")
		.. "; e.AutoBuso=" .. tostring(env.AutoBuso == true)
		.. "; e.TurnOnRaceV3=" .. tostring(env.TurnOnRaceV3 == true)
		.. "; e.TurnOnRaceV4=" .. tostring(env.TurnOnRaceV4 == true)
		.. "; e.TurnOnObservationHaki=" .. tostring(env.TurnOnObservationHaki == true)
		.. "; e.autofarmboss=" .. tostring(env.autofarmboss == true)
		.. "; e.autofarmbosshop=" .. tostring(env.autofarmbosshop == true)
		.. "; e.selectedboss=" .. string.format("%q", env.selectedboss or "Rip Indra")
		.. "; e.__CyborgCodexResume=true; e.__CyborgCodexSource=" .. string.format("%q", source)
		.. "; local f,err=loadstring(e.__CyborgCodexSource, 'CyborgCodex-Standalone'); assert(f,err); f()"
	if env.AutoPullLevel == true or env.autofarmboss == true or env.autoghoulrace == true or env.autottk == true or env.autoyama == true or env.autotushita == true or env.autocdk == true or env.autohakilegendary == true
		or env.autofactoryhop == true or env.autopirateraidhop == true or env.autofruithop == true or env.autoberryhop == true then
		payload = "getgenv().__CyborgCodexBossVisited=game:GetService('HttpService'):JSONDecode("
			.. string.format("%q", HttpService:JSONEncode(state.BossVisited)) .. "); " .. payload
	end
	queue(payload)
end

local function mayHop(reason)
	if not attackActive() or hasItem("Fist of Darkness") or hasItem("Core Brain") or hasItem("Microchip") then
		return false
	end
	return reason == "moon" or (state.ChestCount >= Config.ChestLimit
		and os.clock() - (state.LastChestCollected or 0) >= 0.75)
end

local function teleportToNewServer(reason)
	reason = reason or "chest"
	if not mayHop(reason) then return end
	if state.HopPending or os.clock() - (state.LastRemote.Hop or 0) < 15 then return end
	local browser = ReplicatedStorage:FindFirstChild("__ServerBrowser")
	assert(browser and browser:IsA("RemoteFunction"), "ReplicatedStorage.__ServerBrowser is unavailable")
	state.LastRemote.Hop = os.clock()
	state.HopPending = true
	for page = 1, 100 do
		if not mayHop(reason) then state.HopPending = false; return end
		local success, servers = pcall(function() return browser:InvokeServer(page) end)
		if success and type(servers) == "table" then
			for jobId in pairs(servers) do
				if type(jobId) == "string" and jobId ~= game.JobId then
					if not mayHop(reason) then state.HopPending = false; return end
					queueResume()
					browser:InvokeServer("teleport", jobId)
					return
				end
			end
		elseif not success then
			log("ServerBrowser query failed: " .. tostring(servers))
			break
		end
	end
	local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId)
	local response = game:HttpGet(url)
	local data = HttpService:JSONDecode(response)
	for _, server in ipairs(data.data or {}) do
		if server.id ~= game.JobId and type(server.playing) == "number"
			and type(server.maxPlayers) == "number" and server.playing < server.maxPlayers then
			if not mayHop(reason) then state.HopPending = false; return end
			queueResume()
			browser:InvokeServer("teleport", server.id)
			return
		end
	end
	state.HopPending = false
	log("No public server available to hop into.")
end

local function countChest(chest)
	state.SeenChests[chest] = true
	state.ChestCount += 1
	state.LastChestCollected = os.clock()
	state.CurrentChest = nil
	state.CurrentChestSince = nil
end

local function collectChest()
	if not attackActive() then return end
	if hasItem("Fist of Darkness") then
		cleanupMovement()
		state.CurrentChest = nil
		return
	end
	if state.ChestCount >= Config.ChestLimit then
		cleanupMovement()
		notify("Collected 50 chests; checking Fist of Darkness before server hop.", "chest-hop", 5)
		teleportToNewServer("chest")
		return
	end
	if escapeSeatWhileCollecting() then
		return
	end
	local chest = state.CurrentChest
	if chest and not isChestAvailable(chest) then
		countChest(chest)
		return
	end
	if not chest then
		chest = nearestChest()
		if not chest then
			local spawnPart = findChestSpawn()
			if spawnPart then
				if moveTo(spawnPart.CFrame) then state.SeenChestSpawns[spawnPart] = true end
			else
				notify("Waiting for collectable chests to load or respawn.", "chest-empty", 5)
			end
			return
		end
		state.CurrentChest = chest
		state.CurrentChestSince = os.clock()
	end
	local cf = getChestPosition(chest)
	if not cf then
		state.CurrentChest = nil
		return
	end
	local root = getRoot()
	if not root then return end
	local distance = (root.Position - cf.Position).Magnitude
	moveTo(cf + Vector3.new(0, 2, 0))
	if distance <= 9 then
		setNoClip(false)
		setFloat(false)
		local character = player.Character
		requestJump(character and character:FindFirstChildOfClass("Humanoid"))
		if hasItem("Fist of Darkness") then
			cleanupMovement()
			state.CurrentChest = nil
			return
		end
		if os.clock() - state.CurrentChestSince >= 6 then
			state.SeenChests[chest] = true
			state.CurrentChest = nil
			state.CurrentChestSince = nil
			notify("Chest did not confirm collection; skipping without increasing the counter.", "chest-stalled", 5)
		end
	end
end

local function findOrder()
	local enemies = workspace:FindFirstChild("Enemies")
	local order = enemies and enemies:FindFirstChild("Order")
	if order and order:FindFirstChildOfClass("Humanoid") then return order end
	if enemies then
		for _, mob in ipairs(enemies:GetChildren()) do
			if string.find(string.lower(mob.Name), "order", 1, true)
				and mob:FindFirstChildOfClass("Humanoid") then return mob end
		end
	end
	return nil
end

local function equipSelectedWeapon()
	local selected = env.SelectedWeapon
	local prefixes = { Melee = "M", Sword = "S", Fruit = "B", Gun = "G" }
	local prefix = prefixes[selected]
	if not prefix then return false end
	local character = player.Character
	local backpack = player:FindFirstChild("Backpack")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not (character and humanoid) then return false end
	for _, container in ipairs({ character, backpack }) do
		if container then
			for _, tool in ipairs(container:GetChildren()) do
				if tool:IsA("Tool") and type(tool.ToolTip) == "string" and tool.ToolTip:sub(1, 1) == prefix then
					if tool.Parent == backpack then humanoid:EquipTool(tool) end
					return true
				end
			end
		end
	end
	return false
end

local function ensureBuso()
	local character = player.Character
	if not character then return false end
	local hasBuso = character:FindFirstChild("HasBuso")
		or character:FindFirstChild("_BusoLayer1")
		or CollectionService:HasTag(character, "HasBuso")
	if hasBuso then return true end
	if os.clock() - (state.LastBusoAttempt or 0) < 1.5 then return false end
	state.LastBusoAttempt = os.clock()
	local ok, err = pcall(invokeCommF, "Buso")
	if not ok and os.clock() - (state.LastBusoError or 0) >= 5 then
		state.LastBusoError = os.clock()
		log("Buso activation failed: " .. tostring(err))
	end
	return ok
end

local function findCharacterTool(name)
	local character = player.Character
	local backpack = player:FindFirstChild("Backpack")
	return (character and character:FindFirstChild(name)) or (backpack and backpack:FindFirstChild(name))
end

local function pressGameKey(key)
	local input = game:GetService("VirtualInputManager")
	input:SendKeyEvent(true, key, false, game)
	task.wait(0.06)
	input:SendKeyEvent(false, key, false, game)
end

state.LastRaceV3Attempt = -math.huge
state.LastRaceV4Attempt = -math.huge
task.spawn(function()
	while state.Generation == generation do
		local now = os.clock()
		ensureTeam()
		if env.TurnOnRaceV3 ~= true then state.LastRaceV3Attempt = -math.huge end
		if env.TurnOnRaceV4 ~= true then state.LastRaceV4Attempt = -math.huge end
		local receivingDamage = state.ActiveWorkflow == "CDK" and SwordGet.States.CDK.TakingDamage == true
		if env.AutoBuso == true and not receivingDamage then
			local ok, err = pcall(ensureBuso)
			if not ok and now - (state.LastSettingsError or 0) >= 5 then
				state.LastSettingsError = now
				print("[Teddy Hub][ERROR][Setting][AutoBuso]\n" .. tostring(err))
			end
		end
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 and not receivingDamage then
			if env.TurnOnRaceV4 == true and state.ActiveWorkflow ~= "PullLever" then
				local energy = character:FindFirstChild("RaceEnergy")
				local transformed = character:FindFirstChild("RaceTransformed")
				local awakening = findCharacterTool("Awakening")
				local activate = ReplicatedStorage:FindFirstChild("Events")
					and ReplicatedStorage.Events:FindFirstChild("ActivateRaceV4")
				if awakening and energy and energy.Value >= 1 and not (transformed and transformed.Value)
					and activate and activate:IsA("BindableEvent") and now - state.LastRaceV4Attempt >= 40 then
					state.LastRaceV4Attempt = now
					local ok, err = pcall(function() activate:Fire() end)
					if not ok then
						print("[Teddy Hub][ERROR][Setting][RaceV4]\n" .. tostring(err))
					end
				end
			end
			if env.TurnOnRaceV3 == true and state.ActiveWorkflow ~= "PullLever" and now - state.LastRaceV3Attempt >= 40 then
				state.LastRaceV3Attempt = now
				local ok, err = pcall(pressGameKey, Enum.KeyCode.T)
				if not ok and now - (state.LastSettingsError or 0) >= 5 then
					state.LastSettingsError = now
					print("[Teddy Hub][ERROR][Setting][RaceV3]\n" .. tostring(err))
				end
			end
			if env.TurnOnObservationHaki == true then
				local globals = ReplicatedStorage:FindFirstChild("Global")
				local ok, gameGlobal = pcall(function() return globals and require(globals) end)
				local observation = ok and gameGlobal and gameGlobal.OM
				if observation and not observation.active and not character:FindFirstChild("KenDisabled") then
					local activate = ReplicatedStorage:FindFirstChild("Remotes")
						and ReplicatedStorage.Remotes:FindFirstChild("CommE")
					if activate and activate:IsA("RemoteEvent") then
						observation.radius = 0
						observation:setActive(true)
						activate:FireServer("Ken", true)
					end
				end
			end
		end
		task.wait(0.75)
	end
end)

local isAttackTarget = LPH_JIT_MAX(function(target)
	if not attackActive() then return false end
	if state.FastAttackTargets then
		if state.ZombieBatch then
			for _, mob in ipairs(state.ZombieBatch) do
				local humanoid = mob.Parent and mob:FindFirstChildOfClass("Humanoid")
				if not humanoid or humanoid.Health <= 0 then return false end
			end
		end
		return table.find(state.FastAttackTargets, target) ~= nil
	end
	return state.FastAttackTarget == target
end)

local fastAttack = LPH_JIT_MAX(function(target)
	if not isAttackTarget(target) then return end
	local netRoot = ReplicatedStorage:FindFirstChild("Modules")
	local net = netRoot and netRoot:FindFirstChild("Net")
	local registerAttack = net and net:FindFirstChild("RE/RegisterAttack")
	local registerHit = net and net:FindFirstChild("RE/RegisterHit")
	assert(registerAttack and registerHit, "FastAttack Net remotes are unavailable")
	local humanoid = target and target:FindFirstChildOfClass("Humanoid")
	local root = target and target:FindFirstChild("HumanoidRootPart")
	local characterRoot = getRoot()
	if not (humanoid and humanoid.Health > 0 and root and characterRoot)
		or (root.Position - characterRoot.Position).Magnitude > 60 then return end
	local parts = {}
	for _, mob in ipairs(state.FastAttackTargets or { target }) do
		local mobHumanoid = mob.Parent and mob:FindFirstChildOfClass("Humanoid")
		local mobRoot = mob:FindFirstChild("HumanoidRootPart")
		if mobHumanoid and mobHumanoid.Health > 0 and mobRoot
			and (mobRoot.Position - characterRoot.Position).Magnitude <= 60 then
			local part = mob:FindFirstChild("Head") or mob.PrimaryPart or mobRoot
			parts[#parts + 1] = { mob, part }
		end
	end
	if #parts == 0 then return end
	registerAttack:FireServer(0.1)
	registerHit:FireServer(parts[1][2], parts)
end)

local function stopFastAttack()
	state.CombatFollow = nil
	state.FastAttackTarget = nil
	state.FastAttackTargets = nil
	state.ZombieBatch = nil
	for part, canCollide in pairs(state.PuzzleCollision or {}) do
		if part.Parent then part.CanCollide = canCollide end
	end
	state.PuzzleCollision = nil
end

local function startFastAttack(target)
	state.FastAttackTarget = target
	if state.FastAttackWorker then return end
	state.FastAttackWorker = true
	task.spawn(function()
		while attackActive() do
			local current = state.FastAttackTarget
			local humanoid = current and current:FindFirstChildOfClass("Humanoid")
			if not (current and current.Parent and humanoid and humanoid.Health > 0) then
				state.FastAttackTarget = nil
				break
			end
			local ok, err = pcall(fastAttack, current)
			if not ok and os.clock() - (state.LastFastAttackError or 0) >= 5 then
				state.LastFastAttackError = os.clock()
				log("Fast attack failed: " .. tostring(err))
			end
			task.wait(0.1)
		end
		if state.Generation == generation then state.FastAttackWorker = false end
	end)
end

local updateCombatFollow = LPH_JIT_MAX(function()
	local follow = state.CombatFollow
	if not follow then return false end
	local target = follow.Target
	local root = target.Parent and target:FindFirstChild("HumanoidRootPart")
	local humanoid = target.Parent and target:FindFirstChildOfClass("Humanoid")
	local characterRoot = getRoot()
	local characterHumanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if not attackActive() or state.ActiveWorkflow ~= follow.Owner or characterRoot ~= follow.Root
		or not characterHumanoid or characterHumanoid.Health <= 0
		or not root or not humanoid or humanoid.Health <= 0 then
		stopFastAttack()
		cleanupMovement()
		return false
	end
	local goal = uprightCFrame(root.CFrame) * CFrame.new(Config.OrderOffset)
	if (characterRoot.Position - goal.Position).Magnitude > 150 then return false end
	cancelMovement()
	characterRoot.CFrame = goal
	characterRoot.AssemblyLinearVelocity = Vector3.zero
	characterRoot.AssemblyAngularVelocity = Vector3.zero
	return true
end)

local fightMob = LPH_JIT(function(order)
	if not attackActive() then return end
	local root = order:FindFirstChild("HumanoidRootPart")
	local humanoid = order:FindFirstChildOfClass("Humanoid")
	local characterRoot = getRoot()
	if not (root and humanoid and humanoid.Health > 0 and characterRoot) then
		stopFastAttack()
		cleanupMovement()
		return
	end
	local target = uprightCFrame(root.CFrame) * CFrame.new(Config.OrderOffset)
	local distance = (characterRoot.Position - target.Position).Magnitude
	if distance > 150 then
		state.CombatFollow = nil
		state.FastAttackTarget = nil
		moveTo(target, true)
		return
	end
	setNoClip(true)
	setFloat(true)
	if (state.ActiveWorkflow == "TTK" or state.ActiveWorkflow == "CDK") and state.TTKWeapon then
		assert(equipItem(state.TTKWeapon), "TTK training sword is unavailable: " .. state.TTKWeapon)
	else
		assert(equipSelectedWeapon(), "No " .. tostring(env.SelectedWeapon) .. " Tool is available in Character or Backpack")
	end
	if env.AutoBuso == true then ensureBuso() end
	if not attackActive() then return end
	state.CombatFollow = { Target = order, Root = characterRoot, Owner = state.ActiveWorkflow }
	if not updateCombatFollow() then return end
	startFastAttack(order)
end)

local fightOrder = LPH_JIT(function(order)
	return fightMob(order)
end)

do
	local function normalize(name)
		return (tostring(name):lower():gsub("%b[]", ""):gsub("_", " "):gsub("%s+", " "):match("^%s*(.-)%s*$"))
	end

	function BossFarm.Matches(name, definition)
		for _, alias in ipairs(definition.Names) do
			if normalize(name) == normalize(alias) then return true end
		end
		return false
	end

	function BossFarm.SetStatus(message)
		if state.ActiveWorkflow == "PullLever" then PullLever.SetStatus(message); return end
		if state.ActiveWorkflow == "Ghoul" then Ghoul.SetStatus(message); return end
		if state.BossStatus == message then return end
		state.BossStatus = message
		if state.ActiveWorkflow == "Boss" then setStage(message) end
		if BossFarm.StatusChanged then BossFarm.StatusChanged(message) end
	end

	function BossFarm.Cancel()
		BossFarm.ClearMirror()
		if state.BossRequest then state.HopPending = false end
		state.BossRequest = nil
		state.BossMissingSince = nil
		state.BossNextHopAt = 0
		state.BossHopMessage = nil
		if state.ActiveWorkflow == "Boss" or state.ActiveWorkflow == "Ghoul" then
			stopFastAttack()
			cleanupMovement()
		end
	end

	function BossFarm.FindIn(container, definition)
		if not container then return nil end
		local follow = state.CombatFollow
		local locked = follow and follow.Owner == state.ActiveWorkflow and follow.Target
		if locked and locked.Parent == container and BossFarm.Matches(locked.Name, definition) then
			local humanoid = locked:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 and locked:FindFirstChild("HumanoidRootPart") then return locked end
		end
		local selected, nearest
		local characterRoot = getRoot()
		for _, mob in ipairs(container:GetChildren()) do
			if mob:IsA("Model") and BossFarm.Matches(mob.Name, definition) then
				local humanoid = mob:FindFirstChildOfClass("Humanoid")
				local root = mob:FindFirstChild("HumanoidRootPart")
				if humanoid and humanoid.Health > 0 and root then
					local distance = characterRoot and (root.Position - characterRoot.Position).Magnitude or 0
					if not nearest or distance < nearest then selected, nearest = mob, distance end
				end
			end
		end
		return selected
	end

	function BossFarm.FindActive(definition)
		return BossFarm.FindIn(workspace:FindFirstChild("Enemies"), definition)
	end

	function BossFarm.GetMirrorGate()
		local map = workspace:FindFirstChild("Map")
		local cake = map and map:FindFirstChild("CakeLoaf")
		local mirror = cake and cake:FindFirstChild("BigMirror")
		local gate = mirror and mirror:FindFirstChild("Main")
		if gate and gate:IsA("BasePart") then return gate.CFrame, gate end
		return CFrame.new(-2144.967041015625, 70.37715911865234, -12399.751953125), nil
	end

	function BossFarm.IsInMirrorDimension(position)
		local center = Vector3.new(-2089.865966796875, 4536.923828125, -14800.0068359375)
		local map = workspace:FindFirstChild("Map")
		local dimension = map and map:FindFirstChild("MirrorDimension")
		local main = dimension and dimension:FindFirstChild("MAIN")
		if main and main:IsA("BasePart") then center = main.Position end
		return (position - center).Magnitude <= 2000
			or (position.X >= -2700 and position.X <= -1400 and position.Y >= 4000
				and position.Y <= 5800 and position.Z >= -15600 and position.Z <= -14000)
	end

	function BossFarm.ReleaseMirrorTouch()
		local touch = state.BossMirrorTouch
		state.BossMirrorTouch = nil
		if not touch or not touch.Started or not touch.Root.Parent or not touch.Gate.Parent then return end
		local ok, err = pcall(touch.Fire, touch.Root, touch.Gate, 1)
		if not ok then log("Mirror touch cleanup failed: " .. tostring(err)) end
	end

	function BossFarm.ClearMirror()
		BossFarm.ReleaseMirrorTouch()
		state.BossMirrorWaitUntil = nil
	end

	function BossFarm.CanEnterMirror(root, owner)
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		return workflowActive(owner or "Boss") and root ~= nil and getRoot() == root
			and humanoid ~= nil and humanoid.Health > 0
	end

	function BossFarm.EnterMirror(definition, owner)
		if not definition.Mirror then return true end
		local root = getRoot()
		if not BossFarm.CanEnterMirror(root, owner) then return false end
		local pending = state.BossMirrorTouch
		if pending then
			if os.clock() < pending.EndAt then return false end
			BossFarm.ReleaseMirrorTouch()
			if not BossFarm.CanEnterMirror(root, owner) then return false end
		end
		if BossFarm.IsInMirrorDimension(root.Position) then
			BossFarm.ClearMirror()
			return true
		end
		stopFastAttack()
		if state.BossMirrorWaitUntil and os.clock() < state.BossMirrorWaitUntil then
			BossFarm.SetStatus("Waiting to enter Mirror Dimension")
			return false
		end
		local gateCF, gate = BossFarm.GetMirrorGate()
		if (root.Position - gateCF.Position).Magnitude > 8 then
			BossFarm.SetStatus("Flying to Cake Island mirror")
			moveTo(gateCF)
			return false
		end
		cleanupMovement()
		if not gate then
			BossFarm.SetStatus("Waiting for Cake Island mirror to load")
			return false
		end
		BossFarm.SetStatus("Touching Cake Island mirror")
		if not BossFarm.CanEnterMirror(root, owner) then return false end
		state.BossMirrorWaitUntil = os.clock() + 1.5
		local fire = env.firetouchinterest or firetouchinterest
		if type(fire) == "function" then
			local touch = { Root = root, Gate = gate, Fire = fire, EndAt = os.clock() + 0.05, Started = true }
			state.BossMirrorTouch = touch
			local ok, err = pcall(fire, root, gate, 0)
			if not ok then
				BossFarm.ReleaseMirrorTouch()
				log("Mirror touch failed: " .. tostring(err))
			end
		end
		return false
	end

	function BossFarm.HasProtectedItem()
		for _, name in ipairs({ "Fist of Darkness", "Core Brain", "Microchip", "God's Chalice", "Sweet Chalice", "Hallow Essence", "Hellfire Torch" }) do
			if hasItem(name) then return true end
		end
		return false
	end

	function BossFarm.HopStillAllowed(request)
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local ownerAllowed
		if request.Owner == "Ghoul" then
			ownerAllowed = Ghoul.HopAllowed()
		else
			ownerAllowed = workflowActive("Boss") and env.autofarmbosshop == true and env.selectedboss == request.Selection
		end
		return state.Generation == generation and ownerAllowed
			and humanoid ~= nil and humanoid.Health > 0 and getRoot() ~= nil
			and state.BossRequest == request
			and game.PlaceId == request.PlaceId and currentSea() == request.Definition.Sea
			and not BossFarm.HasProtectedItem() and not BossFarm.FindActive(request.Definition)
			and not BossFarm.FindIn(ReplicatedStorage, request.Definition)
	end

	function BossFarm.FetchServers(slug)
		local url = BossFarm.ApiBase .. slug .. "/"
		local request = (env.syn and env.syn.request) or env.http_request or env.request or http_request or request
		local body
		if type(request) == "function" then
			local response = request({ Url = url, Method = "GET", Timeout = 10 })
			assert(type(response) == "table", "Boss API returned no response")
			local status = tonumber(response.StatusCode or response.Status)
			assert(not status or (status >= 200 and status < 300), "Boss API HTTP " .. tostring(status))
			body = response.Body
		else
			body = game:HttpGet(url)
		end
		assert(type(body) == "string", "Boss API response body is missing")
		local data = HttpService:JSONDecode(body)
		assert(type(data) == "table" and type(data.data) == "table", "Boss API response schema is invalid")
		return data.data
	end

	function BossFarm.SelectServer(servers, definition)
		local now = os.time()
		for id, visitedAt in pairs(state.BossVisited) do
			if type(visitedAt) ~= "number" or now - visitedAt >= BossFarm.VisitedSeconds then state.BossVisited[id] = nil end
		end
		for _, server in ipairs(servers) do
			if type(server) == "table" then
				local jobId = BossFarm.DecodeJobId(server.Jobid or server.jobid or server.JobId or server.id)
				local placeId = tonumber(server.place_id or server.placeid or server.PlaceId)
				local playing, maxPlayers = tonumber(server.playing), tonumber(server.maxPlayers)
				if type(server.players) == "string" then
					local a, b = server.players:match("^(%d+)%s*/%s*(%d+)$")
					playing, maxPlayers = tonumber(a) or playing, tonumber(b) or maxPlayers
				end
				local nameMatches = not server.name or BossFarm.Matches(server.name, definition)
					or normalize(server.name) == normalize(definition.Slug)
				if jobId and jobId ~= game.JobId and not state.BossVisited[jobId] and nameMatches
					and (not placeId or placeId == game.PlaceId)
					and (not playing or not maxPlayers or playing < maxPlayers) then return jobId end
			end
		end
		return nil
	end

	function BossFarm.BeginHop(definition, owner)
		local request = { Owner = owner or "Boss", Selection = owner == "Ghoul" and "Cursed Captain" or env.selectedboss,
			Definition = definition, PlaceId = game.PlaceId,
			StartedAt = os.clock(), Phase = "Query" }
		state.BossRequest = request
		state.HopPending = true
		state.BossNextHopAt = os.clock() + BossFarm.RetrySeconds
		BossFarm.SetStatus("Searching API servers: " .. request.Selection)
		task.spawn(function()
			local ok, message = xpcall(function()
				local servers = BossFarm.FetchServers(definition.Slug)
				if not BossFarm.HopStillAllowed(request) then return end
				local jobId = BossFarm.SelectServer(servers, definition)
				if not jobId then return "No matching API server" end
				local browser = ReplicatedStorage:FindFirstChild("__ServerBrowser")
				assert(browser and browser:IsA("RemoteFunction"), "__ServerBrowser is unavailable")
				if not BossFarm.HopStillAllowed(request) then return end
				request.JobId = jobId
				state.BossVisited[jobId] = os.time()
				state.BossVisited[game.JobId] = os.time()
				queueResume()
				if not BossFarm.HopStillAllowed(request) then return end
				request.Phase = "Teleport"
				request.StartedAt = os.clock()
				BossFarm.SetStatus("Hopping to " .. request.Selection)
				local result = browser:InvokeServer("teleport", jobId)
				assert(result ~= false, "Server rejected the teleport")
			end, debug.traceback)
			if state.Generation ~= generation or state.BossRequest ~= request then return end
			if ok and request.Phase == "Teleport" then return end
			state.BossRequest = nil
			state.HopPending = false
			state.BossHopMessage = ok and (message or "Search cancelled") or "Boss API/teleport failed"
			state.BossNextHopAt = os.clock() + BossFarm.RetrySeconds
			BossFarm.SetStatus(state.BossHopMessage)
			if not ok then reportControllerError(message, request.Owner, request.Phase == "Teleport" and "APITeleport" or "APISearch") end
		end)
	end

	BossFarm.Step = LPH_JIT(function()
		if not workflowActive("Boss") then return end
		local definition = BossFarm.Definitions[env.selectedboss]
		if not definition then BossFarm.SetStatus("Invalid boss selection"); return end
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 or not getRoot() then
			BossFarm.Cancel()
			BossFarm.SetStatus("Waiting for character")
			return
		end
		if not ensureTeam() or not workflowActive("Boss") then return end
		if currentSea() ~= definition.Sea then
			BossFarm.Cancel()
			BossFarm.SetStatus(env.selectedboss .. " requires Sea " .. definition.Sea)
			return
		end
		local boss = BossFarm.FindActive(definition)
		if boss then
			if state.BossRequest then BossFarm.Cancel() end
			state.BossMissingSince = nil
			state.BossNextHopAt = 0
			if not BossFarm.EnterMirror(definition) then return end
			local bossHumanoid = boss.Parent and boss:FindFirstChildOfClass("Humanoid")
			if not workflowActive("Boss") or not bossHumanoid or bossHumanoid.Health <= 0 then return end
			local distance = (boss.HumanoidRootPart.Position - getRoot().Position).Magnitude
			BossFarm.SetStatus((distance > 60 and "Flying to " or "Fighting ") .. env.selectedboss)
			fightMob(boss)
			return
		end
		stopFastAttack()
		local hint = BossFarm.FindIn(ReplicatedStorage, definition)
		if hint and definition.Mirror then
			if state.BossRequest then BossFarm.Cancel() end
			state.BossMissingSince = nil
			if not BossFarm.EnterMirror(definition) then return end
		elseif not hint then
			BossFarm.ClearMirror()
		end
		if hint and (hint.HumanoidRootPart.Position - getRoot().Position).Magnitude > 120 then
			if state.BossRequest then BossFarm.Cancel() end
			state.BossMissingSince = nil
			BossFarm.SetStatus("Approaching replicated boss: " .. env.selectedboss)
			moveTo(hint.HumanoidRootPart.CFrame * CFrame.new(Config.OrderOffset))
			return
		end
		if hint then
			if state.BossRequest then BossFarm.Cancel() end
			cleanupMovement()
			state.BossMissingSince = nil
			BossFarm.SetStatus("Waiting for boss replication: " .. env.selectedboss)
			return
		end
		cleanupMovement()
		state.BossMissingSince = state.BossMissingSince or os.clock()
		if os.clock() - state.BossMissingSince < BossFarm.MissingGrace then
			BossFarm.SetStatus("Checking boss spawn: " .. env.selectedboss)
			return
		end
		if env.autofarmbosshop ~= true then
			if state.BossRequest then BossFarm.Cancel() end
			BossFarm.SetStatus("Waiting for " .. env.selectedboss)
			return
		end
		if BossFarm.HasProtectedItem() then
			BossFarm.Cancel()
			BossFarm.SetStatus("Hop paused: carrying a protected item")
			return
		end
		local pending = state.BossRequest
		if pending then
			if os.clock() - pending.StartedAt >= BossFarm.TeleportTimeout then
				state.BossRequest = nil
				state.HopPending = false
				state.BossHopMessage = pending.Phase == "Teleport" and "Teleport timed out" or "API request timed out"
				state.BossNextHopAt = os.clock() + BossFarm.RetrySeconds
				BossFarm.SetStatus(state.BossHopMessage)
			end
			return
		end
		if os.clock() < (state.BossNextHopAt or 0) then
			BossFarm.SetStatus((state.BossHopMessage or "Waiting for API retry") .. " ("
				.. math.ceil(state.BossNextHopAt - os.clock()) .. "s)")
			return
		end
		BossFarm.BeginHop(definition)
	end)
end

local function getFragments()
	local data = player:FindFirstChild("Data")
	local fragments = data and data:FindFirstChild("Fragments")
	assert(fragments and typeof(fragments.Value) == "number", "Data.Fragments is unavailable")
	return fragments.Value
end

local function buyLawChip()
	if not isRaidUnlocked() or not workflowActive("Cyborg") then return end
	if getFragments() < Config.MinLawFragments then
		notify("Need at least 1000 Fragments; waiting before buying a Law Microchip.", "fragments", 5)
		return
	end
	if os.clock() - (state.LastRemote.BuyChip or 0) < 5 then return end
	state.LastRemote.BuyChip = os.clock()
	invokeCommF("BlackbeardReward", "Microchip", "2")
end

local MaterialTargets = {
	Ectoplasm = {
		Sea = 2, Required = 250,
		Names = { "Ship Deckhand", "Ship Engineer", "Ship Steward", "Ship Officer" },
		Spawns = {
			CFrame.new(1198, 126, 32988), CFrame.new(917, 44, 32785),
			CFrame.new(916, 130, 33418), CFrame.new(917, 181, 33355),
		},
	},
	Bones = {
		Sea = 3, Required = 500,
		Names = { "Reborn Skeleton", "Demonic Soul", "Living Zombie", "Posessed Mummy" },
		Spawns = {
			CFrame.new(-8737, 143, 6035), CFrame.new(-9501, 172, 6036),
			CFrame.new(-10150, 140, 5930), CFrame.new(-9500, 6, 6100),
		},
	},
}
local PuzzleStages = { "Swamp", "Gravestones", "Ghost", "Trophies", "Pipes" }
local PuzzlePositions = {
	Grave = CFrame.new(-8654.314453125, 140.9499053955078, 6167.5283203125),
	Swamp = CFrame.new(-10171.7607421875, 138.62667846679688, 6008.0654296875),
	Gravestones = CFrame.new(-8761.4765625, 142.10487365722656, 6086.07861328125),
	Ghost = CFrame.new(-9755.6591796875, 271.0661315917969, 6290.61474609375),
	Lab = CFrame.new(-9530.0126953125, 6.104853630065918, 6054.83349609375),
}
local BlankTablets = { "Segment6", "Segment2", "Segment8", "Segment9", "Segment5" }
local TrophyTablets = {
	Segment1 = "Trophy1", Segment3 = "Trophy2", Segment4 = "Trophy3",
	Segment7 = "Trophy4", Segment10 = "Trophy5",
}
local PipeColors = {
	Part1 = "Really black", Part2 = "Really black", Part3 = "Dusty Rose",
	Part4 = "Storm blue", Part5 = "Really black", Part6 = "Parsley green",
	Part7 = "Really black", Part8 = "Dusty Rose", Part9 = "Really black", Part10 = "Storm blue",
}

local cleanMobName = LPH_JIT_MAX(function(name)
	return name:gsub(" %p?Lv%.? %d+%p?", ""):match("^%s*(.-)%s*$")
end)

local isAlive = LPH_JIT_MAX(function(mob)
	local humanoid = mob and mob.Parent and mob:FindFirstChildOfClass("Humanoid")
	return humanoid ~= nil and humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") ~= nil
end)

local findMob = LPH_JIT_MAX(function(names)
	local enemies = workspace:FindFirstChild("Enemies")
	local root = getRoot()
	if not enemies or not root then return nil end
	local follow = state.CombatFollow
	local locked = follow and follow.Owner == state.ActiveWorkflow and follow.Target
	if locked and locked.Parent == enemies and isAlive(locked) and table.find(names, cleanMobName(locked.Name)) then return locked end
	local nearest, distance
	for _, mob in ipairs(enemies:GetChildren()) do
		if isAlive(mob) and table.find(names, cleanMobName(mob.Name)) then
			local current = (mob.HumanoidRootPart.Position - root.Position).Magnitude
			if not distance or current < distance then nearest, distance = mob, current end
		end
	end
	return nearest
end)

local itemService, itemConfig
local inventoryCounts = LPH_JIT(function(force)
	if not force and state.InventoryCounts and os.clock() - (state.InventoryReadAt or 0) < 1 then
		return state.InventoryCounts
	end
	if not itemService then
		local replicationModule = ReplicatedStorage:FindFirstChild("ItemReplicationService")
		local configModule = ReplicatedStorage:FindFirstChild("ItemConfig")
		assert(replicationModule and configModule, "ItemReplicationService/ItemConfig are unavailable")
		local service = require(replicationModule)
		local config = require(configModule)
		assert(type(service.GetItems) == "function" and type(service.KEYS) == "table"
			and type(config.match) == "function", "Inventory API does not match the verified sources")
		itemService, itemConfig = service, config
	end
	local items = itemService:GetItems(itemService.KEYS.QUANTITY)
	assert(type(items) == "table", "ItemReplicationService:GetItems did not return a table")
	local counts = {}
	for _, item in pairs(items) do
		assert(type(item.Value) == "number", "Inventory quantity is not numeric")
		if item.Value > 0 then
			local ok, config = pcall(function()
				local match = itemConfig.match(item.ItemId)
				if type(match) ~= "table" then return nil end
				if type(match.asNullable) == "function" then return match:asNullable() end
				if type(match.unwrap) == "function" then return match:unwrap() end
				return match
			end)
			assert(ok and type(config) == "table", "Cannot resolve inventory ItemId " .. tostring(item.ItemId))
			local index = type(config.Index) == "table" and config.Index or {}
			local display = type(config.Display) == "table" and config.Display or {}
			local name
			local candidates = { index.StorageKey, display.Name, display.Title, config.Name }
			for i = 1, 4 do
				local candidate = candidates[i]
				if type(candidate) == "string" and candidate ~= "" then name = candidate; break end
			end
			assert(name, "Inventory item name is unavailable for ItemId " .. tostring(item.ItemId))
			counts[name] = (counts[name] or 0) + item.Value
		end
	end
	state.InventoryCounts = counts
	state.InventoryReadAt = os.clock()
	return counts
end)

do
	function TTK.Canonical(name)
		if type(name) ~= "string" then return nil end
		name = name:gsub("^[Ss][Ww][Oo][Rr][Dd]%s*:%s*", ""):match("^%s*(.-)%s*$")
		if name:lower() == "true triple katana" then return "True Triple Katana" end
		if name:lower() == "yama" then return "Yama" end
		if name:lower() == "tushita" then return "Tushita" end
		if name:lower() == "cursed dual katana" then return "Cursed Dual Katana" end
		for alias, canonical in pairs(TTK.Aliases) do
			if alias:lower() == name:lower() then return canonical end
		end
	end

	function TTK.SetStatus(message)
		if state.ActiveWorkflow == "CDK" then SwordGet.SetStatus("CDK", message); return end
		if TTK.Status == message then return end
		TTK.Status = message
		print("[Teddy Hub][TTK] " .. message)
		if TTK.StatusChanged then TTK.StatusChanged(message) end
	end

	function TTK.Cancel()
		TTK.Epoch += 1
		if TTK.Request then state.HopPending = false end
		TTK.Request = nil
		TTK.NextHop = nil
		TTK.WaitUntil = nil
		state.TTKWeapon = nil
		if state.ActiveWorkflow == "TTK" then stopFastAttack(); cleanupMovement() end
	end

	function TTK.Snapshot(force)
		if force or not TTK.Cache or os.clock() - (TTK.ReadAt or 0) >= 3 then
			TTK.Config = TTK.Config or require(ReplicatedStorage:WaitForChild("ItemConfig", 10))
			local net = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")
			local remote = net and net:FindFirstChild("RF/GetAllItemValues")
			assert(remote and remote:IsA("RemoteFunction"), "TTK inventory snapshot remote is unavailable")
			local values = remote:InvokeServer()
			assert(type(values) == "table", "TTK inventory snapshot is unavailable")
			local snapshot = { Owned = {}, Mastery = {}, Names = {} }
			for _, item in pairs(values) do
				if item.Key == "IsOwned" or item.Key == "Mastery" then
					local resolved = TTK.ItemNames[item.ItemId]
					if resolved == nil then
						local config = TTK.Config.match(item.ItemId):asNullable()
						local name = config and config.Index and config.Index.StorageKey
						resolved = TTK.Canonical(name) and name or false
						TTK.ItemNames[item.ItemId] = resolved
					end
					local canonical = TTK.Canonical(resolved)
					if canonical then
						snapshot.Names[canonical] = resolved
						if item.Key == "IsOwned" and item.Value == true then snapshot.Owned[canonical] = true end
						if item.Key == "Mastery" and type(item.Value) == "number" then snapshot.Mastery[canonical] = item.Value end
					end
				end
			end
			TTK.Cache = snapshot
			TTK.ReadAt = os.clock()
		end
		local snapshot = TTK.Cache
		for _, container in pairs({ Character = player.Character, Backpack = player:FindFirstChild("Backpack") }) do
			for _, tool in ipairs(container:GetChildren()) do
				local canonical = tool:IsA("Tool") and TTK.Canonical(tool.Name)
				if canonical then
					snapshot.Owned[canonical] = true
					snapshot.Names[canonical] = tool.Name
					local level = tool:FindFirstChild("Level")
					if level and type(level.Value) == "number" then
						snapshot.Mastery[canonical] = math.max(level.Value, snapshot.Mastery[canonical] or 0)
					end
				end
			end
		end
		return snapshot
	end

	function TTK.PreferredTraining(snapshot)
		local sword = TTK.Training
		if sword and snapshot.Owned[sword] and (snapshot.Mastery[sword] or 0) < TTK.RequiredMastery then return sword end
		local character = player.Character
		local tool = character and character:FindFirstChildOfClass("Tool")
		sword = tool and TTK.Canonical(tool.Name)
		if sword and table.find(TTK.Swords, sword) and snapshot.Owned[sword]
			and (snapshot.Mastery[sword] or 0) < TTK.RequiredMastery then return sword end
	end

	function TTK.Plan(snapshot, beli, training, choose)
		if snapshot.Owned["True Triple Katana"] then return "Complete" end
		for _, sword in ipairs(TTK.Swords) do
			if not snapshot.Owned[sword] then
				if beli < TTK.SwordPrice then return "Money", TTK.SwordPrice end
				return "Buy", sword
			end
		end
		local pending = {}
		for _, sword in ipairs(TTK.Swords) do
			if (snapshot.Mastery[sword] or 0) < TTK.RequiredMastery then pending[#pending + 1] = sword end
		end
		if #pending > 0 then
			if table.find(pending, training) then return "Mastery", training end
			return "Mastery", pending[(choose or math.random)(1, #pending)]
		end
		if beli < TTK.CraftPrice then return "Money", TTK.CraftPrice end
		return "Craft"
	end

	function TTK.SelectServer(servers, snapshot)
		local now = os.time()
		for id, at in pairs(state.BossVisited) do
			if type(at) ~= "number" or now - at >= BossFarm.VisitedSeconds then state.BossVisited[id] = nil end
		end
		for _, server in ipairs(servers) do
			if type(server) == "table" then
				local sword = TTK.Canonical(server.name)
				local jobId = BossFarm.DecodeJobId(server.Jobid or server.jobid or server.JobId or server.id)
				local placeId = tonumber(server.place_id or server.placeid or server.PlaceId)
				local playing, maximum = tonumber(server.playing), tonumber(server.maxPlayers)
				if type(server.players) == "string" then
					local a, b = server.players:match("^(%d+)%s*/%s*(%d+)$")
					playing, maximum = tonumber(a) or playing, tonumber(b) or maximum
				end
				if sword and sword ~= "True Triple Katana" and not snapshot.Owned[sword]
					and jobId and jobId ~= game.JobId and not state.BossVisited[jobId]
					and (not placeId or placeId == game.PlaceId) and (not playing or not maximum or playing < maximum) then
					return jobId, sword
				end
			end
		end
	end

	function TTK.HopAllowed(request)
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		return workflowActive("TTK") and request.Epoch == TTK.Epoch and TTK.Request == request
			and request.PlaceId == game.PlaceId and currentSea() == 2
			and humanoid and humanoid.Health > 0 and player.Data.Beli.Value >= TTK.SwordPrice
			and not BossFarm.HasProtectedItem()
	end

	function TTK.Hop(snapshot)
		if TTK.Request then
			if os.clock() - TTK.Request.Started >= BossFarm.TeleportTimeout then
				TTK.Epoch += 1; TTK.Request = nil; state.HopPending = false
				TTK.NextHop = os.clock() + BossFarm.RetrySeconds
				TTK.SetStatus("Sword API/teleport timeout; retrying")
			end
			return
		end
		if os.clock() < (TTK.NextHop or 0) then return end
		local request = { Epoch = TTK.Epoch, PlaceId = game.PlaceId, Started = os.clock() }
		TTK.Request = request; state.HopPending = true
		TTK.SetStatus("Searching sword API for missing legendary swords")
		task.spawn(function()
			local ok, message = xpcall(function()
				local servers = BossFarm.FetchServers("sword")
				if not TTK.HopAllowed(request) then return "Sword search cancelled" end
				local fresh = TTK.Snapshot(true)
				if not TTK.HopAllowed(request) then return "Sword search cancelled" end
				local jobId, sword = TTK.SelectServer(servers, fresh)
				if not jobId then return "No API server for a missing sword; retrying" end
				local dealer = TTK.Canonical(invokeCommF("LegendarySwordDealer", "1"))
				if dealer and not fresh.Owned[dealer] then return "Missing sword found in current server" end
				if not TTK.HopAllowed(request) then return "Sword search cancelled" end
				local browser = ReplicatedStorage:FindFirstChild("__ServerBrowser")
				assert(browser and browser:IsA("RemoteFunction"), "Sword server browser is unavailable")
				queueResume()
				if not TTK.HopAllowed(request) then return "Sword search cancelled" end
				state.BossVisited[jobId] = os.time(); state.BossVisited[game.JobId] = os.time()
				request.Teleport = true; request.Started = os.clock()
				TTK.SetStatus("Hopping for " .. sword)
				assert(browser:InvokeServer("teleport", jobId) ~= false, "Sword server teleport rejected")
			end, debug.traceback)
			if state.Generation ~= generation or TTK.Request ~= request then return end
			if ok and request.Teleport then return end
			TTK.Request = nil; state.HopPending = false
			TTK.NextHop = os.clock() + BossFarm.RetrySeconds
			TTK.SetStatus(ok and (message or "Sword search cancelled") or "Sword API error; see console")
			if not ok then reportControllerError(message, "TTK", "SwordHop") end
		end)
	end

	function TTK.EnsureSword(snapshot, sword)
		local name = snapshot.Names[sword] or sword
		state.TTKWeapon = name
		if not hasItem(name) then
			stopFastAttack()
			if os.clock() - (TTK.LastLoad or 0) >= 2 then
				TTK.LastLoad = os.clock(); invokeCommF("LoadItem", name)
			end
			TTK.SetStatus("Loading mastery sword: " .. name)
			return false
		end
		return equipItem(name)
	end

	function TTK.BonesQuest(level)
		if level >= 2050 then return "HauntedQuest2", 2, "Posessed Mummy", CFrame.new(-9506.95313, 172.104858, 6074.63086) end
		if level >= 2025 then return "HauntedQuest2", 1, "Demonic Soul", CFrame.new(-9506.95313, 172.104858, 6074.63086) end
		if level >= 2000 then return "HauntedQuest1", 2, "Living Zombie", CFrame.new(-9490.2793, 142.104858, 5565.8501) end
		if level >= 1975 then return "HauntedQuest1", 1, "Reborn Skeleton", CFrame.new(-9490.2793, 142.104858, 5565.8501) end
	end

	function TTK.AcceptBonesQuest()
		local questName, index, mob, position = TTK.BonesQuest(player.Data.Level.Value)
		if not questName then TTK.SetStatus("Bones quests require level 1975 or higher"); return end
		local questActive, questMatches
		local guide = ReplicatedStorage:FindFirstChild("GuideModule")
		local guideDataModule = guide and guide:FindFirstChild("GuideData")
		if guideDataModule then
			TTK.GuideData = TTK.GuideData or require(guideDataModule)
			assert(type(TTK.GuideData.Data) == "table", "Native quest data is unavailable")
			local current = TTK.GuideData.Data.QuestData
			questActive = current ~= nil
			if questActive then
				assert(type(current) == "table" and type(current.Info) == "table", "Native quest objective is unavailable")
				questMatches = current.InternalQuestName == questName
					and (current.Info.Name == mob or (type(current.Info.Task) == "table" and current.Info.Task[mob] ~= nil))
			end
		else
			local main = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("Main")
			local quest = main and main:FindFirstChild("Quest")
			if not quest then TTK.SetStatus("Waiting for quest UI"); return end
			questActive = quest.Visible
			if questActive then
				local container = quest:FindFirstChild("Container")
				local questTitle = container and container:FindFirstChild("QuestTitle")
				local title = questTitle and questTitle:FindFirstChild("Title")
				if not title or not title:IsA("TextLabel") then
					TTK.SetStatus("Waiting for quest objective UI"); stopFastAttack(); return
				end
				local objective = title.Text:gsub("<[^>]*>", ""):lower()
				if objective == "" then TTK.SetStatus("Waiting for quest objective text"); stopFastAttack(); return end
				questMatches = objective:find(mob:lower(), 1, true) ~= nil
			end
		end
		if questMatches then return mob, position end
		stopFastAttack()
		if questActive then
			if os.clock() - (TTK.LastQuest or 0) >= 2 then TTK.LastQuest = os.clock(); invokeCommF("AbandonQuest") end
			return
		end
		local root = getRoot()
		if not root then return end
		local npcs = workspace:FindFirstChild("NPCs")
		local npcName = questName == "HauntedQuest2" and "Haunted Castle Quest Giver 2" or "Haunted Castle Quest Giver 1"
		local npc = npcs and npcs:FindFirstChild(npcName)
		if npc and npc:IsA("Model") then position = npc:GetPivot() * CFrame.new(0, 0, -3) end
		TTK.SetStatus("Accepting Bones quest: " .. mob)
		if (root.Position - position.Position).Magnitude > 5 then moveTo(position); return end
		cleanupMovement()
		if os.clock() - (TTK.LastQuest or 0) >= 2 then
			TTK.LastQuest = os.clock(); invokeCommF("StartQuest", questName, index)
		end
	end

	function TTK.FarmBones(snapshot, sword, goal, owner)
		owner = owner or "TTK"
		if not travelToSea3() then return end
		if sword and not TTK.EnsureSword(snapshot, sword) then return end
		if not workflowActive(owner) then return end
		local mobName = TTK.AcceptBonesQuest()
		if not mobName or not workflowActive(owner) then return end
		if sword then TTK.SetStatus("Bones mastery: " .. sword .. " " .. tostring(snapshot.Mastery[sword] or "?") .. "/" .. tostring(owner == "CDK" and 350 or 300))
		else TTK.SetStatus("Bones + quest Beli: " .. tostring(player.Data.Beli.Value) .. "/" .. tostring(goal)) end
		local mob = findMob(TTK.BonesMobs)
		if mob then fightMob(mob); return end
		stopFastAttack()
		local positions = { ["Reborn Skeleton"] = CFrame.new(-8737, 143, 6035), ["Living Zombie"] = CFrame.new(-10150, 140, 5930),
			["Demonic Soul"] = CFrame.new(-9501, 172, 6036), ["Posessed Mummy"] = CFrame.new(-9500, 6, 6100) }
		moveTo(positions[mobName] + Vector3.new(0, 18, 0))
	end

	function TTK.Buy(snapshot)
		if not travelToSea2() then return end
		if TTK.Request then TTK.Hop(snapshot); return end
		if os.clock() - (TTK.LastDealer or 0) < 2 then return end
		TTK.LastDealer = os.clock()
		local sword = TTK.Canonical(invokeCommF("LegendarySwordDealer", "1"))
		if not workflowActive("TTK") then return end
		if sword and sword ~= "True Triple Katana" and not snapshot.Owned[sword] and player.Data.Beli.Value >= TTK.SwordPrice then
			TTK.SetStatus("Buying missing legendary sword: " .. sword)
			local result = invokeCommF("LegendarySwordDealer", "2")
			print("[Teddy Hub][TTK] Dealer response: " .. tostring(result))
			TTK.ReadAt = -math.huge; TTK.WaitUntil = os.clock() + 4
			return
		end
		TTK.Hop(snapshot)
	end

	function TTK.Complete()
		TTK.Cancel()
		TTK.Training = nil
		state.TTKCompleted = true
		TTK.SetStatus("Completed: True Triple Katana owned")
	end

	TTK.Step = LPH_JIT(function()
		if not workflowActive("TTK") then return end
		local snapshot = TTK.Snapshot()
		if not workflowActive("TTK") then return end
		local action, target = TTK.Plan(snapshot, player.Data.Beli.Value, TTK.PreferredTraining(snapshot))
		if action == "Complete" then TTK.Complete(); return end
		if TTK.WaitUntil and os.clock() < TTK.WaitUntil then return end
		if BossFarm.HasProtectedItem() then TTK.SetStatus("Paused: carrying a protected item"); stopFastAttack(); cleanupMovement(); return end
		local root = getRoot()
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if not root or not humanoid or humanoid.Health <= 0 then TTK.SetStatus("Waiting for character"); return end
		if action ~= "Mastery" then state.TTKWeapon = nil; TTK.Training = nil end
		if action ~= "Buy" and TTK.Request then TTK.Cancel() end
		if action == "Money" then TTK.FarmBones(snapshot, nil, target)
		elseif action == "Buy" then stopFastAttack(); cleanupMovement(); TTK.Buy(snapshot)
		elseif action == "Mastery" then
			if TTK.Training ~= target then
				stopFastAttack(); cleanupMovement()
				TTK.Training = target; TTK.LastLoad = -math.huge
			end
			TTK.FarmBones(snapshot, target)
		elseif action == "Craft" then
			stopFastAttack(); cleanupMovement()
			if not travelToSea2() then return end
			if os.clock() - (TTK.LastCraft or 0) < 5 then return end
			TTK.LastCraft = os.clock()
			local ready = invokeCommF("MysteriousMan", "1")
			if not workflowActive("TTK") then return end
			if ready == -1 then TTK.Complete(); return end
			if ready ~= 0 then TTK.ReadAt = -math.huge; TTK.SetStatus("Server has not confirmed TTK mastery requirements"); return end
			if player.Data.Beli.Value < TTK.CraftPrice then return end
			TTK.SetStatus("Crafting True Triple Katana")
			local result = invokeCommF("MysteriousMan", "2")
			print("[Teddy Hub][TTK] Craft response: " .. tostring(result))
			TTK.ReadAt = -math.huge; TTK.WaitUntil = os.clock() + 3
		end
	end)
end

do
	function SwordGet.SetStatus(name, message)
		local controller = SwordGet.States[name]
		if controller.Status == message then return end
		controller.Status = message
		print("[Teddy Hub][" .. name .. "] " .. message)
		if controller.StatusChanged then controller.StatusChanged(message) end
	end

	function SwordGet.Cancel(name)
		local controller = SwordGet.States[name]
		controller.Epoch += 1
		if controller.Request then state.HopPending = false end
		controller.Request = nil
		controller.NextHop = nil
		controller.MissingSince = nil
		if name == "CDK" then SwordGet.CDK.ClearDamage(); controller.Final = nil; state.TTKWeapon = nil end
		if state.ActiveWorkflow == name then stopFastAttack(); cleanupMovement() end
	end

	function SwordGet.Complete(name)
		SwordGet.Cancel(name)
		SwordGet.States[name].Completed = true
		SwordGet.SetStatus(name, "Completed: " .. (SwordGet.States[name].InventoryKey or name) .. " owned")
	end

	function SwordGet.FindLive(names)
		local mob = findMob(names)
		if mob then return mob end
		local origin = workspace:FindFirstChild("_WorldOrigin")
		for _, folder in pairs({ Characters = workspace:FindFirstChild("Characters"),
			Origin = origin and origin:FindFirstChild("Enemies"), World = workspace }) do
			mob = BossFarm.FindIn(folder, { Names = names })
			if mob then return mob end
		end
	end

	function SwordGet.FindHint(names)
		return BossFarm.FindIn(ReplicatedStorage, { Names = names })
	end

	function SwordGet.QuestData()
		local guide = ReplicatedStorage:FindFirstChild("GuideModule")
		local module = guide and guide:FindFirstChild("GuideData")
		assert(module, "Native GuideData is unavailable")
		TTK.GuideData = TTK.GuideData or require(module)
		assert(type(TTK.GuideData.Data) == "table", "Native quest state is unavailable")
		return TTK.GuideData.Data.QuestData
	end

	function SwordGet.QuestMatches(quest, mobName)
		if type(quest) ~= "table" or type(quest.Info) ~= "table" then return false end
		local expected = cleanMobName(mobName):lower()
		if cleanMobName(tostring(quest.Info.Name or "")):lower() == expected then return true end
		for name in pairs(type(quest.Info.Task) == "table" and quest.Info.Task or {}) do
			if cleanMobName(tostring(name)):lower() == expected then return true end
		end
		return false
	end

	function SwordGet.EliteProgress(force)
		local controller = SwordGet.States.Yama
		if force or not controller.Progress or os.clock() - (controller.ProgressAt or 0) >= 2 then
			local result = invokeCommF("EliteHunter", "Progress")
			assert(type(result) == "number", "Elite Hunter progress is unavailable")
			controller.Progress = result; controller.ProgressAt = os.clock()
		end
		return controller.Progress
	end

	function SwordGet.TushitaProgress(force)
		local controller = SwordGet.States.Tushita
		if force or not controller.Progress or os.clock() - (controller.ProgressAt or 0) >= 2 then
			local result = invokeCommF("TushitaProgress")
			assert(type(result) == "table" and type(result.OpenedDoor) == "boolean" and type(result.Torches) == "table",
				"Tushita progress is unavailable")
			controller.Progress = result; controller.ProgressAt = os.clock()
		end
		return controller.Progress
	end

	function SwordGet.MapPart(name, position)
		local key = name .. ":" .. tostring(position)
		local cached = SwordGet.PartCache[key]
		if cached and os.clock() - cached.At < 1 then return cached.Part end
		local map = workspace:FindFirstChild("Map")
		if map then
			for _, object in ipairs(map:GetDescendants()) do
				if object.Name == name and object:IsA("BasePart") and (object.Position - position).Magnitude < 2 then
					SwordGet.PartCache[key] = { Part = object, At = os.clock() }; return object
				end
			end
		end
		local getter = env.getnilinstances or getnilinstances
		if type(getter) == "function" then
			for _, object in ipairs(getter()) do
				if object.Name == name and object:IsA("BasePart") and (object.Position - position).Magnitude < 2 then
					SwordGet.PartCache[key] = { Part = object, At = os.clock() }; return object
				end
			end
		end
		SwordGet.PartCache[key] = { At = os.clock() }
	end

	function SwordGet.CanHop(request)
		local controller = SwordGet.States[request.Owner]
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		return workflowActive(request.Owner) and controller.Request == request and controller.Epoch == request.Epoch
			and game.PlaceId == request.PlaceId and currentSea() == 3 and humanoid and humanoid.Health > 0
			and not BossFarm.HasProtectedItem() and not hasItem("Holy Torch")
	end

	function SwordGet.HopNeeded(request)
		if request.Owner == "CDK" then return SwordGet.CDK.HopNeeded(request.Mode) end
		if request.Mode == "Elite" then
			return SwordGet.EliteProgress(true) < 30 and not SwordGet.FindLive(SwordGet.Elites) and not SwordGet.FindHint(SwordGet.Elites)
		end
		local progress = SwordGet.TushitaProgress(true)
		if request.Mode == "Longma" then
			return progress.OpenedDoor and not SwordGet.FindLive({ "Longma" }) and not SwordGet.FindHint({ "Longma" })
		end
		local names = BossFarm.Definitions["Rip Indra"].Names
		return SwordGet.States.Tushita.HydraReady and not progress.OpenedDoor and not hasItem("Holy Torch")
			and not SwordGet.FindLive(names) and not SwordGet.FindHint(names)
	end

	function SwordGet.PublicServer(id, data)
		local job = BossFarm.DecodeJobId(id)
		if not job or job == game.JobId then return end
		local visited = state.BossVisited[job]
		if type(visited) == "number" and os.time() - visited < BossFarm.VisitedSeconds then return end
		state.BossVisited[job] = nil
		if type(data) == "table" then
			local playing = tonumber(data.playing or data.Count or data.PlayerCount)
			local maximum = tonumber(data.maxPlayers or data.MaxPlayers)
			if playing and maximum and playing >= maximum then return end
		end
		return job
	end

	function SwordGet.PublicHopJob(browser, request)
		for page = 1, 5 do
			if not SwordGet.CanHop(request) then return end
			local ok, servers = pcall(function() return browser:InvokeServer(page) end)
			if not SwordGet.CanHop(request) then return end
			if not ok or type(servers) ~= "table" or next(servers) == nil then break end
			for id, server in pairs(servers) do
				local job = SwordGet.PublicServer(type(server) == "table" and (server.id or server.JobId or id) or id, server)
				if job then return job end
			end
		end
		local cursor
		for _ = 1, 10 do
			if not SwordGet.CanHop(request) then return end
			local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId)
			if cursor then url ..= "&cursor=" .. HttpService:UrlEncode(cursor) end
			local data = HttpService:JSONDecode(game:HttpGet(url))
			if not SwordGet.CanHop(request) then return end
			assert(type(data) == "table" and type(data.data) == "table", "Public server list is unavailable")
			for _, server in ipairs(data.data) do
				local job = SwordGet.PublicServer(server.id, server)
				if job then return job end
			end
			cursor = data.nextPageCursor
			if not cursor then return end
		end
	end

	function SwordGet.Hop(name, mode)
		local controller = SwordGet.States[name]
		if controller.Request then
			if controller.Request.Mode ~= mode or os.clock() - controller.Request.Started >= BossFarm.TeleportTimeout then
				SwordGet.Cancel(name); controller.NextHop = os.clock() + BossFarm.RetrySeconds
				SwordGet.SetStatus(name, "Server search/teleport timed out; retrying")
			end
			return
		end
		if BossFarm.HasProtectedItem() or hasItem("Holy Torch") then SwordGet.SetStatus(name, "Hop paused: carrying a protected item"); return end
		controller.MissingSince = controller.MissingSince or os.clock()
		if os.clock() - controller.MissingSince < BossFarm.MissingGrace or os.clock() < (controller.NextHop or 0) then
			SwordGet.SetStatus(name, "Waiting for " .. mode .. " spawn / server retry"); return
		end
		local request = { Owner = name, Mode = mode, Epoch = controller.Epoch, PlaceId = game.PlaceId, Started = os.clock() }
		controller.Request = request; state.HopPending = true
		SwordGet.SetStatus(name, mode == "Indra" and "Searching Rip Indra API"
			or mode == "CastleRaid" and "Searching Castle Raid API" or "Searching public servers for " .. mode)
		task.spawn(function()
			local ok, message = xpcall(function()
				local browser = ReplicatedStorage:FindFirstChild("__ServerBrowser")
				assert(browser and browser:IsA("RemoteFunction"), "Server browser is unavailable")
				local job
				if mode == "Indra" then
					local servers = BossFarm.FetchServers("ripindra")
					if not SwordGet.CanHop(request) then return "Server search cancelled" end
					job = BossFarm.SelectServer(servers, BossFarm.Definitions["Rip Indra"])
				elseif mode == "CastleRaid" then
					local servers = BossFarm.FetchServers("castleraid")
					if not SwordGet.CanHop(request) then return "Server search cancelled" end
					job = BossFarm.SelectServer(servers, { Slug = "castleraid", Names = { "Castle Raid", "Pirate Raid", "Pirate / Castle Raid" } })
				else job = SwordGet.PublicHopJob(browser, request) end
				if not SwordGet.CanHop(request) then return "Server search cancelled" end
				if not job then return "No suitable server found; retrying" end
				local snapshot = TTK.Snapshot(true)
				if not SwordGet.CanHop(request) or snapshot.Owned[controller.InventoryKey or name] then return "Server search cancelled: sword owned or stopped" end
				if not SwordGet.HopNeeded(request) then return "Goal changed; staying in this server" end
				if not SwordGet.CanHop(request) then return "Server search cancelled" end
				queueResume()
				if not SwordGet.CanHop(request) then return "Server search cancelled" end
				state.BossVisited[job] = os.time(); state.BossVisited[game.JobId] = os.time()
				request.Teleport = true; request.Started = os.clock()
				SwordGet.SetStatus(name, "Hopping for " .. mode)
				assert(browser:InvokeServer("teleport", job) ~= false, "Server teleport was rejected")
			end, debug.traceback)
			if state.Generation ~= generation or controller.Request ~= request then return end
			if ok and request.Teleport then return end
			controller.Request = nil; state.HopPending = false; controller.NextHop = os.clock() + BossFarm.RetrySeconds
			SwordGet.SetStatus(name, ok and (message or "Server search cancelled") or "Server search error; see console")
			if not ok then reportControllerError(message, name, "ServerHop") end
		end)
	end

	function SwordGet.Yama()
		local controller = SwordGet.States.Yama
		local progress = SwordGet.EliteProgress()
		if not workflowActive("Yama") then return end
		if progress < 30 then
			if controller.Target and not isAlive(controller.Target) then
				controller.Target = nil; controller.ProgressAt = -math.huge; controller.RewardUntil = os.clock() + 2
			end
			if os.clock() < (controller.RewardUntil or 0) then stopFastAttack(); cleanupMovement(); return end
			local boss = SwordGet.FindLive(SwordGet.Elites)
			local hint = not boss and SwordGet.FindHint(SwordGet.Elites)
			local target = boss or hint
			if not target then stopFastAttack(); cleanupMovement(); SwordGet.Hop("Yama", "Elite"); return end
			if controller.Request then SwordGet.Cancel("Yama") end
			controller.MissingSince = nil
			local quest = SwordGet.QuestData()
			if not SwordGet.QuestMatches(quest, target.Name) then
				stopFastAttack(); cleanupMovement()
				SwordGet.SetStatus("Yama", "Accepting Elite quest: " .. cleanMobName(target.Name) .. " (" .. progress .. "/30)")
				if os.clock() - (controller.LastQuest or 0) >= 2 then
					controller.LastQuest = os.clock()
					if quest then invokeCommF("AbandonQuest")
					else invokeCommF("EliteHunter") end
				end
				return
			end
			if boss then
				controller.Target = boss
				SwordGet.SetStatus("Yama", "Elite " .. progress .. "/30: fighting " .. cleanMobName(boss.Name))
				fightMob(boss)
			else
				SwordGet.SetStatus("Yama", "Approaching Elite / waiting for replication")
				moveTo(uprightCFrame(hint.HumanoidRootPart.CFrame) * CFrame.new(Config.OrderOffset))
			end
			return
		end
		if controller.Request then SwordGet.Cancel("Yama") end
		local map = workspace:FindFirstChild("Map")
		local waterfall = map and map:FindFirstChild("Waterfall")
		local katana = waterfall and waterfall:FindFirstChild("SealedKatana")
		local hitbox = katana and katana:FindFirstChild("Hitbox") or SwordGet.MapPart("Hitbox", SwordGet.YamaRoom.Position)
		local position = hitbox and hitbox:IsA("BasePart") and hitbox.CFrame or SwordGet.YamaRoom
		local root = getRoot()
		if (root.Position - position.Position).Magnitude > 40 then
			stopFastAttack(); SwordGet.SetStatus("Yama", "Elite 30/30: approaching Sealed Katana"); moveTo(position); return
		end
		local ghost = SwordGet.FindLive({ "Ghost" })
		if ghost and (ghost.HumanoidRootPart.Position - position.Position).Magnitude < 150 then
			SwordGet.SetStatus("Yama", "Clearing Sealed Katana ghosts"); fightMob(ghost); return
		end
		stopFastAttack()
		if (root.Position - position.Position).Magnitude > 8 then moveTo(position); return end
		cleanupMovement()
		local click = hitbox and hitbox:FindFirstChildOfClass("ClickDetector")
		if not click then SwordGet.SetStatus("Yama", "Waiting for Sealed Katana ClickDetector"); return end
		local fire = env.fireclickdetector or fireclickdetector
		assert(type(fire) == "function", "Executor fireclickdetector is unavailable")
		SwordGet.SetStatus("Yama", "Pulling Yama; waiting for inventory confirmation")
		if os.clock() - (controller.LastPull or 0) >= 1 and workflowActive("Yama") then
			controller.LastPull = os.clock(); fire(click); TTK.ReadAt = -math.huge
		end
	end

	function SwordGet.TouchHydra(part)
		local controller = SwordGet.States.Tushita
		local root = getRoot()
		local fire = env.firetouchinterest or firetouchinterest
		if type(fire) ~= "function" then return end
		if os.clock() - (controller.LastTouch or 0) < 1 then return end
		controller.LastTouch = os.clock()
		if not workflowActive("Tushita") then return end
		fire(root, part, 0)
		task.wait()
		local ok, err = pcall(fire, root, part, 1)
		if not ok then error(err) end
	end

	function SwordGet.Tushita()
		local controller = SwordGet.States.Tushita
		local progress = SwordGet.TushitaProgress()
		if not workflowActive("Tushita") then return end
		if progress.OpenedDoor then
			if controller.Request and controller.Request.Mode ~= "Longma" then SwordGet.Cancel("Tushita") end
			if controller.Target and not isAlive(controller.Target) then
				controller.Target = nil; controller.RewardUntil = os.clock() + 5; TTK.ReadAt = -math.huge
			end
			if os.clock() < (controller.RewardUntil or 0) then
				stopFastAttack(); cleanupMovement(); SwordGet.SetStatus("Tushita", "Waiting for Tushita drop / inventory replication"); return
			end
			local boss = SwordGet.FindLive({ "Longma" })
			local hint = not boss and SwordGet.FindHint({ "Longma" })
			if boss or hint then
				if controller.Request then SwordGet.Cancel("Tushita") end
				controller.MissingSince = nil
				if boss then controller.Target = boss; SwordGet.SetStatus("Tushita", "Door open: fighting Longma"); fightMob(boss)
				else SwordGet.SetStatus("Tushita", "Approaching Longma / waiting for replication"); moveTo(hint.HumanoidRootPart.CFrame * CFrame.new(Config.OrderOffset)) end
				return
			end
			stopFastAttack()
			if (getRoot().Position - SwordGet.LongmaRoom.Position).Magnitude > 80 then
				SwordGet.SetStatus("Tushita", "Door open: approaching Longma room"); moveTo(SwordGet.LongmaRoom); return
			end
			cleanupMovement(); SwordGet.Hop("Tushita", "Longma"); return
		end
		if hasItem("Holy Torch") then
			if controller.Request then SwordGet.Cancel("Tushita") end
			stopFastAttack()
			assert(equipItem("Holy Torch"), "Holy Torch could not be equipped")
			local nextTorch
			for i = 1, 5 do if progress.Torches[i] ~= true then nextTorch = i; break end end
			if not nextTorch then SwordGet.SetStatus("Tushita", "Torches 5/5: waiting for door confirmation"); cleanupMovement(); return end
			local part = SwordGet.MapPart("Torch" .. nextTorch, SwordGet.Torches[nextTorch].Position)
			local position = part and part.CFrame or SwordGet.Torches[nextTorch]
			SwordGet.SetStatus("Tushita", "Lighting torch " .. nextTorch .. "/5")
			if (getRoot().Position - position.Position).Magnitude > 8 then moveTo(position); return end
			cleanupMovement()
			if os.clock() - (controller.LastTorch or 0) >= 1 and workflowActive("Tushita") then
				controller.LastTorch = os.clock(); invokeCommF("TushitaProgress", "Torch", nextTorch); controller.ProgressAt = -math.huge
			end
			return
		end
		local hitbox = SwordGet.MapPart("Hitbox", SwordGet.HydraGate.Position)
		local position = hitbox and hitbox.CFrame or SwordGet.HydraGate
		if not controller.HydraReady then
			SwordGet.SetStatus("Tushita", "Approaching Hydra gate before Rip Indra search")
			if (getRoot().Position - position.Position).Magnitude > 8 then moveTo(position); return end
			controller.HydraReady = true; cleanupMovement()
		end
		local names = BossFarm.Definitions["Rip Indra"].Names
		local indra = SwordGet.FindLive(names) or SwordGet.FindHint(names)
		if not indra then stopFastAttack(); cleanupMovement(); SwordGet.Hop("Tushita", "Indra"); return end
		if controller.Request then SwordGet.Cancel("Tushita") end
		controller.MissingSince = nil
		SwordGet.SetStatus("Tushita", "Rip Indra found: entering Hydra gate for Holy Torch")
		if (getRoot().Position - position.Position).Magnitude > 3 then moveTo(position); return end
		cleanupMovement()
		if hitbox and hitbox:FindFirstChild("TouchInterest") then SwordGet.TouchHydra(hitbox)
		else SwordGet.SetStatus("Tushita", "Waiting for Hydra gate activation / replication") end
	end

	SwordGet.Step = LPH_JIT(function(name)
		if not workflowActive(name) then return end
		local snapshot = TTK.Snapshot()
		if not workflowActive(name) then return end
		if snapshot.Owned[SwordGet.States[name].InventoryKey or name] then SwordGet.Complete(name); return end
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if not getRoot() or not humanoid or humanoid.Health <= 0 then
			stopFastAttack(); cleanupMovement(); SwordGet.SetStatus(name, "Waiting for character"); return
		end
		if name == "CDK" and (not snapshot.Owned.Yama or not snapshot.Owned.Tushita) then
			SwordGet.CDK.Step(snapshot); return
		end
		if name == "Tushita" and player.Data.Level.Value < 2000 then SwordGet.SetStatus(name, "Tushita requires level 2000 or higher"); return end
		if not travelToSea3() then SwordGet.SetStatus(name, "Travelling to Sea 3"); return end
		if name == "CDK" then SwordGet.CDK.Step(snapshot)
		elseif name == "Yama" then SwordGet.Yama() else SwordGet.Tushita() end
	end)
end

do
	local CDK = SwordGet.CDK
	local controller = SwordGet.States.CDK

	function CDK.Plan(snapshot, training, available, choose)
		if snapshot.Owned["Cursed Dual Katana"] then return "Complete" end
		for _, sword in ipairs(CDK.Swords) do if not snapshot.Owned[sword] then return "Missing", sword end end
		local pending = {}
		for _, sword in ipairs(CDK.Swords) do
			if (snapshot.Mastery[sword] or 0) < CDK.RequiredMastery then pending[#pending + 1] = sword end
		end
		if #pending == 0 then return "Trials" end
		if table.find(pending, training) then return "Mastery", training end
		for _, sword in ipairs(available or {}) do if table.find(pending, sword) then return "Mastery", sword end end
		return "Mastery", pending[(choose or math.random)(1, #pending)]
	end

	function CDK.AvailableSwords()
		local swords = {}
		local containers = {}
		if player.Character then containers[#containers + 1] = player.Character end
		local backpack = player:FindFirstChild("Backpack")
		if backpack then containers[#containers + 1] = backpack end
		for _, container in ipairs(containers) do
			for _, tool in ipairs(container:GetChildren()) do
				local sword = tool:IsA("Tool") and TTK.Canonical(tool.Name)
				if table.find(CDK.Swords, sword) and not table.find(swords, sword) then swords[#swords + 1] = sword end
			end
		end
		return swords
	end

	function CDK.Progress(force, side)
		if force or not controller.Progress or os.clock() - (controller.ProgressAt or 0) >= 2 then
			local progress = invokeCommF("CDKQuest", "Progress", side or "Good")
			assert(type(progress) == "table" and type(progress.Good) == "number" and type(progress.Evil) == "number",
				"CDK progress is unavailable")
			controller.Progress = progress; controller.ProgressAt = os.clock()
		end
		return controller.Progress
	end

	function CDK.Map(name)
		local map = workspace:FindFirstChild("Map")
		if name == "Cursed" then
			local turtle = map and map:FindFirstChild("Turtle")
			return turtle and turtle:FindFirstChild("Cursed")
		end
		return map and map:FindFirstChild(name)
	end

	function CDK.Approach(position, radius)
		if not workflowActive("CDK") then return false end
		if (getRoot().Position - position.Position).Magnitude > (radius or 8) then moveTo(position); return false end
		cleanupMovement(); return true
	end

	function CDK.Remote(key, ...)
		if not workflowActive("CDK") then return end
		controller.Remotes = controller.Remotes or {}
		if os.clock() - (controller.Remotes[key] or -math.huge) < 2 then return end
		controller.Remotes[key] = os.clock()
		local result = invokeCommF(...)
		controller.ProgressAt = -math.huge
		return result
	end

	function CDK.Prompt(part)
		if not part or not part:IsA("BasePart") then return false end
		if not CDK.Approach(part.CFrame, 6) then return false end
		local prompt = part:FindFirstChildOfClass("ProximityPrompt")
		if not prompt or not prompt.Enabled then return false end
		if os.clock() - (controller.LastPrompt or -math.huge) < 1.5 then return false end
		local fire = env.fireproximityprompt or fireproximityprompt
		assert(type(fire) == "function", "Executor fireproximityprompt is unavailable")
		controller.LastPrompt = os.clock()
		if workflowActive("CDK") then fire(prompt); controller.ProgressAt = -math.huge; return true end
		return false
	end

	function CDK.Spawn(name, fallback)
		local origin = workspace:FindFirstChild("_WorldOrigin")
		local spawns = origin and origin:FindFirstChild("EnemySpawns")
		local nearest, distance
		if spawns then
			for _, part in ipairs(spawns:GetChildren()) do
				if BossFarm.Matches(part.Name, { Names = { name } }) then
					local cf = part:IsA("BasePart") and part.CFrame or part:IsA("Model") and part:GetPivot()
					local d = cf and (getRoot().Position - cf.Position).Magnitude
					if d and (not distance or d < distance) then nearest, distance = cf, d end
				end
			end
		end
		return nearest or fallback
	end

	function CDK.NearbyMob(center, radius, filter, hints)
		local root = getRoot()
		local folder = hints and ReplicatedStorage or workspace:FindFirstChild("Enemies")
		local nearest, distance
		for _, mob in ipairs(folder and folder:GetChildren() or {}) do
			if isAlive(mob) and (mob.HumanoidRootPart.Position - center).Magnitude <= radius and (not filter or filter(mob)) then
				local d = (root.Position - mob.HumanoidRootPart.Position).Magnitude
				if not distance or d < distance then nearest, distance = mob, d end
			end
		end
		return nearest
	end

	function CDK.InDimension(name)
		local dimension = CDK.Map(name)
		if not dimension then return end
		local members = dimension:FindFirstChild("ActivePlayers")
		if members then
			local belongs = false
			for _, entry in ipairs(members:GetChildren()) do
				if entry:IsA("ValueBase") and (entry.Value == player or tostring(entry.Value) == player.Name) then belongs = true; break end
			end
			if not belongs then return end
		end
		local origin = workspace:FindFirstChild("_WorldOrigin")
		local locations = origin and origin:FindFirstChild("Locations")
		local location = locations and locations:FindFirstChild(name == "HellDimension" and "Hell Dimension" or "Heavenly Dimension")
		local position = location and location.Position or dimension and dimension:GetPivot().Position
		return dimension and position and (getRoot().Position - position).Magnitude < 1000 and dimension or nil
	end

	function CDK.ClearDamage()
		controller.TakingDamage = nil
		if controller.RestoreObservation then
			local observation = controller.RestoreObservation
			controller.RestoreObservation = nil
			local ok, err = pcall(function()
				observation:setActive(true)
				ReplicatedStorage.Remotes.CommE:FireServer("Ken", true)
			end)
			if not ok then reportControllerError(err, "CDK", "RestoreObservation") end
		end
	end

	function CDK.TakeDamage(mob, fallback)
		controller.TakingDamage = true
		stopFastAttack(); state.TTKWeapon = nil
		if not mob then CDK.Approach(fallback, 12); return end
		SwordGet.SetStatus("CDK", "Receiving damage from " .. cleanMobName(mob.Name) .. "; attacks paused")
		local global = ReplicatedStorage:FindFirstChild("Global")
		local observation = global and require(global).OM
		if observation and observation.active then
			controller.RestoreObservation = observation
			observation:setActive(false); ReplicatedStorage.Remotes.CommE:FireServer("Ken", false)
		end
		player.Character:FindFirstChildOfClass("Humanoid"):UnequipTools()
		CDK.Approach(uprightCFrame(mob.HumanoidRootPart.CFrame) * CFrame.new(0, 0, -3), 4)
	end

	function CDK.OpenRoom(snapshot)
		if controller.DoorOpened then return true end
		SwordGet.SetStatus("CDK", "Opening cursed room behind the mansion")
		local check = CDK.Remote("CheckDoor", "CDKQuest", "OpenDoor")
		if not workflowActive("CDK") then return false end
		if check ~= nil then controller.DoorCheck = check end
		if controller.DoorCheck == "opened" then controller.DoorOpened = true; return true end
		if controller.DoorCheck ~= "can" then SwordGet.SetStatus("CDK", "Waiting for cursed room requirements / server confirmation"); return false end
		local npc = workspace:FindFirstChild("NPCs") and workspace.NPCs:FindFirstChild("Crypt Master")
		local position = npc and npc:GetPivot() or CDK.Manor
		stopFastAttack()
		if not CDK.Approach(position, 10) then return false end
		if not TTK.EnsureSword(snapshot, "Tushita") then return false end
		local result = CDK.Remote("OpenDoor", "CDKQuest", "OpenDoor", true)
		if not workflowActive("CDK") then return false end
		if result == true or result == "opened" then controller.DoorOpened = true end
		return controller.DoorOpened == true
	end

	function CDK.BeginTrial(side)
		stopFastAttack()
		local progress = CDK.Progress(true, side)
		if not workflowActive("CDK") then return end
		if progress[side] >= 0 and progress[side] < 3 then
			cleanupMovement()
			SwordGet.SetStatus("CDK", "Starting " .. side .. " trial remotely")
			CDK.Remote("Start" .. side, "CDKQuest", "StartTrial", side)
		elseif progress[side] == 3 then
			local room = CDK.Map("Cursed")
			local pedestal = room and room:FindFirstChild(side == "Good" and "Pedestal1" or "Pedestal2")
			SwordGet.SetStatus("CDK", "Completing " .. side .. " scroll")
			if not CDK.Approach(pedestal and pedestal.CFrame or CDK.Room, 8) then return end
			CDK.Prompt(pedestal)
		end
	end

	function CDK.Boats()
		stopFastAttack()
		controller.Boats = controller.Boats or {}
		local candidates = {}
		for _, folder in pairs({ World = workspace:FindFirstChild("NPCs"), Stored = ReplicatedStorage:FindFirstChild("NPCs") }) do
			for _, npc in ipairs(folder:GetChildren()) do
				if npc:IsA("Model") and npc.Name:match("Boat Dealer$") then
					local cf = npc:GetPivot(); local key = tostring(cf.Position)
					if not controller.Boats[key] then candidates[#candidates + 1] = { NPC = npc, Position = cf, Key = key } end
				end
			end
		end
		table.sort(candidates, function(a, b)
			return (a.Position.Position - getRoot().Position).Magnitude < (b.Position.Position - getRoot().Position).Magnitude
		end)
		local target = candidates[1]
		SwordGet.SetStatus("CDK", "Good trial 1: visiting boat dealers")
		if not target then
			controller.BoatIndex = controller.BoatIndex or 1
			if not CDK.Approach(CFrame.new(CDK.BoatSpawns[controller.BoatIndex]), 10) then return end
			controller.BoatWait = controller.BoatWait or os.clock()
			if os.clock() - controller.BoatWait >= 3 then
				controller.BoatIndex = controller.BoatIndex % #CDK.BoatSpawns + 1; controller.BoatWait = nil
				if controller.BoatIndex == 1 then controller.Boats = {} end
			end
			return
		end
		if not CDK.Approach(target.Position, 8) then return end
		if os.clock() - (controller.LastBoat or -math.huge) < 2 then return end
		controller.LastBoat = os.clock()
		local eligible = invokeCommF("CDKQuest", "BoatQuest", target.NPC, "Check")
		if not workflowActive("CDK") then return end
		if eligible then invokeCommF("CDKQuest", "BoatQuest", target.NPC) end
		controller.Boats[target.Key] = true; controller.ProgressAt = -math.huge
	end

	function CDK.CastleMob(hints)
		return CDK.NearbyMob(CDK.Castle.Position, 1000, function(mob)
			return not mob.Name:find("Boss") and not mob.Name:find("Friend") and not mob.Name:find("Wraith")
				and mob.Name ~= "Oni2" and mob.Name ~= "rip_indra True Form"
		end, hints)
	end

	function CDK.CastleRaid()
		SwordGet.SetStatus("CDK", "Good trial 2: clearing Castle pirate raid")
		local mob = CDK.CastleMob()
		if mob then
			if controller.Request then SwordGet.Cancel("CDK") end
			controller.RaidWait = nil; controller.MissingSince = nil; fightMob(mob); return
		end
		stopFastAttack()
		local hint = CDK.CastleMob(true)
		if hint then
			if controller.Request then SwordGet.Cancel("CDK") end
			controller.RaidWait = nil; controller.MissingSince = nil; moveTo(hint.HumanoidRootPart.CFrame); return
		end
		if not CDK.Approach(CDK.Castle, 150) then return end
		controller.RaidWait = controller.RaidWait or os.clock()
		local remaining = 15 - (os.clock() - controller.RaidWait)
		if remaining > 0 then
			SwordGet.SetStatus("CDK", "Waiting for Castle Raid pirates (" .. math.ceil(remaining) .. "s before API hop)")
			return
		end
		controller.MissingSince = controller.RaidWait
		SwordGet.Hop("CDK", "CastleRaid")
	end

	function CDK.Dimension(name)
		local dimension = CDK.InDimension(name)
		if not dimension then return false end
		CDK.ClearDamage()
		local exit = dimension:FindFirstChild("Exit")
		local ready = exit and exit:IsA("BasePart") and (#exit:GetChildren() >= 2
			or exit.BrickColor == BrickColor.new(name == "HellDimension" and "Olivine" or "Cloudy grey"))
		if ready then
			stopFastAttack(); SwordGet.SetStatus("CDK", name .. ": leaving through exit"); CDK.Approach(exit.CFrame, 1); return true
		end
		local mob = CDK.NearbyMob(getRoot().Position, 1200)
		if mob then SwordGet.SetStatus("CDK", name .. ": clearing trial enemies"); fightMob(mob); return true end
		stopFastAttack()
		for i = 1, 3 do
			local torch = dimension:FindFirstChild("Torch" .. i)
			local prompt = torch and torch:FindFirstChildOfClass("ProximityPrompt")
			local particles = torch and torch:FindFirstChild("Particles")
			local main = particles and particles:FindFirstChild("Main")
			if prompt and prompt.Enabled and (not main or not main.Enabled) then
				SwordGet.SetStatus("CDK", name .. ": activating torch " .. i .. "/3"); CDK.Prompt(torch); return true
			end
		end
		SwordGet.SetStatus("CDK", name .. ": waiting for enemy wave / exit")
		return true
	end

	function CDK.Queen()
		if CDK.Dimension("HeavenlyDimension") then return end
		local boss = SwordGet.FindLive({ "Cake Queen" })
		local hint = not boss and SwordGet.FindHint({ "Cake Queen" })
		if boss or hint then
			if controller.Request then SwordGet.Cancel("CDK") end
			controller.MissingSince = nil
			SwordGet.SetStatus("CDK", "Good trial 3: defeating Cake Queen")
			if boss then
				controller.Target = boss; fightMob(boss)
			else moveTo(hint.HumanoidRootPart.CFrame * CFrame.new(Config.OrderOffset)) end
			return
		end
		if controller.Target and not isAlive(controller.Target) then
			controller.Target = nil; controller.DimensionWait = os.clock() + 8
		end
		stopFastAttack()
		if os.clock() < (controller.DimensionWait or 0) then
			cleanupMovement(); SwordGet.SetStatus("CDK", "Waiting for Heavenly Dimension teleport"); return
		end
		if not CDK.Approach(CDK.Spawn("Cake Queen", CDK.QueenSpawn), 100) then return end
		SwordGet.Hop("CDK", "CakeQueen")
	end

	function CDK.Haze()
		local quest = player:FindFirstChild("QuestHaze")
		if not quest then
			stopFastAttack(); cleanupMovement(); SwordGet.SetStatus("CDK", "Waiting for QuestHaze"); return
		end
		local targetNames = {}
		for _, value in ipairs(quest:GetChildren()) do
			if value:IsA("ValueBase") and (tonumber(value.Value) or 0) > 0 then
				targetNames[#targetNames + 1] = value.Name
			end
		end
		if #targetNames == 0 then stopFastAttack(); cleanupMovement(); controller.ProgressAt = -math.huge; return end
		local root = getRoot()
		local definition = { Names = targetNames }
		local mob = CDK.NearbyMob(root.Position, math.huge, function(enemy)
			return BossFarm.Matches(enemy.Name, definition) and enemy:FindFirstChild("HazeESP") ~= nil
		end)
		if mob then
			SwordGet.SetStatus("CDK", "Evil trial 2: clearing nearest Haze enemy: " .. mob.Name)
			fightMob(mob); return
		end
		stopFastAttack()
		local position, targetName, nearestDistance
		for _, name in ipairs(targetNames) do
			local spawn = CDK.Spawn(name)
			local distance = spawn and (root.Position - spawn.Position).Magnitude
			if distance and (not nearestDistance or distance < nearestDistance) then
				position, targetName, nearestDistance = spawn, name, distance
			end
		end
		if position then
			SwordGet.SetStatus("CDK", "Approaching nearest Haze spawn: " .. targetName)
			moveTo(position + Vector3.new(0, 18, 0))
		else
			cleanupMovement(); SwordGet.SetStatus("CDK", "Waiting for Haze enemy spawns")
		end
	end

	function CDK.Reaper(snapshot)
		if CDK.Dimension("HellDimension") then return end
		local reaper = SwordGet.FindLive({ "Soul Reaper" })
		if reaper then CDK.TakeDamage(reaper); return end
		CDK.ClearDamage(); stopFastAttack()
		if hasItem("Hallow Essence") then
			local detection = SwordGet.MapPart("Detection", CDK.Summoner.Position)
			local position = detection and detection.CFrame or CDK.Summoner
			SwordGet.SetStatus("CDK", "Evil trial 3: summoning Soul Reaper with Hallow Essence")
			if not CDK.Approach(position, 3) then return end
			assert(equipItem("Hallow Essence"), "Hallow Essence disappeared before summon")
			local fire = env.firetouchinterest or firetouchinterest
			if detection and type(fire) == "function" and os.clock() - (controller.LastSummon or -math.huge) >= 2 then
				controller.LastSummon = os.clock()
				fire(getRoot(), detection, 0); fire(getRoot(), detection, 1)
			end
			return
		end
		local hint = SwordGet.FindHint({ "Soul Reaper" })
		if hint then moveTo(hint.HumanoidRootPart.CFrame); SwordGet.SetStatus("CDK", "Waiting for Soul Reaper replication"); return end
		if os.clock() - (controller.BonesAt or -math.huge) >= 2 then
			controller.Bones = invokeCommF("Bones", "Check"); controller.BonesAt = os.clock()
		end
		local bones = controller.Bones
		if not workflowActive("CDK") then return end
		if type(bones) == "number" and bones >= 50 then
			SwordGet.SetStatus("CDK", "Rolling Bones for Hallow Essence")
			CDK.Remote("BonesRoll", "Bones", "Buy", 1, 1); return
		end
		TTK.FarmBones(snapshot, "Yama", nil, "CDK")
	end

	function CDK.FinalReady(progress)
		return type(progress) == "table" and type(progress.Good) == "number" and type(progress.Evil) == "number"
			and progress.Good >= 3 and progress.Evil >= 3
	end

	function CDK.FinalPartPosition(object)
		if not object then return nil end
		if object:IsA("BasePart") then return object.CFrame end
		if object:IsA("Model") then return object:GetPivot() end
	end

	function CDK.FinalDialogue(session)
		if os.clock() > (session.DialogueUntil or 0) or os.clock() < (session.NextDialogue or 0) then return end
		local gui = player:FindFirstChild("PlayerGui")
		local main = gui and gui:FindFirstChild("Main")
		local dialogue = main and main:FindFirstChild("Dialogue")
		if not dialogue or not dialogue.Visible then return end
		session.NextDialogue = os.clock() + 0.5
		local frame = dialogue:FindFirstChild("TextFrame") or dialogue
		local point = frame.AbsolutePosition + frame.AbsoluteSize / 2
		local input = game:GetService("VirtualUser")
		input:Button1Down(point)
		input:Button1Up(point)
	end

	function CDK.Final(snapshot, progress)
		if not workflowActive("CDK") then return end
		if snapshot.Owned["Cursed Dual Katana"] then SwordGet.Complete("CDK"); return end
		local character, root = player.Character, getRoot()
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not root or not humanoid or humanoid.Health <= 0 then return end
		progress = progress or CDK.Progress()
		if not workflowActive("CDK") or not CDK.FinalReady(progress) then return end
		local session = controller.Final
		if not session or session.JobId ~= game.JobId or session.Character ~= character or session.Epoch ~= controller.Epoch then
			stopFastAttack(); cleanupMovement()
			session = { JobId = game.JobId, Character = character, Epoch = controller.Epoch, Stage = "Scrolls" }
			controller.Final = session
		end
		local function active()
			return workflowActive("CDK") and controller.Final == session and controller.Epoch == session.Epoch
				and player.Character == character and getRoot() == root and humanoid.Health > 0
		end
		CDK.FinalDialogue(session)
		local sword = CDK.AvailableSwords()[1] or "Tushita"
		if not TTK.EnsureSword(snapshot, sword) or not active() then return end
		local boss = SwordGet.FindLive({ "Cursed Skeleton Boss" })
		if boss then
			session.Stage, session.Target, session.BossSeen = "Fight", boss, true
			session.MissingBossSince = nil
			SwordGet.SetStatus("CDK", "Final: fighting Cursed Skeleton Boss with " .. sword)
			fightMob(boss); return
		end
		stopFastAttack()
		local previousHumanoid = session.Target and session.Target:FindFirstChildOfClass("Humanoid")
		if session.BossSeen and previousHumanoid and previousHumanoid.Health <= 0 then
			session.Target, session.BossSeen = nil, nil
			session.Stage, session.RewardUntil = "Reward", os.clock() + 5
			TTK.ReadAt = -math.huge
		end
		if session.BossSeen then
			session.MissingBossSince = session.MissingBossSince or os.clock()
			if os.clock() - session.MissingBossSince < 10 then
				cleanupMovement(); SwordGet.SetStatus("CDK", "Final: waiting for boss replication / reward confirmation"); return
			end
			session.Target, session.BossSeen = nil, nil
			session.Stage = "Approach"
		end
		if session.Stage == "Reward" then
			cleanupMovement()
			SwordGet.SetStatus("CDK", "Final: checking inventory for Cursed Dual Katana")
			if os.clock() < session.RewardUntil then return end
			local owned = TTK.Snapshot(true)
			if not active() then return end
			if owned.Owned["Cursed Dual Katana"] then SwordGet.Complete("CDK"); return end
			session.Stage, session.NextStart = "Approach", os.clock() + 3
		end
		local room = CDK.Map("Cursed")
		if not room then
			SwordGet.SetStatus("CDK", "Final: loading cursed room behind the mansion")
			if CDK.Approach(CDK.Room, 8) and os.clock() >= (session.NextStream or 0) then
				session.NextStream = os.clock() + 8
				task.spawn(function() pcall(function() player:RequestStreamAroundAsync(CDK.Room.Position, 5) end) end)
			end
			return
		end
		for _, side in ipairs({ "Good", "Evil" }) do
			if progress[side] == 3 then
				session.Stage = "Scrolls"
				SwordGet.SetStatus("CDK", "Final: claiming last " .. side .. " scroll reward")
				local pedestal = room:FindFirstChild(side == "Good" and "Pedestal1" or "Pedestal2", true)
				if not CDK.Approach(CDK.FinalPartPosition(pedestal) or CDK.Room, 6) then return end
				if os.clock() < (session.NextScroll or 0) then return end
				session.NextScroll = os.clock() + 2
				local updated = CDK.Progress(true, side)
				if not active() then return end
				if updated[side] == 3 and CDK.Prompt(pedestal) then session.DialogueUntil = os.clock() + 5 end
				return
			end
		end
		local skeleton = SwordGet.FindLive({ "Cursed Skeleton" })
		local skeletonRoot = skeleton and skeleton:FindFirstChild("HumanoidRootPart")
		if skeletonRoot and (skeletonRoot.Position - CDK.BossRoom.Position).Magnitude <= 200 then
			SwordGet.SetStatus("CDK", "Final: clearing Cursed Skeletons in the boss chamber")
			fightMob(skeleton); return
		end
		local pedestal = room:FindFirstChild("Pedestal3", true)
		local position = CDK.FinalPartPosition(pedestal)
		if session.Stage == "Scrolls" then session.Stage = "Approach" end
		if session.Stage == "Approach" then
			SwordGet.SetStatus("CDK", "Final: approaching Alucard Gem pedestal")
			if not CDK.Approach(position or CDK.Room, 6) then return end
			if not pedestal then SwordGet.SetStatus("CDK", "Final: waiting for Pedestal3 replication"); return end
			if os.clock() < (session.NextStart or 0) then return end
			local result = CDK.Remote("BossTrial", "CDKQuest", "StartTrial", "Boss")
			if not active() then return end
			session.NextStart = os.clock() + 8
			if result == false then
				SwordGet.SetStatus("CDK", "Final: boss trial rejected; rechecking scroll rewards")
				controller.ProgressAt = -math.huge; return
			end
			session.Stage, session.StartedAt = "WaitDoor", os.clock()
			session.DialogueUntil = os.clock() + 5
		end
		local gem = room:FindFirstChild("PlacedGem", true)
		local placed = gem and gem:IsA("BasePart") and gem.Transparency < 0.05
		if gem and gem:IsA("Model") then
			for _, part in ipairs(gem:GetDescendants()) do
				if part:IsA("BasePart") and part.Transparency < 0.05 then placed = true; break end
			end
		end
		if session.Stage == "WaitDoor" then
			SwordGet.SetStatus("CDK", "Final: waiting for Alucard Gem / chamber opening")
			cleanupMovement()
			if placed then session.Stage = "Enter"
			elseif os.clock() >= session.NextStart then session.Stage = "Approach" end
			return
		end
		SwordGet.SetStatus("CDK", "Final: entering chamber / waiting for Cursed Skeleton Boss")
		if not CDK.Approach(CDK.BossRoom, 5) then return end
		if session.Stage == "Enter" then session.Stage, session.SpawnUntil = "WaitBoss", os.clock() + 20 end
		if os.clock() >= (session.SpawnUntil or 0) then
			session.Stage, session.NextStart = "Approach", os.clock() + 3
		end
	end

	function CDK.HopNeeded(mode)
		local progress = CDK.Progress(true)
		if CDK.InDimension("HellDimension") or CDK.InDimension("HeavenlyDimension") then return false end
		if mode == "CastleRaid" then return progress.Good == -4 and not CDK.CastleMob() and not CDK.CastleMob(true) end
		return mode == "CakeQueen" and progress.Good == -5
			and not SwordGet.FindLive({ "Cake Queen" }) and not SwordGet.FindHint({ "Cake Queen" })
	end

	CDK.Step = LPH_JIT(function(snapshot)
		local action, sword = CDK.Plan(snapshot, controller.Training, CDK.AvailableSwords())
		if action == "Complete" then SwordGet.Complete("CDK"); return end
		if action == "Missing" then
			stopFastAttack(); cleanupMovement()
			SwordGet.SetStatus("CDK", "Requires " .. sword .. "; obtain both Yama and Tushita first")
			notify("Auto Cursed Dual Katana requires Yama and Tushita.", "cdk-missing", 5); return
		end
		if action == "Mastery" then
			controller.Training = sword
			TTK.FarmBones(snapshot, sword, nil, "CDK"); return
		end
		if player.Data.Level.Value < 2200 then SwordGet.SetStatus("CDK", "CDK trials require level 2200 or higher"); return end
		if not CDK.OpenRoom(snapshot) then return end
		local progress = CDK.Progress()
		if not workflowActive("CDK") then return end
		local phase = tostring(progress.Good) .. ":" .. tostring(progress.Evil)
		if controller.Phase ~= phase then
			if controller.Request then SwordGet.Cancel("CDK") end
			CDK.ClearDamage(); controller.Phase = phase; controller.MissingSince = nil; controller.Target = nil
			controller.DimensionWait = nil; controller.RaidWait = nil
		end
		if CDK.FinalReady(progress) then CDK.ClearDamage(); CDK.Final(snapshot, progress); return end
		local side = (progress.Good ~= -2 and progress.Good < 4) and "Good" or "Evil"
		if not TTK.EnsureSword(snapshot, side == "Good" and "Tushita" or "Yama") then return end
		local value = progress[side]
		if value >= -2 then CDK.ClearDamage(); CDK.BeginTrial(side); return end
		if side == "Good" then
			CDK.ClearDamage()
			if value == -3 then CDK.Boats()
			elseif value == -4 then CDK.CastleRaid()
			elseif value == -5 then CDK.Queen() end
		elseif value == -3 then
			local mob = SwordGet.FindLive({ "Marine Commodore" })
			SwordGet.SetStatus("CDK", "Evil trial 1: Pain and Suffering")
			CDK.TakeDamage(mob, CDK.Spawn("Marine Commodore", CDK.PainSpawn))
		elseif value == -4 then CDK.ClearDamage(); CDK.Haze()
		elseif value == -5 then CDK.Reaper(snapshot) end
	end)
end

do
	function Haki.SetStatus(message)
		if Haki.Status == message then return end
		Haki.Status = message
		print("[Teddy Hub][Haki] " .. message)
	end

	function Haki.Canonical(name)
		if type(name) ~= "string" then return end
		name = name:gsub("^[Hh][Aa][Kk][Ii]%s*:%s*", ""):match("^%s*(.-)%s*$")
		for _, color in ipairs(Haki.Names) do if name:lower() == color:lower() then return color end end
	end

	function Haki.Read(force)
		if not force and Haki.Owned and os.clock() - (Haki.ReadAt or 0) < 1 then return Haki.Owned end
		if not itemService then
			itemService = require(ReplicatedStorage:WaitForChild("ItemReplicationService"))
			itemConfig = require(ReplicatedStorage:WaitForChild("ItemConfig"))
		end
		local items = itemService:GetItems(itemService.KEYS.IS_OWNED)
		assert(type(items) == "table", "Aura ownership inventory is unavailable")
		local owned = {}
		for _, item in pairs(items) do
			if item.Value == true then
				local config = itemConfig.match(item.ItemId)
				if type(config.asNullable) == "function" then config = config:asNullable()
				elseif type(config.unwrap) == "function" then config = config:unwrap() end
				if type(config) == "table" then
					local index, display = config.Index or {}, config.Display or {}
					if index.IdType == "Skin" and config.Skin and config.Skin.Type == "Aura" then
						local name = Haki.Canonical(index.StorageKey) or Haki.Canonical(display.Name)
						if name then owned[name] = true end
					end
				end
			end
		end
		Haki.Owned, Haki.ReadAt = owned, os.clock()
		return owned
	end

	function Haki.ReadCrafting(force)
		if not force and Haki.Crafting and os.clock() - (Haki.CraftingAt or 0) < 5 then return Haki.Crafting end
		Haki.JuiceRemote = Haki.JuiceRemote or require(ReplicatedStorage.Modules.Net):RemoteFunction("JuiceNetworkRF")
		local snapshot = Haki.JuiceRemote:InvokeServer({ Context = "GetRecipesAndMaterials" })
		assert(type(snapshot) == "table" and type(snapshot.Recipes) == "table"
			and type(snapshot.Materials) == "table", "Aura recipe/material inventory is unavailable")
		Haki.Crafting, Haki.CraftingAt = snapshot, os.clock()
		return snapshot
	end

	function Haki.Acquired(force)
		local owned, crafting = Haki.Read(force), Haki.ReadCrafting(force)
		local acquired = {}
		for _, name in ipairs(Haki.Names) do acquired[name] = owned[name] or crafting.Recipes[name] == true end
		return acquired
	end

	function Haki.NeedBerry(name, crafting)
		local recipe = require(ReplicatedStorage.Definitions.Skin.Recipe).match(name, "Skin"):unwrap()
		for id, amount in pairs(recipe.Ingredients) do
			local material = itemConfig.match(id):unwrap().Index.StorageKey
			local count = tonumber(crafting.Materials[material]) or 0
			if count < amount then return material, amount, count end
		end
	end

	function Haki.SelectColor(owned, crafting)
		local target = Haki.Canonical(Haki.Target)
		if target and not owned[target] and crafting.Recipes[target] == true then return target end
		local choices = {}
		for _, name in ipairs(Haki.Names) do
			if not owned[name] and crafting.Recipes[name] == true then choices[#choices + 1] = name end
		end
		Haki.Cancel(); cancelMovement()
		Haki.Target = #choices > 0 and choices[math.random(#choices)] or nil
		env.__CyborgCodexHakiTarget = Haki.Target
		Haki.BerryTarget, Haki.EmptySince, Haki.NextHop = nil, nil, nil
		return Haki.Target
	end

	function Haki.FindCraftNPC()
		local root = getRoot()
		local holder = workspace:FindFirstChild("NPCs")
		if not root or not holder then return end
		local closest, distance
		for _, npc in ipairs(holder:GetChildren()) do
			if npc.Name == "Barista" and npc:IsA("Model") and npc:GetAttribute("NPCLoaded") == true then
				local part = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
				if part then
					local d = (root.Position - part.Position).Magnitude
					if not distance or d < distance then closest, distance = npc, d end
				end
			end
		end
		return closest
	end

	function Haki.ApproachCrafter()
		local root, npc = getRoot(), Haki.FindCraftNPC()
		if not root then return false end
		if npc then
			local part = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
			if (root.Position - part.Position).Magnitude < 15 then return true end
			Haki.SetStatus("Approaching Barista to craft " .. Haki.Target)
			moveTo(part.CFrame * CFrame.new(0, 0, 5))
			return false
		end
		local position, distance
		for _, bar in ipairs(CollectionService:GetTagged("JuiceBar")) do
			local stand = bar:FindFirstChild("StandPart")
			if stand and stand:IsA("BasePart") then
				local d = (root.Position - stand.Position).Magnitude
				if not distance or d < distance then position, distance = stand.CFrame, d end
			end
		end
		Haki.SetStatus(position and ("Approaching JuiceBar / waiting for Barista: " .. Haki.Target)
			or "Waiting for Barista / JuiceBar to load")
		if position then moveTo(position + Vector3.new(0, 3, 0)) end
		return false
	end

	function Haki.Craft(owned, crafting)
		local name = Haki.SelectColor(owned, crafting)
		if not name or Haki.NeedBerry(name, crafting) then return false end
		Haki.Cancel(); Haki.BerryTarget = nil
		if os.clock() < (Haki.NextCraft or 0) or not workflowActive("Haki") then return true end
		if not Haki.ApproachCrafter() then return true end
		cleanupMovement()
		local latest = Haki.ReadCrafting(true)
		if not workflowActive("Haki") or Haki.Read(true)[name] or Haki.NeedBerry(name, latest) then return true end
		local root, npc = getRoot(), Haki.FindCraftNPC()
		local part = npc and (npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart)
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if not root or not part or not humanoid or humanoid.Health <= 0
			or (root.Position - part.Position).Magnitude >= 15 then return true end
		Haki.NextCraft = os.clock() + 15
		Haki.SetStatus("Crafting legendary Haki: " .. name)
		local result = Haki.JuiceRemote:InvokeServer({ Context = "Craft", StorageName = name })
		print("[Teddy Hub][Haki] Craft response: " .. tostring(result))
		Haki.ReadAt, Haki.CraftingAt = -math.huge, -math.huge
		if result then Haki.ConfirmUntil = os.clock() + 35
		else Haki.SetStatus("Craft rejected: " .. name .. "; retrying in 15 seconds") end
		return true
	end

	function Haki.BerryPosition(bush, slot, berry)
		local model = bush and bush.Parent
		if not model or bush:GetAttribute(slot) ~= berry then return end
		local origin, offset = model:GetAttribute("CFrame"), model:GetAttribute(slot)
		if typeof(origin) == "CFrame" and typeof(offset) == "CFrame" then return origin:ToWorldSpace(offset) end
	end

	function Haki.FindBerry(berry)
		local root = getRoot()
		if not root then return end
		local best, distance
		for _, bush in ipairs(CollectionService:GetTagged("BerryBush")) do
			for slot, value in pairs(bush:GetAttributes()) do
				if value == berry and slot:match("^_BerryCFrame%d+$") then
					local ignored = Haki.BerryIgnored[bush]
					local position = Haki.BerryPosition(bush, slot, berry)
					if position and (not ignored or os.clock() >= (ignored[slot] or 0)) then
						local d = (root.Position - position.Position).Magnitude
						if not distance or d < distance then
							best, distance = { Bush = bush, Slot = slot, Berry = berry, Position = position, Attempts = 0 }, d
						end
					end
				end
			end
		end
		return best
	end

	function Haki.CollectBerry(owned, crafting)
		local name = Haki.SelectColor(owned, crafting)
		if not name then return end
		local berry, required, count = Haki.NeedBerry(name, crafting)
		if not berry then Haki.Craft(owned, crafting); return end
		local target = Haki.BerryTarget
		if target and (target.Berry ~= berry or not Haki.BerryPosition(target.Bush, target.Slot, berry)) then
			cancelMovement(); Haki.BerryTarget = nil; target = nil
		end
		if not target then target = Haki.FindBerry(berry); Haki.BerryTarget = target end
		if not target then
			Haki.EmptySince = Haki.EmptySince or os.clock()
			cancelMovement()
			if os.clock() - Haki.EmptySince < 5 then Haki.SetStatus("No " .. berry .. " found; waiting for replication before API hop"); return end
			cancelMovement(); Haki.Hop("berry", berry); return
		end
		if Haki.Request then Haki.Cancel() end
		Haki.EmptySince = nil
		Haki.SetStatus("Collecting " .. berry .. " " .. count .. "/" .. required .. " for " .. name)
		if not moveTo(target.Position + Vector3.new(0, 2, 0)) then return end
		if os.clock() < (Haki.NextClaim or 0) or not workflowActive("Haki") then return end
		local position = Haki.BerryPosition(target.Bush, target.Slot, berry)
		if not position or (getRoot().Position - position.Position).Magnitude > 15 then return end
		Haki.NextClaim = os.clock() + 0.5
		Haki.ClaimRemote = Haki.ClaimRemote or require(ReplicatedStorage.Modules.Net):RemoteFunction("ClaimBerry")
		local result = Haki.ClaimRemote:InvokeServer(target.Bush.Parent.Name, target.Slot)
		Haki.CraftingAt = -math.huge
		target.Attempts += 1
		if result or target.Attempts >= 3 then
			local ignored = Haki.BerryIgnored[target.Bush] or {}
			Haki.BerryIgnored[target.Bush] = ignored
			ignored[target.Slot] = os.clock() + (result and 5 or 60)
			Haki.BerryTarget = nil
			if not result then print("[Teddy Hub][Haki] Berry claim rejected: " .. berry .. "; skipping slot temporarily") end
		end
	end

	function Haki.Complete(owned)
		for _, name in ipairs(Haki.Names) do if not owned[name] then return false end end
		return true
	end

	function Haki.Cancel()
		Haki.Epoch += 1
		if Haki.Request then state.HopPending = false end
		Haki.Request = nil
	end

	function Haki.CanHop(request)
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		local fragments = player.Data:FindFirstChild("Fragments")
		return workflowActive("Haki") and Haki.Request == request and Haki.Epoch == request.Epoch
			and (request.Slug ~= "berry" or Haki.Target == request.Target)
			and game.PlaceId == request.PlaceId and humanoid and humanoid.Health > 0
			and fragments and fragments.Value >= Haki.Price and not BossFarm.HasProtectedItem() and not hasItem("Holy Torch")
	end

	function Haki.Hop(slug, berry)
		slug = slug or "haki"
		if Haki.Request then
			if os.clock() - Haki.Request.Started >= BossFarm.TeleportTimeout then
				Haki.Cancel(); Haki.NextHop = os.clock() + BossFarm.RetrySeconds
				Haki.SetStatus("Haki API/teleport timed out; retrying")
			end
			return
		end
		if os.clock() < (Haki.NextHop or 0) then return end
		if BossFarm.HasProtectedItem() or hasItem("Holy Torch") then Haki.SetStatus("Hop paused: carrying a protected item"); return end
		local request = { Epoch = Haki.Epoch, PlaceId = game.PlaceId, Started = os.clock(),
			Slug = slug, Berry = berry, Target = Haki.Target }
		Haki.Request = request; state.HopPending = true
		Haki.SetStatus(slug == "berry" and ("Searching Berry API: " .. berry) or "Searching Haki API for missing legendary colors")
		task.spawn(function()
			local ok, message = xpcall(function()
				local servers = BossFarm.FetchServers(slug)
				if not Haki.CanHop(request) then return "Haki search cancelled" end
				local owned = Haki.Acquired(true)
				local candidates, aliases = {}, {}
				if slug == "berry" then
					aliases = { berry, "Berry: " .. berry }
					for _, server in ipairs(servers) do
						local name = type(server) == "table" and type(server.name) == "string" and
							server.name:gsub("^[Bb][Ee][Rr][Rr][Yy]%s*:%s*", ""):match("^%s*(.-)%s*$")
						if name and name:lower() == berry:lower() then candidates[#candidates + 1] = server end
					end
				else
					for _, name in ipairs(Haki.Names) do
						if not owned[name] then aliases[#aliases + 1] = name; aliases[#aliases + 1] = "Haki: " .. name end
					end
					for _, server in ipairs(servers) do
						local name = type(server) == "table" and Haki.Canonical(server.name)
						if name and not owned[name] then candidates[#candidates + 1] = server end
					end
				end
				local job = BossFarm.SelectServer(candidates, { Slug = slug, Names = aliases })
				if not job then return "No matching " .. slug .. " API server; retrying" end
				if not Haki.CanHop(request) then return "Haki search cancelled" end
				if slug == "berry" then
					if Haki.Read(true)[request.Target] or Haki.NeedBerry(request.Target, Haki.ReadCrafting(true)) ~= berry then
						return "Berry requirement already met; staying to craft"
					end
					if Haki.FindBerry(berry) then return "Matching berry found in current server; staying" end
				else
					owned = Haki.Acquired(true)
					if Haki.Complete(owned) then return "All legendary recipes already learned" end
					local dealer = Haki.Canonical(invokeCommF("ColorsDealer", "1"))
					if dealer and not owned[dealer] then return "Missing recipe found in current server; staying" end
				end
				if not Haki.CanHop(request) then return "Haki search cancelled" end
				local browser = ReplicatedStorage:FindFirstChild("__ServerBrowser")
				assert(browser and browser:IsA("RemoteFunction"), "Server browser is unavailable")
				queueResume()
				if not Haki.CanHop(request) then return "Haki search cancelled" end
				state.BossVisited[job] = os.time(); state.BossVisited[game.JobId] = os.time()
				request.Teleport = true; request.Started = os.clock()
				Haki.SetStatus(slug == "berry" and ("Hopping for " .. berry .. " / " .. request.Target) or "Hopping to a missing legendary Haki recipe")
				assert(browser:InvokeServer("teleport", job) ~= false, "Haki server teleport was rejected")
			end, debug.traceback)
			if state.Generation ~= generation or Haki.Request ~= request then return end
			if ok and request.Teleport then return end
			Haki.Request = nil; state.HopPending = false; Haki.NextHop = os.clock() + BossFarm.RetrySeconds
			Haki.SetStatus(ok and (message or "Haki search cancelled") or "Haki API error; see console")
			if not ok then reportControllerError(message, "Haki", "APIHop") end
		end)
	end

	Haki.Step = LPH_JIT(function()
		if not workflowActive("Haki") then return end
		local owned = Haki.Read()
		if Haki.Complete(owned) then
			Haki.Cancel(); cancelMovement(); Haki.Target = nil; env.__CyborgCodexHakiTarget = nil
			Haki.Completed = true; Haki.SetStatus("Completed: Pure Red, Winter Sky, Snow White owned"); return
		end
		if os.clock() < (Haki.ConfirmUntil or 0) then Haki.SetStatus("Waiting for Haki inventory confirmation"); return end
		local fragments = player.Data:FindFirstChild("Fragments")
		if not fragments then Haki.SetStatus("Waiting for fragment data"); return end
		if fragments.Value < Haki.Price then
			Haki.Cancel(); env.autohakilegendary = false
			Haki.SetStatus("Stopped: insufficient fragments (need 7500)")
			notify("Auto Haki Legendary stopped: not enough fragments (need 7500).", "haki-fragments", 5); return
		end
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if not getRoot() or not humanoid or humanoid.Health <= 0 then Haki.Cancel(); Haki.SetStatus("Waiting for character"); return end
		if currentSea() == 1 then Haki.SetStatus("Traveling to Sea 2 for Legendary Haki"); travelToSea2(); return end
		if currentSea() ~= 2 and currentSea() ~= 3 then Haki.SetStatus("Unsupported sea for Haki dealer"); return end
		local crafting = Haki.ReadCrafting()
		if not workflowActive("Haki") then return end
		if Haki.Complete(Haki.Acquired()) then Haki.CollectBerry(owned, crafting); return end
		if os.clock() - (Haki.DealerAt or -math.huge) >= 2 then
			Haki.Dealer = Haki.Canonical(invokeCommF("ColorsDealer", "1")); Haki.DealerAt = os.clock()
		end
		if not workflowActive("Haki") then return end
		if Haki.Dealer and not owned[Haki.Dealer] and crafting.Recipes[Haki.Dealer] ~= true then
			Haki.Cancel()
			if os.clock() - (Haki.LastBuy or -math.huge) < 5 then return end
			local offered = Haki.Canonical(invokeCommF("ColorsDealer", "1"))
			owned = Haki.Acquired(true)
			if not workflowActive("Haki") or not offered or owned[offered] or fragments.Value < Haki.Price then return end
			Haki.LastBuy = os.clock(); Haki.SetStatus("Buying legendary Haki recipe: " .. offered)
			local result = invokeCommF("ColorsDealer", "2")
			print("[Teddy Hub][Haki] Buy response: " .. tostring(result))
			Haki.ReadAt = -math.huge; Haki.CraftingAt = -math.huge; Haki.DealerAt = -math.huge
			if result == 1 or result == 2 then
				Haki.ReadCrafting(true)
				Haki.SetStatus(result == 2 and ("Recipe already learned: " .. offered) or ("Recipe learned: " .. offered))
			elseif result == 0 then
				Haki.SetStatus("Recipe purchase rejected: insufficient currency")
			else
				Haki.SetStatus("Dealer offer unavailable; checking again")
			end
			return
		end
		Haki.Hop()
	end)
end

local function soulGuitarOwned(counts)
	if state.SoulGuitarOwned or hasItem("Skull Guitar") or hasItem("Soul Guitar")
		or (counts["Skull Guitar"] or 0) > 0 or (counts["Soul Guitar"] or 0) > 0 then
		state.SoulGuitarOwned = true
		return true
	end
	if os.clock() - (state.LastRemote.SoulOwnership or -math.huge) >= 5 then
		state.LastRemote.SoulOwnership = os.clock()
		state.LastSoulBuyCheck = invokeCommF("soulGuitarBuy", true)
		state.SoulGuitarOwned = state.LastSoulBuyCheck == "[You already own this item.]"
	end
	return state.SoulGuitarOwned == true
end

local function puzzleComplete(progress)
	if type(progress) ~= "table" then return false end
	for _, stage in ipairs(PuzzleStages) do
		if progress[stage] ~= true then return false end
	end
	return true
end

local function soulGuitarPlan(owned, counts, progress, fragments)
	if owned then return "owned" end
	if (counts["Dark Fragment"] or 0) < 1 then return "dark-fragment" end
	if (counts.Ectoplasm or 0) < 250 then return "ectoplasm" end
	if (counts.Bones or 0) < 500 then return "bones" end
	if not puzzleComplete(progress) then return "puzzle" end
	if fragments < Config.MinSoulGuitarFragments then return "fragments" end
	return "buy"
end

local function getPuzzleProgress(force)
	if not force and state.PuzzleReadAt and os.clock() - state.PuzzleReadAt < 1 then
		return state.PuzzleProgress
	end
	local progress = invokeCommF("GuitarPuzzleProgress", "Check")
	assert(progress == nil or progress == false or type(progress) == "table", "Unexpected GuitarPuzzleProgress Check response")
	state.PuzzleProgress = progress
	state.PuzzleReadAt = os.clock()
	return progress
end

local function farmMaterial(name)
	local recipe = MaterialTargets[name]
	if recipe.Sea == 2 and not travelToSea2() then return end
	if recipe.Sea == 3 and not travelToSea3() then return end
	setStage("farm " .. name)
	local mob = findMob(recipe.Names)
	if mob then fightMob(mob); return end
	stopFastAttack()
	local now = os.clock()
	if state.MaterialName ~= name then
		state.MaterialName, state.MaterialSpawnIndex, state.MaterialSpawnAt = name, 1, now
	elseif now - state.MaterialSpawnAt > 12 then
		state.MaterialSpawnIndex = state.MaterialSpawnIndex % #recipe.Spawns + 1
		state.MaterialSpawnAt = now
	end
	moveTo(recipe.Spawns[state.MaterialSpawnIndex] * CFrame.new(0, 20, 0))
end

do
	function Ghoul.Owned()
		local data = player:FindFirstChild("Data")
		local race = data and data:FindFirstChild("Race")
		return race ~= nil and race.Value == "Ghoul"
	end

	function Ghoul.Trace(phase)
		if state.GhoulPhase == phase then return end
		state.GhoulPhase = phase
	end

	function Ghoul.CharacterReady()
		if not workflowActive("Ghoul") then return false end
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if getRoot() and humanoid and humanoid.Health > 0 then return true end
		BossFarm.Cancel()
		Ghoul.Trace("WaitCharacter")
		Ghoul.SetStatus("Waiting for character")
		return false
	end

	function Ghoul.ReadEctoplasm(force)
		Ghoul.Trace("ReadEctoplasm")
		local counts = inventoryCounts(force)
		if not Ghoul.CharacterReady() then return nil end
		local count = counts.Ectoplasm or 0
		assert(type(count) == "number" and count >= 0, "Ectoplasm quantity is invalid")
		state.GhoulCount = count
		return count
	end

	function Ghoul.FarmEctoplasm()
		if not Ghoul.CharacterReady() then return end
		Ghoul.Trace("FarmEctoplasm")
		if state.BossRequest then BossFarm.Cancel() end
		farmMaterial("Ectoplasm")
		Ghoul.SetStatus("Farming Ectoplasm " .. state.GhoulCount .. "/" .. Config.GhoulEctoplasmTarget)
	end

	function Ghoul.SetStatus(message)
		if state.GhoulStatus == message then return end
		state.GhoulStatus = message
		log("Ghoul: " .. message)
		if Ghoul.StatusChanged then
			local ok, err = xpcall(function() Ghoul.StatusChanged(message) end, debug.traceback)
			if not ok then reportControllerError(err, "Ghoul", "UIStatus") end
		end
	end

	function Ghoul.Complete()
		Ghoul.Trace("Completed")
		env.autoghoulrace = false
		BossFarm.Cancel()
		stopFastAttack()
		cleanupMovement()
		Ghoul.SetStatus("Ghoul Race acquired")
		notify("Ghoul Race acquired; workflow stopped.", "ghoul-owned", 5)
	end

	function Ghoul.HopAllowed()
		return workflowActive("Ghoul") and env.autofarmboss ~= true and not Ghoul.Owned() and not hasItem("Hellfire Torch")
			and (state.GhoulCount or 0) >= Config.GhoulEctoplasmTarget
			and os.clock() >= (state.GhoulRewardUntil or 0)
	end

	function Ghoul.CheckUnlocked()
		Ghoul.Trace("CheckUnlock")
		if os.clock() - (state.LastRemote.GhoulCheck or -math.huge) < 5 then return end
		local result = invokeCommF("Ectoplasm", "BuyCheck", 4)
		if not Ghoul.CharacterReady() then return end
		state.LastRemote.GhoulCheck = os.clock()
		if state.GhoulCheckResult ~= result then log("Ghoul BuyCheck response: " .. tostring(result)) end
		state.GhoulCheckResult = result
		state.GhoulUnlocked = result == 1
	end

	function Ghoul.Exchange(action)
		if not Ghoul.CharacterReady() then return end
		Ghoul.Trace("TravelToGhoulNPC")
		stopFastAttack()
		if state.BossRequest then BossFarm.Cancel() end
		Ghoul.SetStatus(action == "Change" and "Changing back to unlocked Ghoul Race" or "Exchanging Hellfire Torch for Ghoul Race")
		if not moveTo(Ghoul.NPC) then return end
		cleanupMovement()
		if os.clock() - (state.LastRemote.GhoulExchange or -math.huge) < 5 then return end
		local root = getRoot()
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not workflowActive("Ghoul") or not root or not humanoid or humanoid.Health <= 0
			or (root.Position - Ghoul.NPC.Position).Magnitude > 8 then return end
		if action == "Buy" then
			local count = Ghoul.ReadEctoplasm(true)
			if not count or not hasItem("Hellfire Torch") or count < Config.GhoulEctoplasmTarget then return end
		end
		if getRoot() ~= root or humanoid.Health <= 0 or (root.Position - Ghoul.NPC.Position).Magnitude > 8 then return end
		state.LastRemote.GhoulExchange = os.clock()
		Ghoul.Trace(action == "Buy" and "BuyGhoul" or "ChangeGhoul")
		local result = invokeCommF("Ectoplasm", action, 4)
		if not workflowActive("Ghoul") then return end
		state.InventoryReadAt = -math.huge
		if action == "Change" then state.GhoulChangeAttempted = true end
		state.GhoulExchangeAwaiting = os.clock() + 5
		log("Ghoul " .. action .. " response: " .. tostring(result))
		if Ghoul.Owned() then Ghoul.Complete() else Ghoul.SetStatus("Waiting for race confirmation / exchange retry") end
	end

	Ghoul.Step = LPH_JIT(function()
		if not workflowActive("Ghoul") then return end
		Ghoul.Trace("CheckRace")
		if Ghoul.Owned() then Ghoul.Complete(); return end
		if not Ghoul.CharacterReady() then return end
		if os.clock() < (state.GhoulExchangeAwaiting or 0) then
			Ghoul.Trace("ConfirmRace")
			stopFastAttack()
			cleanupMovement()
			Ghoul.SetStatus("Waiting for race confirmation")
			return
		end
		Ghoul.Trace("TravelSea2")
		if not travelToSea2() then return end
		Ghoul.CheckUnlocked()
		if not Ghoul.CharacterReady() then return end
		if Ghoul.Owned() then Ghoul.Complete(); return end
		if state.GhoulUnlocked and not hasItem("Hellfire Torch") and not state.GhoulChangeAttempted then
			Ghoul.Exchange("Change")
			return
		end
		local count = Ghoul.ReadEctoplasm()
		if not count then return end
		if count < Config.GhoulEctoplasmTarget then Ghoul.FarmEctoplasm(); return end
		if hasItem("Hellfire Torch") then Ghoul.Exchange("Buy"); return end
		Ghoul.FindTorch()
	end)

	function Ghoul.FindTorch()
		if not Ghoul.CharacterReady() then return end
		Ghoul.Trace("FindCaptain")
		local definition = BossFarm.Definitions["Cursed Captain"]
		local boss = BossFarm.FindActive(definition)
		if boss then
			if state.BossRequest then BossFarm.Cancel() end
			state.BossMissingSince = nil
			state.GhoulTarget = boss
			Ghoul.Trace("FightCaptain")
			Ghoul.SetStatus("Fighting Cursed Captain for Hellfire Torch")
			fightMob(boss)
			return
		end
		stopFastAttack()
		if state.GhoulTarget then
			state.GhoulTarget = nil
			state.GhoulRewardUntil = os.clock() + Ghoul.RewardGrace
			state.InventoryReadAt = -math.huge
		end
		if os.clock() < (state.GhoulRewardUntil or 0) then
			Ghoul.Trace("WaitDrops")
			cleanupMovement()
			Ghoul.SetStatus("Waiting for Cursed Captain drops")
			return
		end
		local hint = BossFarm.FindIn(ReplicatedStorage, definition)
		if hint then
			if state.BossRequest then BossFarm.Cancel() end
			state.BossMissingSince = nil
			Ghoul.Trace("WaitCaptainReplication")
			Ghoul.SetStatus("Approaching Cursed Captain / waiting for replication")
			moveTo(uprightCFrame(hint.HumanoidRootPart.CFrame) * CFrame.new(Config.OrderOffset))
			return
		end
		cleanupMovement()
		state.BossMissingSince = state.BossMissingSince or os.clock()
		if os.clock() - state.BossMissingSince < BossFarm.MissingGrace then
			Ghoul.Trace("CheckCaptainSpawn")
			Ghoul.SetStatus("Checking Cursed Captain spawn (" .. math.ceil(BossFarm.MissingGrace - (os.clock() - state.BossMissingSince)) .. "s)")
			return
		end
		if BossFarm.HasProtectedItem() then
			BossFarm.Cancel()
			Ghoul.SetStatus("Hop paused: carrying a protected item")
			return
		end
		local pending = state.BossRequest
		if pending then
			Ghoul.Trace(pending.Phase == "Teleport" and "APITeleport" or "APISearch")
			if os.clock() - pending.StartedAt >= BossFarm.TeleportTimeout then
				state.BossRequest = nil
				state.HopPending = false
				state.BossNextHopAt = os.clock() + BossFarm.RetrySeconds
				Ghoul.SetStatus("API / teleport timed out; waiting to retry")
			end
			return
		end
		if os.clock() < (state.BossNextHopAt or 0) then Ghoul.SetStatus(state.BossHopMessage or "Waiting for API retry"); return end
		Ghoul.Trace("APISearch")
		BossFarm.BeginHop(definition, "Ghoul")
	end
end

local function getDarkFragment()
	if not travelToSea2() then return end
	local boss = findMob({ "Darkbeard" })
	if boss then
		state.DarkbeardTarget = boss
		state.DarkbeardSummonUntil = nil
		setStage("fight Darkbeard for Dark Fragment")
		fightMob(boss)
		return
	end
	stopFastAttack()
	if state.DarkbeardTarget then
		state.DarkbeardTarget = nil
		state.DarkbeardSummonUntil = os.clock() + 3
		state.InventoryReadAt = -math.huge
	end
	if state.DarkbeardSummonUntil and os.clock() < state.DarkbeardSummonUntil then
		setStage("wait for Darkbeard summon/reward")
		cleanupMovement()
		return
	end
	if hasItem("Fist of Darkness") then
		setStage("summon Darkbeard with Fist of Darkness")
		local map = workspace:FindFirstChild("Map")
		local arena = map and map:FindFirstChild("DarkbeardArena")
		local summoner = arena and arena:FindFirstChild("Summoner")
		local detection = summoner and summoner:FindFirstChild("Detection")
		if not detection then
			moveTo(CFrame.new(3777.22266, 13.319315, -3496.96118))
			notify("Waiting for DarkbeardArena.Summoner.Detection to load.", "darkbeard-map", 5)
			return
		end
		if not moveTo(detection.CFrame) then return end
		if os.clock() - (state.LastRemote.DarkbeardSummon or 0) < 3 then return end
		assert(equipItem("Fist of Darkness"), "Cannot equip Fist of Darkness for Darkbeard")
		task.wait(0.3)
		if not workflowActive("SoulGuitar") then return end
		local character = player.Character
		local tool = character and character:FindFirstChild("Fist of Darkness")
		local handle = tool and tool:FindFirstChild("Handle")
		local root = getRoot()
		assert(handle and root, "Fist of Darkness Handle or character root is unavailable")
		local touch = env.firetouchinterest or _G.firetouchinterest
		assert(type(touch) == "function", "Executor firetouchinterest is unavailable")
		state.LastRemote.DarkbeardSummon = os.clock()
		for _, part in ipairs({ handle, root }) do
			if not workflowActive("SoulGuitar") then return end
			touch(part, detection, 0)
			touch(part, detection, 1)
		end
		state.DarkbeardSummonUntil = os.clock() + 10
		state.InventoryReadAt = -math.huge
		return
	end
	setStage("Soul Guitar: collect chests for Fist of Darkness")
	collectChest()
end

local function fullMoonNight()
	local lighting = game:GetService("Lighting")
	local sky = lighting:FindFirstChildOfClass("Sky")
	local full = lighting:GetAttribute("MoonPhase") == 5
		or (sky and sky.MoonTextureId == "http://www.roblox.com/asset/?id=9709149431")
	return full and (lighting.ClockTime > 16 or lighting.ClockTime < 5)
end

local function puzzleClick(part)
	assert(part, "Required Haunted Castle puzzle part is unavailable")
	local key = part:GetFullName()
	state.LastPuzzleClick = state.LastPuzzleClick or {}
	if os.clock() - (state.LastPuzzleClick[key] or 0) < 0.75 then return end
	if not workflowActive("SoulGuitar") then return end
	clickPart(part)
	state.LastPuzzleClick[key] = os.clock()
	state.PuzzleReadAt = -math.huge
end

local function swampPuzzle()
	local enemies = workspace:FindFirstChild("Enemies")
	local root = getRoot()
	if not enemies or not root then return end
	local swamp = PuzzlePositions.Swamp
	if (root.Position - swamp.Position).Magnitude > 50 then
		stopFastAttack()
		moveTo(swamp * CFrame.new(0, 20, 0))
		return
	end
	local zombies = {}
	for _, mob in ipairs(enemies:GetChildren()) do
		if isAlive(mob) and cleanMobName(mob.Name) == "Living Zombie"
			and (mob.HumanoidRootPart.Position - swamp.Position).Magnitude < 500 then
			zombies[#zombies + 1] = mob
		end
	end
	if #zombies < 6 then
		stopFastAttack()
		cleanupMovement()
		notify("Swamp puzzle: waiting for six living zombies before attacking.", "swamp-zombies", 5)
		return
	end
	local characters = workspace:FindFirstChild("Characters")
	if characters then
		for _, other in ipairs(characters:GetChildren()) do
			local otherRoot = other ~= player.Character and other:FindFirstChild("HumanoidRootPart")
			if otherRoot and (otherRoot.Position - swamp.Position).Magnitude <= 300 then
				stopFastAttack()
				notify("Swamp puzzle: another player is near the zombie group; waiting.", "swamp-authority", 5)
				return
			end
		end
	end
	if state.ZombieBatch then
		local valid = true
		for _, mob in ipairs(state.ZombieBatch) do if not isAlive(mob) then valid = false; break end end
		if not valid then stopFastAttack(); return end
		zombies = state.ZombieBatch
	else
		table.sort(zombies, function(a, b) return a.Humanoid.Health > b.Humanoid.Health end)
		while #zombies > 6 do table.remove(zombies) end
		state.ZombieBatch = zombies
	end
	state.PuzzleCollision = state.PuzzleCollision or setmetatable({}, { __mode = "k" })
	for _, mob in ipairs(zombies) do
		for _, part in ipairs(mob:GetDescendants()) do
			if part:IsA("BasePart") then
				if state.PuzzleCollision[part] == nil then state.PuzzleCollision[part] = part.CanCollide end
				part.CanCollide = false
			end
		end
		mob.HumanoidRootPart.CFrame = swamp * CFrame.new(0, 1, 1)
	end
	state.FastAttackTargets = zombies
	fightMob(zombies[1])
end

local function guitarPuzzleStep(progress)
	if not progress then
		stopFastAttack()
		if not fullMoonNight() then
			cleanupMovement()
			setStage("Soul Guitar: wait for full moon at night")
			notify("Soul Guitar puzzle needs a full moon at night; searching another server.", "soul-moon", 5)
			teleportToNewServer("moon")
			return
		end
		setStage("start Soul Guitar gravestone event")
		if not moveTo(PuzzlePositions.Grave) then return end
		if os.clock() - (state.LastRemote.GravestoneStart or 0) >= 5 and workflowActive("SoulGuitar") then
			state.LastRemote.GravestoneStart = os.clock()
			invokeCommF("gravestoneEvent", 2)
			if not workflowActive("SoulGuitar") then return end
			invokeCommF("gravestoneEvent", 2, true)
			state.PuzzleReadAt = -math.huge
		end
		return
	end
	local stage
	for _, name in ipairs(PuzzleStages) do
		if progress[name] ~= true then stage = name; break end
	end
	if not stage then return end
	setStage("Soul Guitar puzzle: " .. stage)
	if stage == "Swamp" then swampPuzzle(); return end
	stopFastAttack()
	local destination = PuzzlePositions[stage] or PuzzlePositions.Lab
	if not moveTo(destination) then return end
	if os.clock() - (state.LastRemote.PuzzleAdvance or 0) >= 3 and workflowActive("SoulGuitar") then
		state.LastRemote.PuzzleAdvance = os.clock()
		invokeCommF("GuitarPuzzleProgress", stage)
		state.PuzzleReadAt = -math.huge
		local updated = getPuzzleProgress(true)
		if not workflowActive("SoulGuitar") or (updated and updated[stage] == true) then return end
	end
	if stage == "Ghost" then return end
	local map = workspace:FindFirstChild("Map")
	local castle = map and map:FindFirstChild("Haunted Castle")
	assert(castle, "Map.Haunted Castle has not loaded at the puzzle location")
	if stage == "Gravestones" then
		local sides = { "Right", "Right", "Left", "Right", "Left", "Left", "Left" }
		state.PlacardIndex = state.PlacardIndex or 1
		local index = state.PlacardIndex
		local placard = castle:FindFirstChild("Placard" .. index)
		puzzleClick(placard and placard:FindFirstChild(sides[index]))
		state.PlacardIndex = index % #sides + 1
	elseif stage == "Trophies" then
		local tablet = castle:FindFirstChild("Tablet")
		assert(tablet, "Haunted Castle Tablet is unavailable")
		for _, name in ipairs(BlankTablets) do
			local segment = tablet:FindFirstChild(name)
			local line = segment and segment:FindFirstChild("Line")
			assert(line, "Blank tablet Line is unavailable: " .. name)
			if math.abs(line.Position.X + 9707.86328125) > 0.05 then puzzleClick(segment); return end
		end
		local trophies = castle:FindFirstChild("Trophies")
		local quest = trophies and trophies:FindFirstChild("Quest")
		assert(quest, "Haunted Castle Trophies.Quest is unavailable")
		for segmentName, trophyName in pairs(TrophyTablets) do
			local trophy = quest:FindFirstChild(trophyName)
			local handle = trophy and trophy:FindFirstChild("Handle")
			local segment = tablet:FindFirstChild(segmentName)
			local line = segment and segment:FindFirstChild("Line")
			assert(handle and line, "Trophy handle/tablet Line is unavailable: " .. trophyName)
			local _, _, _, r00 = handle.CFrame:GetComponents()
			local expected = math.abs(r00) > 0.9 and 90 or 0
			local angle = line.Rotation.Z % 180
			if math.abs(angle - expected) > 0.1 then puzzleClick(segment); return end
		end
	elseif stage == "Pipes" then
		local lab = castle:FindFirstChild("Lab Puzzle")
		local floor = lab and lab:FindFirstChild("ColorFloor")
		local model = floor and floor:FindFirstChild("Model")
		assert(model, "Haunted Castle Lab Puzzle.ColorFloor.Model is unavailable")
		for name, color in pairs(PipeColors) do
			local tile = model:FindFirstChild(name)
			assert(tile, "Pipe floor tile is unavailable: " .. name)
			if tile.BrickColor.Name ~= color then puzzleClick(tile); return end
		end
	end
end

local runStep = LPH_JIT(function()
	if state.Busy or not workflowActive("Cyborg") then return end
	if state.HopPending then
		if os.clock() - (state.LastRemote.Hop or 0) < 20 then return end
		state.HopPending = false
	end
	if os.clock() < state.NextAction then return end
	state.NextAction = os.clock() + Config.ActionDelay
	state.Busy = true
	local ok, err = xpcall(function()
		local owned, coreBrainSubmitted = checkRace()
		if not workflowActive("Cyborg") then return end
		if owned then
			state.CoreBrainSubmissionAwaiting = false
			setStage("Cyborg already owned")
			stopFastAttack()
			cleanupMovement()
			notify("Cyborg Race is already owned.", "owned", 5)
			return
		end
		if coreBrainSubmitted then
			state.CoreBrainSubmissionAwaiting = false
		end
		if state.CoreBrainSubmissionAwaiting then
			setStage("verify Core Brain submission")
			stopFastAttack()
			cleanupMovement()
			notify("Waiting for server confirmation of Core Brain submission.", "core-brain-check", 5)
			return
		end
		if coreBrainSubmitted then
			setStage("buy Cyborg Race")
			stopFastAttack()
			cleanupMovement()
			if getFragments() < Config.MinCyborgFragments then
				notify("Need at least 2500 Fragments to buy Cyborg Race.", "cyborg-fragments", 5)
				return
			end
			requestCyborgBuy()
			return
		end
		if not ensureTeam() then
			setStage("join team")
			return
		end
		if not travelToSea2() then return end
		if not (getRoot() and player.Character:FindFirstChildOfClass("Humanoid")) then return end

		local button = getRaidButton()
		if not button then return end
		if hasItem("Core Brain") then
			setStage("submit Core Brain and buy Cyborg")
			stopFastAttack()
			cleanupMovement()
			if (getRoot().Position - RaidButtonCFrame.Position).Magnitude > 14 then
				moveTo(RaidButtonCFrame)
				return
			end
			if os.clock() - (state.LastRemote.Submit or 0) >= 1 then
				if submitItem("Core Brain") then
					task.wait(0.4)
					if not hasItem("Core Brain") then
						state.CoreBrainSubmissionAwaiting = true
						state.LastRaceCheck = -math.huge
						state.LastRaceCheckOk = false
						state.LastRemote.Submit = os.clock()
						log("Core Brain consumed; waiting for CyborgTrainer Check=true.")
					else
						log("Core Brain was not consumed by RaidSummon; will retry.")
					end
				end
			end
			return
		end

		local raidUnlocked = isRaidUnlocked()
		if not workflowActive("Cyborg") then return end
		if not raidUnlocked then
			stopFastAttack()
			cleanupMovement()
			if hasItem("Fist of Darkness") then
				setStage("submit Fist of Darkness")
				if (getRoot().Position - RaidButtonCFrame.Position).Magnitude > 14 then
					moveTo(RaidButtonCFrame)
					return
				end
				if os.clock() - (state.LastRemote.Submit or 0) >= 1 and equipItem("Fist of Darkness") then
					task.wait(0.3)
					if not workflowActive("Cyborg") then return end
					interactWithRaidButton(button, true)
				end
				return
			end
			setStage("collect chests for Fist of Darkness")
			collectChest()
			return
		end

		local order = findOrder()
		if order then
			setStage("fight Order for Core Brain")
			fightOrder(order)
			return
		end
		stopFastAttack()
		cleanupMovement()
		if not hasItem("Microchip") then
			setStage("buy Law Microchip")
			buyLawChip()
			return
		end
		setStage("summon Order")
		if (getRoot().Position - RaidButtonCFrame.Position).Magnitude > 14 then
			moveTo(RaidButtonCFrame)
			return
		end
		if os.clock() - (state.LastRemote.Summon or 0) >= 5 then
			assert(equipItem("Microchip"), "Microchip could not be equipped")
			clickPart(button)
			state.LastRemote.Summon = os.clock()
		end
	end, debug.traceback)
	if state.Generation ~= generation then return end
	state.Busy = false
	if not ok then
		if os.clock() - (state.LastErrorLog or 0) >= 5 then
			state.LastErrorLog = os.clock()
			log(err)
			notify("Workflow error; see executor console.", "error", 5)
		end
	end
end)

local runSoulGuitarStep = LPH_JIT(function()
	if state.Busy or not workflowActive("SoulGuitar") then return end
	if state.HopPending then
		if os.clock() - (state.LastRemote.Hop or 0) < 20 then return end
		state.HopPending = false
	end
	if os.clock() < state.NextAction then return end
	state.NextAction = os.clock() + Config.ActionDelay
	state.Busy = true
	local ok, err = xpcall(function()
		if state.SoulGuitarOwned or hasItem("Skull Guitar") or hasItem("Soul Guitar") then
			state.SoulGuitarOwned = true
			setStage("Soul Guitar already owned")
			stopFastAttack()
			cleanupMovement()
			notify("Soul Guitar is already owned; completed.", "soul-owned", 5)
			return
		end
		local counts = inventoryCounts()
		local owned = soulGuitarOwned(counts)
		if not workflowActive("SoulGuitar") then return end
		if owned then
			setStage("Soul Guitar already owned")
			stopFastAttack()
			cleanupMovement()
			notify("Soul Guitar is already owned; completed.", "soul-owned", 5)
			return
		end
		if not ensureTeam() then setStage("join team"); return end
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not getRoot() or not humanoid or humanoid.Health <= 0 then
			stopFastAttack()
			cleanupMovement()
			return
		end
		local plan = soulGuitarPlan(false, counts, nil, getFragments())
		if plan == "dark-fragment" then getDarkFragment(); return end
		if plan == "ectoplasm" then farmMaterial("Ectoplasm"); return end
		if plan == "bones" then farmMaterial("Bones"); return end
		local data = player:FindFirstChild("Data")
		local level = data and data:FindFirstChild("Level")
		assert(level and type(level.Value) == "number", "Data.Level is unavailable")
		if level.Value < Config.MinSoulGuitarLevel then
			setStage("Soul Guitar: waiting for level 2300")
			stopFastAttack()
			cleanupMovement()
			notify("Soul Guitar puzzle requires level 2300; material farming is complete.", "soul-level", 5)
			return
		end
		if not travelToSea3() then return end
		local progress = getPuzzleProgress()
		if not workflowActive("SoulGuitar") then return end
		plan = soulGuitarPlan(false, counts, progress, getFragments())
		if plan == "puzzle" then guitarPuzzleStep(progress); return end
		stopFastAttack()
		cleanupMovement()
		if plan == "fragments" then
			setStage("Soul Guitar: waiting for 5000 Fragments")
			notify("Need at least 5000 Fragments to buy Soul Guitar.", "soul-fragments", 5)
			return
		end
		if plan == "buy" and os.clock() - (state.LastRemote.SoulBuy or 0) >= 5 then
			setStage("buy Soul Guitar")
			state.LastRemote.SoulBuy = os.clock()
			local response = invokeCommF("soulGuitarBuy")
			log("Soul Guitar buy response: " .. tostring(response))
			state.InventoryReadAt = -math.huge
			state.LastRemote.SoulOwnership = -math.huge
		end
	end, debug.traceback)
	if state.Generation ~= generation then return end
	state.Busy = false
	if not ok then
		stopFastAttack()
		cleanupMovement()
		if os.clock() - (state.LastSoulErrorLog or 0) >= 5 then
			state.LastSoulErrorLog = os.clock()
			log(err)
			notify("Soul Guitar workflow error; see executor console.", "soul-error", 5)
		end
	end
end)

assert(type(env) == "table", "getgenv() is unavailable")
assert(type(loadstring) == "function", "Executor loadstring is unavailable")
local bootstrapDeadline = os.clock() + 120
repeat
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	if remotes and remotes:FindFirstChild("CommF_") then ensureTeam() end
	if state.Generation ~= generation then return end
	if player:FindFirstChild("DataLoaded") and remotes and remotes:FindFirstChild("CommF_") then
		break
	end
	task.wait(0.5)
until os.clock() >= bootstrapDeadline
assert(player:FindFirstChild("DataLoaded"), "LocalPlayer.DataLoaded did not appear within 120 seconds")
assert(ReplicatedStorage:FindFirstChild("Remotes"), "ReplicatedStorage.Remotes is unavailable")
assert(ReplicatedStorage.Remotes:FindFirstChild("CommF_"), "ReplicatedStorage.Remotes.CommF_ is unavailable")

env.CyborgCodex = env.CyborgCodex or {}
env.CyborgCodex.Run = runStep
env.CyborgCodex.Start = function()
	env.cyborgrace = true
	log("Cyborg workflow enabled.")
end
env.CyborgCodex.Stop = function()
	env.cyborgrace = false
	if state.ActiveWorkflow == "Cyborg" then
		state.HopPending = false
		stopFastAttack()
		cleanupMovement()
	end
	log("Cyborg workflow disabled.")
end
env.SoulGuitarCodex = {
	Run = runSoulGuitarStep,
	Start = function() env.autosoulguitar = true; log("Soul Guitar workflow enabled.") end,
	Stop = function()
		env.autosoulguitar = false
		if state.ActiveWorkflow == "SoulGuitar" then
			state.HopPending = false
			stopFastAttack()
			cleanupMovement()
		end
		log("Soul Guitar workflow disabled.")
	end,
}

env.BossFarmCodex = {
	Run = BossFarm.Step,
	Start = function()
		env.autofarmboss = true
		BossFarm.Cancel()
		log("Boss farming enabled.")
	end,
	Stop = function()
		env.autofarmboss = false
		if state.ActiveWorkflow ~= "Ghoul" then BossFarm.Cancel(); BossFarm.SetStatus("Idle") end
	end,
}

env.GhoulCodex = {
	Run = Ghoul.Step,
	Start = function()
		env.autoghoulrace = true
		state.GhoulChangeAttempted = false
		state.GhoulExchangeAwaiting = nil
		state.GhoulCheckResult = nil
		state.LastRemote.GhoulCheck = nil
		Ghoul.Trace("Queued")
		Ghoul.SetStatus("Queued")
		log("Ghoul workflow enabled.")
	end,
	Stop = function()
		env.autoghoulrace = false
		if state.ActiveWorkflow == "Ghoul" then BossFarm.Cancel(); stopFastAttack(); cleanupMovement() end
		Ghoul.Trace("Stopped")
		Ghoul.SetStatus("Stopped")
		log("Ghoul workflow disabled.")
	end,
}

env.HakiCodex = {
	Run = Haki.Step,
	Start = function()
		env.autohakilegendary = true
		Haki.Cancel(); Haki.Completed = false; Haki.ReadAt = -math.huge; Haki.DealerAt = -math.huge
		Haki.CraftingAt = -math.huge
		Haki.NextHop = nil; Haki.ConfirmUntil = nil; Haki.SetStatus("Queued")
	end,
	Stop = function()
		env.autohakilegendary = false
		Haki.Cancel(); Haki.SetStatus("Stopped")
	end,
}

env.TTKCodex = {
	Run = TTK.Step,
	Start = function()
		env.autottk = true
		TTK.Cancel(); TTK.ReadAt = -math.huge; state.TTKCompleted = false
		TTK.SetStatus("Queued")
	end,
	Stop = function()
		env.autottk = false
		TTK.Cancel(); TTK.SetStatus("Stopped")
	end,
}

for name, controller in pairs(SwordGet.States) do
	local workflow, entry = name, controller
	env[name .. "Codex"] = {
		Run = function() SwordGet.Step(workflow) end,
		Start = function()
			env[entry.Flag] = true
			SwordGet.Cancel(workflow); entry.Completed = false; entry.RewardUntil = nil; entry.Target = nil
			if workflow == "Tushita" then entry.HydraReady = false end
			entry.ProgressAt = -math.huge; TTK.ReadAt = -math.huge
			SwordGet.SetStatus(workflow, "Queued")
		end,
		Stop = function()
			env[entry.Flag] = false
			SwordGet.Cancel(workflow); SwordGet.SetStatus(workflow, "Stopped")
		end,
	}
end

do
	function GameEvents.SetStatus(name, message)
		local entry = GameEvents.States[name]
		if entry.Status ~= message then entry.Status = message; log(name .. ": " .. message) end
	end

	function GameEvents.Cancel(name)
		local entry = GameEvents.States[name]
		entry.Epoch += 1
		if entry.Request then state.HopPending = false end
		entry.Request = nil
		entry.WaitSince, entry.Character, entry.Target = nil, nil, nil
		entry.PickupSince, entry.RewardUntil = nil, nil
		entry.NextHop = 0
	end

	function GameEvents.FruitKey(tool)
		if not tool or not tool:IsA("Tool") or not tool.Name:find("Fruit", 1, true) then return nil end
		local original = tool:GetAttribute("OriginalName")
		local value = tool:FindFirstChild("OriginalName")
		if type(original) ~= "string" and value and value:IsA("StringValue") then original = value.Value end
		local ok, fruitInfo = pcall(function() return require(ReplicatedStorage.FruitInfo) end)
		local list = ok and fruitInfo.List
		if not list then return nil end
		if type(original) == "string" and list[original] then return original end
		local name = tool.Name:gsub(" Fruit$", "")
		local key = name .. "-" .. name
		return list[key] and key or nil
	end

	function GameEvents.CarriedFruit()
		local fruits = {}
		for _, container in pairs({ player.Character, player:FindFirstChild("Backpack") }) do
			for _, tool in ipairs(container:GetChildren()) do
				if GameEvents.FruitKey(tool) then fruits[#fruits + 1] = tool end
			end
		end
		return fruits
	end

	GameEvents.StorageSnapshot = LPH_JIT(function(force)
		if not force and GameEvents.StorageCache and os.clock() - (GameEvents.StorageAt or 0) < 1 then return GameEvents.StorageCache end
		local ok, snapshot = pcall(function()
			local service = require(ReplicatedStorage.ItemReplicationService)
			local config = require(ReplicatedStorage.ItemConfig)
			local rows = service:GetItems(service.KEYS.QUANTITY)
			assert(type(rows) == "table", "Stored fruit quantities are unavailable")
			local counts = {}
			for _, item in pairs(rows) do
				assert(type(item.Value) == "number", "Stored fruit quantity is invalid")
				if item.Value > 0 then
					local info = config.match(item.ItemId):asNullable()
					assert(type(info) == "table", "Stored fruit item metadata is unavailable")
					if info.State and info.State.StorageMethod == "StoredFruits" then
						local key = info.Index and info.Index.StorageKey
						assert(type(key) == "string", "Stored fruit key is unavailable")
						counts[key] = (counts[key] or 0) + item.Value
					end
				end
			end
			local data = player:FindFirstChild("Data")
			local cap = data and data:FindFirstChild("FruitCap")
			local limit = cap and tonumber(cap.Value)
			return { Counts = counts, Limit = limit and limit >= 1 and limit or nil }
		end)
		if not ok then
			GameEvents.StorageCache = nil
			if os.clock() - (GameEvents.StorageErrorAt or -math.huge) >= 5 then
				GameEvents.StorageErrorAt = os.clock()
				reportControllerError(snapshot, "FruitSafe", "Inventory")
			end
			return nil
		end
		GameEvents.StorageCache, GameEvents.StorageAt = snapshot, os.clock()
		return snapshot
	end)

	GameEvents.PendingFruit = LPH_JIT(function(name, force)
		local carried = GameEvents.CarriedFruit()
		if #carried == 0 then return carried end
		local snapshot = GameEvents.StorageSnapshot(force)
		carried = GameEvents.CarriedFruit()
		local pending = {}
		for _, tool in ipairs(carried) do
			local key = GameEvents.FruitKey(tool)
			local count = snapshot and key and snapshot.Counts[key]
			local duplicate = (name == "Pirate" or name == "Factory") and count and count >= 1
			local full = count and snapshot.Limit and count >= snapshot.Limit
			if not duplicate and not full then pending[#pending + 1] = tool end
		end
		return pending
	end)

	GameEvents.StoreStep = LPH_JIT(function()
		if env.AutoStoreFruit ~= true or state.Generation ~= generation then return end
		local snapshot = GameEvents.StorageSnapshot()
		if not snapshot or not snapshot.Limit then return end
		for _, tool in ipairs(GameEvents.CarriedFruit()) do
			local key = GameEvents.FruitKey(tool)
			if not key then continue end
			if (snapshot.Counts[key] or 0) >= snapshot.Limit then continue end
			if os.clock() >= (GameEvents.StoreRetry[tool] or 0) then
				if env.AutoStoreFruit ~= true or state.Generation ~= generation then return end
				if tool.Parent ~= player.Character and tool.Parent ~= player:FindFirstChild("Backpack") then return end
				GameEvents.StoreRetry[tool] = os.clock() + 15
				local result = invokeCommF("StoreFruit", key, tool)
				GameEvents.StorageCache = nil
				log("Store Fruit: " .. key .. " | response " .. tostring(result))
				if tool.Parent == player.Character or tool.Parent == player:FindFirstChild("Backpack") then
					notify("Store requested for " .. key .. "; waiting for inventory confirmation.", "fruit-store-" .. key, 15)
				end
				return
			end
		end
	end)

	function GameEvents.FindFruit()
		local root = getRoot()
		if not root then return nil end
		local best, distance
		local candidates = workspace:GetChildren()
		local folder = workspace:FindFirstChild("Fruits")
		if folder and folder:IsA("Folder") then
			for _, fruit in ipairs(folder:GetChildren()) do candidates[#candidates + 1] = fruit end
		end
		for _, fruit in ipairs(candidates) do
			if (fruit:IsA("Tool") or fruit:IsA("Model")) and fruit.Name:find("Fruit", 1, true)
				and os.clock() >= (GameEvents.FruitIgnored[fruit] or 0) then
				local handle = fruit:FindFirstChild("Handle")
				if handle and handle:IsA("BasePart") then
					local delta = (root.Position - handle.Position).Magnitude
					if not distance or delta < distance then best, distance = fruit, delta end
				end
			end
		end
		return best
	end

	function GameEvents.FindTarget(name)
		if name == "Fruit" then return GameEvents.FindFruit() end
		if name == "Berry" then return GameEvents.States.Berry.Target or GameEvents.FindBerry(true) end
		if name == "Factory" then return BossFarm.FindIn(workspace:FindFirstChild("Enemies"), { Names = { "Core" } }) end
		local entry, root = GameEvents.States.Pirate, getRoot()
		local enemies = workspace:FindFirstChild("Enemies")
		if not enemies then return nil end
		local best, distance
		for _, mob in ipairs(enemies:GetChildren()) do
			local part = mob:FindFirstChild("HumanoidRootPart")
			local hum = mob:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 and part and (part.Position - GameEvents.Castle.Position).Magnitude <= 1000
				and not mob.Name:find("Boss", 1, true) and not mob.Name:find("Friend", 1, true)
				and not mob.Name:find("Wraith", 1, true) and not mob.Name:lower():find("rip_indra", 1, true)
				and mob.Name ~= "Oni2" then
				if mob == entry.Target then return mob end
				local delta = root and (part.Position - root.Position).Magnitude or 0
				if not distance or delta < distance then best, distance = mob, delta end
			end
		end
		return best
	end

	function GameEvents.FindBerry(includeDeferred)
		local root = getRoot()
		if not root then return nil end
		local best, distance
		for _, bush in ipairs(CollectionService:GetTagged("BerryBush")) do
			if bush:IsDescendantOf(workspace) then
				for slot, berry in pairs(bush:GetAttributes()) do
					if slot:match("^_BerryCFrame%d+$") and type(berry) == "string" and berry ~= "" then
						local position = Haki.BerryPosition(bush, slot, berry)
						local ignored = GameEvents.BerryIgnored[bush]
						local retryAt = ignored and ignored[slot] or 0
						if position and (includeDeferred or os.clock() >= retryAt) then
							local delta = (root.Position - position.Position).Magnitude
							if not distance or delta < distance then
								best, distance = { Bush = bush, BushId = bush.Parent.Name, Slot = slot, Berry = berry, Position = position, Attempts = 0 }, delta
							end
						end
					end
				end
			end
		end
		return best
	end

	GameEvents.BerryStep = LPH_JIT(function()
		local entry, root = GameEvents.States.Berry, getRoot()
		if not root or not workflowActive("Berry") then return end
		local target = entry.Target
		if not target then target = GameEvents.FindBerry(); entry.Target = target end
		if not target then
			cleanupMovement()
			if GameEvents.FindBerry(true) then
				entry.WaitSince = nil
				GameEvents.SetStatus("Berry", "Waiting to retry uncollected berries"); return
			end
			entry.WaitSince = entry.WaitSince or os.clock()
			if os.clock() - entry.WaitSince < 8 then
				GameEvents.SetStatus("Berry", "No berries found; waiting for replication"); return
			end
			GameEvents.Hop("Berry"); return
		end
		entry.WaitSince = nil
		if entry.Request then GameEvents.Cancel("Berry"); entry.Target = target end
		target.BushId = target.BushId or (target.Bush.Parent and target.Bush.Parent.Name)
		local bush = target.Bush
		if not bush:IsDescendantOf(workspace) then
			for _, candidate in ipairs(CollectionService:GetTagged("BerryBush")) do
				if candidate.Parent and candidate.Parent.Name == target.BushId and candidate:IsDescendantOf(workspace) then
					bush = candidate; target.Bush = candidate; break
				end
			end
		end
		local replicated = bush:IsDescendantOf(workspace) and Haki.BerryPosition(bush, target.Slot, target.Berry)
		if replicated then target.Position = replicated end
		local position = target.Position
		if (root.Position - position.Position).Magnitude > 10 then
			GameEvents.SetStatus("Berry", "Flying to " .. target.Berry)
			moveTo(position + Vector3.new(0, 2, 0)); return
		end
		cleanupMovement()
		if not replicated then
			if target.LastClaimSucceeded or (target.Attempts > 0 and bush:IsDescendantOf(workspace)
				and bush:GetAttribute(target.Slot) ~= target.Berry) then
				entry.Target = nil; return
			end
			target.MissingSince = target.MissingSince or os.clock()
			if not target.StreamRequested then
				target.StreamRequested = true
				task.spawn(function()
					local ok, err = pcall(function() player:RequestStreamAroundAsync(position.Position, 5) end)
					if not ok and workflowActive("Berry") then log("Berry streaming request: " .. tostring(err)) end
				end)
			end
			if os.clock() - target.MissingSince < 8 then
				GameEvents.SetStatus("Berry", "At berry position; waiting for bush replication"); return
			end
			GameEvents.SetStatus("Berry", "Berry no longer present at destination; checking next target")
			entry.Target = nil; return
		end
		target.MissingSince = nil
		GameEvents.SetStatus("Berry", "Collecting " .. target.Berry)
		if os.clock() < (entry.NextClaim or 0) or os.clock() < (target.VerifyUntil or 0) then return end
		if target.Attempts >= 3 then
			local ignored = GameEvents.BerryIgnored[target.Bush] or {}
			GameEvents.BerryIgnored[target.Bush] = ignored
			ignored[target.Slot] = os.clock() + 30
			entry.Target = nil
			GameEvents.SetStatus("Berry", "Collection not confirmed; retrying this berry in 30 seconds"); return
		end
		local epoch, character = entry.Epoch, player.Character
		GameEvents.ClaimRemote = GameEvents.ClaimRemote or require(ReplicatedStorage.Modules.Net):RemoteFunction("ClaimBerry")
		if not workflowActive("Berry") or getRoot() ~= root or not target.Bush.Parent then return end
		entry.NextClaim = os.clock() + 0.5
		target.Attempts += 1
		local result = GameEvents.ClaimRemote:InvokeServer(target.BushId, target.Slot)
		if not workflowActive("Berry") or entry.Epoch ~= epoch or player.Character ~= character then return end
		target.LastClaimSucceeded = result == true
		target.VerifyUntil = os.clock() + (result and 2 or 0.5)
	end)

	GameEvents.RandomStep = LPH_JIT(function()
		if env.AutoRandomFruit ~= true or state.Generation ~= generation or state.HopPending
			or os.clock() < (GameEvents.NextRandom or 0) then return end
		for _, entry in pairs(GameEvents.States) do if entry.Request then return end end
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 or not player.Team then return end
		GameEvents.NextRandom = os.clock() + 15
		local box = "ZiolesGacha"
		local bannerModule = ReplicatedStorage.Controllers:FindFirstChild("BannerClient")
		if bannerModule then
			local banner = require(bannerModule)
			if type(banner.TryGetBannerItemIfActiveAsync) == "function" then
				local item = banner.TryGetBannerItemIfActiveAsync()
				if type(item) == "table" and type(item.BoxName) == "string" then box = item.BoxName end
			end
		end
		GameEvents.GachaRemote = GameEvents.GachaRemote or require(ReplicatedStorage.Modules.Net):RemoteFunction("GachaNetworkRF")
		local check = GameEvents.GachaRemote:InvokeServer({ Context = "Check", BoxName = box,
			SpokeNPC = box == "ZiolesGacha" and "Blox Fruit Gacha" or nil })
		if type(check) ~= "table" or check.RequirementsMet ~= true then return end
		if env.AutoRandomFruit ~= true or state.Generation ~= generation or state.HopPending
			or player.Character ~= character or humanoid.Health <= 0 then return end
		for _, entry in pairs(GameEvents.States) do if entry.Request then return end end
		local result = GameEvents.GachaRemote:InvokeServer({ Context = "Purchase", BoxName = box })
		if state.Generation ~= generation then return end
		log("Random Fruit: " .. box .. " | response " .. tostring(result))
	end)

	function GameEvents.Position(value)
		local parts = type(value) == "table" and value or {}
		if type(value) == "string" then
		for number in value:gmatch("[^,%s]+") do
			local parsed = tonumber(number)
			if not parsed then return nil end
			parts[#parts + 1] = parsed
		end
		end
		if #parts < 3 then return nil end
		local x, y, z = tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3])
		if not x or not y or not z or x ~= x or y ~= y or z ~= z or math.abs(x) > 1000000 or math.abs(y) > 1000000 or math.abs(z) > 1000000 then return nil end
		return CFrame.new(x, y, z)
	end

	function GameEvents.SelectServer(data, name)
		local targetSea = GameEvents.States[name].Sea or currentSea()
		for job, visitedAt in pairs(state.BossVisited) do
			if type(visitedAt) ~= "number" or os.time() - visitedAt >= BossFarm.VisitedSeconds then state.BossVisited[job] = nil end
		end
		for _, server in ipairs(data) do
			if type(server) == "table" then
				local job = BossFarm.DecodeJobId(server.Jobid or server.JobId or server.Job_id or server.jobId)
				local place = tonumber(server.place_id or server.PlaceId or server.placeId)
				local playing, maximum = tostring(server.players or server.Players or ""):match("^(%d+)%s*/%s*(%d+)$")
				playing, maximum = tonumber(playing) or tonumber(server.playing), tonumber(maximum) or tonumber(server.maxPlayers)
				if job and job ~= game.JobId and not state.BossVisited[job] and SeaByPlaceId[place] == targetSea
					and (not playing or not maximum or playing < maximum) then
					return job, place, name == "Fruit" and GameEvents.Position(server.cframe or server.CFrame) or nil
				end
			end
		end
	end

	function GameEvents.CanHop(name, request)
		local entry = GameEvents.States[name]
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		local allowed = workflowActive(name) and entry.Request == request and entry.Epoch == request.Epoch
			and not GameEvents.RandomBusy
			and game.JobId == request.JobId and player.Character == request.Character
			and currentSea() == request.Sea and humanoid and humanoid.Health > 0
			and not BossFarm.HasProtectedItem() and not hasItem("Holy Torch")
			and #GameEvents.PendingFruit(name, true) == 0 and not GameEvents.FindTarget(name)
		return allowed and workflowActive(name) and entry.Request == request and entry.Epoch == request.Epoch
			and not GameEvents.RandomBusy
			and game.JobId == request.JobId and player.Character == request.Character and currentSea() == request.Sea
			and humanoid.Health > 0 and not BossFarm.HasProtectedItem() and not hasItem("Holy Torch")
	end

	function GameEvents.Hop(name)
		local entry = GameEvents.States[name]
		if name == "Berry" and entry.Target then return end
		if entry.Request or state.HopPending or GameEvents.RandomBusy or os.clock() < (entry.NextHop or 0) then return end
		if BossFarm.HasProtectedItem() or hasItem("Holy Torch") or #GameEvents.PendingFruit(name, true) > 0 then
			GameEvents.SetStatus(name, "Hop paused: store carried fruit / keep protected items safe"); return
		end
		if #GameEvents.CarriedFruit() > 0 then
			notify("Carried fruit is already stored or storage is full; continuing API hop. Unstored duplicates may be lost.", "event-fruit-duplicate-hop", 15)
		end
		local request = { Epoch = entry.Epoch, Sea = currentSea(), JobId = game.JobId, Character = player.Character }
		entry.Request = request
		entry.NextHop = os.clock() + 15
		GameEvents.SetStatus(name, "Searching " .. entry.Slug .. " server API")
		task.spawn(function()
			local ok, err = xpcall(function()
				local data = BossFarm.FetchServers(entry.Slug)
				if not GameEvents.CanHop(name, request) then return end
				local job, _, hint = GameEvents.SelectServer(data, name)
				if not job then GameEvents.SetStatus(name, "No available API server; retrying in 15 seconds"); return end
				if not GameEvents.CanHop(name, request) then return end
				local browser = ReplicatedStorage:FindFirstChild("__ServerBrowser")
				assert(browser and browser:IsA("RemoteFunction"), "ReplicatedStorage.__ServerBrowser is unavailable")
				if name == "Fruit" then entry.Hint = hint and { JobId = job, Position = { hint.X, hint.Y, hint.Z } } or nil end
				queueResume()
				if not GameEvents.CanHop(name, request) then return end
				state.BossVisited[job] = os.time()
				state.HopPending = true
				request.Teleporting = true
				GameEvents.SetStatus(name, "Joining event server")
				assert(browser:InvokeServer("teleport", job) ~= false, "Event server teleport rejected")
				task.delay(25, function()
					if state.Generation == generation and entry.Request == request then
						entry.Request = nil; state.HopPending = false
						GameEvents.SetStatus(name, "Transfer timed out; retrying")
					end
				end)
			end, debug.traceback)
			if entry.Request == request and (not ok or not request.Teleporting) then entry.Request = nil; state.HopPending = false end
			if not ok and state.Generation == generation then reportControllerError(err, name, "APIHop") end
		end)
	end

	function GameEvents.Pickup(fruit)
		local entry, root = GameEvents.States.Fruit, getRoot()
		local handle = fruit and fruit:FindFirstChild("Handle")
		if not handle or not root then return end
		if entry.Target ~= fruit then entry.Target = fruit; entry.PickupSince = nil end
		GameEvents.SetStatus("Fruit", "Collecting " .. fruit.Name)
		if (root.Position - handle.Position).Magnitude > 8 then moveTo(handle.CFrame); return end
		cleanupMovement()
		entry.PickupSince = entry.PickupSince or os.clock()
		local touch = env.firetouchinterest or firetouchinterest
		if type(touch) == "function" and os.clock() >= (entry.NextTouch or 0) then
			entry.NextTouch = os.clock() + 1
			touch(root, handle, 0); touch(root, handle, 1)
		elseif type(touch) ~= "function" then
			local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
			if humanoid then humanoid:MoveTo(handle.Position) end
		end
		if os.clock() - entry.PickupSince > 10 then
			GameEvents.FruitIgnored[fruit] = os.clock() + 30
			entry.Target, entry.PickupSince = nil, nil
			GameEvents.SetStatus("Fruit", "Pickup not confirmed; retrying this fruit later")
		end
	end

	GameEvents.FindIsland = LPH_JIT(function(name)
		local entry = GameEvents.States[name]
		local map = workspace:FindFirstChild("Map")
		local island = map and map:FindFirstChild(entry.Island)
		if island then return island end
		local origin = workspace:FindFirstChild("_WorldOrigin")
		local locations = origin and origin:FindFirstChild("Locations")
		return locations and locations:FindFirstChild(entry.Location)
	end)

	GameEvents.IslandDestination = LPH_JIT(function(name, island)
		local entry = GameEvents.States[name]
		local pivot = island:GetAttribute("CFrame")
		if typeof(pivot) ~= "CFrame" then
			if island:IsA("Model") then pivot = island:GetPivot()
			elseif island:IsA("BasePart") then pivot = island.CFrame end
		end
		if typeof(pivot) ~= "CFrame" then return nil end
		if name == "Kitsune" then
			local shrine = island:FindFirstChild("ShrineDialogPart", true)
			if shrine and shrine:IsA("BasePart") then return shrine.CFrame + Vector3.new(0, 4, 0), true end
			local inactive = island:FindFirstChild("ShrineInactive", true)
			if inactive and inactive:IsA("Model") then return inactive:GetPivot() + Vector3.new(0, 4, 0), true end
			return pivot + Vector3.new(0, 80, 0), false
		end
		local npcs = workspace:FindFirstChild("NPCs")
		local npc = npcs and npcs:FindFirstChild(entry.NPC)
		local part = npc and npc:FindFirstChild("HumanoidRootPart")
		if part and part:IsA("BasePart") and (part.Position - pivot.Position).Magnitude < 2500 then
			return part.CFrame * CFrame.new(0, 0, 6), true
		end
		local spawn = island:FindFirstChild(name == "Volcanic" and "FossilExpertSpawn" or entry.NPC, true)
		if spawn and spawn:IsA("BasePart") then return spawn.CFrame + Vector3.new(0, 4, 0), true end
		return pivot + Vector3.new(0, 80, 0), false
	end)

	GameEvents.IslandStep = LPH_JIT(function(name)
		local island = GameEvents.FindIsland(name)
		if not island then
			cleanupMovement()
			GameEvents.SetStatus(name, "Waiting for island to spawn in this server")
			return
		end
		local goal, landed = GameEvents.IslandDestination(name, island)
		local root = getRoot()
		if not goal or not root then
			cleanupMovement()
			GameEvents.SetStatus(name, "Waiting for island position replication")
			return
		end
		if (root.Position - goal.Position).Magnitude > 8 then
			GameEvents.SetStatus(name, landed and "Tweening to " .. (GameEvents.States[name].NPC or "Kitsune shrine") or "Approaching island; waiting for target replication")
			moveTo(goal)
		elseif landed then
			cleanupMovement()
			GameEvents.SetStatus(name, "Arrived at island")
		else
			cancelMovement()
			setNoClip(false)
			setFloat(true)
			GameEvents.SetStatus(name, "At island; waiting for target replication")
		end
	end)

	GameEvents.Step = LPH_JIT(function(name)
		if not workflowActive(name) then return end
		local entry, character = GameEvents.States[name], player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local root = getRoot()
		if not root or not humanoid or humanoid.Health <= 0 then GameEvents.Cancel(name); return end
		if entry.Character ~= character then GameEvents.Cancel(name); entry.Character = character end
		if state.HopPending then return end
		if entry.Island then GameEvents.IslandStep(name); return end
		if name == "Berry" then GameEvents.BerryStep(); return end
		if entry.Sea and currentSea() ~= entry.Sea then
			if #GameEvents.PendingFruit(name, true) > 0 or BossFarm.HasProtectedItem() then
				GameEvents.SetStatus(name, "Travel paused: store fruit / protect carried items"); return
			end
			GameEvents.SetStatus(name, "Traveling to Sea " .. entry.Sea)
			if entry.Sea == 2 then travelToSea2() else travelToSea3() end
			return
		end
		local target = GameEvents.FindTarget(name)
		if target then
			entry.WaitSince = nil
			if name == "Fruit" then GameEvents.Pickup(target)
			else
				entry.Target = target
				entry.RewardUntil = os.clock() + 5
				GameEvents.SetStatus(name, "Fighting " .. target.Name)
				fightMob(target)
			end
			return
		end
		stopFastAttack()
		if entry.RewardUntil and os.clock() < entry.RewardUntil then
			GameEvents.SetStatus(name, "Waiting for event reward"); return
		end
		if #GameEvents.PendingFruit(name) > 0 then
			cleanupMovement()
			GameEvents.SetStatus(name, env.AutoStoreFruit == true and "Waiting for fruit storage" or "Fruit collected; enable Auto Store Fruit before hopping")
			return
		end
		local goal = name == "Pirate" and GameEvents.Castle or name == "Factory" and GameEvents.Factory
		if name == "Fruit" and type(entry.Hint) == "table" and entry.Hint.JobId == game.JobId then goal = GameEvents.Position(entry.Hint.Position) end
		if goal and not entry.WaitSince then
			GameEvents.SetStatus(name, "Approaching " .. (name == "Pirate" and "Castle gate" or name == "Factory" and "Factory" or "API fruit position"))
			if (root.Position - goal.Position).Magnitude > 60 then moveTo(goal); return end
			cleanupMovement()
		end
		entry.WaitSince = entry.WaitSince or os.clock()
		local waitSeconds = name == "Pirate" and 15 or name == "Fruit" and goal and 15 or 8
		local remaining = waitSeconds - (os.clock() - entry.WaitSince)
		if remaining > 0 then GameEvents.SetStatus(name, "Waiting for event replication (" .. math.ceil(remaining) .. "s)"); return end
		GameEvents.Hop(name)
	end)

	env.EventFarmCodex = GameEvents
end

do
	PullLever.SetStatus = LPH_JIT(function(message)
		if PullLever.Status ~= message then
			PullLever.Status = message
			log("Auto Pull Level: " .. message)
		end
	end)

	PullLever.RestoreCamera = LPH_JIT(function()
		local saved = PullLever.Camera
		PullLever.Camera = nil
		PullLever.MoonSince = nil
		if saved and saved.Instance.Parent then
			saved.Instance.CameraType = saved.Type
			saved.Instance.CameraSubject = saved.Subject and saved.Subject.Parent and saved.Subject
				or (player.Character and player.Character:FindFirstChildOfClass("Humanoid"))
		end
	end)

	PullLever.ClearFakeV3 = LPH_JIT(function()
		local emitter = PullLever.FakeV3Emitter
		PullLever.FakeV3Emitter = nil
		if emitter then emitter:Destroy() end
	end)

	PullLever.FakeV3 = LPH_JIT(function()
		if not workflowActive("PullLever") then return nil end
		local root = getRoot()
		if not root then return nil end
		local existing = root:FindFirstChild("Agility")
		if existing then return existing end
		PullLever.ClearFakeV3()
		local emitter = Instance.new("ParticleEmitter")
		emitter.Acceleration = Vector3.new(0, 0, 0)
		emitter.Archivable = true
		emitter.Drag = 20
		emitter.EmissionDirection = Enum.NormalId.Top
		emitter.Enabled = true
		emitter.Lifetime = NumberRange.new(0, 0)
		emitter.LightInfluence = 0
		emitter.LockedToPart = true
		emitter.Name = "Agility"
		emitter.Rate = 500
		emitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 4) })
		emitter.RotSpeed = NumberRange.new(9999, 99999)
		emitter.Rotation = NumberRange.new(0, 0)
		emitter.Speed = NumberRange.new(30, 30)
		emitter.SpreadAngle = Vector2.new(0, 0)
		emitter.Texture = "rbxassetid://243098098"
		emitter.VelocityInheritance = 0
		emitter.ZOffset = 2
		emitter.Transparency = NumberSequence.new(0)
		emitter.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromRGB(0, 0, 0))
		PullLever.FakeV3Emitter = emitter
		emitter.Parent = root
		return emitter
	end)

	PullLever.Cancel = LPH_JIT(function()
		PullLever.Epoch += 1
		if PullLever.Request then state.HopPending = false end
		PullLever.Request, PullLever.WaitSince, PullLever.RewardUntil = nil, nil, nil
		PullLever.ActionPending = nil
		for _, call in pairs(PullLever.Calls) do
			if call.Thread and not call.Done then pcall(task.cancel, call.Thread) end
		end
		PullLever.Calls = {}
		PullLever.RestoreCamera()
		PullLever.ClearFakeV3()
		BossFarm.ClearMirror()
	end)

	PullLever.Poll = LPH_JIT(function(command, action)
		if not workflowActive("PullLever") then return false end
		local key = command .. ":" .. tostring(action)
		local now = os.clock()
		local call = PullLever.Calls[key]
		if call then
			if not call.Done and now - call.At >= 8 then
				if call.Thread then pcall(task.cancel, call.Thread) end
				call.Done, call.Ok, call.Error, call.FinishedAt = true, false, "Remote timed out: " .. key, now
				reportControllerError(call.Error, "PullLever", "Remote")
			end
			if not call.Done then return false end
			if now - call.FinishedAt < (call.Ok and 2 or 5) then return call.Ok, call.Value end
		end
		call = { At = now, Epoch = PullLever.Epoch }
		PullLever.Calls[key] = call
		call.Thread = task.spawn(function()
			if not workflowActive("PullLever") or call.Epoch ~= PullLever.Epoch then return end
			local ok, value = pcall(function()
				if action == nil then return invokeCommF(command) end
				return invokeCommF(command, action)
			end)
			if call.Done or state.Generation ~= generation or call.Epoch ~= PullLever.Epoch
				or PullLever.Calls[key] ~= call then return end
			call.Done, call.Ok, call.Value, call.FinishedAt = true, ok, value, os.clock()
			if not ok then reportControllerError(value, "PullLever", "Remote") end
		end)
		return false
	end)

	PullLever.Read = LPH_JIT(function()
		local progressReady, progress = PullLever.Poll("RaceV4Progress", "Check")
		local doorReady, door = PullLever.Poll("CheckTempleDoor")
		if not progressReady or not doorReady or not tonumber(progress) or type(door) ~= "boolean" then
			PullLever.SetStatus("Waiting for verified RaceV4Progress / CheckTempleDoor")
			return nil
		end
		return { Progress = tonumber(progress), Door = door }
	end)

	PullLever.Advance = LPH_JIT(function(action)
		stopFastAttack(); cleanupMovement()
		PullLever.ActionPending = action
		PullLever.Poll("RaceV4Progress", action)
	end)

	PullLever.AwaitTransition = LPH_JIT(function()
		if not PullLever.ActionPending then return false end
		local ready = PullLever.Poll("RaceV4Progress", PullLever.ActionPending)
		if not ready then
			PullLever.SetStatus("Waiting for ancient tablet transition: " .. PullLever.ActionPending)
			return true
		end
		PullLever.ActionPending = nil
		for _, key in ipairs({ "RaceV4Progress:Check", "CheckTempleDoor:nil" }) do
			local call = PullLever.Calls[key]
			if call and call.Thread and not call.Done then pcall(task.cancel, call.Thread) end
			PullLever.Calls[key] = nil
		end
		return true
	end)

	PullLever.Items = LPH_JIT(function(force)
		if not force and PullLever.Inventory and os.clock() - PullLever.InventoryAt < 2 then return PullLever.Inventory end
		local service = require(ReplicatedStorage.ItemReplicationService)
		local config = require(ReplicatedStorage.ItemConfig)
		local owned = { Helm = false, Fractal = false }
		for _, key in ipairs({ service.KEYS.IS_OWNED, service.KEYS.QUANTITY }) do
			local rows = service:GetItems(key)
			assert(type(rows) == "table", "Pull Level inventory is unavailable")
			for _, item in pairs(rows) do
				if item.Value == true or (type(item.Value) == "number" and item.Value > 0) then
					local data = config.match(item.ItemId):asNullable()
					assert(type(data) == "table" and type(data.Index) == "table", "Pull Level item metadata is unavailable")
					local name = data.Index.StorageKey
					if name == "Valkyrie Helm" then owned.Helm = true end
					if name == "Mirror Fractal" then owned.Fractal = true end
				end
			end
		end
		PullLever.Inventory, PullLever.InventoryAt = owned, os.clock()
		return owned
	end)

	PullLever.Plan = LPH_JIT_MAX(function(level, owned, progress, door, completed)
		if completed then return "Complete" end
		if level < 1500 then return "Level" end
		if door == true then return "Lever" end
		if not owned.Helm then return "Helm" end
		if not owned.Fractal then return "Fractal" end
		if progress == 1 then return "Begin" end
		if progress == 2 then return "Tree" end
		if progress == 3 then return "Continue" end
		if progress == 4 then return "Mirage" end
		return "Unknown"
	end)

	PullLever.Approach = LPH_JIT(function(goal, radius)
		local root = getRoot()
		if not root then return false end
		if (root.Position - goal.Position).Magnitude > (radius or 8) then
			moveTo(goal, false, radius)
			return false
		end
		cleanupMovement()
		return true
	end)

	PullLever.CanHop = LPH_JIT(function(request)
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not workflowActive("PullLever") or PullLever.Request ~= request or PullLever.Epoch ~= request.Epoch
			or game.JobId ~= request.JobId or currentSea() ~= 3 or character ~= request.Character
			or not humanoid or humanoid.Health <= 0 or not getRoot()
			or BossFarm.HasProtectedItem() or hasItem("Holy Torch") or #GameEvents.CarriedFruit() > 0 then return false end
		local items = PullLever.Items(true)
		if request.Goal == "Helm" then
			return not items.Helm and not BossFarm.FindActive(BossFarm.Definitions["Rip Indra"])
		elseif request.Goal == "Fractal" then
			return items.Helm and not items.Fractal and not BossFarm.FindActive(BossFarm.Definitions["Dough King"])
		end
		local door = PullLever.Calls["CheckTempleDoor:nil"]
		local progress = PullLever.Calls["RaceV4Progress:Check"]
		return items.Helm and items.Fractal and door and door.Done and door.Ok and door.Value == false
			and progress and progress.Done and progress.Ok and tonumber(progress.Value) == 4
			and not GameEvents.FindIsland("Mirage")
	end)

	PullLever.Hop = LPH_JIT(function(goal, slug)
		if PullLever.Request or state.HopPending or os.clock() < (PullLever.NextHop or 0) then return end
		local request = { Goal = goal, Epoch = PullLever.Epoch, JobId = game.JobId, Character = player.Character }
		PullLever.Request = request
		PullLever.NextHop = os.clock() + 15
		PullLever.SetStatus("Searching " .. slug .. " API")
		task.spawn(function()
			local ok, err = xpcall(function()
				if not PullLever.CanHop(request) then return end
				local data = BossFarm.FetchServers(slug)
				if not PullLever.CanHop(request) then return end
				local definition = goal == "Helm" and BossFarm.Definitions["Rip Indra"]
					or goal == "Fractal" and BossFarm.Definitions["Dough King"] or { Slug = "mirage", Names = { "Mirage", "Mirage Island" } }
				local job = BossFarm.SelectServer(data, definition)
				if not job then PullLever.SetStatus("No matching API server; retrying in 15s"); return end
				local browser = ReplicatedStorage:FindFirstChild("__ServerBrowser")
				assert(browser and browser:IsA("RemoteFunction"), "__ServerBrowser is unavailable")
				queueResume()
				if not PullLever.CanHop(request) then return end
				request.Teleporting = true
				state.HopPending = true
				state.BossVisited[job], state.BossVisited[game.JobId] = os.time(), os.time()
				PullLever.SetStatus("Joining " .. slug .. " server")
				assert(browser:InvokeServer("teleport", job) ~= false, "Pull Level teleport rejected")
				task.delay(25, function()
					if state.Generation == generation and PullLever.Request == request then
						PullLever.Request = nil; state.HopPending = false
						PullLever.SetStatus("Transfer timed out; retrying")
					end
				end)
			end, debug.traceback)
			if PullLever.Request == request and (not ok or not request.Teleporting) then
				PullLever.Request = nil; state.HopPending = false
			end
			if not ok and state.Generation == generation then reportControllerError(err, "PullLever", "APIHop") end
		end)
	end)

	PullLever.Boss = LPH_JIT(function(goal)
		local name = goal == "Helm" and "Rip Indra" or "Dough King"
		local definition = BossFarm.Definitions[name]
		local target = BossFarm.FindActive(definition)
		if target then
			PullLever.WaitSince = nil
			PullLever.RewardUntil = os.clock() + 5
			if not BossFarm.EnterMirror(definition, "PullLever") then return end
			PullLever.SetStatus("Fighting " .. name .. " for " .. (goal == "Helm" and "Valkyrie Helm" or "Mirror Fractal"))
			fightMob(target)
			return
		end
		stopFastAttack()
		if os.clock() < (PullLever.RewardUntil or 0) then PullLever.SetStatus("Waiting for boss reward replication"); return end
		if definition.Mirror and BossFarm.FindIn(ReplicatedStorage, definition) then
			if not BossFarm.EnterMirror(definition, "PullLever") then return end
			PullLever.WaitSince = PullLever.WaitSince or os.clock()
			PullLever.SetStatus("Waiting for Dough King replication inside Mirror Dimension")
			if os.clock() - PullLever.WaitSince < 8 then return end
			PullLever.Hop(goal, definition.Slug)
			return
		end
		local gate = goal == "Helm" and GameEvents.Castle or BossFarm.GetMirrorGate()
		PullLever.SetStatus("Approaching " .. (goal == "Helm" and "Castle gate" or "Cake Island gate"))
		if not PullLever.Approach(gate) then return end
		PullLever.WaitSince = PullLever.WaitSince or os.clock()
		if os.clock() - PullLever.WaitSince < 8 then return end
		PullLever.Hop(goal, definition.Slug)
	end)

	PullLever.FindGear = LPH_JIT(function(island)
		for _, part in ipairs(island:GetDescendants()) do
			if part:IsA("MeshPart") and part.MeshId:match("10153114969$") and part.Transparency < 1 and not part.CanCollide then return part end
		end
	end)

	PullLever.HighestPoint = LPH_JIT(function(island)
		local highest, height
		for _, part in ipairs(island:GetDescendants()) do
			if part:IsA("MeshPart") and part.MeshId:match("6745037796$") then return part.CFrame * CFrame.new(0, 211.88, 0) end
			if part:IsA("Model") and part.Name ~= "BiggTree" then
				local cf = part:GetPivot()
				if not height or cf.Y > height then highest, height = cf, cf.Y end
			end
		end
		return highest and highest + Vector3.new(0, 210, 0)
	end)

	PullLever.MoonVisible = LPH_JIT(function()
		local lighting = game:GetService("Lighting")
		return (lighting.ClockTime >= 18 or lighting.ClockTime < 6) and lighting:GetMoonDirection().Y > 0
	end)

	PullLever.LookMoon = LPH_JIT(function()
		if not PullLever.MoonVisible() then
			PullLever.RestoreCamera()
			PullLever.SetStatus("Waiting for the moon on Mirage Island")
			return
		end
		local camera = workspace.CurrentCamera
		if not camera then return end
		if not PullLever.Camera then
			PullLever.Camera = { Instance = camera, Type = camera.CameraType, Subject = camera.CameraSubject }
			PullLever.MoonSince = os.clock()
			camera.CameraType = Enum.CameraType.Scriptable
		end
		cancelMovement(); setNoClip(false); setFloat(true)
		PullLever.SetStatus("Locking moon / activating Race V3")
		if os.clock() - PullLever.MoonSince < 3 or os.clock() - (PullLever.LastV3 or -math.huge) < 40 then return end
		local ability
		for _, name in ipairs({ "Last Resort", "Agility", "Water Body", "Heavenly Blood", "Energy Core", "Heightened Senses" }) do
			if findCharacterTool(name) then ability = true; break end
		end
		if not ability then notify("Auto Pull Level requires Race V3 ability.", "pull-v3-required", 5); return end
		PullLever.LastV3 = os.clock()
		state.LastRaceV3Attempt = PullLever.LastV3
		pressGameKey(Enum.KeyCode.T)
		PullLever.FakeV3()
	end)

	PullLever.Mirage = LPH_JIT(function()
		local island = GameEvents.FindIsland("Mirage")
		if not island then
			PullLever.RestoreCamera()
			PullLever.SetStatus("Approaching Tiki Outpost gate before Mirage API hop")
			if PullLever.Approach(PullLever.Tiki) then PullLever.Hop("Mirage", "mirage") end
			return
		end
		local gear = PullLever.FindGear(island)
		if gear then
			PullLever.RestoreCamera()
			PullLever.ClearFakeV3()
			PullLever.SetStatus("Collecting Blue Gear; waiting for CheckTempleDoor confirmation")
			moveTo(gear.CFrame, false, 3)
			return
		end
		local peak = PullLever.HighestPoint(island)
		if not peak then
			PullLever.RestoreCamera()
			GameEvents.IslandStep("Mirage")
			PullLever.SetStatus("Approaching Mirage / waiting for peak and gear replication")
			return
		end
		if not getRoot() or (getRoot().Position - peak.Position).Magnitude > 8 then
			PullLever.RestoreCamera()
			PullLever.SetStatus("Tweening to highest Mirage point")
			moveTo(peak)
			return
		end
		PullLever.LookMoon()
	end)

	PullLever.TempleMap = LPH_JIT(function()
		local map = workspace:FindFirstChild("Map")
		local temple = map and map:FindFirstChild("Temple of Time")
		return temple and not temple:GetAttribute("ClientBorrowed") and temple or nil
	end)

	PullLever.Pulled = LPH_JIT(function(temple)
		local group = temple and temple:FindFirstChild("Lever")
		local lever = group and group:FindFirstChild("Lever")
		return lever and lever:IsA("BasePart") and math.abs(lever.Position.Z - PullLever.LeverClosedZ) <= 0.2 or false
	end)

	PullLever.Finish = LPH_JIT(function()
		PullLever.Completed = true
		PullLever.Cancel()
		stopFastAttack(); cleanupMovement()
		PullLever.SetStatus("Completed: Temple lever pulled")
		notify("Auto Pull Level completed: Temple lever pulled.", "pull-level-complete", 5)
	end)

	PullLever.CheckCompletion = LPH_JIT(function(progress)
		PullLever.RestoreCamera()
		PullLever.ClearFakeV3()
		stopFastAttack(); cleanupMovement()
		local temple = PullLever.TempleMap()
		if progress and progress.Door == true and PullLever.Pulled(temple) then
			PullLever.Finish()
			return
		end
		PullLever.SetStatus(temple and "Waiting for player to pull the lever; automatic pulling disabled"
			or "Gear unlocked; waiting for replicated player lever status; no automatic teleport or pull")
	end)

	PullLever.Step = LPH_JIT(function()
		if not workflowActive("PullLever") then return end
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 or not getRoot() then PullLever.Cancel(); return end
		if PullLever.Character ~= character then PullLever.Cancel(); PullLever.Character = character end
		local level = player:FindFirstChild("Data") and player.Data:FindFirstChild("Level")
		if not level or level.Value < 1500 then
			stopFastAttack(); cleanupMovement(); PullLever.SetStatus("Stopped: requires level 1500+")
			notify("Auto Pull Level requires level 1500 or higher.", "pull-level-required", 5)
			return
		end
		if currentSea() ~= 3 then PullLever.SetStatus("Traveling to Sea 3"); travelToSea3(); return end
		if state.HopPending then return end
		if PullLever.AwaitTransition() then return end
		local progress = PullLever.Read()
		if not progress then return end
		if progress.Door == true and PullLever.Pulled(PullLever.TempleMap()) then
			PullLever.Finish(); return
		end
		local owned = PullLever.Items()
		local goal = PullLever.Plan(level.Value, owned, progress.Progress, progress.Door, PullLever.Completed)
		if goal ~= PullLever.Goal then
			stopFastAttack(); cleanupMovement(); PullLever.RestoreCamera()
			PullLever.Goal, PullLever.WaitSince, PullLever.RewardUntil = goal, nil, nil
		end
		if goal == "Helm" or goal == "Fractal" then PullLever.Boss(goal)
		elseif goal == "Begin" or goal == "Continue" then
			PullLever.SetStatus("Ancient tablet: RaceV4Progress " .. goal)
			PullLever.Advance(goal)
		elseif goal == "Tree" then
			PullLever.SetStatus("Ancient tablet: approaching Great Tree")
			if PullLever.Approach(PullLever.Tree) then PullLever.Advance("Teleport") end
		elseif goal == "Mirage" then PullLever.Mirage()
		elseif goal == "Lever" then PullLever.CheckCompletion(progress)
		else PullLever.SetStatus("Unknown RaceV4Progress; no hop or trial action") end
	end)

	state.Connections[#state.Connections + 1] = RunService.RenderStepped:Connect(function()
		local saved = PullLever.Camera
		if not saved then return end
		if not workflowActive("PullLever") or not PullLever.MoonVisible() or not GameEvents.FindIsland("Mirage") then
			PullLever.RestoreCamera(); return
		end
		local direction = game:GetService("Lighting"):GetMoonDirection()
		saved.Instance.CFrame = CFrame.lookAt(saved.Instance.CFrame.Position, saved.Instance.CFrame.Position + direction)
	end)

	env.PullLevelCodex = {
		Run = PullLever.Step,
		Start = function()
			env.AutoPullLevel = true; PullLever.Cancel(); PullLever.Completed = false
			PullLever.NextHop, PullLever.Inventory = nil, nil; PullLever.SetStatus("Queued")
		end,
		Stop = function()
			env.AutoPullLevel = false; PullLever.Cancel()
			if state.ActiveWorkflow == "PullLever" then stopFastAttack(); cleanupMovement() end
			PullLever.SetStatus("Stopped")
		end,
	}
end

local function releaseWorkflow()
	PullLever.Cancel()
	BossFarm.Cancel()
	TTK.Cancel()
	Haki.Cancel()
	for name in pairs(GameEvents.States) do GameEvents.Cancel(name) end
	for name in pairs(SwordGet.States) do SwordGet.Cancel(name) end
	stopFastAttack()
	cleanupMovement()
	state.ActiveWorkflow = nil
	state.Stage = nil
	state.CurrentChest = nil
	state.CurrentChestSince = nil
	state.ZombieBatch = nil
	state.PuzzleReadAt = nil
	state.HopPending = false
	state.BossSelection = nil
	state.GhoulTarget = nil
	state.GhoulRewardUntil = nil
	state.GhoulExchangeAwaiting = nil
end

local SettingManager = {}
local fileAPI = {
	isfolder = env.isfolder or isfolder,
	makefolder = env.makefolder or makefolder,
	isfile = env.isfile or isfile,
	readfile = env.readfile or readfile,
	writefile = env.writefile or writefile,
}

function SettingManager:SetFolder(folder)
	for _, name in ipairs({ "isfolder", "makefolder", "isfile", "readfile", "writefile" }) do
		assert(type(fileAPI[name]) == "function", "Executor " .. name .. " is unavailable; cannot save config")
	end
	self.CurrentFolder = folder
	self.AutoSave = folder .. "/Main"
	self.Config = folder .. "/ConfigMain"
	self.AutoLoad = self.AutoSave .. "/" .. player.Name .. ".txt"
	self.AutoData = self.Config .. "/" .. player.Name .. ".json"
	self.AutoConfig = self.AutoData
	for _, directory in ipairs({ folder, self.AutoSave, self.Config }) do
		if not fileAPI.isfolder(directory) then fileAPI.makefolder(directory) end
	end
	self.Ready = true
end

function SettingManager:LoadAutoConfig()
	assert(self.Ready, "Config storage has not initialized")
	if not fileAPI.isfile(self.AutoLoad) then
		fileAPI.writefile(self.AutoLoad, self.AutoData)
	else
		local path = fileAPI.readfile(self.AutoLoad)
		assert(path == self.AutoData, "Unexpected CyborgCodex auto-load config path")
		self.AutoConfig = path
	end
	if not fileAPI.isfile(self.AutoConfig) then return nil end
	local data = HttpService:JSONDecode(fileAPI.readfile(self.AutoConfig))
	assert(type(data) == "table" and type(data.Setting) == "table", "Invalid CyborgCodex config schema")
	for _, key in ipairs({ "cyborgrace", "autosoulguitar" }) do
		assert(type(data.Setting[key]) == "boolean", "Config " .. key .. " must be boolean")
	end
	for _, key in ipairs({ "autofarmboss", "autofarmbosshop", "autoghoulrace", "autottk", "autoyama", "autotushita", "autocdk", "autohakilegendary",
		"autofactoryhop", "autopirateraidhop", "autofruithop", "autoberryhop", "AutoRandomFruit", "AutoStoreFruit", "TeleportMirageIsland", "TeleportVolcanicIsland", "TeleportKitsuneIsland", "AutoPullLevel" }) do
		if data.Setting[key] == nil then data.Setting[key] = false end
		assert(type(data.Setting[key]) == "boolean", "Config " .. key .. " must be boolean")
	end
	if data.Setting.SelectedWeapon == nil then data.Setting.SelectedWeapon = "Melee" end
	if data.Setting.Team == nil then data.Setting.Team = "Marines" end
	assert(data.Setting.Team == "Pirates" or data.Setting.Team == "Marines", "Config Team is invalid")
	assert(table.find({ "Melee", "Sword", "Fruit", "Gun" }, data.Setting.SelectedWeapon), "Config SelectedWeapon is invalid")
	for _, key in ipairs({ "AutoBuso", "TurnOnRaceV3", "TurnOnRaceV4", "TurnOnObservationHaki" }) do
		if data.Setting[key] == nil then data.Setting[key] = key == "AutoBuso" end
		assert(type(data.Setting[key]) == "boolean", "Config " .. key .. " must be boolean")
	end
	if data.Setting.selectedboss == nil then data.Setting.selectedboss = BossFarm.List[1] end
	assert(BossFarm.Definitions[data.Setting.selectedboss], "Config selectedboss is invalid")
	return data
end

function SettingManager:Save()
	assert(self.Ready, "Config storage is unavailable")
	assert(type(env.cyborgrace) == "boolean" and type(env.autosoulguitar) == "boolean", "Workflow flags must be boolean")
	assert(type(env.autofarmboss) == "boolean" and type(env.autofarmbosshop) == "boolean", "Boss flags must be boolean")
	assert(type(env.autoghoulrace) == "boolean", "Ghoul flag must be boolean")
	assert(type(env.autottk) == "boolean", "TTK flag must be boolean")
	assert(type(env.autoyama) == "boolean" and type(env.autotushita) == "boolean", "Sword workflow flags must be boolean")
	assert(type(env.autocdk) == "boolean", "CDK flag must be boolean")
	assert(type(env.autohakilegendary) == "boolean", "Haki flag must be boolean")
	for _, key in ipairs({ "autofactoryhop", "autopirateraidhop", "autofruithop", "autoberryhop", "AutoRandomFruit", "AutoStoreFruit", "TeleportMirageIsland", "TeleportVolcanicIsland", "TeleportKitsuneIsland", "AutoPullLevel" }) do
		assert(type(env[key]) == "boolean", key .. " must be boolean")
	end
	assert(BossFarm.Definitions[env.selectedboss], "Boss selection is invalid")
	assert(env.Team == "Pirates" or env.Team == "Marines", "Team selection is invalid")
	assert(table.find({ "Melee", "Sword", "Fruit", "Gun" }, env.SelectedWeapon), "Weapon selection is invalid")
	for _, key in ipairs({ "AutoBuso", "TurnOnRaceV3", "TurnOnRaceV4", "TurnOnObservationHaki" }) do
		assert(type(env[key]) == "boolean", key .. " must be boolean")
	end
	fileAPI.writefile(self.AutoData, HttpService:JSONEncode({
		Setting = { Team = env.Team, cyborgrace = env.cyborgrace, autosoulguitar = env.autosoulguitar,
			autoghoulrace = env.autoghoulrace, autottk = env.autottk,
			autoyama = env.autoyama, autotushita = env.autotushita,
			autocdk = env.autocdk,
			autohakilegendary = env.autohakilegendary,
			autofactoryhop = env.autofactoryhop, autopirateraidhop = env.autopirateraidhop,
			autofruithop = env.autofruithop, AutoStoreFruit = env.AutoStoreFruit,
			autoberryhop = env.autoberryhop, AutoRandomFruit = env.AutoRandomFruit,
			TeleportMirageIsland = env.TeleportMirageIsland, TeleportVolcanicIsland = env.TeleportVolcanicIsland,
			TeleportKitsuneIsland = env.TeleportKitsuneIsland,
			AutoPullLevel = env.AutoPullLevel,
			autofarmboss = env.autofarmboss, autofarmbosshop = env.autofarmbosshop, selectedboss = env.selectedboss,
			SelectedWeapon = env.SelectedWeapon, AutoBuso = env.AutoBuso, TurnOnRaceV3 = env.TurnOnRaceV3,
			TurnOnRaceV4 = env.TurnOnRaceV4, TurnOnObservationHaki = env.TurnOnObservationHaki },
	}))
	fileAPI.writefile(self.AutoLoad, self.AutoData)
end

local ui
local function withUIContext(callback)
	local getter = env.getthreadidentity or getthreadidentity or getidentity
	local setter = env.setthreadidentity or setthreadidentity or setidentity
	local previous
	if ui and ui.Identity and type(getter) == "function" and type(setter) == "function" then
		previous = getter()
		setter(ui.Identity)
	end
	local ok, result = xpcall(callback, debug.traceback)
	if previous ~= nil then setter(previous) end
	if not ok then error(result, 0) end
	return result
end
local function saveUISettings()
	local ok, err = pcall(function() SettingManager:Save() end)
	if not ok then
		log("Config save failed: " .. tostring(err))
		notify("Config save failed; see executor console.", "config-save-error", 5)
	end
	return ok
end

local function sharedWorkflowStatus()
	local owner=state.ActiveWorkflow
	if not owner then return "TEDDY HUB  ·  READY","idle" end
	local title,message
	if owner=="Ghoul" then title,message="AUTO GHOUL",state.GhoulStatus
	elseif owner=="PullLever" then title,message="AUTO PULL LEVEL",PullLever.Status
	elseif owner=="Haki" then title,message="AUTO HAKI LEGENDARY",Haki.Status
	elseif owner=="Boss" then title,message="BOSS FARM",state.BossStatus
	elseif GameEvents.States[owner] then title,message=GameEvents.States[owner].Title,GameEvents.States[owner].Status
	elseif owner=="TTK" then title,message="AUTO TTK",TTK.Status
	elseif SwordGet.States[owner] then title,message="AUTO "..string.upper(owner),SwordGet.States[owner].Status
	elseif owner=="Cyborg" or owner=="SoulGuitar" then
		title=owner=="Cyborg" and "AUTO CYBORG" or "AUTO SOUL GUITAR"
		message=state.Stage
	end
	message=tostring(message or state.Stage or "Starting")
	local lower=string.lower(message)
	local kind="active"
	if lower:find("error",1,true) or lower:find("failed",1,true) or lower:find("cannot",1,true) then kind="error"
	elseif lower:find("wait",1,true) or lower:find("idle",1,true) or lower:find("checking",1,true)
		or lower:find("need ",1,true) or lower:find("not found",1,true) then kind="waiting"
	elseif lower:find("complete",1,true) or lower:find("owned",1,true) or lower:find("success",1,true) then kind="success" end
	return title.."  ·  "..message,kind
end

local function createDynamicStatusIsland()
	local playerGui=player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui",10)
	if not playerGui then return nil end
	local old=playerGui:FindFirstChild("CyborgCodexDynamicIsland")
	if old then old:Destroy() end
	local displayOrder=1
	for _,child in ipairs(playerGui:GetChildren()) do
		if child:IsA("ScreenGui") then displayOrder=math.max(displayOrder,child.DisplayOrder+1) end
	end
	local gui=Instance.new("ScreenGui")
	gui.Name="CyborgCodexDynamicIsland"
	gui.ResetOnSpawn=false
	gui.IgnoreGuiInset=true
	gui.ScreenInsets=Enum.ScreenInsets.None
	gui.DisplayOrder=displayOrder
	gui.Parent=playerGui
	local pill=Instance.new("Frame")
	pill.Name="StatusIsland"
	pill.AnchorPoint=Vector2.new(.5,0)
	pill.Position=UDim2.new(.5,0,0,8)
	pill.Size=UDim2.fromOffset(124,30)
	pill.BackgroundColor3=Color3.fromRGB(18,18,18)
	pill.BorderSizePixel=0
	pill.ClipsDescendants=true
	pill.Parent=gui
	Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
	local stroke=Instance.new("UIStroke",pill)
	stroke.Color=Color3.fromRGB(65,65,65)
	stroke.Thickness=1
	local dot=Instance.new("Frame",pill)
	dot.Name="StatusDot"
	dot.Position=UDim2.fromOffset(12,11)
	dot.Size=UDim2.fromOffset(8,8)
	dot.BorderSizePixel=0
	Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
	local label=Instance.new("TextLabel",pill)
	label.Name="StatusText"
	label.Position=UDim2.fromOffset(30,0)
	label.Size=UDim2.new(1,-42,1,0)
	label.BackgroundTransparency=1
	label.TextColor3=Color3.fromRGB(238,238,242)
	label.Font=Enum.Font.GothamBold
	label.TextSize=10
	label.TextXAlignment=Enum.TextXAlignment.Center
	label.TextTruncate=Enum.TextTruncate.AtEnd
	local colors={idle=Color3.fromRGB(145,145,150),active=Color3.fromRGB(190,65,255),
		waiting=Color3.fromRGB(245,185,80),success=Color3.fromRGB(85,220,150),error=Color3.fromRGB(255,100,110)}
	local textService=game:GetService("TextService")
	local lastText,lastKind,sizeTween,colorTween
	local function refresh()
		if not gui.Parent then return end
		local text,kind=sharedWorkflowStatus()
		if text~=lastText then
			lastText=text;label.Text=text
			local measured=textService:GetTextSize(text,10,Enum.Font.GothamBold,Vector2.new(1000,30))
			local camera=workspace.CurrentCamera
			local maxWidth=math.max(150,math.min(420,(camera and camera.ViewportSize.X or 480)-24))
			local width=math.clamp(math.ceil(measured.X)+54,124,maxWidth)
			if sizeTween then sizeTween:Cancel() end
			sizeTween=TweenService:Create(pill,TweenInfo.new(.2,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(width,30)})
			sizeTween:Play()
		end
		if kind~=lastKind then
			lastKind=kind;dot.BackgroundColor3=colors[kind]
			if colorTween then colorTween:Cancel() end
			colorTween=TweenService:Create(stroke,TweenInfo.new(.2),{Color=kind=="idle" and Color3.fromRGB(65,65,65) or colors[kind]})
			colorTween:Play()
		end
	end
	local elapsed=0
	local connection=RunService.Heartbeat:Connect(function(dt)
		elapsed+=dt
		if elapsed>=.15 then elapsed=0;refresh() end
	end)
	gui.Destroying:Connect(function()
		connection:Disconnect()
		if sizeTween then sizeTween:Cancel() end
		if colorTween then colorTween:Cancel() end
	end)
	refresh()
	return gui
end

local syncUISettings = LPH_JIT(function()
	if not ui or ui.Fluent.Unloaded then return end
	local changed = false
	ui.Syncing = true
	local ok, err = xpcall(function() withUIContext(function()
		for key, toggle in pairs(ui.Toggles) do
			local value = env[key] == true
			if toggle.Value ~= value then toggle:SetValue(value) end
			if ui.LastFlags[key] ~= value then changed = true end
			ui.LastFlags[key] = value
		end
		if ui.WeaponDropdown and ui.WeaponDropdown.Value ~= env.SelectedWeapon then
			ui.WeaponDropdown:SetValue(env.SelectedWeapon)
			changed = true
		end
		if ui.TeamDropdown and ui.TeamDropdown.Value ~= env.Team then
			ui.TeamDropdown:SetValue(env.Team)
			changed = true
		end
		if ui.BossDropdown and BossFarm.Definitions[env.selectedboss] then
			if ui.BossDropdown.Value ~= env.selectedboss then ui.BossDropdown:SetValue(env.selectedboss) end
			if ui.LastBoss ~= env.selectedboss then changed = true end
			ui.LastBoss = env.selectedboss
		end
	end) end, debug.traceback)
	ui.Syncing = false
	if not ok then error(err) end
	if changed then saveUISettings() end
end)

do
	function ServerPanel.Duration(seconds)
		seconds = math.max(0, math.floor(seconds or 0))
		return string.format("%02d:%02d:%02d", math.floor(seconds / 3600), math.floor(seconds / 60) % 60, seconds % 60)
	end

	function ServerPanel.ReadStatus()
		local origin = workspace:FindFirstChild("_WorldOrigin")
		local locations = origin and origin:FindFirstChild("Locations")
		local map = workspace:FindFirstChild("Map")
		local earliest
		if locations then
			for _, location in ipairs(locations:GetChildren()) do
				local timeIn = location:GetAttribute("TimeIn")
				if type(timeIn) == "number" and (not earliest or timeIn < earliest) then earliest = timeIn end
			end
		end
		local age = earliest and math.max(0, workspace:GetServerTimeNow() - earliest)
		local sky = game:GetService("Lighting"):FindFirstChildOfClass("Sky")
		local moonId = sky and sky.MoonTextureId:match("(%d+)$")
		local moon = moonId == "9709149431" and "Full Moon" or moonId == "9709149052" and "Next Night" or "Other Phase"
		local clock = game:GetService("Lighting").ClockTime
		local present = function(container, name) return container and container:FindFirstChild(name) and "Present" or "Not found" end
		local elites = {}
		for _, name in ipairs(SwordGet.Elites) do
			if BossFarm.FindIn(workspace:FindFirstChild("Enemies"), { Names = { name } }) then elites[#elites + 1] = name end
		end
		local eyes, found = 0, 0
		local tiki = map and map:FindFirstChild("TikiOutpost")
		for index = 1, 4 do
			local eye = tiki and tiki:FindFirstChild("Eye" .. index, true)
			if eye and eye:IsA("BasePart") then found += 1; if eye.Transparency == 1 then eyes += 1 end end
		end
		local status = {
			Timer = ServerPanel.Duration(os.clock() - ServerPanel.Started),
			ServerTimer = age and (ServerPanel.Duration(age) .. " (location estimate)") or "Unavailable",
			NextSpawn = age and (ServerPanel.Duration(14400 - age % 14400) .. " (4-hour estimate)") or "Unavailable",
			Elite = #elites > 0 and table.concat(elites, ", ") or "Not found",
			Tyrant = currentSea() == 3 and (found > 0 and (eyes .. "/4 eyes") or "Island not loaded") or "Sea 3 only",
			CakePrince = "Sea 3 only", Leviathan = "Sea 3 only", AncientOne = "Sea 3 only",
			Mirage = present(map, "MysticIsland"), Prehistoric = present(map, "PrehistoricIsland"),
			Frozen = present(locations, "Frozen Dimension"),
			Moon = moon .. string.format(" | %02d:%02d | %s", math.floor(clock), math.floor(clock % 1 * 60),
				(clock >= 18 or clock < 5) and "Night" or "Day"),
			Server = string.format("Sea %s | %d players\nPlaceId: %s\nJobId: %s", tostring(currentSea()), #Players:GetPlayers(), tostring(game.PlaceId), game.JobId),
		}
		if currentSea() == 3 then
			local ok, cake = pcall(invokeCommF, "CakePrinceSpawner", true)
			status.CakePrince = ok and type(cake) == "string" and (cake:match("%d+") and (cake:match("%d+") .. " mobs remaining")
				or cake:gsub("<[^>]+>", "")) or "Unavailable"
			local spyOK, spy = pcall(invokeCommF, "InfoLeviathan", "1")
			status.Leviathan = spyOK and spy == 5 and "Ready to search" or spyOK and type(spy) == "number"
				and (spy == -1 and "Unavailable" or ("Spy progress: " .. spy .. "/5")) or "Unavailable"
			local character = player.Character
			status.AncientOne = "Race V4 not unlocked"
			if character and character:FindFirstChild("RaceTransformed") then
				local raceOK, code, sessions, price = pcall(invokeCommF, "UpgradeRace", "Check")
				if raceOK then
					if code == 0 then status.AncientOne = "Ready for trial"
					elseif code == 2 or code == 4 or code == 7 then status.AncientOne = "Can buy gear: " .. tostring(price or 0) .. " fragments"
					elseif code == 5 then status.AncientOne = "Race upgrades completed"
					elseif code == 8 then status.AncientOne = tostring(math.max(0, 10 - (sessions or 0))) .. " training sessions remaining"
					elseif code == 6 then status.AncientOne = tostring((sessions or 2) - 2) .. "/3 upgrades; train more"
					else status.AncientOne = "More training required" end
				else status.AncientOne = "Unavailable" end
			end
		end
		return status
	end

	ServerPanel.RefreshStatus = LPH_JIT(function()
		local values = ServerPanel.ReadStatus()
		withUIContext(function()
			for key, value in pairs(values) do
				local label = ServerPanel.Labels[key]
				if label and ServerPanel.LastStatus[key] ~= value then label:SetDesc(value); ServerPanel.LastStatus[key] = value end
			end
		end)
	end)

	function ServerPanel.Fetch(reset)
		if ServerPanel.Fetching then return end
		if not reset and ServerPanel.Finished then return end
		if os.clock() < (ServerPanel.RetryAt or 0) then error("Server API cooldown; try again shortly") end
		ServerPanel.Fetching = true
		local ok, result = xpcall(function()
			local request = (env.syn and env.syn.request) or env.http_request or env.request or http_request or request
			local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId)
			if not reset and ServerPanel.Cursor then url ..= "&cursor=" .. HttpService:UrlEncode(ServerPanel.Cursor) end
			local body
			if type(request) == "function" then
				local response = request({ Url = url, Method = "GET", Timeout = 10 })
				assert(type(response) == "table", "Server API returned no response")
				local code = tonumber(response.StatusCode or response.Status)
				if code == 429 then ServerPanel.RetryAt = os.clock() + 30 end
				assert(not code or code >= 200 and code < 300, "Server API HTTP " .. tostring(code))
				body = response.Body
			else body = game:HttpGet(url) end
			local decoded = HttpService:JSONDecode(body)
			assert(type(decoded.data) == "table", "Invalid server API response")
			if state.Generation ~= generation then return end
			if reset then ServerPanel.Servers = {}; ServerPanel.Seen = {} end
			ServerPanel.Seen = ServerPanel.Seen or {}
			for _, server in ipairs(decoded.data) do
				if BossFarm.IsJobId(server.id) and server.id ~= game.JobId and tonumber(server.playing) and tonumber(server.maxPlayers)
					and server.playing < server.maxPlayers and not ServerPanel.Seen[server.id] then
					ServerPanel.Seen[server.id] = true; ServerPanel.Servers[#ServerPanel.Servers + 1] = server
				end
			end
			ServerPanel.Cursor = decoded.nextPageCursor
			ServerPanel.Finished = not ServerPanel.Cursor or ServerPanel.Cursor == ""
			ServerPanel.RenderServers()
		end, debug.traceback)
		ServerPanel.Fetching = false
		if not ok then error(result, 0) end
	end

	function ServerPanel.RenderServers()
		table.sort(ServerPanel.Servers, function(a, b)
			local x, y = ServerPanel.Sort == "Lowest Ping" and (tonumber(a.ping) or math.huge) or a.playing,
				ServerPanel.Sort == "Lowest Ping" and (tonumber(b.ping) or math.huge) or b.playing
			return x == y and a.id < b.id or x < y
		end)
		local values, choices = {}, {}
		for index, server in ipairs(ServerPanel.Servers) do
			if index > 50 then break end
			local label = string.format("%d/%d | %s ms | %s", server.playing, server.maxPlayers, tostring(server.ping or "?"), server.id:sub(1, 8))
			values[#values + 1] = label; choices[label] = server.id
		end
		ServerPanel.Choices = choices
		withUIContext(function()
			ServerPanel.Dropdown:SetValues(values)
			local selection
			for label, id in pairs(choices) do if id == ServerPanel.Selected then selection = label end end
			ServerPanel.Dropdown:SetValue(selection or values[1])
			ServerPanel.BrowserLabel:SetDesc(#ServerPanel.Servers .. " available servers | " .. (ServerPanel.Finished and "All pages loaded" or "More pages available"))
		end)
	end

	function ServerPanel.Join(value, targetPlace)
		local job = BossFarm.DecodeJobId(value)
		assert(job, "Invalid or unsupported JobId")
		local place = tonumber(targetPlace) or game.PlaceId
		assert(SeaByPlaceId[place], "Unsupported server PlaceId")
		local browser = ReplicatedStorage:FindFirstChild("__ServerBrowser")
		assert(browser and browser:IsA("RemoteFunction"), "ReplicatedStorage.__ServerBrowser is unavailable")
		if state.HopPending then notify("A server transfer is already pending.", "manual-hop-busy", 5); return end
		queueResume(true)
		state.HopPending = true
		local ok, err = pcall(function()
			assert(browser:InvokeServer("teleport", job) ~= false, "Server teleport rejected")
		end)
		if not ok then state.HopPending = false; error(err) end
		task.delay(30, function() if state.Generation == generation then state.HopPending = false end end)
	end

	function ServerPanel.Action(callback)
		task.spawn(function()
			if state.Generation ~= generation then return end
			local ok, err = xpcall(callback, debug.traceback)
			if not ok then reportControllerError(err, "Server", "Action"); notify("Server action failed; see console.", "server-action-error", 5) end
		end)
	end

	ServerPanel.HopEvents = {
		{ "berry", "Berry", "cherry" },
		{ "prehistoric", "Prehistoric Island", "mountain" },
		{ "fullmoon", "Full Moon", "moon" },
		{ "nearmoon", "Near Full Moon", "moon" },
		{ "mirage", "Mirage Island", "compass" },
		{ "kitsune", "Kitsune Island", "flame" },
		{ "fruit", "Fruit Spawns", "apple" },
		{ "haki", "Legendary Haki", "sparkles" },
		{ "sword", "Legendary Sword", "swords" },
		{ "castleraid", "Castle Raid", "castle" },
		{ "factory", "Factory Raid", "factory" },
		{ "4hours", "4 Hours Server", "clock" },
		{ "doughking", "Dough King", "crown" },
		{ "ripindra", "Rip Indra", "swords" },
		{ "cakeprince", "Cake Prince", "crown" },
		{ "soulreaper", "Soul Reaper", "skull" },
		{ "cursedcaptain", "Cursed Captain", "ship" },
		{ "tyrant", "Tyrant of the Skies", "bird" },
		{ "darkbeard", "Darkbeard", "skull" },
		{ "elite", "Elite Hunter", "swords" },
	}
	ServerPanel.HopLists = {}

	function ServerPanel.NormalizeEventServers(data)
		local rows, seen, skipped = {}, {}, 0
		local function escape(value)
			return tostring(value):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
		end
		for _, server in ipairs(data) do
			if type(server) == "table" then
				local job = BossFarm.DecodeJobId(server.Jobid or server.Job_id or server.jobId or server.JobId or server.jobid or server.id)
				local seaText = tostring(server.map or server.MAP or server.Sea or server.sea or "")
				local sea = tonumber(seaText) or tonumber(seaText:lower():match("sea%s*(%d)"))
				local rawPlace = server.place_id or server.placeId or server.PlaceId or server.placeid
				local place = tonumber(rawPlace)
				if not rawPlace then
					if sea and sea ~= currentSea() then
						place = ({ [1] = 2753915549, [2] = 4442272183, [3] = 7449423635 })[sea]
					else place = game.PlaceId end
				end
				sea = SeaByPlaceId[place] or sea
				if job and place and SeaByPlaceId[place] and not seen[job] then
					seen[job] = true
					local name = tostring(server.name or server.Name or "Server")
					local players = tostring(server.players or server.Players or "?")
					local color = sea == currentSea() and "#00FF88" or "#FF3333"
					rows[#rows + 1] = {
						JobId = job, PlaceId = place,
						Title = string.format("[%d] %s%s", #rows + 1, name, job == game.JobId and " [Current]" or ""),
						Description = string.format("Name: %s\nPlayers: %s\nSea: %s\nPlaceId: <font color=\"%s\">%s</font>\nJobId: %s",
							escape(name), escape(players), tostring(sea), color, tostring(place), job),
					}
				elseif not job or not place or not SeaByPlaceId[place] then skipped += 1 end
			else skipped += 1 end
		end
		return rows, skipped
	end

	function ServerPanel.RefreshEvent(entry)
		if entry.Busy or os.clock() < (entry.NextRefresh or 0) then return end
		entry.Busy = true
		entry.NextRefresh = os.clock() + 3
		local ok, err = xpcall(function()
			withUIContext(function() entry.Status:SetDesc("Loading server list...") end)
			local data = BossFarm.FetchServers(entry.Slug)
			if state.Generation ~= generation or not ui or ui.Fluent.Unloaded then return end
			local rows, skipped = ServerPanel.NormalizeEventServers(data)
			for index, server in ipairs(rows) do
				if state.Generation ~= generation or ui.Fluent.Unloaded then return end
				withUIContext(function()
					local item = entry.Buttons[index]
					if not item then
						item = {}
						entry.Buttons[index] = item
						item.Button = entry.Tab:AddButton({ Title = server.Title, Description = server.Description,
							Callback = function()
								local selected = item.Server
								if selected then ServerPanel.Action(function()
									if selected.JobId == game.JobId then
										notify("You are already in this server.", "manual-hop-current", 3)
									else ServerPanel.Join(selected.JobId, selected.PlaceId) end
								end) end
							end,
						})
						item.Button.DescLabel.RichText = true
						item.Button.TitleLabel.RichText = false
					end
					item.Server = server
					item.Button:SetTitle(server.Title)
					item.Button:SetDesc(server.Description)
					item.Button.Frame.Visible = true
				end)
				if index % 12 == 0 then task.wait() end
			end
			withUIContext(function()
				for index = #rows + 1, #entry.Buttons do
					entry.Buttons[index].Server = nil
					entry.Buttons[index].Button.Frame.Visible = false
				end
				entry.Tab.ContainerFrame.CanvasPosition = Vector2.zero
				entry.Status:SetDesc(string.format("%d servers | %d unsupported entries skipped", #rows, skipped))
			end)
			notify(#rows > 0 and string.format("Loaded %d servers for %s.", #rows, entry.Title)
				or "No servers found for " .. entry.Title .. ".", "hop-list-" .. entry.Slug, 3)
		end, debug.traceback)
		entry.Busy = false
		if not ok and state.Generation == generation and ui and not ui.Fluent.Unloaded then
			withUIContext(function() entry.Status:SetDesc("Refresh failed. Previous list retained; see console.") end)
			reportControllerError(err, "Server", entry.Slug)
			notify("Could not load " .. entry.Title .. " servers; see console.", "hop-list-error-" .. entry.Slug, 4)
		end
	end

	function ServerPanel.SetupHopTab(tab, slug, title)
		local entry = { Tab = tab, Slug = slug, Title = title, Buttons = {} }
		ServerPanel.HopLists[slug] = entry
		tab:AddSection(title .. " - Server List")
		tab:AddButton({ Title = "Refresh Server", Description = "Reload server list",
			Callback = function() ServerPanel.Action(function() ServerPanel.RefreshEvent(entry) end) end })
		entry.Status = tab:AddParagraph({ Title = "Server List", Content = "Not loaded" })
		return entry
	end

	function ServerPanel.BuildHopTabs(group)
		for _, event in ipairs(ServerPanel.HopEvents) do
			local tab = group:AddTab({ Title = event[2], Icon = "" })
			ServerPanel.SetupHopTab(tab, event[1], event[2])
		end
	end

	function ServerPanel.Build(window)
		local tab = window:AddTab({ Title = "Status And Server", Icon = "server" })
		ServerPanel.Tab = tab; ServerPanel.LastStatus = {}; ServerPanel.Labels = {}
		tab:AddSection("Status")
		for _, entry in ipairs({ {"Timer", "Session Timer"}, {"ServerTimer", "Server Timer"},
			{"NextSpawn", "Next Fist of Darkness / God's Chalice"}, {"Elite", "Elite Hunter"}, {"Tyrant", "Tyrant Eyes"},
			{"CakePrince", "Cake Prince"}, {"Leviathan", "Leviathan / Spy"}, {"Mirage", "Mirage Island"},
			{"Prehistoric", "Prehistoric Island"}, {"Frozen", "Frozen Dimension"}, {"Moon", "Moon Phase"}, {"AncientOne", "Ancient One"} }) do
			ServerPanel.Labels[entry[1]] = tab:AddParagraph({ Title = entry[2], Content = "Loading..." })
		end
		tab:AddSection("Server")
		ServerPanel.Labels.Server = tab:AddParagraph({ Title = "Current Server", Content = "Loading..." })
		tab:AddInput("ServerJobId", { Title = "Input JobId", Default = "", Placeholder = "JobId", Finished = true,
			Callback = function(value) ServerPanel.Input = tostring(value):match("^%s*(.-)%s*$") end })
		tab:AddButton({ Title = "Join JobId", Callback = function() ServerPanel.Action(function() ServerPanel.Join(ServerPanel.Input) end) end })
		tab:AddButton({ Title = "Copy JobId", Callback = function()
			ServerPanel.Action(function()
				local copy = env.setclipboard or setclipboard or env.toclipboard or toclipboard
				assert(type(copy) == "function", "Clipboard is unavailable"); copy(game.JobId)
				notify("JobId copied.", "jobid-copied", 2)
			end)
		end })
		tab:AddButton({ Title = "Rejoin Server", Callback = function() ServerPanel.Action(function() ServerPanel.Join(game.JobId) end) end })
		ServerPanel.BrowserLabel = tab:AddParagraph({ Title = "Server Browser", Content = "Not loaded" })
		local sort = tab:AddDropdown("ServerSort", { Title = "Sort Servers", Values = { "Lowest Players", "Lowest Ping" }, Multi = false, Default = "Lowest Players" })
		ServerPanel.Dropdown = tab:AddDropdown("ServerSelection", { Title = "Selected Server", Values = {}, Multi = false })
		ServerPanel.Dropdown:OnChanged(function(value) ServerPanel.Selected = ServerPanel.Choices[value] end)
		sort:OnChanged(function(value) ServerPanel.Sort = value; ServerPanel.RenderServers() end)
		for _, entry in ipairs({ {"Open Server Browser / Refresh", true}, {"Load More Servers", false} }) do
			local reset = entry[2]
			tab:AddButton({ Title = entry[1], Callback = function() ServerPanel.Action(function() ServerPanel.Fetch(reset) end) end })
		end
		tab:AddButton({ Title = "Join Selected Server", Callback = function() ServerPanel.Action(function() ServerPanel.Join(ServerPanel.Selected) end) end })
		for _, title in ipairs({ "Hop Server", "Hop Server Less People" }) do
			local less = title == "Hop Server Less People"
			tab:AddButton({ Title = title, Callback = function() ServerPanel.Action(function()
				ServerPanel.Sort = "Lowest Players"; ServerPanel.Fetch(true)
				assert(#ServerPanel.Servers > 0, "No available server found")
				ServerPanel.Join(ServerPanel.Servers[less and 1 or math.random(#ServerPanel.Servers)].id)
			end) end })
		end
		task.spawn(function()
			while state.Generation == generation and ui and not ui.Fluent.Unloaded do
				local ok, err = xpcall(ServerPanel.RefreshStatus, debug.traceback)
				if not ok then reportControllerError(err, "Status", "Refresh") end
				task.wait(5)
			end
		end)
	end
end

local function installSidebarSections(window, fluent)
	if window.Section then return end
	local holder, manager = window.TabHolder, window.TabManager
	assert(holder and manager, "Fluent sidebar extension is unavailable")
	local tweenService = game:GetService("TweenService")
	local layout = holder:FindFirstChildOfClass("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	local groups, connections, order = {}, {}, 0
	local info = TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	local function connect(signal, callback)
		local connection = signal:Connect(callback)
		connections[#connections + 1] = connection
		return connection
	end
	local function new(class, properties, parent)
		local object = Instance.new(class)
		for key, value in pairs(properties) do object[key] = value end
		object.Parent = parent
		return object
	end
	local function refresh()
		if holder.Parent then
			holder.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 4)
			window:RefreshTabSelector()
		end
	end
	local originalPosition = manager.GetCurrentTabPos
	manager.GetCurrentTabPos = function(self)
		local tab = self.Tabs[self.SelectedTab]
		if not tab then return 0 end
		local group = groups[tab]
		local frame = group and not group.Opened and group.Header or tab.Frame
		return frame.AbsolutePosition.Y - holder.AbsolutePosition.Y
	end
	local originalSelect = manager.SelectTab
	manager.SelectTab = function(self, index)
		local tab = self.Tabs[index]
		assert(tab, "Invalid Fluent tab index")
		local group = groups[tab]
		if group and not group.Opened then group:SetOpened(true) end
		return originalSelect(self, index)
	end
	connect(layout:GetPropertyChangedSignal("AbsoluteContentSize"), refresh)
	local originalAddTab = window.AddTab
	window.AddTab = function(self, options)
		local tab = originalAddTab(self, options)
		order += 1
		tab.Frame.LayoutOrder = order
		connect(tab.Frame:GetPropertyChangedSignal("AbsolutePosition"), refresh)
		return tab
	end
	function window:Section(options)
		assert(type(options.Title) == "string", "Section requires a Title")
		local icon = fluent:GetIcon(options.Icon)
		order += 1
		local group = { Opened = options.Opened ~= false, Tabs = {}, Tweens = {} }
		group.Frame = new("Frame", {
			Name = "SidebarSection", BackgroundTransparency = 1, BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 30), LayoutOrder = order, ClipsDescendants = true,
		}, holder)
		group.Header = new("TextButton", {
			Name = "Header", Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
			BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 30),
		}, group.Frame)
		group.Icon = new("ImageLabel", {
			BackgroundTransparency = 1, Size = UDim2.fromOffset(16, 16),
			Position = UDim2.fromOffset(8, 7), Image = icon or "", Visible = icon ~= nil,
			ImageColor3 = Color3.fromRGB(210, 210, 220),
		}, group.Header)
		group.Label = new("TextLabel", {
			BackgroundTransparency = 1, Text = options.Title, TextSize = 12,
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
			TextColor3 = Color3.fromRGB(210, 210, 220), TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd, Size = UDim2.new(1, icon and -54 or -36, 1, 0),
			Position = UDim2.fromOffset(icon and 30 or 12, 0),
		}, group.Header)
		group.Chevron = new("ImageLabel", {
			BackgroundTransparency = 1, Image = assert(fluent:GetIcon("chevron-right")),
			Size = UDim2.fromOffset(14, 14), Position = UDim2.new(1, -20, 0, 8),
			Rotation = group.Opened and 90 or 0, ImageColor3 = group.Label.TextColor3,
		}, group.Header)
		group.Body = new("Frame", {
			BackgroundTransparency = 1, BorderSizePixel = 0,
			Position = UDim2.fromOffset(8, 34), Size = UDim2.new(1, -8, 0, 0),
		}, group.Frame)
		new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, group.Body)
		function group:SetOpened(value, instant)
			self.Opened = value == true
			for _, tween in ipairs(self.Tweens) do tween:Cancel() end
			self.Tweens = {}
			local height = #self.Tabs > 0 and 34 + #self.Tabs * 38 - 4 or 30
			local size = UDim2.new(1, 0, 0, self.Opened and height or 30)
			local rotation = self.Opened and 90 or 0
			if instant then
				self.Frame.Size, self.Chevron.Rotation = size, rotation
			else
				self.Tweens = {
					tweenService:Create(self.Frame, info, { Size = size }),
					tweenService:Create(self.Chevron, info, { Rotation = rotation }),
				}
				for _, tween in ipairs(self.Tweens) do tween:Play() end
			end
			refresh()
		end
		function group:AdoptTab(tab)
			assert(not groups[tab], "Tab already belongs to a sidebar section")
			self.Tabs[#self.Tabs + 1] = tab
			groups[tab] = self
			tab.Frame.Parent, tab.Frame.LayoutOrder = self.Body, #self.Tabs
			local label = tab.Frame:FindFirstChildOfClass("TextLabel")
			if label then
				label.Size = UDim2.new(1, -label.Position.X.Offset - 6, 1, 0)
				label.TextTruncate = Enum.TextTruncate.AtEnd
				local function theme()
					self.Label.TextColor3 = label.TextColor3
					self.Icon.ImageColor3, self.Chevron.ImageColor3 = label.TextColor3, label.TextColor3
				end
				theme()
				connect(label:GetPropertyChangedSignal("TextColor3"), theme)
			end
			self.Body.Size = UDim2.new(1, -8, 0, #self.Tabs * 38 - 4)
			connect(tab.Frame:GetPropertyChangedSignal("AbsolutePosition"), refresh)
			self:SetOpened(self.Opened, true)
			return tab
		end
		function group:AddTab(tabOptions)
			return self:AdoptTab(originalAddTab(window, tabOptions))
		end
		connect(group.Header.Activated, function() group:SetOpened(not group.Opened) end)
		self.SidebarSections[#self.SidebarSections + 1] = group
		return group
	end
	window.SidebarSections = {}
	connect(window.Root.Destroying, function()
		for _, group in ipairs(window.SidebarSections) do
			for _, tween in ipairs(group.Tweens) do tween:Cancel() end
		end
		for _, connection in ipairs(connections) do connection:Disconnect() end
	end)
end

local function initializeUI()
	local ok, err = xpcall(function()
		SettingManager:SetFolder("CyborgCodex")
		local saved = SettingManager:LoadAutoConfig()
		if saved then
			for _, key in ipairs({ "cyborgrace", "autosoulguitar", "autoghoulrace", "autottk", "autoyama", "autotushita", "autocdk", "autohakilegendary", "autofarmboss", "autofarmbosshop", "selectedboss",
				"autofactoryhop", "autopirateraidhop", "autofruithop", "autoberryhop", "AutoRandomFruit", "AutoStoreFruit", "TeleportMirageIsland", "TeleportVolcanicIsland", "TeleportKitsuneIsland", "AutoPullLevel",
				"Team", "SelectedWeapon", "AutoBuso", "TurnOnRaceV3", "TurnOnRaceV4", "TurnOnObservationHaki" }) do
				if not explicitFlags[key] then env[key] = saved.Setting[key] end
			end
		end
	end, debug.traceback)
	if not ok then
		log("Config load failed: " .. tostring(err))
		notify("Config could not load; current workflow flags are unchanged.", "config-load-error", 5)
	end
	local _nSrc = game:HttpGet("https://raw.githubusercontent.com/idrisvale-dev/Scripts/refs/heads/master/Library/NoctraLibrary.luau")
	local _nChunk = assert(loadstring(_nSrc, "Noctra"))
	local Noctra = _nChunk()
	assert(type(Noctra) == "table" and type(Noctra.CreateWindow) == "function", "Noctra failed to load")
	local fluent = { Unloaded = false }
	function fluent:CreateWindow(opts)
		local w = Noctra:CreateWindow({
			Name = opts.Title or "Hub",
			Status = opts.SubTitle or "",
			Width = (opts.Size and opts.Size.X.Offset) or 480,
			Height = (opts.Size and opts.Size.Y.Offset) or 360,
			ToggleKey = opts.MinimizeKey or Enum.KeyCode.RightShift,
			Logo = "T",
		})
		local FW = { _w = w, Unloaded = false }
		function FW:Minimize() w:SetVisible(not w.Visible) end
		function FW:Destroy() w:Destroy(); self.Unloaded = true; fluent.Unloaded = true end
		function FW:AddTab(to)
			local t = w:AddTab({ Name = to.Title or to.Name or "Tab", Icon = to.Icon })
			local FT = { _t = t }
			function FT:AddSection(title)
				local titleStr = type(title) == "string" and title or (title and title.Title) or ""
				local s = t:AddSection({ Title = titleStr })
				local FS = {}
				function FS:AddToggle(key, o)
					o = o or {}
					local tog = s:AddToggle({ Name = o.Title or key, Flag = key, Default = o.Default, Callback = o.Callback })
					local proxy = setmetatable({}, {
						__index = function(_, k)
							if k == "Value" then return tog:Get() end
							if k == "OnChanged" then return { Connect = function() end } end
						end,
						__newindex = function(_, k, v) if k == "Value" then tog:Set(v, true) end end,
					})
					function proxy:SetValue(v) tog:Set(v, true) end
					function proxy:Get() return tog:Get() end
					return proxy
				end
				function FS:AddDropdown(key, o)
					o = o or {}
					local dd = s:AddDropdown({ Name = o.Title or key, Flag = key, Options = o.Values or {}, Multi = o.Multi, Default = o.Default, Callback = o.Callback })
					local proxy = setmetatable({}, {
						__index = function(_, k)
							if k == "Value" then return dd:Get() end
						end,
					})
					function proxy:SetValue(v) dd:Set(v, true) end
					function proxy:SetValues(list) dd:SetOptions(list, false) end
					function proxy:Get() return dd:Get() end
					return proxy
				end
				function FS:AddButton(o)
					o = o or {}
					return s:AddButton({ Text = o.Title or o.Text or "Run", Callback = o.Callback })
				end
				function FS:AddInput(key, o)
					o = o or {}
					return s:AddInput({ Name = o.Title or key, Flag = key, Default = o.Default or "", Placeholder = o.Placeholder or "", Callback = o.Callback })
				end
				function FS:AddParagraph(o)
					o = o or {}
					local heading = o.Title or ""
					local lbl = s:AddLabel(heading .. (o.Content and (": " .. o.Content) or ""))
					local prx = {}
					function prx:SetDesc(txt)
						lbl:SetText(heading ~= "" and (heading .. ": " .. (txt or "")) or (txt or ""))
					end
					return prx
				end
				return FS
			end
			return FT
		end
		return FW
	end
	function fluent.Destroy() end
	ui = { Fluent = fluent, Toggles = {}, LastFlags = {}, Syncing = true, SettingManager = SettingManager }
	local identityGetter = env.getthreadidentity or getthreadidentity or getidentity
	if type(identityGetter) == "function" then ui.Identity = identityGetter() end
	env.CyborgCodexUI = ui
	local window = fluent:CreateWindow({
		Title = "Teddy Hub",
		SubTitle = "discord.gg/YYeRQnhQH5",
		TabWidth = 140,
		Size = UDim2.fromOffset(480, 360),
		Acrylic = false,
		Theme = "Dark",
		MinimizeKey = Enum.KeyCode.LeftControl,
	})
	assert(window, "Fluent did not create the window")
	ui.Window = window
	local coreGui = game:GetService("CoreGui")
	local oldButton = coreGui:FindFirstChild("UIBUTTON")
	if oldButton then oldButton:Destroy() end
	local buttonGui = Instance.new("ScreenGui")
	buttonGui.Name = "UIBUTTON"
	buttonGui.ResetOnSpawn = false
	buttonGui.DisplayOrder = 20
	buttonGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	buttonGui.Parent = coreGui
	ui.ToggleGui = buttonGui
	local buttonFrame = Instance.new("Frame")
	buttonFrame.BackgroundTransparency = 1
	buttonFrame.Position = UDim2.new(0.15, 0, 0.16, 0)
	buttonFrame.Size = UDim2.fromOffset(50, 50)
	buttonFrame.Parent = buttonGui
	local imageButton = Instance.new("ImageButton")
	imageButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	imageButton.BorderSizePixel = 0
	imageButton.Size = UDim2.fromScale(1, 1)
	imageButton.Image = "rbxassetid://136103435617044"
	imageButton.Active = true
	imageButton.Draggable = false
	imageButton.Parent = buttonFrame
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = imageButton
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 3
	stroke.Color = Color3.fromRGB(128, 0, 128)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = imageButton
	local inputService = game:GetService("UserInputService")
	local pointer, pointerStart, frameStart, dragged, releaseConnection
	imageButton.InputBegan:Connect(function(input)
		if pointer or (input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch) then return end
		pointer, pointerStart, frameStart, dragged = input, input.Position, buttonFrame.Position, false
		releaseConnection = input.Changed:Connect(function()
			if input.UserInputState ~= Enum.UserInputState.End
				and input.UserInputState ~= Enum.UserInputState.Cancel then return end
			local clicked = not dragged and input.UserInputState == Enum.UserInputState.End
			pointer = nil
			releaseConnection:Disconnect()
			releaseConnection = nil
			if not clicked or state.Generation ~= generation or fluent.Unloaded then return end
			local ok, err = pcall(function() withUIContext(function() window:Minimize() end) end)
			if not ok then reportControllerError(err, "UI", "ToggleButton") end
		end)
	end)
	local dragConnection = inputService.InputChanged:Connect(function(input)
		if not pointer then return end
		if input ~= pointer and not (pointer.UserInputType == Enum.UserInputType.MouseButton1
			and input.UserInputType == Enum.UserInputType.MouseMovement) then return end
		local delta = input.Position - pointerStart
		if delta.Magnitude > 6 then dragged = true end
		if dragged then
			buttonFrame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X,
				frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
		end
	end)
	buttonGui.Destroying:Connect(function()
		dragConnection:Disconnect()
		if releaseConnection then releaseConnection:Disconnect() end
	end)
	installSidebarSections(window, fluent)
	ServerPanel.Build(window)
	local generalGroup = window:Section({ Title = "General Tab", Icon = "", Opened = true })
	local hopGroup = window:Section({ Title = "Hop Tab", Icon = "bird", Opened = false })
	ui.StatusGui = createDynamicStatusIsland()
	local farmTab = generalGroup:AddTab({ Title = "Farm", Icon = "layers" })
	local tab = generalGroup:AddTab({ Title = "Auto Get", Icon = "scroll" })
	for _, option in ipairs({
		{ Key = "AutoPullLevel", Title = "Auto Pull Level", Controller = env.PullLevelCodex },
		{ Key = "cyborgrace", Title = "Auto Cyborg Race", Controller = env.CyborgCodex },
		{ Key = "autosoulguitar", Title = "Auto Soul Guitar", Controller = env.SoulGuitarCodex },
		{ Key = "autoghoulrace", Title = "Auto Ghoul Race", Controller = env.GhoulCodex },
		{ Key = "autottk", Title = "Auto Get TTK", Controller = env.TTKCodex },
		{ Key = "autoyama", Title = "Auto Yama", Controller = env.YamaCodex },
		{ Key = "autotushita", Title = "Auto Tushita", Controller = env.TushitaCodex },
		{ Key = "autocdk", Title = "Auto Cursed Dual Katana", Controller = env.CDKCodex },
		{ Key = "autohakilegendary", Title = "Auto Haki Legendary", Controller = env.HakiCodex },
	}) do
		local key, controller = option.Key, option.Controller
		local toggle = tab:AddToggle(key, { Title = option.Title, Default = env[key] == true })
		ui.Toggles[key] = toggle
		ui.LastFlags[key] = env[key] == true
		toggle:OnChanged(function(value)
			if state.Generation ~= generation or ui.Syncing then return end
			if value then controller.Start() else controller.Stop() end
			ui.LastFlags[key] = value
			saveUISettings()
		end)
	end
	ui.FarmTab = farmTab
	ui.BossDropdown = farmTab:AddDropdown("selectedboss", {
		Title = "Selected Boss", Values = BossFarm.List, Multi = false, Default = env.selectedboss,
	})
	ui.LastBoss = env.selectedboss
	ui.BossDropdown:OnChanged(function(value)
		if state.Generation ~= generation or ui.Syncing or not BossFarm.Definitions[value] then return end
		env.selectedboss = value
		if state.ActiveWorkflow ~= "Ghoul" then BossFarm.Cancel() end
		ui.LastBoss = value
		saveUISettings()
	end)
	for _, option in ipairs({
		{ Key = "autofarmboss", Title = "Auto Farm Boss" },
		{ Key = "autofarmbosshop", Title = "Auto Farm Boss [Hop]" },
	}) do
		local key = option.Key
		local toggle = farmTab:AddToggle(key, { Title = option.Title, Default = env[key] == true })
		ui.Toggles[key] = toggle
		ui.LastFlags[key] = env[key] == true
		toggle:OnChanged(function(value)
			if state.Generation ~= generation or ui.Syncing then return end
			if key == "autofarmboss" then
				if value then env.BossFarmCodex.Start() else env.BossFarmCodex.Stop() end
			else
				env.autofarmbosshop = value
				if state.ActiveWorkflow ~= "Ghoul" then BossFarm.Cancel() end
			end
			ui.LastFlags[key] = value
			saveUISettings()
		end)
	end
	local eventSection = farmTab:AddSection("Event Game")
	for _, name in ipairs({ "Factory", "Pirate", "Fruit", "Berry" }) do
		local entry = GameEvents.States[name]
		local key = entry.Flag
		local toggle = eventSection:AddToggle(key, { Title = entry.Title, Default = env[key] == true })
		ui.Toggles[key], ui.LastFlags[key] = toggle, env[key] == true
		toggle:OnChanged(function(value)
			if state.Generation ~= generation or ui.Syncing then return end
			env[key] = value == true
			GameEvents.Cancel(name)
			if state.ActiveWorkflow == name and not value then stopFastAttack(); cleanupMovement() end
			GameEvents.SetStatus(name, value and "Queued" or "Stopped")
			ui.LastFlags[key] = env[key]
			saveUISettings()
		end)
	end
	local safeSection = farmTab:AddSection("Fruit Safe")
	local randomToggle = safeSection:AddToggle("AutoRandomFruit", { Title = "Auto Random Fruit", Default = env.AutoRandomFruit == true })
	ui.Toggles.AutoRandomFruit, ui.LastFlags.AutoRandomFruit = randomToggle, env.AutoRandomFruit == true
	randomToggle:OnChanged(function(value)
		if state.Generation ~= generation or ui.Syncing then return end
		env.AutoRandomFruit = value == true
		GameEvents.NextRandom = 0
		ui.LastFlags.AutoRandomFruit = env.AutoRandomFruit
		saveUISettings()
	end)
	local storeToggle = safeSection:AddToggle("AutoStoreFruit", { Title = "Auto Store Fruit", Default = env.AutoStoreFruit == true })
	ui.Toggles.AutoStoreFruit, ui.LastFlags.AutoStoreFruit = storeToggle, env.AutoStoreFruit == true
	storeToggle:OnChanged(function(value)
		if state.Generation ~= generation or ui.Syncing then return end
		env.AutoStoreFruit = value == true
		ui.LastFlags.AutoStoreFruit = env.AutoStoreFruit
		saveUISettings()
	end)
	local islandSection = farmTab:AddSection("Island")
	for _, name in ipairs({ "Mirage", "Volcanic", "Kitsune" }) do
		local entry = GameEvents.States[name]
		local key = entry.Flag
		local toggle = islandSection:AddToggle(key, { Title = entry.Title, Default = env[key] == true })
		ui.Toggles[key], ui.LastFlags[key] = toggle, env[key] == true
		toggle:OnChanged(function(value)
			if state.Generation ~= generation or ui.Syncing then return end
			env[key] = value == true
			GameEvents.Cancel(name)
			if state.ActiveWorkflow == name then releaseWorkflow(); state.ActiveWorkflow = nil end
			ui.LastFlags[key] = env[key]
			saveUISettings()
		end)
	end
	local settingTab = generalGroup:AddTab({ Title = "Setting", Icon = "settings" })
	ui.TeamDropdown = settingTab:AddDropdown("SelectedTeam", {
		Title = "Selected Team", Values = { "Pirates", "Marines" }, Multi = false,
		Default = env.Team,
	})
	ui.TeamDropdown:OnChanged(function(value)
		if state.Generation ~= generation or ui.Syncing
			or (value ~= "Pirates" and value ~= "Marines") then return end
		env.Team = value
		Config.Team = value
		state.LastRemote.Team = nil
		saveUISettings()
		task.spawn(ensureTeam)
	end)
	ui.WeaponDropdown = settingTab:AddDropdown("SelectedWeapon", {
		Title = "Selected Weapon", Values = { "Melee", "Sword", "Fruit", "Gun" }, Multi = false,
		Default = env.SelectedWeapon,
	})
	ui.WeaponDropdown:OnChanged(function(value)
		if state.Generation ~= generation or ui.Syncing
			or not table.find({ "Melee", "Sword", "Fruit", "Gun" }, value) then return end
		env.SelectedWeapon = value
		saveUISettings()
	end)
	for _, option in ipairs({
		{ Key = "AutoBuso", Title = "Auto Buso" },
		{ Key = "TurnOnRaceV3", Title = "Turn On Race V3" },
		{ Key = "TurnOnRaceV4", Title = "Turn On Race V4" },
		{ Key = "TurnOnObservationHaki", Title = "Auto Turn On Observation" },
	}) do
		local key = option.Key
		local toggle = settingTab:AddToggle(key, { Title = option.Title, Default = env[key] == true })
		ui.Toggles[key] = toggle
		ui.LastFlags[key] = env[key] == true
		toggle:OnChanged(function(value)
			if state.Generation ~= generation or ui.Syncing then return end
			env[key] = value == true
			if key == "TurnOnRaceV3" then state.LastRaceV3Attempt = -math.huge end
			if key == "TurnOnRaceV4" then state.LastRaceV4Attempt = -math.huge end
			ui.LastFlags[key] = env[key]
			saveUISettings()
		end)
	end
	tab:AddButton({ Title = "Save Config", Callback = function()
		if state.Generation ~= generation then return end
		syncUISettings()
		if saveUISettings() then notify("Configuration saved.", "config-saved", 5) end
	end })
	window:SelectTab(1)
	ui.Syncing = false
	ServerPanel.BuildHopTabs(hopGroup)
	local currentUI = ui
	currentUI.Worker = task.spawn(function()
		while state.Generation == generation and ui == currentUI and not currentUI.Fluent.Unloaded do
			local ok, err = xpcall(syncUISettings, debug.traceback)
			if not ok then reportControllerError(err, "UI", "Sync") end
			task.wait(0.2)
		end
		if currentUI.StatusGui and currentUI.StatusGui.Parent then currentUI.StatusGui:Destroy() end
		if currentUI.ToggleGui then currentUI.ToggleGui:Destroy() end
	end)
end

env.CyborgCodex.StopAll = function()
	env.cyborgrace = false
	env.autosoulguitar = false
	env.autoghoulrace = false
	env.autottk = false
	env.autoyama = false
	env.autotushita = false
	env.autocdk = false
	env.autohakilegendary = false
	env.autofarmboss = false
	env.autofarmbosshop = false
	env.autofactoryhop = false
	env.autopirateraidhop = false
	env.autofruithop = false
	env.autoberryhop = false
	env.AutoRandomFruit = false
	env.AutoStoreFruit = false
	env.AutoPullLevel = false
	env.TeleportMirageIsland = false
	env.TeleportVolcanicIsland = false
	env.TeleportKitsuneIsland = false
	state.Enabled = false
	releaseWorkflow()
end
env.CyborgCodex.Shutdown = function()
	state.Enabled = false
	releaseWorkflow()
	state.Generation += 1
	for _, connection in ipairs(state.Connections) do connection:Disconnect() end
	state.Connections = {}
	if ui then
		local ok, err = pcall(function() ui.Fluent:Destroy() end)
		if not ok then log("Fluent cleanup failed: " .. tostring(err)) end
		if ui.StatusGui and ui.StatusGui.Parent then ui.StatusGui:Destroy() end
		if ui.ToggleGui then ui.ToggleGui:Destroy() end
		if env.CyborgCodexUI == ui then env.CyborgCodexUI = nil end
	end
end

state.Connections[#state.Connections + 1] = RunService.Heartbeat:Connect(function()
	if state.Generation ~= generation then return end
	if state.ActiveWorkflow and not workflowActive(state.ActiveWorkflow) then releaseWorkflow() end
	if state.CombatFollow then
		local ok, err = pcall(updateCombatFollow)
		if not ok then
			stopFastAttack()
			cleanupMovement()
			reportControllerError(err, "Combat", "Follow")
		end
	end
end)

local resumed = env.__CyborgCodexResume == true
env.__CyborgCodexResume = false
if resumed then
	state.ChestCount = 0
	state.SeenChests = {}
end
local uiOk, uiError = xpcall(initializeUI, debug.traceback)
if not uiOk then
	if ui then
		local ok, err = pcall(function() ui.Fluent:Destroy() end)
		if not ok then log("Fluent cleanup failed: " .. tostring(err)) end
		if ui.StatusGui and ui.StatusGui.Parent then ui.StatusGui:Destroy() end
		if ui.ToggleGui then ui.ToggleGui:Destroy() end
		if env.CyborgCodexUI == ui then env.CyborgCodexUI = nil end
		ui = nil
	end
	log("Fluent UI startup failed: " .. tostring(uiError))
	notify("Fluent UI failed to load; see executor console.", "ui-error", 5)
end
state.Worker = true
task.spawn(function()
	while state.Generation == generation do
		local ok, err = xpcall(function()
			local cyborgEnabled, soulEnabled = env.cyborgrace == true, env.autosoulguitar == true
			local bossEnabled = env.autofarmboss == true
			local ghoulEnabled = env.autoghoulrace == true
			local ttkEnabled = env.autottk == true
			local yamaEnabled, tushitaEnabled = env.autoyama == true, env.autotushita == true
			local cdkEnabled = env.autocdk == true
			local hakiEnabled = env.autohakilegendary == true
			state.Enabled = cyborgEnabled or soulEnabled or bossEnabled or ghoulEnabled or (ttkEnabled and not state.TTKCompleted)
				or (yamaEnabled and not SwordGet.States.Yama.Completed) or (tushitaEnabled and not SwordGet.States.Tushita.Completed)
				or (cdkEnabled and not SwordGet.States.CDK.Completed)
				or (hakiEnabled and not Haki.Completed)
				or env.autofactoryhop == true or env.autopirateraidhop == true or env.autofruithop == true or env.autoberryhop == true
				or env.TeleportMirageIsland == true or env.TeleportVolcanicIsland == true
				or env.TeleportKitsuneIsland == true
				or (env.AutoPullLevel == true and not PullLever.Completed)
			if env.AutoPullLevel == true and PullLever.Completed then
				notify("Auto Pull Level completed: Temple lever pulled.", "pull-level-complete", 5)
			end
			if hakiEnabled and Haki.Completed then
				notify("Auto Haki Legendary completed: Pure Red, Winter Sky and Snow White are owned.", "haki-complete", 5)
			end
			if ttkEnabled and state.TTKCompleted then notify("Auto Get TTK completed: True Triple Katana is owned.", "ttk-complete", 5) end
			for name, controller in pairs(SwordGet.States) do
				local item = controller.InventoryKey or name
				if env[controller.Flag] == true and not controller.Completed and TTK.Snapshot().Owned[item] then SwordGet.Complete(name) end
				if env[controller.Flag] == true and controller.Completed then notify("Completed: " .. item .. " is already owned.", name .. "-complete", 5) end
			end
			local data = player:FindFirstChild("Data")
			local race = data and data:FindFirstChild("Race")
			local cyborgOwned = race ~= nil and race.Value == "Cyborg"
			local owner = chooseWorkflow(cyborgEnabled, soulEnabled, cyborgOwned, bossEnabled, ghoulEnabled, ttkEnabled, yamaEnabled, tushitaEnabled, cdkEnabled, hakiEnabled)
			if owner ~= state.ActiveWorkflow or (owner == "Boss" and state.BossSelection ~= env.selectedboss) then
				releaseWorkflow()
				state.ActiveWorkflow = owner
				state.NextAction = 0
				if owner == "Boss" then state.BossSelection = env.selectedboss end
			end
			if not ensureTeam() then
				if owner == "Boss" then BossFarm.SetStatus("Waiting to join " .. Config.Team) end
				return
			end
			if cyborgEnabled and cyborgOwned then notify("Cyborg Race is already owned; completed.", "owned", 5) end
			if ghoulEnabled and owner ~= "Ghoul" then
				Ghoul.Trace("WaitingWorkflow")
				Ghoul.SetStatus("Waiting for " .. tostring(owner) .. " workflow")
			end
			if owner ~= "Boss" and owner ~= "Ghoul" then BossFarm.SetStatus("Idle") end
			for name, controller in pairs(SwordGet.States) do
				if env[controller.Flag] == true and not controller.Completed and owner ~= name then SwordGet.SetStatus(name, "Waiting for " .. tostring(owner) .. " workflow") end
			end
			for name, entry in pairs(GameEvents.States) do
				if env[entry.Flag] == true and owner ~= name then GameEvents.SetStatus(name, "Waiting for " .. tostring(owner) .. " workflow") end
			end
			if owner == "PullLever" then
				PullLever.Step()
			elseif GameEvents.States[owner] then
				GameEvents.Step(owner)
			elseif owner == "Haki" then
				Haki.Step()
			elseif owner == "Yama" or owner == "Tushita" or owner == "CDK" then
				SwordGet.Step(owner)
			elseif owner == "TTK" then
				TTK.Step()
			elseif owner == "Boss" then
				BossFarm.Step()
			elseif owner == "Ghoul" then
				Ghoul.Step()
			elseif owner == "Cyborg" then
				if soulEnabled then notify("Soul Guitar is waiting for the active Cyborg workflow.", "soul-priority", 5) end
				runStep()
			elseif owner == "SoulGuitar" then
				runSoulGuitarStep()
			end
		end, debug.traceback)
		if not ok then
			reportControllerError(err)
			local cleanupOk, cleanupErr = pcall(function() stopFastAttack(); cleanupMovement() end)
			if not cleanupOk then print("[Teddy Hub][ERROR][Cleanup] " .. tostring(cleanupErr)) end
			notify("Controller error; full traceback printed in console.", "controller-error", 5)
		end
		task.wait(Config.ActionDelay)
	end
	if state.Generation == generation then state.Worker = false end
end)
task.spawn(function()
	while state.Generation == generation do
		GameEvents.RandomBusy = true
		local randomOk, randomError = xpcall(GameEvents.RandomStep, debug.traceback)
		GameEvents.RandomBusy = false
		if not randomOk then reportControllerError(randomError, "FruitSafe", "Random") end
		local ok, err = xpcall(GameEvents.StoreStep, debug.traceback)
		if not ok then reportControllerError(err, "FruitSafe", "Store") end
		task.wait(1)
	end
end)
--log("Standalone controller ready. Controls: cyborgrace / autosoulguitar / autoghoulrace / autottk / autoyama / autotushita / autocdk / autohakilegendary / autofarmboss / autofarmbosshop / selectedboss / autofactoryhop / autopirateraidhop / autofruithop / AutoStoreFruit.")
-------
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer
local Backpack = LP.Backpack
local Enemies = Workspace:WaitForChild("Enemies")
local Characters = Workspace:WaitForChild("Characters")
local Net = RS.Modules.Net
local atk = Net["RE/RegisterAttack"]
local hit = Net["RE/RegisterHit"]
local Remote, RemoteId
for _, v in next, {RS.Util, RS.Common, RS.Remotes, RS.Assets, RS.FX} do
    for _, x in next, v:GetChildren() do
        if x:IsA("RemoteEvent") and x:GetAttribute("Id") then
            Remote = x
            RemoteId = x:GetAttribute("Id")
        end
    end
    state.Connections[#state.Connections + 1] = v.ChildAdded:Connect(function(x)
        if x:IsA("RemoteEvent") and x:GetAttribute("Id") then
            Remote = x
            RemoteId = x:GetAttribute("Id")
        end
    end)
end

local FastHit = {Rate = 0.036}
function FastHit:GetMob(c, f)
    local p = c:GetPivot().Position
    local t = {}
    for _, m in next, f:GetChildren() do
        local h = m:FindFirstChild("Humanoid")
        local r = m:FindFirstChild("HumanoidRootPart")
        if isAttackTarget(m) and h and r and h.Health > 0 and (r.Position - p).Magnitude <= 60 then
            t[#t + 1] = m
        end
    end
    return t
end
function FastHit:Collect(c)
    local t = {}
    local a = self:GetMob(c, Enemies)
    local b = self:GetMob(c, Characters)
    for i = 1, #a do t[#t + 1] = a[i] end
    for i = 1, #b do t[#t + 1] = b[i] end
    return t
end
function FastHit:Fast()
    if not attackActive() then return end
    local c = LP.Character
    if not c then return end
    local list = self:Collect(c)
    if #list < 1 then return end
    local parts = {}
    for i = 1, #list do
        local h = list[i]:FindFirstChild("Head") or list[i].PrimaryPart
        if h then parts[#parts + 1] = {list[i], h} end
    end
    if #parts < 1 then return end
    atk:FireServer(FastHit.Rate)
    hit:FireServer(parts[1][2], parts)
end

local function pmtHit()
    if not attackActive() then return end
    local c = LP.Character
    if not c then return end
    local r = c:FindFirstChild("HumanoidRootPart")
    if not r then return end
    local gather = {}
    local function scan(f)
        for _, m in next, f:GetChildren() do
            local h = m:FindFirstChild("Humanoid")
            local hr = m:FindFirstChild("HumanoidRootPart")
            if isAttackTarget(m) and h and hr and h.Health > 0 and m ~= c and (hr.Position - r.Position).Magnitude <= 60 then
                for _, v in next, m:GetChildren() do
                    if v:IsA("BasePart") then gather[#gather + 1] = {m, v} end
                end
            end
        end
    end
    scan(Enemies)
    scan(Characters)
    if #gather < 1 then return end
    local seed = Net.seed:InvokeServer()
    if not attackActive() or LP.Character ~= c then return end
    for _, entry in ipairs(gather) do
        if not isAttackTarget(entry[1]) then return end
    end
    atk:FireServer()
    local head = gather[1][1]:FindFirstChild("Head")
    if not head then return end
    hit:FireServer(head, gather, {})
    if Remote then
        local n = math.floor(Workspace:GetServerTimeNow() / 10 % 10) + 1
        Remote:FireServer(("RE/RegisterHit"):gsub(".", function(s) return string.char(bit32.bxor(s:byte(), n)) end), bit32.bxor(RemoteId + 909090, seed * 2), head, gather)
    end
end

local cameraStopped = false

task.spawn(function()
    while state.Generation == generation and task.wait(FastHit.Rate) do
        if not attackActive() or not state.FastAttackTarget then continue end
        if not cameraStopped then
            local ok, err = pcall(function() require(RS.Util.CameraShaker):Stop() end)
            cameraStopped = true
            if not ok then log("CameraShaker stop failed: " .. tostring(err)) end
        end
        local ok, err = pcall(function() FastHit:Fast() end)
        if not ok and os.clock() - (state.LastSupplementalError or 0) >= 5 then
            state.LastSupplementalError = os.clock()
            log("Supplemental FastHit failed: " .. tostring(err))
        end
    end
end)

state.Connections[#state.Connections + 1] = RunService.Heartbeat:Connect(function()
    if state.Generation ~= generation or not attackActive() or not state.FastAttackTarget then return end
    local ok, err = pcall(pmtHit)
    if not ok and os.clock() - (state.LastSeedAttackError or 0) >= 5 then
        state.LastSeedAttackError = os.clock()
        log("Seed fast attack failed: " .. tostring(err))
    end
end)

task.spawn(function()
    while state.Generation == generation and task.wait() do
        if not attackActive() or not state.FastAttackTarget then continue end
        local c = LP.Character
        if not c then continue end
        local r = c:FindFirstChild("HumanoidRootPart")
        if not r then continue end
        local id = tostring(LP.UserId):sub(2, 4) .. tostring(coroutine.running()):sub(11, 15)
        local fired = false
        for _, m in next, Enemies:GetChildren() do
            local h = m:FindFirstChild("HumanoidRootPart")
            local u = m:FindFirstChild("Humanoid")
            if isAttackTarget(m) and h and u and u.Health > 0 and (h.Position - r.Position).Magnitude <= 60 then
                if not fired then atk:FireServer(); fired = true end
                hit:FireServer(h, {{m, h}}, nil, nil, id)
            end
        end
    end
end)
----
]=]

local chunk, v = loadstring([=[if not LPH_OBFUSCATED then
	LPH_ATTRIBUTES = function(...) end
	VM = function(...) end
	PRESET = function(...) end
	TRANSFORM = function(...) end
	NONE = "NONE"
	FAST = "FAST"
	OPAL = "OPAL"
	ONYX = "ONYX"
	SECURE = "SECURE"

	LPH_NO_VIRTUALIZE = function(f) return f end
	LPH_JIT_MAX = function(f) return f end
	LPH_JIT = function(f) return f end
end

local env = getgenv()
local explicitFlags = {
	cyborgrace = type(env.cyborgrace) == "boolean",
	autosoulguitar = type(env.autosoulguitar) == "boolean",
	autoghoulrace = type(env.autoghoulrace) == "boolean",
	autottk = type(env.autottk) == "boolean",
	autoyama = type(env.autoyama) == "boolean",
	autotushita = type(env.autotushita) == "boolean",
	autocdk = type(env.autocdk) == "boolean",
	autohakilegendary = type(env.autohakilegendary) == "boolean",
	AutoPullLevel = type(env.AutoPullLevel) == "boolean",
	autofarmboss = type(env.autofarmboss) == "boolean",
	autofarmbosshop = type(env.autofarmbosshop) == "boolean",
	autofactoryhop = type(env.autofactoryhop) == "boolean",
	autopirateraidhop = type(env.autopirateraidhop) == "boolean",
	autofruithop = type(env.autofruithop) == "boolean",
	autoberryhop = type(env.autoberryhop) == "boolean",
	AutoRandomFruit = type(env.AutoRandomFruit) == "boolean",
	AutoStoreFruit = type(env.AutoStoreFruit) == "boolean",
	TeleportMirageIsland = type(env.TeleportMirageIsland) == "boolean",
	TeleportVolcanicIsland = type(env.TeleportVolcanicIsland) == "boolean",
	TeleportKitsuneIsland = type(env.TeleportKitsuneIsland) == "boolean",
	selectedboss = type(env.selectedboss) == "string",
	SelectedWeapon = type(env.SelectedWeapon) == "string",
	Team = env.Team == "Pirates" or env.Team == "Marines",
	AutoBuso = true,
	TurnOnRaceV3 = type(env.TurnOnRaceV3) == "boolean",
	TurnOnRaceV4 = type(env.TurnOnRaceV4) == "boolean",
	TurnOnObservationHaki = type(env.TurnOnObservationHaki) == "boolean",
}
if env.cyborgrace == nil then env.cyborgrace = false end
if env.autosoulguitar == nil then env.autosoulguitar = false end
if env.autoghoulrace == nil then env.autoghoulrace = false end
if env.autottk == nil then env.autottk = false end
if env.autoyama == nil then env.autoyama = false end
if env.autotushita == nil then env.autotushita = false end
if env.autocdk == nil then env.autocdk = false end
if env.autohakilegendary == nil then env.autohakilegendary = false end
if env.AutoPullLevel == nil then env.AutoPullLevel = false end
if env.autofarmboss == nil then env.autofarmboss = false end
if env.autofarmbosshop == nil then env.autofarmbosshop = false end
if env.autofactoryhop == nil then env.autofactoryhop = false end
if env.autopirateraidhop == nil then env.autopirateraidhop = false end
if env.autofruithop == nil then env.autofruithop = false end
if env.autoberryhop == nil then env.autoberryhop = false end
if env.AutoRandomFruit == nil then env.AutoRandomFruit = false end
if env.AutoStoreFruit == nil then env.AutoStoreFruit = false end
if env.TeleportMirageIsland == nil then env.TeleportMirageIsland = false end
if env.TeleportVolcanicIsland == nil then env.TeleportVolcanicIsland = false end
if env.TeleportKitsuneIsland == nil then env.TeleportKitsuneIsland = false end
if env.selectedboss == nil then env.selectedboss = "Rip Indra" end
if env.SelectedWeapon == nil then env.SelectedWeapon = "Melee" end
env.AutoBuso = true
if env.TurnOnRaceV3 == nil then env.TurnOnRaceV3 = false end
if env.TurnOnRaceV4 == nil then env.TurnOnRaceV4 = false end
if env.TurnOnObservationHaki == nil then env.TurnOnObservationHaki = false end
local previousController = env.CyborgCodex
if previousController and type(previousController.Shutdown) == "function" then
	previousController.Shutdown()
elseif previousController and type(previousController.Stop) == "function" then
	previousController.Stop()
end
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
repeat task.wait() until game:IsLoaded() and game:GetService("Players") and game.Players.LocalPlayer and game.Players.LocalPlayer:FindFirstChild("PlayerGui")
local player = Players.LocalPlayer
if not explicitFlags.Team then
	local ok, saved = pcall(function()
		local exists, read = env.isfile or isfile, env.readfile or readfile
		local path = "CyborgCodex/ConfigMain/" .. player.Name .. ".json"
		if type(exists) == "function" and type(read) == "function" and exists(path) then
			return HttpService:JSONDecode(read(path))
		end
	end)
	local team = ok and type(saved) == "table" and type(saved.Setting) == "table" and saved.Setting.Team
	env.Team = (team == "Pirates" or team == "Marines") and team or "Marines"
end
local utilFolder = ReplicatedStorage:WaitForChild("Util", 120)
local seatUtilModule = utilFolder and utilFolder:WaitForChild("SeatUtil", 120)
assert(seatUtilModule and seatUtilModule:IsA("ModuleScript"), "ReplicatedStorage.Util.SeatUtil is unavailable")
local SeatUtil = require(seatUtilModule)
assert(type(SeatUtil.isSeated) == "function", "SeatUtil.isSeated is unavailable")
assert(type(SeatUtil.unseat) == "function", "SeatUtil.unseat is unavailable")

local Config = {
	Team = env.Team == "Pirates" and "Pirates" or "Marines",
	ChestLimit = 50,
	MinLawFragments = 1000,
	MinCyborgFragments = 2500,
	MinSoulGuitarFragments = 5000,
	MinSoulGuitarLevel = 2300,
	GhoulEctoplasmTarget = 100,
	TweenSpeed = 150,
	OrderOffset = Vector3.new(7, 18, 0),
	ActionDelay = 0.35,
}

local Ghoul = {
	NPC = CFrame.new(918.615234, 122.202454, 33454.3789),
	RewardGrace = 5,
}

local TTK = {
	Swords = { "Shizu", "Saishi", "Oroshi" },
	BonesMobs = { "Reborn Skeleton", "Living Zombie", "Demonic Soul", "Posessed Mummy" },
	Aliases = { Shizu = "Shizu", Shisui = "Shizu", Saishi = "Saishi", Saddi = "Saishi", Oroshi = "Oroshi", Wando = "Oroshi" },
	SwordPrice = 2000000, CraftPrice = 2000000, RequiredMastery = 300,
	Epoch = 0, Status = "Idle", ItemNames = {},
}

local Haki = {
	Names = { "Pure Red", "Winter Sky", "Snow White" },
	Price = 7500, Epoch = 0, Status = "Idle",
	Target = env.__CyborgCodexHakiTarget,
	BerryIgnored = setmetatable({}, { __mode = "k" }),
}

local ServerPanel = { Labels = {}, Servers = {}, Choices = {}, Input = "", Started = os.clock() }
local PullLever = {
	Epoch = 0, Status = "Idle", Calls = {},
	Tree = CFrame.new(3032.780029296875, 2280.85107421875, -7325.47802734375),
	Temple = CFrame.new(28282.5703125, 14896.8505859375, 105.1042709350586),
	Tiki = CFrame.new(-16204.0810546875, 9.0863618850708, 479.2259521484375),
	LeverClosedZ = 75.469101,
}
local GameEvents = {
	States = {
		Factory = { Flag = "autofactoryhop", Title = "Auto Factory [Hop]", Sea = 2, Slug = "factory", Epoch = 0 },
		Pirate = { Flag = "autopirateraidhop", Title = "Auto Pirate Raid [Hop]", Sea = 3, Slug = "castleraid", Epoch = 0 },
		Fruit = { Flag = "autofruithop", Title = "Auto Fruit [Hop]", Slug = "fruit", Epoch = 0, Hint = env.__CyborgCodexFruitHint },
		Berry = { Flag = "autoberryhop", Title = "Auto Berry [Hop]", Slug = "berry", Epoch = 0 },
		Mirage = { Flag = "TeleportMirageIsland", Title = "Teleport Mirage Island", Island = "MysticIsland", Location = "Mirage Island", NPC = "Advanced Fruit Dealer", Epoch = 0 },
		Volcanic = { Flag = "TeleportVolcanicIsland", Title = "Teleport Vocalnic Island", Island = "PrehistoricIsland", Location = "Prehistoric Island", NPC = "Fossil Expert", Epoch = 0 },
		Kitsune = { Flag = "TeleportKitsuneIsland", Title = "Teleport Kitsune Island", Island = "KitsuneIsland", Location = "Kitsune Island", Epoch = 0 },
	},
	Castle = CFrame.new(-5581.2353515625, 313.76556396484375, -3064.094970703125),
	Factory = CFrame.new(448, 199, -441),
	StoreRetry = setmetatable({}, { __mode = "k" }),
	FruitIgnored = setmetatable({}, { __mode = "k" }),
	BerryIgnored = setmetatable({}, { __mode = "k" }),
}

local SwordGet = {
	States = {
		Yama = { Flag = "autoyama", Status = "Idle", Epoch = 0 },
		Tushita = { Flag = "autotushita", Status = "Idle", Epoch = 0,
			HydraReady = env.__CyborgCodexTushitaHydraReady == true },
		CDK = { Flag = "autocdk", InventoryKey = "Cursed Dual Katana", Status = "Idle", Epoch = 0,
			Training = env.__CyborgCodexCDKTraining },
	},
	Elites = { "Deandre", "Urban", "Diablo" },
	HydraGate = CFrame.new(5713.53759765625, 38.38311767578125, 255.2017059326172),
	YamaRoom = CFrame.new(5251.900390625, 17.18115234375, 453.6025390625),
	LongmaRoom = CFrame.new(-10156.22265625, 337.77801513671875, -9445.865234375),
	PartCache = {},
	CDK = {
		Swords = { "Tushita", "Yama" }, RequiredMastery = 350,
		Manor = CFrame.new(-12133.0283203125, 576.9030151367188, -6707.39892578125),
		Room = CFrame.new(-12396.498046875, 603.3455810546875, -6502.42529296875),
		BossRoom = CFrame.new(-12341.66796875, 603.3455810546875, -6550.6064453125),
		Castle = CFrame.new(-5543.5327148438, 313.80062866211, -2964.2585449219),
		PainSpawn = CFrame.new(-2138.746826171875, 69.98304748535156, -12322.69140625),
		QueenSpawn = CFrame.new(-821, 66, -10965),
		Summoner = CFrame.new(-8932.322265625, 146.83154296875, 6062.55078125),
		BoatSpawns = {
			Vector3.new(-369.507, 6.730, 5190.749), Vector3.new(-9530.968, 7.219, -8375.256),
			Vector3.new(-6126.134, 16.508, -2251.773), Vector3.new(3234.833, 9.432, 1602.182),
			Vector3.new(-9549.828, 21.105, 4685.521), Vector3.new(-963.313, 7.768, -10813.180),
			Vector3.new(-1933.908, 8.049, -11475.199), Vector3.new(2222.733, 5.336, -6261.203),
		},
	},
	Torches = {
		CFrame.new(-10752.7861328125, 413.9829406738281, -9367.361328125),
		CFrame.new(-11671.5146484375, 334.0489196777344, -9474.318359375),
		CFrame.new(-12131.79296875, 520.3677368164062, -10655.0419921875),
		CFrame.new(-13335.0869140625, 485.4693298339844, -6985.51953125),
		CFrame.new(-13488.1171875, 335.7599792480469, -7923.94970703125),
	},
}

local BossFarm = {
	List = { "Rip Indra", "Dough King", "Tyrant of the Skies", "Darkbeard", "Cursed Captain", "Cake Prince", "Soul Reaper" },
	Definitions = {
		["Rip Indra"] = { Sea = 3, Slug = "ripindra", Names = { "rip_indra True Form", "rip_indra", "Rip Indra" } },
		["Dough King"] = { Sea = 3, Slug = "doughking", Names = { "Dough King" }, Mirror = true },
		["Tyrant of the Skies"] = { Sea = 3, Slug = "tyrant", Names = { "Tyrant of the Skies" } },
		["Darkbeard"] = { Sea = 2, Slug = "darkbeard", Names = { "Darkbeard" } },
		["Cursed Captain"] = { Sea = 2, Slug = "cursedcaptain", Names = { "Cursed Captain" } },
		["Cake Prince"] = { Sea = 3, Slug = "cakeprince", Names = { "Cake Prince" }, Mirror = true },
		["Soul Reaper"] = { Sea = 3, Slug = "soulreaper", Names = { "Soul Reaper" } },
	},
	ApiBase = "http://162.4.177.49:8080/jobid/",
	MissingGrace = 8,
	RetrySeconds = 15,
	TeleportTimeout = 25,
	VisitedSeconds = 600,
}
if not BossFarm.Definitions[env.selectedboss] then env.selectedboss = BossFarm.List[1] end

do
	local AES_SECRET_KEY = "VyZubu@MasterAES2026#SecureKey!!"
	local PREFIX = "diepvyaes|"
	local DECOY_A = "x9KqW1mZpL8vNbRt7yUj"
	local DECOY_B = "5cFgH2jK4sD6aQ8wE0rT"

	local b32 = bit32 or bit
	local bxor = b32.bxor
	local band = b32.band
	local bor = b32.bor
	local lshift = b32.lshift
	local rshift = b32.rshift
	local rrotate = b32.rrotate or function(x, n)
	    n = n % 32
	    return bor(rshift(x, n), lshift(x, 32 - n))
	end

	local SBOX = {
	    0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
	    0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
	    0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
	    0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
	    0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,
	    0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
	    0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
	    0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,
	    0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
	    0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,
	    0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
	    0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
	    0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,
	    0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
	    0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
	    0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16
	}

	local RCON = { 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36 }

	local T1 = {
	    0xc66363a5, 0xf87c7c84, 0xee777799, 0xf67b7b8d, 0xfff2f20d, 0xd66b6bbd, 0xde6f6fb1, 0x91c5c554,
	    0x60303050, 0x02010103, 0xce6767a9, 0x562b2b7d, 0xe7fefe19, 0xb5d7d762, 0x4dababe6, 0xec76769a,
	    0x8fcaca45, 0x1f82829d, 0x89c9c940, 0xfa7d7d87, 0xeffafa15, 0xb25959eb, 0x8e4747c9, 0xfbf0f00b,
	    0x41adadec, 0xb3d4d467, 0x5fa2a2fd, 0x45afafea, 0x239c9cbf, 0x53a4a4f7, 0xe4727296, 0x9bc0c05b,
	    0x75b7b7c2, 0xe1fdfd1c, 0x3d9393ae, 0x4c26266a, 0x6c36365a, 0x7e3f3f41, 0xf5f7f702, 0x83cccc4f,
	    0x6834345c, 0x51a5a5f4, 0xd1e5e534, 0xf9f1f108, 0xe2717193, 0xabd8d873, 0x62313153, 0x2a15153f,
	    0x0804040c, 0x95c7c752, 0x46232365, 0x9dc3c35e, 0x30181828, 0x379696a1, 0x0a05050f, 0x2f9a9ab5,
	    0x0e070709, 0x24121236, 0x1b80809b, 0xdfe2e23d, 0xcdebeb26, 0x4e272769, 0x7fb2b2cd, 0xea75759f,
	    0x1209091b, 0x1d83839e, 0x582c2c74, 0x341a1a2e, 0x361b1b2d, 0xdc6e6eb2, 0xb45a5aee, 0x5ba0a0fb,
	    0xa45252f6, 0x763b3b4d, 0xb7d6d661, 0x7db3b3ce, 0x5229297b, 0xdde3e33e, 0x5e2f2f71, 0x13848497,
	    0xa65353f5, 0xb9d1d168, 0x00000000, 0xc1eded2c, 0x40202060, 0xe3fcfc1f, 0x79b1b1c8, 0xb65b5bed,
	    0xd46a6abe, 0x8dcbcb46, 0x67bebed9, 0x7239394b, 0x944a4ade, 0x984c4cd4, 0xb05858e8, 0x85cfcf4a,
	    0xbbd0d06b, 0xc5efef2a, 0x4faaaae5, 0xedfbfb16, 0x864343c5, 0x9a4d4dd7, 0x66333355, 0x11858594,
	    0x8a4545cf, 0xe9f9f910, 0x04020206, 0xfe7f7f81, 0xa05050f0, 0x783c3c44, 0x259f9fba, 0x4ba8a8e3,
	    0xa25151f3, 0x5da3a3fe, 0x804040c0, 0x058f8f8a, 0x3f9292ad, 0x219d9dbc, 0x70383848, 0xf1f5f504,
	    0x63bcbcdf, 0x77b6b6c1, 0xafdada75, 0x42212163, 0x20101030, 0xe5ffff1a, 0xfdf3f30e, 0xbfd2d26d,
	    0x81cdcd4c, 0x180c0c14, 0x26131335, 0xc3ecec2f, 0xbe5f5fe1, 0x359797a2, 0x884444cc, 0x2e171739,
	    0x93c4c457, 0x55a7a7f2, 0xfc7e7e82, 0x7a3d3d47, 0xc86464ac, 0xba5d5de7, 0x3219192b, 0xe6737395,
	    0xc06060a0, 0x19818198, 0x9e4f4fd1, 0xa3dcdc7f, 0x44222266, 0x542a2a7e, 0x3b9090ab, 0x0b888883,
	    0x8c4646ca, 0xc7eeee29, 0x6bb8b8d3, 0x2814143c, 0xa7dede79, 0xbc5e5ee2, 0x160b0b1d, 0xaddbdb76,
	    0xdbe0e03b, 0x64323256, 0x743a3a4e, 0x140a0a1e, 0x924949db, 0x0c06060a, 0x4824246c, 0xb85c5ce4,
	    0x9fc2c25d, 0xbdd3d36e, 0x43acacef, 0xc46262a6, 0x399191a8, 0x319595a4, 0xd3e4e437, 0xf279798b,
	    0xd5e7e732, 0x8bc8c843, 0x6e373759, 0xda6d6db7, 0x018d8d8c, 0xb1d5d564, 0x9c4e4ed2, 0x49a9a9e0,
	    0xd86c6cb4, 0xac5656fa, 0xf3f4f407, 0xcfeaea25, 0xca6565af, 0xf47a7a8e, 0x47aeaee9, 0x10080818,
	    0x6fbabad5, 0xf0787888, 0x4a25256f, 0x5c2e2e72, 0x381c1c24, 0x57a6a6f1, 0x73b4b4c7, 0x97c6c651,
	    0xcbe8e823, 0xa1dddd7c, 0xe874749c, 0x3e1f1f21, 0x964b4bdd, 0x61bdbddc, 0x0d8b8b86, 0x0f8a8a85,
	    0xe0707090, 0x7c3e3e42, 0x71b5b5c4, 0xcc6666aa, 0x904848d8, 0x06030305, 0xf7f6f601, 0x1c0e0e12,
	    0xc26161a3, 0x6a35355f, 0xae5757f9, 0x69b9b9d0, 0x17868691, 0x99c1c158, 0x3a1d1d27, 0x279e9eb9,
	    0xd9e1e138, 0xebf8f813, 0x2b9898b3, 0x22111133, 0xd26969bb, 0xa9d9d970, 0x078e8e89, 0x339494a7,
	    0x2d9b9bb6, 0x3c1e1e22, 0x15878792, 0xc9e9e920, 0x87cece49, 0xaa5555ff, 0x50282878, 0xa5dfdf7a,
	    0x038c8c8f, 0x59a1a1f8, 0x09898980, 0x1a0d0d17, 0x65bfbfda, 0xd7e6e631, 0x844242c6, 0xd06868b8,
	    0x824141c3, 0x299999b0, 0x5a2d2d77, 0x1e0f0f11, 0x7bb0b0cb, 0xa85454fc, 0x6dbbbbd6, 0x2c16163a
	}

	local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	local b64lookup = {}
	for i = 1, #b64chars do b64lookup[string.byte(b64chars, i)] = i - 1 end

	local function Base64Decode(data)
	    local out = {}
	    local len = #data
	    local i = 1
	    while i <= len do
	        local c1 = b64lookup[string.byte(data, i)]
	        local c2 = b64lookup[string.byte(data, i + 1)]
	        local c3 = b64lookup[string.byte(data, i + 2)]
	        local c4 = b64lookup[string.byte(data, i + 3)]
	        if not c1 or not c2 then break end

	        local triple = bor(lshift(c1, 18), lshift(c2, 12), lshift(c3 or 0, 6), (c4 or 0))
	        out[#out + 1] = band(rshift(triple, 16), 0xff)
	        if c3 ~= nil then out[#out + 1] = band(rshift(triple, 8), 0xff) end
	        if c4 ~= nil then out[#out + 1] = band(triple, 0xff) end
	        i = i + 4
	    end
	    return out
	end

	local function ExpandKey(keyBytes)
	    local rounds = 14
	    local roundKeyCount = (rounds + 1) * 4
	    local KC = 8

	    local tk = {}
	    for i = 0, KC - 1 do
	        local b0 = keyBytes[i * 4 + 1]
	        local b1 = keyBytes[i * 4 + 2]
	        local b2 = keyBytes[i * 4 + 3]
	        local b3 = keyBytes[i * 4 + 4]
	        tk[i] = bor(lshift(b0, 24), lshift(b1, 16), lshift(b2, 8), b3)
	    end

	    local Ke = {}
	    for r = 0, rounds do Ke[r] = {0, 0, 0, 0} end
	    for i = 0, KC - 1 do Ke[math.floor(i / 4)][i % 4] = tk[i] end

	    local rconptr = 1
	    local t = KC
	    while t < roundKeyCount do
	        local tt = tk[KC - 1]
	        local subtt = bor(
	            lshift(SBOX[band(rshift(tt, 16), 0xff) + 1], 24),
	            lshift(SBOX[band(rshift(tt, 8), 0xff) + 1], 16),
	            lshift(SBOX[band(tt, 0xff) + 1], 8),
	            SBOX[band(rshift(tt, 24), 0xff) + 1]
	        )
	        tk[0] = bxor(tk[0], subtt, lshift(RCON[rconptr], 24))
	        rconptr = rconptr + 1

	        for i = 1, 3 do tk[i] = bxor(tk[i], tk[i - 1]) end

	        tt = tk[3]
	        local subtt2 = bor(
	            lshift(SBOX[band(rshift(tt, 24), 0xff) + 1], 24),
	            lshift(SBOX[band(rshift(tt, 16), 0xff) + 1], 16),
	            lshift(SBOX[band(rshift(tt, 8), 0xff) + 1], 8),
	            SBOX[band(tt, 0xff) + 1]
	        )
	        tk[4] = bxor(tk[4], subtt2)

	        for i = 5, 7 do tk[i] = bxor(tk[i], tk[i - 1]) end

	        local j = 0
	        while j < KC and t < roundKeyCount do
	            Ke[math.floor(t / 4)][t % 4] = tk[j]
	            j = j + 1
	            t = t + 1
	        end
	    end
	    return Ke
	end

	local function EncryptBlock(ptBytes, Ke)
	    local t0 = bxor(bor(lshift(ptBytes[1], 24), lshift(ptBytes[2], 16), lshift(ptBytes[3], 8), ptBytes[4]), Ke[0][0])
	    local t1 = bxor(bor(lshift(ptBytes[5], 24), lshift(ptBytes[6], 16), lshift(ptBytes[7], 8), ptBytes[8]), Ke[0][1])
	    local t2 = bxor(bor(lshift(ptBytes[9], 24), lshift(ptBytes[10], 16), lshift(ptBytes[11], 8), ptBytes[12]), Ke[0][2])
	    local t3 = bxor(bor(lshift(ptBytes[13], 24), lshift(ptBytes[14], 16), lshift(ptBytes[15], 8), ptBytes[16]), Ke[0][3])

	    local a0, a1, a2, a3
	    for r = 1, 13 do
	        local kr = Ke[r]
	        a0 = bxor(
	            T1[band(rshift(t0, 24), 0xff) + 1],
	            rrotate(T1[band(rshift(t1, 16), 0xff) + 1], 8),
	            rrotate(T1[band(rshift(t2, 8), 0xff) + 1], 16),
	            rrotate(T1[band(t3, 0xff) + 1], 24),
	            kr[0]
	        )
	        a1 = bxor(
	            T1[band(rshift(t1, 24), 0xff) + 1],
	            rrotate(T1[band(rshift(t2, 16), 0xff) + 1], 8),
	            rrotate(T1[band(rshift(t3, 8), 0xff) + 1], 16),
	            rrotate(T1[band(t0, 0xff) + 1], 24),
	            kr[1]
	        )
	        a2 = bxor(
	            T1[band(rshift(t2, 24), 0xff) + 1],
	            rrotate(T1[band(rshift(t3, 16), 0xff) + 1], 8),
	            rrotate(T1[band(rshift(t0, 8), 0xff) + 1], 16),
	            rrotate(T1[band(t1, 0xff) + 1], 24),
	            kr[2]
	        )
	        a3 = bxor(
	            T1[band(rshift(t3, 24), 0xff) + 1],
	            rrotate(T1[band(rshift(t0, 16), 0xff) + 1], 8),
	            rrotate(T1[band(rshift(t1, 8), 0xff) + 1], 16),
	            rrotate(T1[band(t2, 0xff) + 1], 24),
	            kr[3]
	        )
	        t0, t1, t2, t3 = a0, a1, a2, a3
	    end

	    local k14 = Ke[14]
	    return {
	        band(bxor(SBOX[band(rshift(t0, 24), 0xff) + 1], band(rshift(k14[0], 24), 0xff)), 0xff),
	        band(bxor(SBOX[band(rshift(t1, 16), 0xff) + 1], band(rshift(k14[0], 16), 0xff)), 0xff),
	        band(bxor(SBOX[band(rshift(t2, 8), 0xff) + 1], band(rshift(k14[0], 8), 0xff)), 0xff),
	        band(bxor(SBOX[band(t3, 0xff) + 1], band(k14[0], 0xff)), 0xff),

	        band(bxor(SBOX[band(rshift(t1, 24), 0xff) + 1], band(rshift(k14[1], 24), 0xff)), 0xff),
	        band(bxor(SBOX[band(rshift(t2, 16), 0xff) + 1], band(rshift(k14[1], 16), 0xff)), 0xff),
	        band(bxor(SBOX[band(rshift(t3, 8), 0xff) + 1], band(rshift(k14[1], 8), 0xff)), 0xff),
	        band(bxor(SBOX[band(t0, 0xff) + 1], band(k14[1], 0xff)), 0xff),

	        band(bxor(SBOX[band(rshift(t2, 24), 0xff) + 1], band(rshift(k14[2], 24), 0xff)), 0xff),
	        band(bxor(SBOX[band(rshift(t3, 16), 0xff) + 1], band(rshift(k14[2], 16), 0xff)), 0xff),
	        band(bxor(SBOX[band(rshift(t0, 8), 0xff) + 1], band(rshift(k14[2], 8), 0xff)), 0xff),
	        band(bxor(SBOX[band(t1, 0xff) + 1], band(k14[2], 0xff)), 0xff),

	        band(bxor(SBOX[band(rshift(t3, 24), 0xff) + 1], band(rshift(k14[3], 24), 0xff)), 0xff),
	        band(bxor(SBOX[band(rshift(t0, 16), 0xff) + 1], band(rshift(k14[3], 16), 0xff)), 0xff),
	        band(bxor(SBOX[band(rshift(t1, 8), 0xff) + 1], band(rshift(k14[3], 8), 0xff)), 0xff),
	        band(bxor(SBOX[band(t2, 0xff) + 1], band(k14[3], 0xff)), 0xff)
	    }
	end

	local cachedKe = nil
	local function AesCtrDecrypt(dataBytes, nonceBytes, keyStr)
	    if not cachedKe then
	        local keyBytes = {}
	        for i = 1, #keyStr do keyBytes[i] = string.byte(keyStr, i) end
	        cachedKe = ExpandKey(keyBytes)
	    end

	    local counter = {}
	    for i = 1, 16 do counter[i] = nonceBytes[i] end

	    local out = {}
	    local len = #dataBytes
	    local offset = 1

	    while offset <= len do
	        local keystream = EncryptBlock(counter, cachedKe)
	        local blockLen = math.min(16, len - offset + 1)
	        for i = 1, blockLen do
	            out[offset + i - 1] = bxor(dataBytes[offset + i - 1], keystream[i])
	        end
	        offset = offset + 16

	        for i = 16, 1, -1 do
	            counter[i] = (counter[i] + 1) % 256
	            if counter[i] ~= 0 then break end
	        end
	    end

	    local chars = {}
	    for i = 1, #out do chars[i] = string.char(out[i]) end
	    return table.concat(chars)
	end

	local function DecodeAesJobId(token)
	    if not token or type(token) ~= "string" then return nil end
	    local s = token
	    if s:sub(1, #PREFIX) == PREFIX then s = s:sub(#PREFIX + 1) end
	    s = s:gsub(DECOY_A, "")
	    s = s:gsub(DECOY_B, "")

	    local rawBytes = Base64Decode(s)
	    if #rawBytes < 17 then return nil end

	    local nonce = {}
	    for i = 1, 16 do nonce[i] = rawBytes[i] end

	    local ct = {}
	    for i = 17, #rawBytes do ct[#ct + 1] = rawBytes[i] end

	    return AesCtrDecrypt(ct, nonce, AES_SECRET_KEY)
	end

	function BossFarm.IsJobId(value)
		if type(value) ~= "string" or #value ~= 36 then return false end
		local a, b, c, d, e = value:match("^(%x+)%-(%x+)%-(%x+)%-(%x+)%-(%x+)$")
		return a ~= nil and #a == 8 and #b == 4 and #c == 4 and #d == 4 and #e == 12
	end

	function BossFarm.DecodeJobId(token)
		if BossFarm.IsJobId(token) then return token end
		if type(token) ~= "string" or #token > 512 or token:sub(1, #PREFIX) ~= PREFIX then return nil end
		local payload = token:sub(#PREFIX + 1):gsub(DECOY_A, ""):gsub(DECOY_B, "")
		if #payload % 4 ~= 0 or payload:find("[^%w+/=]") then return nil end
		local ok, jobId = pcall(DecodeAesJobId, token)
		if ok and BossFarm.IsJobId(jobId) then return jobId end
		return nil
	end
end

local SeaByPlaceId = {
	[85211729168715] = 1,
	[2753915549] = 1,
	[4442272183] = 2,
	[79091703265657] = 2,
	[7449423635] = 3,
	[100117331123089] = 3,
}

local state = env.__CyborgCodexState or {}
env.__CyborgCodexState = state
state.JobId = state.JobId or game.JobId
state.ChestCount = state.ChestCount or 0
state.SeenChests = state.SeenChests or {}
state.NextAction = 0
state.LastNotice = state.LastNotice or {}
state.LastRemote = state.LastRemote or {}
state.LastRemote.FistCheck = nil
state.Busy = false
state.Enabled = false
state.HopPending = false
state.FistSubmitted = false
state.FistSubmissionJob = nil
state.Generation = (state.Generation or 0) + 1
local generation = state.Generation
state.Worker = false
state.FastAttackWorker = false
state.FastAttackTarget = nil
state.FastAttackTargets = nil
state.ActiveWorkflow = nil
state.Connections = {}
state.BossSelection = nil
state.BossRequest = nil
state.BossStatus = "Idle"
state.GhoulStatus = "Idle"
state.GhoulPhase = "Idle"
state.GhoulExchangeAwaiting = nil
state.GhoulTarget = nil
state.GhoulRewardUntil = nil
state.GhoulCount = nil
state.GhoulUnlocked = nil
state.GhoulChangeAttempted = false
state.TTKCompleted = false
state.TTKWeapon = nil
state.LastRemote.GhoulCheck = nil
state.LastRemote.GhoulExchange = nil
state.BossVisited = type(env.__CyborgCodexBossVisited) == "table" and env.__CyborgCodexBossVisited
	 or (type(state.BossVisited) == "table" and state.BossVisited or {})
env.__CyborgCodexBossVisited = nil

if state.JobId ~= game.JobId then
	state.JobId = game.JobId
	state.ChestCount = 0
	state.SeenChests = {}
	state.HopPending = false
	state.FistSubmitted = false
	state.Enabled = false
	state.Worker = false
	state.CurrentChest = nil
	state.CurrentChestSince = nil
end

local function log(message)
	warn("[Teddy Hub] " .. tostring(message))
end

local function reportControllerError(err, workflow, phase)
	workflow = workflow or state.ActiveWorkflow or "Controller"
	phase = phase or (workflow == "Ghoul" and state.GhoulPhase) or state.Stage or "Unknown"
	local now = os.clock()
	local previous = state.LastControllerError
	local trace = tostring(err)
	state.LastControllerError = { Workflow = workflow, Phase = phase, Traceback = trace, Time = now }
	if not previous or previous.Traceback ~= trace or previous.Phase ~= phase
		or now - (state.LastControllerErrorPrint or -math.huge) >= 5 then
		state.LastControllerErrorPrint = now
		print("[Teddy Hub][ERROR][" .. workflow .. "][" .. phase .. "]\n" .. trace)
	end
end

local workflowActive = LPH_JIT_MAX(function(name)
	return state.Generation == generation and state.Enabled and state.ActiveWorkflow == name
		and ((name == "Cyborg" and env.cyborgrace == true)
			or (name == "SoulGuitar" and env.autosoulguitar == true)
			or (name == "Ghoul" and env.autoghoulrace == true)
			or (name == "TTK" and env.autottk == true and not state.TTKCompleted)
			or (name == "Haki" and env.autohakilegendary == true and not Haki.Completed)
			or (name == "PullLever" and env.AutoPullLevel == true and not PullLever.Completed)
			or (GameEvents.States[name] and env[GameEvents.States[name].Flag] == true)
			or (SwordGet.States[name] and env[SwordGet.States[name].Flag] == true and not SwordGet.States[name].Completed)
			or (name == "Boss" and env.autofarmboss == true and state.BossSelection == env.selectedboss))
end)

local attackActive = LPH_JIT_MAX(function()
	return workflowActive("Cyborg") or workflowActive("SoulGuitar") or workflowActive("Boss") or workflowActive("Ghoul")
		or workflowActive("TTK") or workflowActive("Yama") or workflowActive("Tushita") or workflowActive("CDK") or workflowActive("Haki")
		or workflowActive("Factory") or workflowActive("Pirate") or workflowActive("Fruit") or workflowActive("Berry")
		or workflowActive("Mirage") or workflowActive("Volcanic")
		or workflowActive("Kitsune")
		or workflowActive("PullLever")
end)

local chooseWorkflow = LPH_JIT_MAX(function(cyborgEnabled, soulEnabled, cyborgOwned, bossEnabled, ghoulEnabled, ttkEnabled, yamaEnabled, tushitaEnabled, cdkEnabled, hakiEnabled)
	if env.AutoPullLevel == true and not PullLever.Completed then return "PullLever" end
	for _, name in ipairs({ "Mirage", "Volcanic", "Kitsune" }) do
		if env[GameEvents.States[name].Flag] == true and GameEvents.FindIsland(name) then return name end
	end
	if tushitaEnabled and not SwordGet.States.Tushita.Completed then return "Tushita" end
	if yamaEnabled and not SwordGet.States.Yama.Completed then return "Yama" end
	if cdkEnabled and not SwordGet.States.CDK.Completed then return "CDK" end
	if ttkEnabled and not state.TTKCompleted then return "TTK" end
	if bossEnabled then return "Boss" end
	if ghoulEnabled then return "Ghoul" end
	if hakiEnabled and not Haki.Completed then return "Haki" end
	if cyborgEnabled and not cyborgOwned then return "Cyborg" end
	if soulEnabled then return "SoulGuitar" end
	for _, name in ipairs({ "Factory", "Pirate", "Fruit", "Berry" }) do
		if env[GameEvents.States[name].Flag] == true then return name end
	end
	for _, name in ipairs({ "Mirage", "Volcanic", "Kitsune" }) do
		if env[GameEvents.States[name].Flag] == true then return name end
	end
	return nil
end)

local function setStage(stage)
	if state.Stage ~= stage then
		state.FastAttackTarget = nil
		state.FastAttackTargets = nil
		state.ZombieBatch = nil
		state.Stage = stage
		log("Stage: " .. stage)
	end
end

local function notify(message, key, interval)
	local now = os.clock()
	if key and state.LastNotice[key] and now - state.LastNotice[key] < (interval or 5) then
		return
	end
	if key then
		state.LastNotice[key] = now
	end
	local notification = ReplicatedStorage:FindFirstChild("Notification")
	if notification then
		local ok, err = pcall(function()
			require(notification).new("<Color=Red>Teddy Hub: " .. message .. "<Color=/>"):Display()
		end)
		if ok then
			return
		end
		log("Notification unavailable: " .. tostring(err))
	end
	log(message)
end

local function getCommF()
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	local remote = remotes and remotes:FindFirstChild("CommF_")
	assert(remote and remote:IsA("RemoteFunction"), "ReplicatedStorage.Remotes.CommF_ is unavailable")
	return remote
end

local function invokeCommF(...)
	local args = { ... }
	local command = args[1]
	local mutation = command == "Buso" or command == "SetTeam" or command == "TravelDressrosa"
		or command == "TravelZou" or command == "requestEntrance" or command == "BlackbeardReward"
		or command == "gravestoneEvent" or (command == "CyborgTrainer" and args[2] == "Buy")
		or command == "LoadItem" or command == "StartQuest" or command == "AbandonQuest"
		or (command == "LegendarySwordDealer" and args[2] == "2") or (command == "MysteriousMan" and args[2] == "2")
		or (command == "ColorsDealer" and args[2] == "2")
		or (command == "EliteHunter" and args[2] ~= "Progress") or (command == "TushitaProgress" and args[2] == "Torch")
		or (command == "CDKQuest" and args[2] ~= "Progress") or (command == "Bones" and args[2] == "Buy")
		or (command == "soulGuitarBuy" and args[2] ~= true)
		or (command == "GuitarPuzzleProgress" and args[2] ~= "Check")
		or (command == "Ectoplasm" and (args[2] == "Buy" or args[2] == "Change"))
	if mutation and not attackActive() and not (command == "Buso" and env.AutoBuso == true) then return nil end
	return getCommF():InvokeServer(...)
end

local function hasItem(name)
	local character = player.Character
	local backpack = player:FindFirstChild("Backpack")
	return (character and character:FindFirstChild(name) ~= nil)
		or (backpack and backpack:FindFirstChild(name) ~= nil)
		or false
end

local function equipItem(name)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local backpack = player:FindFirstChild("Backpack")
	local tool = (character and character:FindFirstChild(name)) or (backpack and backpack:FindFirstChild(name))
	if not (humanoid and tool and tool:IsA("Tool")) then
		return false
	end
	if tool.Parent == backpack then
		humanoid:EquipTool(tool)
	end
	return true
end

local function checkRace()
	local data = player:FindFirstChild("Data")
	local race = data and data:FindFirstChild("Race")
	local owned = race ~= nil and race.Value == "Cyborg"
	if owned then
		state.LastRaceCheck = os.clock()
		state.LastRaceCheckOk = true
		state.LastRaceCheckError = nil
		state.LastRaceOwned = true
		state.LastCoreBrainSubmitted = state.LastCoreBrainSubmitted or false
		return true, state.LastCoreBrainSubmitted
	end
	if os.clock() - (state.LastRaceCheck or 0) < 2 then
		if state.LastRaceCheckOk then
			return state.LastRaceOwned, state.LastCoreBrainSubmitted
		end
		error(state.LastRaceCheckError or "CyborgTrainer Check failed")
	end
	state.LastRaceCheck = os.clock()
	state.LastRaceCheckOk = false
	local ok, result = pcall(invokeCommF, "CyborgTrainer", "Check")
	if not ok then
		state.LastRaceCheckError = tostring(result)
		error("CyborgTrainer Check failed: " .. tostring(result))
	end
	state.LastRaceCheckOk = true
	state.LastRaceCheckError = nil
	state.LastRaceValue = result
	state.LastRaceOwned = false
	state.LastCoreBrainSubmitted = result == true
	return false, state.LastCoreBrainSubmitted
end

local function requestCyborgBuy()
	if os.clock() - (state.LastRemote.BuyRace or 0) < 5 then
		return false
	end
	state.LastRemote.BuyRace = os.clock()
	local ok, result = pcall(invokeCommF, "CyborgTrainer", "Buy")
	state.LastRaceCheck = -math.huge
	state.LastRaceCheckOk = false
	if not ok then
		error("CyborgTrainer Buy failed: " .. tostring(result))
	end
	log("CyborgTrainer Buy response: " .. tostring(result))
	return true
end

local ensureTeam = LPH_JIT(function()
	if state.Generation ~= generation then return false end
	Config.Team = env.Team == "Pirates" and "Pirates" or "Marines"
	if player.Team and player.Team.Name == Config.Team then
		return true
	end
	local now = os.clock()
	if state.LastRemote.Team and now - state.LastRemote.Team < 3 then return false end
	state.LastRemote.Team = now
	local ok, err = pcall(function()
		return getCommF():InvokeServer("SetTeam", Config.Team)
	end)
	if state.Generation ~= generation then return false end
	if not ok and (not state.LastTeamError or now - state.LastTeamError >= 5) then
		state.LastTeamError = now
		log("Team join failed: " .. tostring(err))
	end
	return player.Team ~= nil and player.Team.Name == Config.Team
end)

local function currentSea()
	if SeaByPlaceId[game.PlaceId] then return SeaByPlaceId[game.PlaceId] end
	if type(env.CheckPlaceId) == "number" then SeaByPlaceId[env.CheckPlaceId] = 1 end
	if type(env.CheckPlaceId2) == "number" then SeaByPlaceId[env.CheckPlaceId2] = 2 end
	if type(env.CheckPlaceId3) == "number" then SeaByPlaceId[env.CheckPlaceId3] = 3 end
	return SeaByPlaceId[game.PlaceId]
end

local queueResume

local function travelToSea2()
	local sea = currentSea()
	if sea == 2 then
		return true
	end
	if sea ~= 1 and sea ~= 3 then
		setStage("unsupported place")
		notify("Unsupported PlaceId " .. tostring(game.PlaceId) .. "; cannot determine sea.", "place", 15)
		return false
	end
	setStage("travel to Sea 2")
	if os.clock() - (state.LastRemote.Travel or 0) >= 10 then
		state.LastRemote.Travel = os.clock()
		queueResume()
		invokeCommF("TravelDressrosa")
	end
	return false
end

local function travelToSea3()
	if currentSea() == 3 then return true end
	if not currentSea() then
		notify("Cannot determine sea for this PlaceId.", "place", 5)
		return false
	end
	setStage("travel to Sea 3")
	if os.clock() - (state.LastRemote.Travel or 0) >= 10 then
		state.LastRemote.Travel = os.clock()
		queueResume()
		invokeCommF("TravelZou")
	end
	return false
end

local getRoot = LPH_JIT_MAX(function()
	local character = player.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end)

local uprightCFrame = LPH_JIT_MAX(function(cf)
	local facing = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z)
	if facing.Magnitude < 0.001 then facing = Vector3.new(0, 0, -1) end
	return CFrame.lookAt(cf.Position, cf.Position + facing, Vector3.yAxis)
end)

local function releaseUpright()
	local hold = state.UprightHold
	state.UprightHold = nil
	if not hold then return end
	if hold.Connection then hold.Connection:Disconnect() end
	if hold.Humanoid.Parent then hold.Humanoid.AutoRotate = hold.AutoRotate end
	hold.Alignment:Destroy()
	hold.Attachment:Destroy()
end

local function holdUpright(root)
	if state.UprightHold and state.UprightHold.Root == root then return end
	releaseUpright()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	local attachment = Instance.new("Attachment")
	attachment.Name = "CyborgCodexUprightAttachment"
	attachment.Parent = root
	local alignment = Instance.new("AlignOrientation")
	alignment.Name = "CyborgCodexUpright"
	alignment.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignment.Attachment0 = attachment
	alignment.MaxTorque = 10000000
	alignment.MaxAngularVelocity = 30
	alignment.Responsiveness = 40
	alignment.RigidityEnabled = false
	root.CFrame = uprightCFrame(root.CFrame)
	root.AssemblyAngularVelocity = Vector3.zero
	alignment.CFrame = root.CFrame
	alignment.Parent = root
	local hold = { Root = root, Humanoid = humanoid, AutoRotate = humanoid.AutoRotate,
		Alignment = alignment, Attachment = attachment }
	state.UprightHold = hold
	humanoid.AutoRotate = false
	hold.Connection = RunService.Stepped:Connect(function()
		if state.UprightHold ~= hold then return end
		if not attackActive() or getRoot() ~= root or humanoid.Health <= 0 then releaseUpright(); return end
		alignment.CFrame = uprightCFrame(root.CFrame)
		root.AssemblyAngularVelocity = Vector3.zero
	end)
end

local function setFloat(enabled)
	local root = getRoot()
	if state.FloatRoot and (not enabled or state.FloatRoot ~= root) then
		local oldForce = state.FloatRoot:FindFirstChild("CyborgCodexFloat")
		if oldForce then oldForce:Destroy() end
		state.FloatRoot = nil
	end
	if not enabled then releaseUpright() end
	if not root then
		releaseUpright()
		return
	end
	local force = root:FindFirstChild("CyborgCodexFloat")
	if enabled then
		holdUpright(root)
		state.FloatRoot = root
		if not force then
			force = Instance.new("BodyVelocity")
			force.Name = "CyborgCodexFloat"
			force.Velocity = Vector3.zero
			force.MaxForce = Vector3.new(100000, 100000, 100000)
			force.P = 10000
			force.Parent = root
		end
	elseif force then
		force:Destroy()
	end
end

local function setNoClip(enabled)
	state.NoClipEnabled = enabled
	if enabled then
		if state.NoClipConnection then
			return
		end
		state.SavedCollision = setmetatable({}, { __mode = "k" })
		state.NoClipConnection = RunService.Stepped:Connect(function()
			local character = player.Character
			if not character then return end
			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") and part.Name ~= "CyborgCodexFloat" then
					if state.SavedCollision[part] == nil then
						state.SavedCollision[part] = part.CanCollide
					end
					part.CanCollide = false
				end
			end
		end)
		return
	end
	if state.NoClipConnection then
		state.NoClipConnection:Disconnect()
		state.NoClipConnection = nil
	end
	for part, canCollide in pairs(state.SavedCollision or {}) do
		if part.Parent then
			part.CanCollide = canCollide
		end
	end
	state.SavedCollision = nil
end

local function cancelMovement()
	if state.Tween then
		state.Tween:Cancel()
		state.Tween = nil
	end
	state.TweenGoal = nil
end

local moveTo = LPH_JIT(function(target, combat, arrivalRadius)
	if not combat then state.CombatFollow = nil end
	if not attackActive() then return false end
	local root = getRoot()
	assert(root, "Character HumanoidRootPart is unavailable")
	assert(typeof(target) == "CFrame", "moveTo target must be a CFrame")
	target = uprightCFrame(target)
	local portal
	if currentSea() == 2 then
		local ship = Vector3.new(923.2125244140625, 126.97600555419922, 32852.83203125)
		local fromShip = (root.Position - ship).Magnitude
		local toShip = (target.Position - ship).Magnitude
		if (fromShip >= 3000) ~= (toShip >= 3000) then
			local map = workspace:FindFirstChild("Map")
			local model = map and map:FindFirstChild(fromShip >= 3000 and "GhostShip" or "GhostShipInterior")
			portal = model and model:FindFirstChild("Teleport")
			assert(portal and portal:IsA("BasePart") and portal:FindFirstChild("TouchInterest"),
				"Cursed Ship Teleport/TouchInterest is unavailable; waiting for map replication")
			target = uprightCFrame(portal.CFrame)
		end
	end
	local distance = (root.Position - target.Position).Magnitude
	if distance <= (portal and 3 or arrivalRadius or 8) then
		cancelMovement()
		setNoClip(false)
		setFloat(false)
		if portal then
			local touch = env.firetouchinterest or firetouchinterest
			if type(touch) == "function" and os.clock() - (state.LastRemote.ShipTouch or -math.huge) >= 2 then
				state.LastRemote.ShipTouch = os.clock()
				local owner = state.ActiveWorkflow
				local ok, err = xpcall(function()
					if not attackActive() or getRoot() ~= root then return end
					touch(root, portal, 0)
					task.wait()
				end, debug.traceback)
				local ended, endError = pcall(touch, root, portal, 1)
				if not ok then error(err) end
				if not ended then error(endError) end
				if not attackActive() or getRoot() ~= root or state.ActiveWorkflow ~= owner then return false end
			end
			return false
		end
		return true
	end
	if state.Tween and state.Tween.PlaybackState == Enum.PlaybackState.Playing
		and state.TweenGoal and (state.TweenGoal.Position - target.Position).Magnitude < 8 then
		return false
	end
	cancelMovement()
	setNoClip(true)
	setFloat(true)
	local duration = math.max(distance / Config.TweenSpeed, 0.15)
	local tween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), { CFrame = target })
	state.Tween = tween
	state.TweenGoal = target
	tween:Play()
	tween.Completed:Once(function()
		if state.Tween == tween then
			state.Tween = nil
			state.TweenGoal = nil
		end
	end)
	return false
end)

local function cleanupMovement()
	state.CombatFollow = nil
	cancelMovement()
	setNoClip(false)
	setFloat(false)
end

local function requestJump(humanoid)
	if not humanoid or os.clock() - (state.LastJumpRequest or 0) < 0.8 then
		return
	end
	state.LastJumpRequest = os.clock()
	local ok, err = pcall(function()
		humanoid.Jump = true
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end)
	if not ok then
		log("Humanoid jump request failed: " .. tostring(err))
	end
end

local function escapeSeatWhileCollecting()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		state.SeatStuckSince = nil
		return false
	end
	local ok, seated = pcall(SeatUtil.isSeated, humanoid)
	if not ok then
		if os.clock() - (state.LastSeatUtilWarning or 0) >= 5 then
			state.LastSeatUtilWarning = os.clock()
			log("SeatUtil.isSeated failed: " .. tostring(seated))
		end
		seated = false
	end
	seated = seated == true or humanoid.Sit or humanoid.SeatPart ~= nil
	if not seated then
		state.SeatStuckSince = nil
		return false
	end

	cancelMovement()
	setNoClip(false)
	setFloat(false)
	local now = os.clock()
	state.SeatStuckSince = state.SeatStuckSince or now
	if now - state.SeatStuckSince < 0.4 or now - (state.LastSeatEscape or 0) < 1.5 then
		return true
	end
	state.LastSeatEscape = now
	local unseatOk, unseatError = pcall(SeatUtil.unseat, humanoid)
	if not unseatOk then
		log("SeatUtil.unseat failed: " .. tostring(unseatError))
	end
	humanoid.Sit = false
	requestJump(humanoid)
	local root = character:FindFirstChild("HumanoidRootPart")
	if root then
		root.CFrame = root.CFrame * CFrame.new(0, 10, 0)
	end
	return true
end

local function getRaidButton()
	local map = workspace:FindFirstChild("Map")
	local island = map and map:FindFirstChild("CircleIsland")
	local summon = island and island:FindFirstChild("RaidSummon")
	local button = summon and summon:FindFirstChild("Button")
	return button and button:FindFirstChild("Main")
end

local RaidButtonCFrame = CFrame.new(-5570.052734375, 332.41363525391, -5965.91015625)

local function clickPart(part)
	if not attackActive() then return false end
	local detector = part and part:FindFirstChildOfClass("ClickDetector")
	assert(detector, "RaidSummon ClickDetector is unavailable")
	local click = env.fireclickdetector or _G.fireclickdetector
	assert(type(click) == "function", "Executor fireclickdetector is unavailable")
	click(detector)
end

local function isRaidUnlocked()
	if not workflowActive("Cyborg") then return false end
	if state.FistSubmitted == true and state.FistSubmissionJob == game.JobId then
		return true
	end
	if os.clock() - (state.LastRemote.FistCheck or -math.huge) < 2 then return false end
	state.LastRemote.FistCheck = os.clock()
	local jobId = game.JobId
	local ok, result = pcall(invokeCommF, "CheckBlockPart")
	if not workflowActive("Cyborg") or game.JobId ~= jobId then return false end
	if ok and result == true then
		state.FistSubmitted = true
		state.FistSubmissionJob = jobId
		return true
	end
	return false
end

local function interactWithRaidButton(button, hadFist)
	if not workflowActive("Cyborg") or not hadFist or not hasItem("Fist of Darkness") then return false end
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = getRoot()
	local jobId = game.JobId
	local fist = character and character:FindFirstChild("Fist of Darkness")
	if not humanoid or humanoid.Health <= 0 or not root
		or not fist or not fist:IsA("Tool")
		or (root.Position - RaidButtonCFrame.Position).Magnitude > 14 then return false end
	local ok, err = pcall(clickPart, button)
	if ok then
		task.wait(0.5)
	end
	if not ok then
		error(err)
	end
	if not workflowActive("Cyborg") or game.JobId ~= jobId or player.Character ~= character
		or humanoid.Health <= 0 or getRoot() ~= root then return false end
	state.LastRemote.Submit = os.clock()
	if not hasItem("Fist of Darkness") then
		state.FistSubmitted = true
		state.FistSubmissionJob = jobId
		log("RaidSummon confirmed the Fist of Darkness submission.")
		return true
	end
	state.LastRemote.FistCheck = nil
	if isRaidUnlocked() then return true end
	log("RaidSummon did not confirm Fist submission; will verify again before resuming chest farming.")
	return false
end

local function submitItem(name)
	local button = getRaidButton()
	assert(button, "Map.CircleIsland.RaidSummon.Button.Main is unavailable")
	local root = getRoot()
	assert(root, "Character HumanoidRootPart is unavailable")
	if (root.Position - RaidButtonCFrame.Position).Magnitude > 14 then
		moveTo(RaidButtonCFrame)
		return false
	end
	if not equipItem(name) then
		return false
	end
	task.wait(0.3)
	if not workflowActive("Cyborg") then return false end
	clickPart(button)
	state.LastRemote.Submit = os.clock()
	return true
end

local function getChestPosition(chest)
	if chest:IsA("BasePart") then return chest.CFrame end
	if chest:IsA("Model") then return chest:GetPivot() end
	return nil
end

local function isChestAvailable(chest)
	return chest and chest.Parent and not chest:GetAttribute("IsDisabled")
		and not chest:FindFirstChild("Ignored") and CollectionService:HasTag(chest, "_ChestTagged")
end

local function nearestChest()
	local root = getRoot()
	if not root then return nil end
	local nearest, nearestDistance
	for _, chest in ipairs(CollectionService:GetTagged("_ChestTagged")) do
		if isChestAvailable(chest) and not state.SeenChests[chest] then
			local cf = getChestPosition(chest)
			if cf then
				local distance = (root.Position - cf.Position).Magnitude
				if not nearestDistance or distance < nearestDistance then
					nearest, nearestDistance = chest, distance
				end
			end
		end
	end
	return nearest
end

local function findChestSpawn()
	local origin = workspace:FindFirstChild("_WorldOrigin")
	local spawns = origin and origin:FindFirstChild("PlayerSpawns")
	local pirates = spawns and spawns:FindFirstChild("Pirates")
	local root = getRoot()
	local best, bestDistance
	if not (pirates and root) then return nil end
	state.SeenChestSpawns = state.SeenChestSpawns or {}
	for _, spawn in ipairs(pirates:GetChildren()) do
		local part = spawn:FindFirstChild("Part")	
		if part and not spawn:FindFirstChild("Ignored") and not state.SeenChestSpawns[part] then
			local distance = (root.Position - part.Position).Magnitude
			if not bestDistance or distance < bestDistance then
				best, bestDistance = part, distance
			end
		end
	end
	if not best and os.clock() - (state.LastChestSpawnReset or 0) > 30 then
		state.SeenChestSpawns = {}
		state.SeenChests = {}
		state.LastChestSpawnReset = os.clock()
	end
	return best
end

queueResume = function(manual)
	assert(manual == true or attackActive(), "No enabled workflow owns this teleport")
	local source = env.__CyborgCodexSource
	assert(type(source) == "string", "Standalone resume source is unavailable")
	local queue = env.queue_on_teleport or _G.queue_on_teleport
	if env.syn and type(env.syn.queue_on_teleport) == "function" then
		queue = env.syn.queue_on_teleport
	end
	assert(type(queue) == "function", "Executor queue_on_teleport is unavailable; cannot resume after teleport")
	local payload = "local e=getgenv(); e.cyborgrace=" .. tostring(env.cyborgrace == true)
		.. "; e.Team=" .. string.format("%q", env.Team or "Marines")
		.. "; e.autosoulguitar=" .. tostring(env.autosoulguitar == true)
		.. "; e.autoghoulrace=" .. tostring(env.autoghoulrace == true)
		.. "; e.autottk=" .. tostring(env.autottk == true)
		.. "; e.autoyama=" .. tostring(env.autoyama == true)
		.. "; e.autotushita=" .. tostring(env.autotushita == true)
		.. "; e.autocdk=" .. tostring(env.autocdk == true)
		.. "; e.autohakilegendary=" .. tostring(env.autohakilegendary == true)
		.. "; e.AutoPullLevel=" .. tostring(env.AutoPullLevel == true)
		.. "; e.autofactoryhop=" .. tostring(env.autofactoryhop == true)
		.. "; e.autopirateraidhop=" .. tostring(env.autopirateraidhop == true)
		.. "; e.autofruithop=" .. tostring(env.autofruithop == true)
		.. "; e.autoberryhop=" .. tostring(env.autoberryhop == true)
		.. "; e.AutoRandomFruit=" .. tostring(env.AutoRandomFruit == true)
		.. "; e.AutoStoreFruit=" .. tostring(env.AutoStoreFruit == true)
		.. "; e.TeleportMirageIsland=" .. tostring(env.TeleportMirageIsland == true)
		.. "; e.TeleportVolcanicIsland=" .. tostring(env.TeleportVolcanicIsland == true)
		.. "; e.TeleportKitsuneIsland=" .. tostring(env.TeleportKitsuneIsland == true)
		.. "; e.__CyborgCodexFruitHint=game:GetService('HttpService'):JSONDecode(" .. string.format("%q", HttpService:JSONEncode(GameEvents.States.Fruit.Hint or {})) .. ")"
		.. "; e.__CyborgCodexHakiTarget=" .. string.format("%q", Haki.Target or "")
		.. "; e.__CyborgCodexCDKTraining=" .. string.format("%q", SwordGet.States.CDK.Training or "")
		.. "; e.__CyborgCodexTushitaHydraReady=" .. tostring(SwordGet.States.Tushita.HydraReady == true)
		.. "; e.SelectedWeapon=" .. string.format("%q", env.SelectedWeapon or "Melee")
		.. "; e.AutoBuso=" .. tostring(env.AutoBuso == true)
		.. "; e.TurnOnRaceV3=" .. tostring(env.TurnOnRaceV3 == true)
		.. "; e.TurnOnRaceV4=" .. tostring(env.TurnOnRaceV4 == true)
		.. "; e.TurnOnObservationHaki=" .. tostring(env.TurnOnObservationHaki == true)
		.. "; e.autofarmboss=" .. tostring(env.autofarmboss == true)
		.. "; e.autofarmbosshop=" .. tostring(env.autofarmbosshop == true)
		.. "; e.selectedboss=" .. string.format("%q", env.selectedboss or "Rip Indra")
		.. "; e.__CyborgCodexResume=true; e.__CyborgCodexSource=" .. string.format("%q", source)
		.. "; local f,err=loadstring(e.__CyborgCodexSource, 'CyborgCodex-Standalone'); assert(f,err); f()"
	if env.AutoPullLevel == true or env.autofarmboss == true or env.autoghoulrace == true or env.autottk == true or env.autoyama == true or env.autotushita == true or env.autocdk == true or env.autohakilegendary == true
		or env.autofactoryhop == true or env.autopirateraidhop == true or env.autofruithop == true or env.autoberryhop == true then
		payload = "getgenv().__CyborgCodexBossVisited=game:GetService('HttpService'):JSONDecode("
			.. string.format("%q", HttpService:JSONEncode(state.BossVisited)) .. "); " .. payload
	end
	queue(payload)
end

local function mayHop(reason)
	if not attackActive() or hasItem("Fist of Darkness") or hasItem("Core Brain") or hasItem("Microchip") then
		return false
	end
	return reason == "moon" or (state.ChestCount >= Config.ChestLimit
		and os.clock() - (state.LastChestCollected or 0) >= 0.75)
end

local function teleportToNewServer(reason)
	reason = reason or "chest"
	if not mayHop(reason) then return end
	if state.HopPending or os.clock() - (state.LastRemote.Hop or 0) < 15 then return end
	local browser = ReplicatedStorage:FindFirstChild("__ServerBrowser")
	assert(browser and browser:IsA("RemoteFunction"), "ReplicatedStorage.__ServerBrowser is unavailable")
	state.LastRemote.Hop = os.clock()
	state.HopPending = true
	for page = 1, 100 do
		if not mayHop(reason) then state.HopPending = false; return end
		local success, servers = pcall(function() return browser:InvokeServer(page) end)
		if success and type(servers) == "table" then
			for jobId in pairs(servers) do
				if type(jobId) == "string" and jobId ~= game.JobId then
					if not mayHop(reason) then state.HopPending = false; return end
					queueResume()
					browser:InvokeServer("teleport", jobId)
					return
				end
			end
		elseif not success then
			log("ServerBrowser query failed: " .. tostring(servers))
			break
		end
	end
	local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId)
	local response = game:HttpGet(url)
	local data = HttpService:JSONDecode(response)
	for _, server in ipairs(data.data or {}) do
		if server.id ~= game.JobId and type(server.playing) == "number"
			and type(server.maxPlayers) == "number" and server.playing < server.maxPlayers then
			if not mayHop(reason) then state.HopPending = false; return end
			queueResume()
			browser:InvokeServer("teleport", server.id)
			return
		end
	end
	state.HopPending = false
	log("No public server available to hop into.")
end

local function countChest(chest)
	state.SeenChests[chest] = true
	state.ChestCount += 1
	state.LastChestCollected = os.clock()
	state.CurrentChest = nil
	state.CurrentChestSince = nil
end

local function collectChest()
	if not attackActive() then return end
	if hasItem("Fist of Darkness") then
		cleanupMovement()
		state.CurrentChest = nil
		return
	end
	if state.ChestCount >= Config.ChestLimit then
		cleanupMovement()
		notify("Collected 50 chests; checking Fist of Darkness before server hop.", "chest-hop", 5)
		teleportToNewServer("chest")
		return
	end
	if escapeSeatWhileCollecting() then
		return
	end
	local chest = state.CurrentChest
	if chest and not isChestAvailable(chest) then
		countChest(chest)
		return
	end
	if not chest then
		chest = nearestChest()
		if not chest then
			local spawnPart = findChestSpawn()
			if spawnPart then
				if moveTo(spawnPart.CFrame) then state.SeenChestSpawns[spawnPart] = true end
			else
				notify("Waiting for collectable chests to load or respawn.", "chest-empty", 5)
			end
			return
		end
		state.CurrentChest = chest
		state.CurrentChestSince = os.clock()
	end
	local cf = getChestPosition(chest)
	if not cf then
		state.CurrentChest = nil
		return
	end
	local root = getRoot()
	if not root then return end
	local distance = (root.Position - cf.Position).Magnitude
	moveTo(cf + Vector3.new(0, 2, 0))
	if distance <= 9 then
		setNoClip(false)
		setFloat(false)
		local character = player.Character
		requestJump(character and character:FindFirstChildOfClass("Humanoid"))
		if hasItem("Fist of Darkness") then
			cleanupMovement()
			state.CurrentChest = nil
			return
		end
		if os.clock() - state.CurrentChestSince >= 6 then
			state.SeenChests[chest] = true
			state.CurrentChest = nil
			state.CurrentChestSince = nil
			notify("Chest did not confirm collection; skipping without increasing the counter.", "chest-stalled", 5)
		end
	end
end

local function findOrder()
	local enemies = workspace:FindFirstChild("Enemies")
	local order = enemies and enemies:FindFirstChild("Order")
	if order and order:FindFirstChildOfClass("Humanoid") then return order end
	if enemies then
		for _, mob in ipairs(enemies:GetChildren()) do
			if string.find(string.lower(mob.Name), "order", 1, true)
				and mob:FindFirstChildOfClass("Humanoid") then return mob end
		end
	end
	return nil
end

local function equipSelectedWeapon()
	local selected = env.SelectedWeapon
	local prefixes = { Melee = "M", Sword = "S", Fruit = "B", Gun = "G" }
	local prefix = prefixes[selected]
	if not prefix then return false end
	local character = player.Character
	local backpack = player:FindFirstChild("Backpack")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not (character and humanoid) then return false end
	for _, container in ipairs({ character, backpack }) do
		if container then
			for _, tool in ipairs(container:GetChildren()) do
				if tool:IsA("Tool") and type(tool.ToolTip) == "string" and tool.ToolTip:sub(1, 1) == prefix then
					if tool.Parent == backpack then humanoid:EquipTool(tool) end
					return true
				end
			end
		end
	end
	return false
end

local function ensureBuso()
	local character = player.Character
	if not character then return false end
	local hasBuso = character:FindFirstChild("HasBuso")
		or character:FindFirstChild("_BusoLayer1")
		or CollectionService:HasTag(character, "HasBuso")
	if hasBuso then return true end
	if os.clock() - (state.LastBusoAttempt or 0) < 1.5 then return false end
	state.LastBusoAttempt = os.clock()
	local ok, err = pcall(invokeCommF, "Buso")
	if not ok and os.clock() - (state.LastBusoError or 0) >= 5 then
		state.LastBusoError = os.clock()
		log("Buso activation failed: " .. tostring(err))
	end
	return ok
end

local function findCharacterTool(name)
	local character = player.Character
	local backpack = player:FindFirstChild("Backpack")
	return (character and character:FindFirstChild(name)) or (backpack and backpack:FindFirstChild(name))
end

local function pressGameKey(key)
	local input = game:GetService("VirtualInputManager")
	input:SendKeyEvent(true, key, false, game)
	task.wait(0.06)
	input:SendKeyEvent(false, key, false, game)
end

state.LastRaceV3Attempt = -math.huge
state.LastRaceV4Attempt = -math.huge
task.spawn(function()
	while state.Generation == generation do
		local now = os.clock()
		ensureTeam()
		if env.TurnOnRaceV3 ~= true then state.LastRaceV3Attempt = -math.huge end
		if env.TurnOnRaceV4 ~= true then state.LastRaceV4Attempt = -math.huge end
		local receivingDamage = state.ActiveWorkflow == "CDK" and SwordGet.States.CDK.TakingDamage == true
		if env.AutoBuso == true and not receivingDamage then
			local ok, err = pcall(ensureBuso)
			if not ok and now - (state.LastSettingsError or 0) >= 5 then
				state.LastSettingsError = now
				print("[Teddy Hub][ERROR][Setting][AutoBuso]\n" .. tostring(err))
			end
		end
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 and not receivingDamage then
			if env.TurnOnRaceV4 == true and state.ActiveWorkflow ~= "PullLever" then
				local energy = character:FindFirstChild("RaceEnergy")
				local transformed = character:FindFirstChild("RaceTransformed")
				local awakening = findCharacterTool("Awakening")
				local activate = ReplicatedStorage:FindFirstChild("Events")
					and ReplicatedStorage.Events:FindFirstChild("ActivateRaceV4")
				if awakening and energy and energy.Value >= 1 and not (transformed and transformed.Value)
					and activate and activate:IsA("BindableEvent") and now - state.LastRaceV4Attempt >= 40 then
					state.LastRaceV4Attempt = now
					local ok, err = pcall(function() activate:Fire() end)
					if not ok then
						print("[Teddy Hub][ERROR][Setting][RaceV4]\n" .. tostring(err))
					end
				end
			end
			if env.TurnOnRaceV3 == true and state.ActiveWorkflow ~= "PullLever" and now - state.LastRaceV3Attempt >= 40 then
				state.LastRaceV3Attempt = now
				local ok, err = pcall(pressGameKey, Enum.KeyCode.T)
				if not ok and now - (state.LastSettingsError or 0) >= 5 then
					state.LastSettingsError = now
					print("[Teddy Hub][ERROR][Setting][RaceV3]\n" .. tostring(err))
				end
			end
			if env.TurnOnObservationHaki == true then
				local globals = ReplicatedStorage:FindFirstChild("Global")
				local ok, gameGlobal = pcall(function() return globals and require(globals) end)
				local observation = ok and gameGlobal and gameGlobal.OM
				if observation and not observation.active and not character:FindFirstChild("KenDisabled") then
					local activate = ReplicatedStorage:FindFirstChild("Remotes")
						and ReplicatedStorage.Remotes:FindFirstChild("CommE")
					if activate and activate:IsA("RemoteEvent") then
						observation.radius = 0
						observation:setActive(true)
						activate:FireServer("Ken", true)
					end
				end
			end
		end
		task.wait(0.75)
	end
end)

local isAttackTarget = LPH_JIT_MAX(function(target)
	if not attackActive() then return false end
	if state.FastAttackTargets then
		if state.ZombieBatch then
			for _, mob in ipairs(state.ZombieBatch) do
				local humanoid = mob.Parent and mob:FindFirstChildOfClass("Humanoid")
				if not humanoid or humanoid.Health <= 0 then return false end
			end
		end
		return table.find(state.FastAttackTargets, target) ~= nil
	end
	return state.FastAttackTarget == target
end)

local fastAttack = LPH_JIT_MAX(function(target)
	if not isAttackTarget(target) then return end
	local netRoot = ReplicatedStorage:FindFirstChild("Modules")
	local net = netRoot and netRoot:FindFirstChild("Net")
	local registerAttack = net and net:FindFirstChild("RE/RegisterAttack")
	local registerHit = net and net:FindFirstChild("RE/RegisterHit")
	assert(registerAttack and registerHit, "FastAttack Net remotes are unavailable")
	local humanoid = target and target:FindFirstChildOfClass("Humanoid")
	local root = target and target:FindFirstChild("HumanoidRootPart")
	local characterRoot = getRoot()
	if not (humanoid and humanoid.Health > 0 and root and characterRoot)
		or (root.Position - characterRoot.Position).Magnitude > 60 then return end
	local parts = {}
	for _, mob in ipairs(state.FastAttackTargets or { target }) do
		local mobHumanoid = mob.Parent and mob:FindFirstChildOfClass("Humanoid")
		local mobRoot = mob:FindFirstChild("HumanoidRootPart")
		if mobHumanoid and mobHumanoid.Health > 0 and mobRoot
			and (mobRoot.Position - characterRoot.Position).Magnitude <= 60 then
			local part = mob:FindFirstChild("Head") or mob.PrimaryPart or mobRoot
			parts[#parts + 1] = { mob, part }
		end
	end
	if #parts == 0 then return end
	registerAttack:FireServer(0.1)
	registerHit:FireServer(parts[1][2], parts)
end)

local function stopFastAttack()
	state.CombatFollow = nil
	state.FastAttackTarget = nil
	state.FastAttackTargets = nil
	state.ZombieBatch = nil
	for part, canCollide in pairs(state.PuzzleCollision or {}) do
		if part.Parent then part.CanCollide = canCollide end
	end
	state.PuzzleCollision = nil
end

local function startFastAttack(target)
	state.FastAttackTarget = target
	if state.FastAttackWorker then return end
	state.FastAttackWorker = true
	task.spawn(function()
		while attackActive() do
			local current = state.FastAttackTarget
			local humanoid = current and current:FindFirstChildOfClass("Humanoid")
			if not (current and current.Parent and humanoid and humanoid.Health > 0) then
				state.FastAttackTarget = nil
				break
			end
			local ok, err = pcall(fastAttack, current)
			if not ok and os.clock() - (state.LastFastAttackError or 0) >= 5 then
				state.LastFastAttackError = os.clock()
				log("Fast attack failed: " .. tostring(err))
			end
			task.wait(0.1)
		end
		if state.Generation == generation then state.FastAttackWorker = false end
	end)
end

local updateCombatFollow = LPH_JIT_MAX(function()
	local follow = state.CombatFollow
	if not follow then return false end
	local target = follow.Target
	local root = target.Parent and target:FindFirstChild("HumanoidRootPart")
	local humanoid = target.Parent and target:FindFirstChildOfClass("Humanoid")
	local characterRoot = getRoot()
	local characterHumanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if not attackActive() or state.ActiveWorkflow ~= follow.Owner or characterRoot ~= follow.Root
		or not characterHumanoid or characterHumanoid.Health <= 0
		or not root or not humanoid or humanoid.Health <= 0 then
		stopFastAttack()
		cleanupMovement()
		return false
	end
	local goal = uprightCFrame(root.CFrame) * CFrame.new(Config.OrderOffset)
	if (characterRoot.Position - goal.Position).Magnitude > 150 then return false end
	cancelMovement()
	characterRoot.CFrame = goal
	characterRoot.AssemblyLinearVelocity = Vector3.zero
	characterRoot.AssemblyAngularVelocity = Vector3.zero
	return true
end)

local fightMob = LPH_JIT(function(order)
	if not attackActive() then return end
	local root = order:FindFirstChild("HumanoidRootPart")
	local humanoid = order:FindFirstChildOfClass("Humanoid")
	local characterRoot = getRoot()
	if not (root and humanoid and humanoid.Health > 0 and characterRoot) then
		stopFastAttack()
		cleanupMovement()
		return
	end
	local target = uprightCFrame(root.CFrame) * CFrame.new(Config.OrderOffset)
	local distance = (characterRoot.Position - target.Position).Magnitude
	if distance > 150 then
		state.CombatFollow = nil
		state.FastAttackTarget = nil
		moveTo(target, true)
		return
	end
	setNoClip(true)
	setFloat(true)
	if (state.ActiveWorkflow == "TTK" or state.ActiveWorkflow == "CDK") and state.TTKWeapon then
		assert(equipItem(state.TTKWeapon), "TTK training sword is unavailable: " .. state.TTKWeapon)
	else
		assert(equipSelectedWeapon(), "No " .. tostring(env.SelectedWeapon) .. " Tool is available in Character or Backpack")
	end
	if env.AutoBuso == true then ensureBuso() end
	if not attackActive() then return end
	state.CombatFollow = { Target = order, Root = characterRoot, Owner = state.ActiveWorkflow }
	if not updateCombatFollow() then return end
	startFastAttack(order)
end)

local fightOrder = LPH_JIT(function(order)
	return fightMob(order)
end)

do
	local function normalize(name)
		return (tostring(name):lower():gsub("%b[]", ""):gsub("_", " "):gsub("%s+", " "):match("^%s*(.-)%s*$"))
	end

	function BossFarm.Matches(name, definition)
		for _, alias in ipairs(definition.Names) do
			if normalize(name) == normalize(alias) then return true end
		end
		return false
	end

	function BossFarm.SetStatus(message)
		if state.ActiveWorkflow == "PullLever" then PullLever.SetStatus(message); return end
		if state.ActiveWorkflow == "Ghoul" then Ghoul.SetStatus(message); return end
		if state.BossStatus == message then return end
		state.BossStatus = message
		if state.ActiveWorkflow == "Boss" then setStage(message) end
		if BossFarm.StatusChanged then BossFarm.StatusChanged(message) end
	end

	function BossFarm.Cancel()
		BossFarm.ClearMirror()
		if state.BossRequest then state.HopPending = false end
		state.BossRequest = nil
		state.BossMissingSince = nil
		state.BossNextHopAt = 0
		state.BossHopMessage = nil
		if state.ActiveWorkflow == "Boss" or state.ActiveWorkflow == "Ghoul" then
			stopFastAttack()
			cleanupMovement()
		end
	end

	function BossFarm.FindIn(container, definition)
		if not container then return nil end
		local follow = state.CombatFollow
		local locked = follow and follow.Owner == state.ActiveWorkflow and follow.Target
		if locked and locked.Parent == container and BossFarm.Matches(locked.Name, definition) then
			local humanoid = locked:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 and locked:FindFirstChild("HumanoidRootPart") then return locked end
		end
		local selected, nearest
		local characterRoot = getRoot()
		for _, mob in ipairs(container:GetChildren()) do
			if mob:IsA("Model") and BossFarm.Matches(mob.Name, definition) then
				local humanoid = mob:FindFirstChildOfClass("Humanoid")
				local root = mob:FindFirstChild("HumanoidRootPart")
				if humanoid and humanoid.Health > 0 and root then
					local distance = characterRoot and (root.Position - characterRoot.Position).Magnitude or 0
					if not nearest or distance < nearest then selected, nearest = mob, distance end
				end
			end
		end
		return selected
	end

	function BossFarm.FindActive(definition)
		return BossFarm.FindIn(workspace:FindFirstChild("Enemies"), definition)
	end

	function BossFarm.GetMirrorGate()
		local map = workspace:FindFirstChild("Map")
		local cake = map and map:FindFirstChild("CakeLoaf")
		local mirror = cake and cake:FindFirstChild("BigMirror")
		local gate = mirror and mirror:FindFirstChild("Main")
		if gate and gate:IsA("BasePart") then return gate.CFrame, gate end
		return CFrame.new(-2144.967041015625, 70.37715911865234, -12399.751953125), nil
	end

	function BossFarm.IsInMirrorDimension(position)
		local center = Vector3.new(-2089.865966796875, 4536.923828125, -14800.0068359375)
		local map = workspace:FindFirstChild("Map")
		local dimension = map and map:FindFirstChild("MirrorDimension")
		local main = dimension and dimension:FindFirstChild("MAIN")
		if main and main:IsA("BasePart") then center = main.Position end
		return (position - center).Magnitude <= 2000
			or (position.X >= -2700 and position.X <= -1400 and position.Y >= 4000
				and position.Y <= 5800 and position.Z >= -15600 and position.Z <= -14000)
	end

	function BossFarm.ReleaseMirrorTouch()
		local touch = state.BossMirrorTouch
		state.BossMirrorTouch = nil
		if not touch or not touch.Started or not touch.Root.Parent or not touch.Gate.Parent then return end
		local ok, err = pcall(touch.Fire, touch.Root, touch.Gate, 1)
		if not ok then log("Mirror touch cleanup failed: " .. tostring(err)) end
	end

	function BossFarm.ClearMirror()
		BossFarm.ReleaseMirrorTouch()
		state.BossMirrorWaitUntil = nil
	end

	function BossFarm.CanEnterMirror(root, owner)
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		return workflowActive(owner or "Boss") and root ~= nil and getRoot() == root
			and humanoid ~= nil and humanoid.Health > 0
	end

	function BossFarm.EnterMirror(definition, owner)
		if not definition.Mirror then return true end
		local root = getRoot()
		if not BossFarm.CanEnterMirror(root, owner) then return false end
		local pending = state.BossMirrorTouch
		if pending then
			if os.clock() < pending.EndAt then return false end
			BossFarm.ReleaseMirrorTouch()
			if not BossFarm.CanEnterMirror(root, owner) then return false end
		end
		if BossFarm.IsInMirrorDimension(root.Position) then
			BossFarm.ClearMirror()
			return true
		end
		stopFastAttack()
		if state.BossMirrorWaitUntil and os.clock() < state.BossMirrorWaitUntil then
			BossFarm.SetStatus("Waiting to enter Mirror Dimension")
			return false
		end
		local gateCF, gate = BossFarm.GetMirrorGate()
		if (root.Position - gateCF.Position).Magnitude > 8 then
			BossFarm.SetStatus("Flying to Cake Island mirror")
			moveTo(gateCF)
			return false
		end
		cleanupMovement()
		if not gate then
			BossFarm.SetStatus("Waiting for Cake Island mirror to load")
			return false
		end
		BossFarm.SetStatus("Touching Cake Island mirror")
		if not BossFarm.CanEnterMirror(root, owner) then return false end
		state.BossMirrorWaitUntil = os.clock() + 1.5
		local fire = env.firetouchinterest or firetouchinterest
		if type(fire) == "function" then
			local touch = { Root = root, Gate = gate, Fire = fire, EndAt = os.clock() + 0.05, Started = true }
			state.BossMirrorTouch = touch
			local ok, err = pcall(fire, root, gate, 0)
			if not ok then
				BossFarm.ReleaseMirrorTouch()
				log("Mirror touch failed: " .. tostring(err))
			end
		end
		return false
	end

	function BossFarm.HasProtectedItem()
		for _, name in ipairs({ "Fist of Darkness", "Core Brain", "Microchip", "God's Chalice", "Sweet Chalice", "Hallow Essence", "Hellfire Torch" }) do
			if hasItem(name) then return true end
		end
		return false
	end

	function BossFarm.HopStillAllowed(request)
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local ownerAllowed
		if request.Owner == "Ghoul" then
			ownerAllowed = Ghoul.HopAllowed()
		else
			ownerAllowed = workflowActive("Boss") and env.autofarmbosshop == true and env.selectedboss == request.Selection
		end
		return state.Generation == generation and ownerAllowed
			and humanoid ~= nil and humanoid.Health > 0 and getRoot() ~= nil
			and state.BossRequest == request
			and game.PlaceId == request.PlaceId and currentSea() == request.Definition.Sea
			and not BossFarm.HasProtectedItem() and not BossFarm.FindActive(request.Definition)
			and not BossFarm.FindIn(ReplicatedStorage, request.Definition)
	end

	function BossFarm.FetchServers(slug)
		local url = BossFarm.ApiBase .. slug .. "/"
		local request = (env.syn and env.syn.request) or env.http_request or env.request or http_request or request
		local body
		if type(request) == "function" then
			local response = request({ Url = url, Method = "GET", Timeout = 10 })
			assert(type(response) == "table", "Boss API returned no response")
			local status = tonumber(response.StatusCode or response.Status)
			assert(not status or (status >= 200 and status < 300), "Boss API HTTP " .. tostring(status))
			body = response.Body
		else
			body = game:HttpGet(url)
		end
		assert(type(body) == "string", "Boss API response body is missing")
		local data = HttpService:JSONDecode(body)
		assert(type(data) == "table" and type(data.data) == "table", "Boss API response schema is invalid")
		return data.data
	end

	function BossFarm.SelectServer(servers, definition)
		local now = os.time()
		for id, visitedAt in pairs(state.BossVisited) do
			if type(visitedAt) ~= "number" or now - visitedAt >= BossFarm.VisitedSeconds then state.BossVisited[id] = nil end
		end
		for _, server in ipairs(servers) do
			if type(server) == "table" then
				local jobId = BossFarm.DecodeJobId(server.Jobid or server.jobid or server.JobId or server.id)
				local placeId = tonumber(server.place_id or server.placeid or server.PlaceId)
				local playing, maxPlayers = tonumber(server.playing), tonumber(server.maxPlayers)
				if type(server.players) == "string" then
					local a, b = server.players:match("^(%d+)%s*/%s*(%d+)$")
					playing, maxPlayers = tonumber(a) or playing, tonumber(b) or maxPlayers
				end
				local nameMatches = not server.name or BossFarm.Matches(server.name, definition)
					or normalize(server.name) == normalize(definition.Slug)
				if jobId and jobId ~= game.JobId and not state.BossVisited[jobId] and nameMatches
					and (not placeId or placeId == game.PlaceId)
					and (not playing or not maxPlayers or playing < maxPlayers) then return jobId end
			end
		end
		return nil
	end

	function BossFarm.BeginHop(definition, owner)
		local request = { Owner = owner or "Boss", Selection = owner == "Ghoul" and "Cursed Captain" or env.selectedboss,
			Definition = definition, PlaceId = game.PlaceId,
			StartedAt = os.clock(), Phase = "Query" }
		state.BossRequest = request
		state.HopPending = true
		state.BossNextHopAt = os.clock() + BossFarm.RetrySeconds
		BossFarm.SetStatus("Searching API servers: " .. request.Selection)
		task.spawn(function()
			local ok, message = xpcall(function()
				local servers = BossFarm.FetchServers(definition.Slug)
				if not BossFarm.HopStillAllowed(request) then return end
				local jobId = BossFarm.SelectServer(servers, definition)
				if not jobId then return "No matching API server" end
				local browser = ReplicatedStorage:FindFirstChild("__ServerBrowser")
				assert(browser and browser:IsA("RemoteFunction"), "__ServerBrowser is unavailable")
				if not BossFarm.HopStillAllowed(request) then return end
				request.JobId = jobId
				state.BossVisited[jobId] = os.time()
				state.BossVisited[game.JobId] = os.time()
				queueResume()
				if not BossFarm.HopStillAllowed(request) then return end
				request.Phase = "Teleport"
				request.StartedAt = os.clock()
				BossFarm.SetStatus("Hopping to " .. request.Selection)
				local result = browser:InvokeServer("teleport", jobId)
				assert(result ~= false, "Server rejected the teleport")
			end, debug.traceback)
			if state.Generation ~= generation or state.BossRequest ~= request then return end
			if ok and request.Phase == "Teleport" then return end
			state.BossRequest = nil
			state.HopPending = false
			state.BossHopMessage = ok and (message or "Search cancelled") or "Boss API/teleport failed"
			state.BossNextHopAt = os.clock() + BossFarm.RetrySeconds
			BossFarm.SetStatus(state.BossHopMessage)
			if not ok then reportControllerError(message, request.Owner, request.Phase == "Teleport" and "APITeleport" or "APISearch") end
		end)
	end

	BossFarm.Step = LPH_JIT(function()
		if not workflowActive("Boss") then return end
		local definition = BossFarm.Definitions[env.selectedboss]
		if not definition then BossFarm.SetStatus("Invalid boss selection"); return end
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 or not getRoot() then
			BossFarm.Cancel()
			BossFarm.SetStatus("Waiting for character")
			return
		end
		if not ensureTeam() or not workflowActive("Boss") then return end
		if currentSea() ~= definition.Sea then
			BossFarm.Cancel()
			BossFarm.SetStatus(env.selectedboss .. " requires Sea " .. definition.Sea)
			return
		end
		local boss = BossFarm.FindActive(definition)
		if boss then
			if state.BossRequest then BossFarm.Cancel() end
			state.BossMissingSince = nil
			state.BossNextHopAt = 0
			if not BossFarm.EnterMirror(definition) then return end
			local bossHumanoid = boss.Parent and boss:FindFirstChildOfClass("Humanoid")
			if not workflowActive("Boss") or not bossHumanoid or bossHumanoid.Health <= 0 then return end
			local distance = (boss.HumanoidRootPart.Position - getRoot().Position).Magnitude
			BossFarm.SetStatus((distance > 60 and "Flying to " or "Fighting ") .. env.selectedboss)
			fightMob(boss)
			return
		end
		stopFastAttack()
		local hint = BossFarm.FindIn(ReplicatedStorage, definition)
		if hint and definition.Mirror then
			if state.BossRequest then BossFarm.Cancel() end
			state.BossMissingSince = nil
			if not BossFarm.EnterMirror(definition) then return end
		elseif not hint then
			BossFarm.ClearMirror()
		end
		if hint and (hint.HumanoidRootPart.Position - getRoot().Position).Magnitude > 120 then
			if state.BossRequest then BossFarm.Cancel() end
			state.BossMissingSince = nil
			BossFarm.SetStatus("Approaching replicated boss: " .. env.selectedboss)
			moveTo(hint.HumanoidRootPart.CFrame * CFrame.new(Config.OrderOffset))
			return
		end
		if hint then
			if state.BossRequest then BossFarm.Cancel() end
			cleanupMovement()
			state.BossMissingSince = nil
			BossFarm.SetStatus("Waiting for boss replication: " .. env.selectedboss)
			return
		end
		cleanupMovement()
		state.BossMissingSince = state.BossMissingSince or os.clock()
		if os.clock() - state.BossMissingSince < BossFarm.MissingGrace then
			BossFarm.SetStatus("Checking boss spawn: " .. env.selectedboss)
			return
		end
		if env.autofarmbosshop ~= true then
			if state.BossRequest then BossFarm.Cancel() end
			BossFarm.SetStatus("Waiting for " .. env.selectedboss)
			return
		end
		if BossFarm.HasProtectedItem() then
			BossFarm.Cancel()
			BossFarm.SetStatus("Hop paused: carrying a protected item")
			return
		end
		local pending = state.BossRequest
		if pending then
			if os.clock() - pending.StartedAt >= BossFarm.TeleportTimeout then
				state.BossRequest = nil
				state.HopPending = false
				state.BossHopMessage = pending.Phase == "Teleport" and "Teleport timed out" or "API request timed out"
				state.BossNextHopAt = os.clock() + BossFarm.RetrySeconds
				BossFarm.SetStatus(state.BossHopMessage)
			end
			return
		end
		if os.clock() < (state.BossNextHopAt or 0) then
			BossFarm.SetStatus((state.BossHopMessage or "Waiting for API retry") .. " ("
				.. math.ceil(state.BossNextHopAt - os.clock()) .. "s)")
			return
		end
		BossFarm.BeginHop(definition)
	end)
end

local function getFragments()
	local data = player:FindFirstChild("Data")
	local fragments = data and data:FindFirstChild("Fragments")
	assert(fragments and typeof(fragments.Value) == "number", "Data.Fragments is unavailable")
	return fragments.Value
end

local function buyLawChip()
	if not isRaidUnlocked() or not workflowActive("Cyborg") then return end
	if getFragments() < Config.MinLawFragments then
		notify("Need at least 1000 Fragments; waiting before buying a Law Microchip.", "fragments", 5)
		return
	end
	if os.clock() - (state.LastRemote.BuyChip or 0) < 5 then return end
	state.LastRemote.BuyChip = os.clock()
	invokeCommF("BlackbeardReward", "Microchip", "2")
end

local MaterialTargets = {
	Ectoplasm = {
		Sea = 2, Required = 250,
		Names = { "Ship Deckhand", "Ship Engineer", "Ship Steward", "Ship Officer" },
		Spawns = {
			CFrame.new(1198, 126, 32988), CFrame.new(917, 44, 32785),
			CFrame.new(916, 130, 33418), CFrame.new(917, 181, 33355),
		},
	},
	Bones = {
		Sea = 3, Required = 500,
		Names = { "Reborn Skeleton", "Demonic Soul", "Living Zombie", "Posessed Mummy" },
		Spawns = {
			CFrame.new(-8737, 143, 6035), CFrame.new(-9501, 172, 6036),
			CFrame.new(-10150, 140, 5930), CFrame.new(-9500, 6, 6100),
		},
	},
}
local PuzzleStages = { "Swamp", "Gravestones", "Ghost", "Trophies", "Pipes" }
local PuzzlePositions = {
	Grave = CFrame.new(-8654.314453125, 140.9499053955078, 6167.5283203125),
	Swamp = CFrame.new(-10171.7607421875, 138.62667846679688, 6008.0654296875),
	Gravestones = CFrame.new(-8761.4765625, 142.10487365722656, 6086.07861328125),
	Ghost = CFrame.new(-9755.6591796875, 271.0661315917969, 6290.61474609375),
	Lab = CFrame.new(-9530.0126953125, 6.104853630065918, 6054.83349609375),
}
local BlankTablets = { "Segment6", "Segment2", "Segment8", "Segment9", "Segment5" }
local TrophyTablets = {
	Segment1 = "Trophy1", Segment3 = "Trophy2", Segment4 = "Trophy3",
	Segment7 = "Trophy4", Segment10 = "Trophy5",
}
local PipeColors = {
	Part1 = "Really black", Part2 = "Really black", Part3 = "Dusty Rose",
	Part4 = "Storm blue", Part5 = "Really black", Part6 = "Parsley green",
	Part7 = "Really black", Part8 = "Dusty Rose", Part9 = "Really black", Part10 = "Storm blue",
}

local cleanMobName = LPH_JIT_MAX(function(name)
	return name:gsub(" %p?Lv%.? %d+%p?", ""):match("^%s*(.-)%s*$")
end)

local isAlive = LPH_JIT_MAX(function(mob)
	local humanoid = mob and mob.Parent and mob:FindFirstChildOfClass("Humanoid")
	return humanoid ~= nil and humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") ~= nil
end)

local findMob = LPH_JIT_MAX(function(names)
	local enemies = workspace:FindFirstChild("Enemies")
	local root = getRoot()
	if not enemies or not root then return nil end
	local follow = state.CombatFollow
	local locked = follow and follow.Owner == state.ActiveWorkflow and follow.Target
	if locked and locked.Parent == enemies and isAlive(locked) and table.find(names, cleanMobName(locked.Name)) then return locked end
	local nearest, distance
	for _, mob in ipairs(enemies:GetChildren()) do
		if isAlive(mob) and table.find(names, cleanMobName(mob.Name)) then
			local current = (mob.HumanoidRootPart.Position - root.Position).Magnitude
			if not distance or current < distance then nearest, distance = mob, current end
		end
	end
	return nearest
end)

local itemService, itemConfig
local inventoryCounts = LPH_JIT(function(force)
	if not force and state.InventoryCounts and os.clock() - (state.InventoryReadAt or 0) < 1 then
		return state.InventoryCounts
	end
	if not itemService then
		local replicationModule = ReplicatedStorage:FindFirstChild("ItemReplicationService")
		local configModule = ReplicatedStorage:FindFirstChild("ItemConfig")
		assert(replicationModule and configModule, "ItemReplicationService/ItemConfig are unavailable")
		local service = require(replicationModule)
		local config = require(configModule)
		assert(type(service.GetItems) == "function" and type(service.KEYS) == "table"
			and type(config.match) == "function", "Inventory API does not match the verified sources")
		itemService, itemConfig = service, config
	end
	local items = itemService:GetItems(itemService.KEYS.QUANTITY)
	assert(type(items) == "table", "ItemReplicationService:GetItems did not return a table")
	local counts = {}
	for _, item in pairs(items) do
		assert(type(item.Value) == "number", "Inventory quantity is not numeric")
		if item.Value > 0 then
			local ok, config = pcall(function()
				local match = itemConfig.match(item.ItemId)
				if type(match) ~= "table" then return nil end
				if type(match.asNullable) == "function" then return match:asNullable() end
				if type(match.unwrap) == "function" then return match:unwrap() end
				return match
			end)
			assert(ok and type(config) == "table", "Cannot resolve inventory ItemId " .. tostring(item.ItemId))
			local index = type(config.Index) == "table" and config.Index or {}
			local display = type(config.Display) == "table" and config.Display or {}
			local name
			local candidates = { index.StorageKey, display.Name, display.Title, config.Name }
			for i = 1, 4 do
				local candidate = candidates[i]
				if type(candidate) == "string" and candidate ~= "" then name = candidate; break end
			end
			assert(name, "Inventory item name is unavailable for ItemId " .. tostring(item.ItemId))
			counts[name] = (counts[name] or 0) + item.Value
		end
	end
	state.InventoryCounts = counts
	state.InventoryReadAt = os.clock()
	return counts
end)

do
	function TTK.Canonical(name)
		if type(name) ~= "string" then return nil end
		name = name:gsub("^[Ss][Ww][Oo][Rr][Dd]%s*:%s*", ""):match("^%s*(.-)%s*$")
		if name:lower() == "true triple katana" then return "True Triple Katana" end
		if name:lower() == "yama" then return "Yama" end
		if name:lower() == "tushita" then return "Tushita" end
		if name:lower() == "cursed dual katana" then return "Cursed Dual Katana" end
		for alias, canonical in pairs(TTK.Aliases) do
			if alias:lower() == name:lower() then return canonical end
		end
	end

	function TTK.SetStatus(message)
		if state.ActiveWorkflow == "CDK" then SwordGet.SetStatus("CDK", message); return end
		if TTK.Status == message then return end
		TTK.Status = message
		print("[Teddy Hub][TTK] " .. message)
		if TTK.StatusChanged then TTK.StatusChanged(message) end
	end

	function TTK.Cancel()
		TTK.Epoch += 1
		if TTK.Request then state.HopPending = false end
		TTK.Request = nil
		TTK.NextHop = nil
		TTK.WaitUntil = nil
		state.TTKWeapon = nil
		if state.ActiveWorkflow == "TTK" then stopFastAttack(); cleanupMovement() end
	end

	function TTK.Snapshot(force)
		if force or not TTK.Cache or os.clock() - (TTK.ReadAt or 0) >= 3 then
			TTK.Config = TTK.Config or require(ReplicatedStorage:WaitForChild("ItemConfig", 10))
			local net = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")
			local remote = net and net:FindFirstChild("RF/GetAllItemValues")
			assert(remote and remote:IsA("RemoteFunction"), "TTK inventory snapshot remote is unavailable")
			local values = remote:InvokeServer()
			assert(type(values) == "table", "TTK inventory snapshot is unavailable")
			local snapshot = { Owned = {}, Mastery = {}, Names = {} }
			for _, item in pairs(values) do
				if item.Key == "IsOwned" or item.Key == "Mastery" then
					local resolved = TTK.ItemNames[item.ItemId]
					if resolved == nil then
						local config = TTK.Config.match(item.ItemId):asNullable()
						local name = config and config.Index and config.Index.StorageKey
						resolved = TTK.Canonical(name) and name or false
						TTK.ItemNames[item.ItemId] = resolved
					end
					local canonical = TTK.Canonical(resolved)
					if canonical then
						snapshot.Names[canonical] = resolved
						if item.Key == "IsOwned" and item.Value == true then snapshot.Owned[canonical] = true end
						if item.Key == "Mastery" and type(item.Value) == "number" then snapshot.Mastery[canonical] = item.Value end
					end
				end
			end
			TTK.Cache = snapshot
			TTK.ReadAt = os.clock()
		end
		local snapshot = TTK.Cache
		for _, container in pairs({ Character = player.Character, Backpack = player:FindFirstChild("Backpack") }) do
			for _, tool in ipairs(container:GetChildren()) do
				local canonical = tool:IsA("Tool") and TTK.Canonical(tool.Name)
				if canonical then
					snapshot.Owned[canonical] = true
					snapshot.Names[canonical] = tool.Name
					local level = tool:FindFirstChild("Level")
					if level and type(level.Value) == "number" then
						snapshot.Mastery[canonical] = math.max(level.Value, snapshot.Mastery[canonical] or 0)
					end
				end
			end
		end
		return snapshot
	end

	function TTK.PreferredTraining(snapshot)
		local sword = TTK.Training
		if sword and snapshot.Owned[sword] and (snapshot.Mastery[sword] or 0) < TTK.RequiredMastery then return sword end
		local character = player.Character
		local tool = character and character:FindFirstChildOfClass("Tool")
		sword = tool and TTK.Canonical(tool.Name)
		if sword and table.find(TTK.Swords, sword) and snapshot.Owned[sword]
			and (snapshot.Mastery[sword] or 0) < TTK.RequiredMastery then return sword end
	end

	function TTK.Plan(snapshot, beli, training, choose)
		if snapshot.Owned["True Triple Katana"] then return "Complete" end
		for _, sword in ipairs(TTK.Swords) do
			if not snapshot.Owned[sword] then
				if beli < TTK.SwordPrice then return "Money", TTK.SwordPrice end
				return "Buy", sword
			end
		end
		local pending = {}
		for _, sword in ipairs(TTK.Swords) do
			if (snapshot.Mastery[sword] or 0) < TTK.RequiredMastery then pending[#pending + 1] = sword end
		end
		if #pending > 0 then
			if table.find(pending, training) then return "Mastery", training end
			return "Mastery", pending[(choose or math.random)(1, #pending)]
		end
		if beli < TTK.CraftPrice then return "Money", TTK.CraftPrice end
		return "Craft"
	end

	function TTK.SelectServer(servers, snapshot)
		local now = os.time()
		for id, at in pairs(state.BossVisited) do
			if type(at) ~= "number" or now - at >= BossFarm.VisitedSeconds then state.BossVisited[id] = nil end
		end
		for _, server in ipairs(servers) do
			if type(server) == "table" then
				local sword = TTK.Canonical(server.name)
				local jobId = BossFarm.DecodeJobId(server.Jobid or server.jobid or server.JobId or server.id)
				local placeId = tonumber(server.place_id or server.placeid or server.PlaceId)
				local playing, maximum = tonumber(server.playing), tonumber(server.maxPlayers)
				if type(server.players) == "string" then
					local a, b = server.players:match("^(%d+)%s*/%s*(%d+)$")
					playing, maximum = tonumber(a) or playing, tonumber(b) or maximum
				end
				if sword and sword ~= "True Triple Katana" and not snapshot.Owned[sword]
					and jobId and jobId ~= game.JobId and not state.BossVisited[jobId]
					and (not placeId or placeId == game.PlaceId) and (not playing or not maximum or playing < maximum) then
					return jobId, sword
				end
			end
		end
	end

	function TTK.HopAllowed(request)
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		return workflowActive("TTK") and request.Epoch == TTK.Epoch and TTK.Request == request
			and request.PlaceId == game.PlaceId and currentSea() == 2
			and humanoid and humanoid.Health > 0 and player.Data.Beli.Value >= TTK.SwordPrice
			and not BossFarm.HasProtectedItem()
	end

	function TTK.Hop(snapshot)
		if TTK.Request then
			if os.clock() - TTK.Request.Started >= BossFarm.TeleportTimeout then
				TTK.Epoch += 1; TTK.Request = nil; state.HopPending = false
				TTK.NextHop = os.clock() + BossFarm.RetrySeconds
				TTK.SetStatus("Sword API/teleport timeout; retrying")
			end
			return
		end
		if os.clock() < (TTK.NextHop or 0) then return end
		local request = { Epoch = TTK.Epoch, PlaceId = game.PlaceId, Started = os.clock() }
		TTK.Request = request; state.HopPending = true
		TTK.SetStatus("Searching sword API for missing legendary swords")
		task.spawn(function()
			local ok, message = xpcall(function()
				local servers = BossFarm.FetchServers("sword")
				if not TTK.HopAllowed(request) then return "Sword search cancelled" end
				local fresh = TTK.Snapshot(true)
				if not TTK.HopAllowed(request) then return "Sword search cancelled" end
				local jobId, sword = TTK.SelectServer(servers, fresh)
				if not jobId then return "No API server for a missing sword; retrying" end
				local dealer = TTK.Canonical(invokeCommF("LegendarySwordDealer", "1"))
				if dealer and not fresh.Owned[dealer] then return "Missing sword found in current server" end
				if not TTK.HopAllowed(request) then return "Sword search cancelled" end
				local browser = ReplicatedStorage:FindFirstChild("__ServerBrowser")
				assert(browser and browser:IsA("RemoteFunction"), "Sword server browser is unavailable")
				queueResume()
				if not TTK.HopAllowed(request) then return "Sword search cancelled" end
				state.BossVisited[jobId] = os.time(); state.BossVisited[game.JobId] = os.time()
				request.Teleport = true; request.Started = os.clock()
				TTK.SetStatus("Hopping for " .. sword)
				assert(browser:InvokeServer("teleport", jobId) ~= false, "Sword server teleport rejected")
			end, debug.traceback)
			if state.Generation ~= generation or TTK.Request ~= request then return end
			if ok and request.Teleport then return end
			TTK.Request = nil; state.HopPending = false
			TTK.NextHop = os.clock() + BossFarm.RetrySeconds
			TTK.SetStatus(ok and (message or "Sword search cancelled") or "Sword API error; see console")
			if not ok then reportControllerError(message, "TTK", "SwordHop") end
		end)
	end

	function TTK.EnsureSword(snapshot, sword)
		local name = snapshot.Names[sword] or sword
		state.TTKWeapon = name
		if not hasItem(name) then
			stopFastAttack()
			if os.clock() - (TTK.LastLoad or 0) >= 2 then
				TTK.LastLoad = os.clock(); invokeCommF("LoadItem", name)
			end
			TTK.SetStatus("Loading mastery sword: " .. name)
			return false
		end
		return equipItem(name)
	end

	function TTK.BonesQuest(level)
		if level >= 2050 then return "HauntedQuest2", 2, "Posessed Mummy", CFrame.new(-9506.95313, 172.104858, 6074.63086) end
		if level >= 2025 then return "HauntedQuest2", 1, "Demonic Soul", CFrame.new(-9506.95313, 172.104858, 6074.63086) end
		if level >= 2000 then return "HauntedQuest1", 2, "Living Zombie", CFrame.new(-9490.2793, 142.104858, 5565.8501) end
		if level >= 1975 then return "HauntedQuest1", 1, "Reborn Skeleton", CFrame.new(-9490.2793, 142.104858, 5565.8501) end
	end

	function TTK.AcceptBonesQuest()
		local questName, index, mob, position = TTK.BonesQuest(player.Data.Level.Value)
		if not questName then TTK.SetStatus("Bones quests require level 1975 or higher"); return end
		local questActive, questMatches
		local guide = ReplicatedStorage:FindFirstChild("GuideModule")
		local guideDataModule = guide and guide:FindFirstChild("GuideData")
		if guideDataModule then
			TTK.GuideData = TTK.GuideData or require(guideDataModule)
			assert(type(TTK.GuideData.Data) == "table", "Native quest data is unavailable")
			local current = TTK.GuideData.Data.QuestData
			questActive = current ~= nil
			if questActive then
				assert(type(current) == "table" and type(current.Info) == "table", "Native quest objective is unavailable")
				questMatches = current.InternalQuestName == questName
					and (current.Info.Name == mob or (type(current.Info.Task) == "table" and current.Info.Task[mob] ~= nil))
			end
		else
			local main = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("Main")
			local quest = main and main:FindFirstChild("Quest")
			if not quest then TTK.SetStatus("Waiting for quest UI"); return end
			questActive = quest.Visible
			if questActive then
				local container = quest:FindFirstChild("Container")
				local questTitle = container and container:FindFirstChild("QuestTitle")
				local title = questTitle and questTitle:FindFirstChild("Title")
				if not title or not title:IsA("TextLabel") then
					TTK.SetStatus("Waiting for quest objective UI"); stopFastAttack(); return
				end
				local objective = title.Text:gsub("<[^>]*>", ""):lower()
				if objective == "" then TTK.SetStatus("Waiting for quest objective text"); stopFastAttack(); return end
				questMatches = objective:find(mob:lower(), 1, true) ~= nil
			end
		end
		if questMatches then return mob, position end
		stopFastAttack()
		if questActive then
			if os.clock() - (TTK.LastQuest or 0) >= 2 then TTK.LastQuest = os.clock(); invokeCommF("AbandonQuest") end
			return
		end
		local root = getRoot()
		if not root then return end
		local npcs = workspace:FindFirstChild("NPCs")
		local npcName = questName == "HauntedQuest2" and "Haunted Castle Quest Giver 2" or "Haunted Castle Quest Giver 1"
		local npc = npcs and npcs:FindFirstChild(npcName)
		if npc and npc:IsA("Model") then position = npc:GetPivot() * CFrame.new(0, 0, -3) end
		TTK.SetStatus("Accepting Bones quest: " .. mob)
		if (root.Position - position.Position).Magnitude > 5 then moveTo(position); return end
		cleanupMovement()
		if os.clock() - (TTK.LastQuest or 0) >= 2 then
			TTK.LastQuest = os.clock(); invokeCommF("StartQuest", questName, index)
		end
	end

	function TTK.FarmBones(snapshot, sword, goal, owner)
		owner = owner or "TTK"
		if not travelToSea3() then return end
		if sword and not TTK.EnsureSword(snapshot, sword) then return end
		if not workflowActive(owner) then return end
		local mobName = TTK.AcceptBonesQuest()
		if not mobName or not workflowActive(owner) then return end
		if sword then TTK.SetStatus("Bones mastery: " .. sword .. " " .. tostring(snapshot.Mastery[sword] or "?") .. "/" .. tostring(owner == "CDK" and 350 or 300))
		else TTK.SetStatus("Bones + quest Beli: " .. tostring(player.Data.Beli.Value) .. "/" .. tostring(goal)) end
		local mob = findMob(TTK.BonesMobs)
		if mob then fightMob(mob); return end
		stopFastAttack()
		local positions = { ["Reborn Skeleton"] = CFrame.new(-8737, 143, 6035), ["Living Zombie"] = CFrame.new(-10150, 140, 5930),
			["Demonic Soul"] = CFrame.new(-9501, 172, 6036), ["Posessed Mummy"] = CFrame.new(-9500, 6, 6100) }
		moveTo(positions[mobName] + Vector3.new(0, 18, 0))
	end

	function TTK.Buy(snapshot)
		if not travelToSea2() then return end
		if TTK.Request then TTK.Hop(snapshot); return end
		if os.clock() - (TTK.LastDealer or 0) < 2 then return end
		TTK.LastDealer = os.clock()
		local sword = TTK.Canonical(invokeCommF("LegendarySwordDealer", "1"))
		if not workflowActive("TTK") then return end
		if sword and sword ~= "True Triple Katana" and not snapshot.Owned[sword] and player.Data.Beli.Value >= TTK.SwordPrice then
			TTK.SetStatus("Buying missing legendary sword: " .. sword)
			local result = invokeCommF("LegendarySwordDealer", "2")
			print("[Teddy Hub][TTK] Dealer response: " .. tostring(result))
			TTK.ReadAt = -math.huge; TTK.WaitUntil = os.clock() + 4
			return
		end
		TTK.Hop(snapshot)
	end

	function TTK.Complete()
		TTK.Cancel()
		TTK.Training = nil
		state.TTKCompleted = true
		TTK.SetStatus("Completed: True Triple Katana owned")
	end

	TTK.Step = LPH_JIT(function()
		if not workflowActive("TTK") then return end
		local snapshot = TTK.Snapshot()
		if not workflowActive("TTK") then return end
		local action, target = TTK.Plan(snapshot, player.Data.Beli.Value, TTK.PreferredTraining(snapshot))
		if action == "Complete" then TTK.Complete(); return end
		if TTK.WaitUntil and os.clock() < TTK.WaitUntil then return end
		if BossFarm.HasProtectedItem() then TTK.SetStatus("Paused: carrying a protected item"); stopFastAttack(); cleanupMovement(); return end
		local root = getRoot()
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if not root or not humanoid or humanoid.Health <= 0 then TTK.SetStatus("Waiting for character"); return end
		if action ~= "Mastery" then state.TTKWeapon = nil; TTK.Training = nil end
		if action ~= "Buy" and TTK.Request then TTK.Cancel() end
		if action == "Money" then TTK.FarmBones(snapshot, nil, target)
		elseif action == "Buy" then stopFastAttack(); cleanupMovement(); TTK.Buy(snapshot)
		elseif action == "Mastery" then
			if TTK.Training ~= target then
				stopFastAttack(); cleanupMovement()
				TTK.Training = target; TTK.LastLoad = -math.huge
			end
			TTK.FarmBones(snapshot, target)
		elseif action == "Craft" then
			stopFastAttack(); cleanupMovement()
			if not travelToSea2() then return end
			if os.clock() - (TTK.LastCraft or 0) < 5 then return end
			TTK.LastCraft = os.clock()
			local ready = invokeCommF("MysteriousMan", "1")
			if not workflowActive("TTK") then return end
			if ready == -1 then TTK.Complete(); return end
			if ready ~= 0 then TTK.ReadAt = -math.huge; TTK.SetStatus("Server has not confirmed TTK mastery requirements"); return end
			if player.Data.Beli.Value < TTK.CraftPrice then return end
			TTK.SetStatus("Crafting True Triple Katana")
			local result = invokeCommF("MysteriousMan", "2")
			print("[Teddy Hub][TTK] Craft response: " .. tostring(result))
			TTK.ReadAt = -math.huge; TTK.WaitUntil = os.clock() + 3
		end
	end)
end

do
	function SwordGet.SetStatus(name, message)
		local controller = SwordGet.States[name]
		if controller.Status == message then return end
		controller.Status = message
		print("[Teddy Hub][" .. name .. "] " .. message)
		if controller.StatusChanged then controller.StatusChanged(message) end
	end

	function SwordGet.Cancel(name)
		local controller = SwordGet.States[name]
		controller.Epoch += 1
		if controller.Request then state.HopPending = false end
		controller.Request = nil
		controller.NextHop = nil
		controller.MissingSince = nil
		if name == "CDK" then SwordGet.CDK.ClearDamage(); controller.Final = nil; state.TTKWeapon = nil end
		if state.ActiveWorkflow == name then stopFastAttack(); cleanupMovement() end
	end

	function SwordGet.Complete(name)
		SwordGet.Cancel(name)
		SwordGet.States[name].Completed = true
		SwordGet.SetStatus(name, "Completed: " .. (SwordGet.States[name].InventoryKey or name) .. " owned")
	end

	function SwordGet.FindLive(names)
		local mob = findMob(names)
		if mob then return mob end
		local origin = workspace:FindFirstChild("_WorldOrigin")
		for _, folder in pairs({ Characters = workspace:FindFirstChild("Characters"),
			Origin = origin and origin:FindFirstChild("Enemies"), World = workspace }) do
			mob = BossFarm.FindIn(folder, { Names = names })
			if mob then return mob end
		end
	end

	function SwordGet.FindHint(names)
		return BossFarm.FindIn(ReplicatedStorage, { Names = names })
	end

	function SwordGet.QuestData()
		local guide = ReplicatedStorage:FindFirstChild("GuideModule")
		local module = guide and guide:FindFirstChild("GuideData")
		assert(module, "Native GuideData is unavailable")
		TTK.GuideData = TTK.GuideData or require(module)
		assert(type(TTK.GuideData.Data) == "table", "Native quest state is unavailable")
		return TTK.GuideData.Data.QuestData
	end

	function SwordGet.QuestMatches(quest, mobName)
		if type(quest) ~= "table" or type(quest.Info) ~= "table" then return false end
		local expected = cleanMobName(mobName):lower()
		if cleanMobName(tostring(quest.Info.Name or "")):lower() == expected then return true end
		for name in pairs(type(quest.Info.Task) == "table" and quest.Info.Task or {}) do
			if cleanMobName(tostring(name)):lower() == expected then return true end
		end
		return false
	end

	function SwordGet.EliteProgress(force)
		local controller = SwordGet.States.Yama
		if force or not controller.Progress or os.clock() - (controller.ProgressAt or 0) >= 2 then
			local result = invokeCommF("EliteHunter", "Progress")
			assert(type(result) == "number", "Elite Hunter progress is unavailable")
			controller.Progress = result; controller.ProgressAt = os.clock()
		end
		return controller.Progress
	end

	function SwordGet.TushitaProgress(force)
		local controller = SwordGet.States.Tushita
		if force or not controller.Progress or os.clock() - (controller.ProgressAt or 0) >= 2 then
			local result = invokeCommF("TushitaProgress")
			assert(type(result) == "table" and type(result.OpenedDoor) == "boolean" and type(result.Torches) == "table",
				"Tushita progress is unavailable")
			controller.Progress = result; controller.ProgressAt = os.clock()
		end
		return controller.Progress
	end

	function SwordGet.MapPart(name, position)
		local key = name .. ":" .. tostring(position)
		local cached = SwordGet.PartCache[key]
		if cached and os.clock() - cached.At < 1 then return cached.Part end
		local map = workspace:FindFirstChild("Map")
		if map then
			for _, object in ipairs(map:GetDescendants()) do
				if object.Name == name and object:IsA("BasePart") and (object.Position - position).Magnitude < 2 then
					SwordGet.PartCache[key] = { Part = object, At = os.clock() }; return object
				end
			end
		end
		local getter = env.getnilinstances or getnilinstances
		if type(getter) == "function" then
			for _, object in ipairs(getter()) do
				if object.Name == name and object:IsA("BasePart") and (object.Position - position).Magnitude < 2 then
					SwordGet.PartCache[key] = { Part = object, At = os.clock() }; return object
				end
			end
		end
		SwordGet.PartCache[key] = { At = os.clock() }
	end

	function SwordGet.CanHop(request)
		local controller = SwordGet.States[request.Owner]
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		return workflowActive(request.Owner) and controller.Request == request and controller.Epoch == request.Epoch
			and game.PlaceId == request.PlaceId and currentSea() == 3 and humanoid and humanoid.Health > 0
			and not BossFarm.HasProtectedItem() and not hasItem("Holy Torch")
	end

	function SwordGet.HopNeeded(request)
		if request.Owner == "CDK" then return SwordGet.CDK.HopNeeded(request.Mode) end
		if request.Mode == "Elite" then
			return SwordGet.EliteProgress(true) < 30 and not SwordGet.FindLive(SwordGet.Elites) and not SwordGet.FindHint(SwordGet.Elites)
		end
		local progress = SwordGet.TushitaProgress(true)
		if request.Mode == "Longma" then
			return progress.OpenedDoor and not SwordGet.FindLive({ "Longma" }) and not SwordGet.FindHint({ "Longma" })
		end
		local names = BossFarm.Definitions["Rip Indra"].Names
		return SwordGet.States.Tushita.HydraReady and not progress.OpenedDoor and not hasItem("Holy Torch")
			and not SwordGet.FindLive(names) and not SwordGet.FindHint(names)
	end

	function SwordGet.PublicServer(id, data)
		local job = BossFarm.DecodeJobId(id)
		if not job or job == game.JobId then return end
		local visited = state.BossVisited[job]
		if type(visited) == "number" and os.time() - visited < BossFarm.VisitedSeconds then return end
		state.BossVisited[job] = nil
		if type(data) == "table" then
			local playing = tonumber(data.playing or data.Count or data.PlayerCount)
			local maximum = tonumber(data.maxPlayers or data.MaxPlayers)
			if playing and maximum and playing >= maximum then return end
		end
		return job
	end

	function SwordGet.PublicHopJob(browser, request)
		for page = 1, 5 do
			if not SwordGet.CanHop(request) then return end
			local ok, servers = pcall(function() return browser:InvokeServer(page) end)
			if not SwordGet.CanHop(request) then return end
			if not ok or type(servers) ~= "table" or next(servers) == nil then break end
			for id, server in pairs(servers) do
				local job = SwordGet.PublicServer(type(server) == "table" and (server.id or server.JobId or id) or id, server)
				if job then return job end
			end
		end
		local cursor
		for _ = 1, 10 do
			if not SwordGet.CanHop(request) then return end
			local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId)
			if cursor then url ..= "&cursor=" .. HttpService:UrlEncode(cursor) end
			local data = HttpService:JSONDecode(game:HttpGet(url))
			if not SwordGet.CanHop(request) then return end
			assert(type(data) == "table" and type(data.data) == "table", "Public server list is unavailable")
			for _, server in ipairs(data.data) do
				local job = SwordGet.PublicServer(server.id, server)
				if job then return job end
			end
			cursor = data.nextPageCursor
			if not cursor then return end
		end
	end

	function SwordGet.Hop(name, mode)
		local controller = SwordGet.States[name]
		if controller.Request then
			if controller.Request.Mode ~= mode or os.clock() - controller.Request.Started >= BossFarm.TeleportTimeout then
				SwordGet.Cancel(name); controller.NextHop = os.clock() + BossFarm.RetrySeconds
				SwordGet.SetStatus(name, "Server search/teleport timed out; retrying")
			end
			return
		end
		if BossFarm.HasProtectedItem() or hasItem("Holy Torch") then SwordGet.SetStatus(name, "Hop paused: carrying a protected item"); return end
		controller.MissingSince = controller.MissingSince or os.clock()
		if os.clock() - controller.MissingSince < BossFarm.MissingGrace or os.clock() < (controller.NextHop or 0) then
			SwordGet.SetStatus(name, "Waiting for " .. mode .. " spawn / server retry"); return
		end
		local request = { Owner = name, Mode = mode, Epoch = controller.Epoch, PlaceId = game.PlaceId, Started = os.clock() }
		controller.Request = request; state.HopPending = true
		SwordGet.SetStatus(name, mode == "Indra" and "Searching Rip Indra API"
			or mode == "CastleRaid" and "Searching Castle Raid API" or "Searching public servers for " .. mode)
		task.spawn(function()
			local ok, message = xpcall(function()
				local browser = ReplicatedStorage:FindFirstChild("__ServerBrowser")
				assert(browser and browser:IsA("RemoteFunction"), "Server browser is unavailable")
				local job
				if mode == "Indra" then
					local servers = BossFarm.FetchServers("ripindra")
					if not SwordGet.CanHop(request) then return "Server search cancelled" end
					job = BossFarm.SelectServer(servers, BossFarm.Definitions["Rip Indra"])
				elseif mode == "CastleRaid" then
					local servers = BossFarm.FetchServers("castleraid")
					if not SwordGet.CanHop(request) then return "Server search cancelled" end
					job = BossFarm.SelectServer(servers, { Slug = "castleraid", Names = { "Castle Raid", "Pirate Raid", "Pirate / Castle Raid" } })
				else job = SwordGet.PublicHopJob(browser, request) end
				if not SwordGet.CanHop(request) then return "Server search cancelled" end
				if not job then return "No suitable server found; retrying" end
				local snapshot = TTK.Snapshot(true)
				if not SwordGet.CanHop(request) or snapshot.Owned[controller.InventoryKey or name] then return "Server search cancelled: sword owned or stopped" end
				if not SwordGet.HopNeeded(request) then return "Goal changed; staying in this server" end
				if not SwordGet.CanHop(request) then return "Server search cancelled" end
				queueResume()
				if not SwordGet.CanHop(request) then return "Server search cancelled" end
				state.BossVisited[job] = os.time(); state.BossVisited[game.JobId] = os.time()
				request.Teleport = true; request.Started = os.clock()
				SwordGet.SetStatus(name, "Hopping for " .. mode)
				assert(browser:InvokeServer("teleport", job) ~= false, "Server teleport was rejected")
			end, debug.traceback)
			if state.Generation ~= generation or controller.Request ~= request then return end
			if ok and request.Teleport then return end
			controller.Request = nil; state.HopPending = false; controller.NextHop = os.clock() + BossFarm.RetrySeconds
			SwordGet.SetStatus(name, ok and (message or "Server search cancelled") or "Server search error; see console")
			if not ok then reportControllerError(message, name, "ServerHop") end
		end)
	end

	function SwordGet.Yama()
		local controller = SwordGet.States.Yama
		local progress = SwordGet.EliteProgress()
		if not workflowActive("Yama") then return end
		if progress < 30 then
			if controller.Target and not isAlive(controller.Target) then
				controller.Target = nil; controller.ProgressAt = -math.huge; controller.RewardUntil = os.clock() + 2
			end
			if os.clock() < (controller.RewardUntil or 0) then stopFastAttack(); cleanupMovement(); return end
			local boss = SwordGet.FindLive(SwordGet.Elites)
			local hint = not boss and SwordGet.FindHint(SwordGet.Elites)
			local target = boss or hint
			if not target then stopFastAttack(); cleanupMovement(); SwordGet.Hop("Yama", "Elite"); return end
			if controller.Request then SwordGet.Cancel("Yama") end
			controller.MissingSince = nil
			local quest = SwordGet.QuestData()
			if not SwordGet.QuestMatches(quest, target.Name) then
				stopFastAttack(); cleanupMovement()
				SwordGet.SetStatus("Yama", "Accepting Elite quest: " .. cleanMobName(target.Name) .. " (" .. progress .. "/30)")
				if os.clock() - (controller.LastQuest or 0) >= 2 then
					controller.LastQuest = os.clock()
					if quest then invokeCommF("AbandonQuest")
					else invokeCommF("EliteHunter") end
				end
				return
			end
			if boss then
				controller.Target = boss
				SwordGet.SetStatus("Yama", "Elite " .. progress .. "/30: fighting " .. cleanMobName(boss.Name))
				fightMob(boss)
			else
				SwordGet.SetStatus("Yama", "Approaching Elite / waiting for replication")
				moveTo(uprightCFrame(hint.HumanoidRootPart.CFrame) * CFrame.new(Config.OrderOffset))
			end
			return
		end
		if controller.Request then SwordGet.Cancel("Yama") end
		local map = workspace:FindFirstChild("Map")
		local waterfall = map and map:FindFirstChild("Waterfall")
		local katana = waterfall and waterfall:FindFirstChild("SealedKatana")
		local hitbox = katana and katana:FindFirstChild("Hitbox") or SwordGet.MapPart("Hitbox", SwordGet.YamaRoom.Position)
		local position = hitbox and hitbox:IsA("BasePart") and hitbox.CFrame or SwordGet.YamaRoom
		local root = getRoot()
		if (root.Position - position.Position).Magnitude > 40 then
			stopFastAttack(); SwordGet.SetStatus("Yama", "Elite 30/30: approaching Sealed Katana"); moveTo(position); return
		end
		local ghost = SwordGet.FindLive({ "Ghost" })
		if ghost and (ghost.HumanoidRootPart.Position - position.Position).Magnitude < 150 then
			SwordGet.SetStatus("Yama", "Clearing Sealed Katana ghosts"); fightMob(ghost); return
		end
		stopFastAttack()
		if (root.Position - position.Position).Magnitude > 8 then moveTo(position); return end
		cleanupMovement()
		local click = hitbox and hitbox:FindFirstChildOfClass("ClickDetector")
		if not click then SwordGet.SetStatus("Yama", "Waiting for Sealed Katana ClickDetector"); return end
		local fire = env.fireclickdetector or fireclickdetector
		assert(type(fire) == "function", "Executor fireclickdetector is unavailable")
		SwordGet.SetStatus("Yama", "Pulling Yama; waiting for inventory confirmation")
		if os.clock() - (controller.LastPull or 0) >= 1 and workflowActive("Yama") then
			controller.LastPull = os.clock(); fire(click); TTK.ReadAt = -math.huge
		end
	end

	function SwordGet.TouchHydra(part)
		local controller = SwordGet.States.Tushita
		local root = getRoot()
		local fire = env.firetouchinterest or firetouchinterest
		if type(fire) ~= "function" then return end
		if os.clock() - (controller.LastTouch or 0) < 1 then return end
		controller.LastTouch = os.clock()
		if not workflowActive("Tushita") then return end
		fire(root, part, 0)
		task.wait()
		local ok, err = pcall(fire, root, part, 1)
		if not ok then error(err) end
	end

	function SwordGet.Tushita()
		local controller = SwordGet.States.Tushita
		local progress = SwordGet.TushitaProgress()
		if not workflowActive("Tushita") then return end
		if progress.OpenedDoor then
			if controller.Request and controller.Request.Mode ~= "Longma" then SwordGet.Cancel("Tushita") end
			if controller.Target and not isAlive(controller.Target) then
				controller.Target = nil; controller.RewardUntil = os.clock() + 5; TTK.ReadAt = -math.huge
			end
			if os.clock() < (controller.RewardUntil or 0) then
				stopFastAttack(); cleanupMovement(); SwordGet.SetStatus("Tushita", "Waiting for Tushita drop / inventory replication"); return
			end
			local boss = SwordGet.FindLive({ "Longma" })
			local hint = not boss and SwordGet.FindHint({ "Longma" })
			if boss or hint then
				if controller.Request then SwordGet.Cancel("Tushita") end
				controller.MissingSince = nil
				if boss then controller.Target = boss; SwordGet.SetStatus("Tushita", "Door open: fighting Longma"); fightMob(boss)
				else SwordGet.SetStatus("Tushita", "Approaching Longma / waiting for replication"); moveTo(hint.HumanoidRootPart.CFrame * CFrame.new(Config.OrderOffset)) end
				return
			end
			stopFastAttack()
			if (getRoot().Position - SwordGet.LongmaRoom.Position).Magnitude > 80 then
				SwordGet.SetStatus("Tushita", "Door open: approaching Longma room"); moveTo(SwordGet.LongmaRoom); return
			end
			cleanupMovement(); SwordGet.Hop("Tushita", "Longma"); return
		end
		if hasItem("Holy Torch") then
			if controller.Request then SwordGet.Cancel("Tushita") end
			stopFastAttack()
			assert(equipItem("Holy Torch"), "Holy Torch could not be equipped")
			local nextTorch
			for i = 1, 5 do if progress.Torches[i] ~= true then nextTorch = i; break end end
			if not nextTorch then SwordGet.SetStatus("Tushita", "Torches 5/5: waiting for door confirmation"); cleanupMovement(); return end
			local part = SwordGet.MapPart("Torch" .. nextTorch, SwordGet.Torches[nextTorch].Position)
			local position = part and part.CFrame or SwordGet.Torches[nextTorch]
			SwordGet.SetStatus("Tushita", "Lighting torch " .. nextTorch .. "/5")
			if (getRoot().Position - position.Position).Magnitude > 8 then moveTo(position); return end
			cleanupMovement()
			if os.clock() - (controller.LastTorch or 0) >= 1 and workflowActive("Tushita") then
				controller.LastTorch = os.clock(); invokeCommF("TushitaProgress", "Torch", nextTorch); controller.ProgressAt = -math.huge
			end
			return
		end
		local hitbox = SwordGet.MapPart("Hitbox", SwordGet.HydraGate.Position)
		local position = hitbox and hitbox.CFrame or SwordGet.HydraGate
		if not controller.HydraReady then
			SwordGet.SetStatus("Tushita", "Approaching Hydra gate before Rip Indra search")
			if (getRoot().Position - position.Position).Magnitude > 8 then moveTo(position); return end
			controller.HydraReady = true; cleanupMovement()
		end
		local names = BossFarm.Definitions["Rip Indra"].Names
		local indra = SwordGet.FindLive(names) or SwordGet.FindHint(names)
		if not indra then stopFastAttack(); cleanupMovement(); SwordGet.Hop("Tushita", "Indra"); return end
		if controller.Request then SwordGet.Cancel("Tushita") end
		controller.MissingSince = nil
		SwordGet.SetStatus("Tushita", "Rip Indra found: entering Hydra gate for Holy Torch")
		if (getRoot().Position - position.Position).Magnitude > 3 then moveTo(position); return end
		cleanupMovement()
		if hitbox and hitbox:FindFirstChild("TouchInterest") then SwordGet.TouchHydra(hitbox)
		else SwordGet.SetStatus("Tushita", "Waiting for Hydra gate activation / replication") end
	end

	SwordGet.Step = LPH_JIT(function(name)
		if not workflowActive(name) then return end
		local snapshot = TTK.Snapshot()
		if not workflowActive(name) then return end
		if snapshot.Owned[SwordGet.States[name].InventoryKey or name] then SwordGet.Complete(name); return end
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if not getRoot() or not humanoid or humanoid.Health <= 0 then
			stopFastAttack(); cleanupMovement(); SwordGet.SetStatus(name, "Waiting for character"); return
		end
		if name == "CDK" and (not snapshot.Owned.Yama or not snapshot.Owned.Tushita) then
			SwordGet.CDK.Step(snapshot); return
		end
		if name == "Tushita" and player.Data.Level.Value < 2000 then SwordGet.SetStatus(name, "Tushita requires level 2000 or higher"); return end
		if not travelToSea3() then SwordGet.SetStatus(name, "Travelling to Sea 3"); return end
		if name == "CDK" then SwordGet.CDK.Step(snapshot)
		elseif name == "Yama" then SwordGet.Yama() else SwordGet.Tushita() end
	end)
end

do
	local CDK = SwordGet.CDK
	local controller = SwordGet.States.CDK

	function CDK.Plan(snapshot, training, available, choose)
		if snapshot.Owned["Cursed Dual Katana"] then return "Complete" end
		for _, sword in ipairs(CDK.Swords) do if not snapshot.Owned[sword] then return "Missing", sword end end
		local pending = {}
		for _, sword in ipairs(CDK.Swords) do
			if (snapshot.Mastery[sword] or 0) < CDK.RequiredMastery then pending[#pending + 1] = sword end
		end
		if #pending == 0 then return "Trials" end
		if table.find(pending, training) then return "Mastery", training end
		for _, sword in ipairs(available or {}) do if table.find(pending, sword) then return "Mastery", sword end end
		return "Mastery", pending[(choose or math.random)(1, #pending)]
	end

	function CDK.AvailableSwords()
		local swords = {}
		local containers = {}
		if player.Character then containers[#containers + 1] = player.Character end
		local backpack = player:FindFirstChild("Backpack")
		if backpack then containers[#containers + 1] = backpack end
		for _, container in ipairs(containers) do
			for _, tool in ipairs(container:GetChildren()) do
				local sword = tool:IsA("Tool") and TTK.Canonical(tool.Name)
				if table.find(CDK.Swords, sword) and not table.find(swords, sword) then swords[#swords + 1] = sword end
			end
		end
		return swords
	end

	function CDK.Progress(force, side)
		if force or not controller.Progress or os.clock() - (controller.ProgressAt or 0) >= 2 then
			local progress = invokeCommF("CDKQuest", "Progress", side or "Good")
			assert(type(progress) == "table" and type(progress.Good) == "number" and type(progress.Evil) == "number",
				"CDK progress is unavailable")
			controller.Progress = progress; controller.ProgressAt = os.clock()
		end
		return controller.Progress
	end

	function CDK.Map(name)
		local map = workspace:FindFirstChild("Map")
		if name == "Cursed" then
			local turtle = map and map:FindFirstChild("Turtle")
			return turtle and turtle:FindFirstChild("Cursed")
		end
		return map and map:FindFirstChild(name)
	end

	function CDK.Approach(position, radius)
		if not workflowActive("CDK") then return false end
		if (getRoot().Position - position.Position).Magnitude > (radius or 8) then moveTo(position); return false end
		cleanupMovement(); return true
	end

	function CDK.Remote(key, ...)
		if not workflowActive("CDK") then return end
		controller.Remotes = controller.Remotes or {}
		if os.clock() - (controller.Remotes[key] or -math.huge) < 2 then return end
		controller.Remotes[key] = os.clock()
		local result = invokeCommF(...)
		controller.ProgressAt = -math.huge
		return result
	end

	function CDK.Prompt(part)
		if not part or not part:IsA("BasePart") then return false end
		if not CDK.Approach(part.CFrame, 6) then return false end
		local prompt = part:FindFirstChildOfClass("ProximityPrompt")
		if not prompt or not prompt.Enabled then return false end
		if os.clock() - (controller.LastPrompt or -math.huge) < 1.5 then return false end
		local fire = env.fireproximityprompt or fireproximityprompt
		assert(type(fire) == "function", "Executor fireproximityprompt is unavailable")
		controller.LastPrompt = os.clock()
		if workflowActive("CDK") then fire(prompt); controller.ProgressAt = -math.huge; return true end
		return false
	end

	function CDK.Spawn(name, fallback)
		local origin = workspace:FindFirstChild("_WorldOrigin")
		local spawns = origin and origin:FindFirstChild("EnemySpawns")
		local nearest, distance
		if spawns then
			for _, part in ipairs(spawns:GetChildren()) do
				if BossFarm.Matches(part.Name, { Names = { name } }) then
					local cf = part:IsA("BasePart") and part.CFrame or part:IsA("Model") and part:GetPivot()
					local d = cf and (getRoot().Position - cf.Position).Magnitude
					if d and (not distance or d < distance) then nearest, distance = cf, d end
				end
			end
		end
		return nearest or fallback
	end

	function CDK.NearbyMob(center, radius, filter, hints)
		local root = getRoot()
		local folder = hints and ReplicatedStorage or workspace:FindFirstChild("Enemies")
		local nearest, distance
		for _, mob in ipairs(folder and folder:GetChildren() or {}) do
			if isAlive(mob) and (mob.HumanoidRootPart.Position - center).Magnitude <= radius and (not filter or filter(mob)) then
				local d = (root.Position - mob.HumanoidRootPart.Position).Magnitude
				if not distance or d < distance then nearest, distance = mob, d end
			end
		end
		return nearest
	end

	function CDK.InDimension(name)
		local dimension = CDK.Map(name)
		if not dimension then return end
		local members = dimension:FindFirstChild("ActivePlayers")
		if members then
			local belongs = false
			for _, entry in ipairs(members:GetChildren()) do
				if entry:IsA("ValueBase") and (entry.Value == player or tostring(entry.Value) == player.Name) then belongs = true; break end
			end
			if not belongs then return end
		end
		local origin = workspace:FindFirstChild("_WorldOrigin")
		local locations = origin and origin:FindFirstChild("Locations")
		local location = locations and locations:FindFirstChild(name == "HellDimension" and "Hell Dimension" or "Heavenly Dimension")
		local position = location and location.Position or dimension and dimension:GetPivot().Position
		return dimension and position and (getRoot().Position - position).Magnitude < 1000 and dimension or nil
	end

	function CDK.ClearDamage()
		controller.TakingDamage = nil
		if controller.RestoreObservation then
			local observation = controller.RestoreObservation
			controller.RestoreObservation = nil
			local ok, err = pcall(function()
				observation:setActive(true)
				ReplicatedStorage.Remotes.CommE:FireServer("Ken", true)
			end)
			if not ok then reportControllerError(err, "CDK", "RestoreObservation") end
		end
	end

	function CDK.TakeDamage(mob, fallback)
		controller.TakingDamage = true
		stopFastAttack(); state.TTKWeapon = nil
		if not mob then CDK.Approach(fallback, 12); return end
		SwordGet.SetStatus("CDK", "Receiving damage from " .. cleanMobName(mob.Name) .. "; attacks paused")
		local global = ReplicatedStorage:FindFirstChild("Global")
		local observation = global and require(global).OM
		if observation and observation.active then
			controller.RestoreObservation = observation
			observation:setActive(false); ReplicatedStorage.Remotes.CommE:FireServer("Ken", false)
		end
		player.Character:FindFirstChildOfClass("Humanoid"):UnequipTools()
		CDK.Approach(uprightCFrame(mob.HumanoidRootPart.CFrame) * CFrame.new(0, 0, -3), 4)
	end

	function CDK.OpenRoom(snapshot)
		if controller.DoorOpened then return true end
		SwordGet.SetStatus("CDK", "Opening cursed room behind the mansion")
		local check = CDK.Remote("CheckDoor", "CDKQuest", "OpenDoor")
		if not workflowActive("CDK") then return false end
		if check ~= nil then controller.DoorCheck = check end
		if controller.DoorCheck == "opened" then controller.DoorOpened = true; return true end
		if controller.DoorCheck ~= "can" then SwordGet.SetStatus("CDK", "Waiting for cursed room requirements / server confirmation"); return false end
		local npc = workspace:FindFirstChild("NPCs") and workspace.NPCs:FindFirstChild("Crypt Master")
		local position = npc and npc:GetPivot() or CDK.Manor
		stopFastAttack()
		if not CDK.Approach(position, 10) then return false end
		if not TTK.EnsureSword(snapshot, "Tushita") then return false end
		local result = CDK.Remote("OpenDoor", "CDKQuest", "OpenDoor", true)
		if not workflowActive("CDK") then return false end
		if result == true or result == "opened" then controller.DoorOpened = true end
		return controller.DoorOpened == true
	end

	function CDK.BeginTrial(side)
		stopFastAttack()
		local progress = CDK.Progress(true, side)
		if not workflowActive("CDK") then return end
		if progress[side] >= 0 and progress[side] < 3 then
			cleanupMovement()
			SwordGet.SetStatus("CDK", "Starting " .. side .. " trial remotely")
			CDK.Remote("Start" .. side, "CDKQuest", "StartTrial", side)
		elseif progress[side] == 3 then
			local room = CDK.Map("Cursed")
			local pedestal = room and room:FindFirstChild(side == "Good" and "Pedestal1" or "Pedestal2")
			SwordGet.SetStatus("CDK", "Completing " .. side .. " scroll")
			if not CDK.Approach(pedestal and pedestal.CFrame or CDK.Room, 8) then return end
			CDK.Prompt(pedestal)
		end
	end

	function CDK.Boats()
		stopFastAttack()
		controller.Boats = controller.Boats or {}
		local candidates = {}
		for _, folder in pairs({ World = workspace:FindFirstChild("NPCs"), Stored = ReplicatedStorage:FindFirstChild("NPCs") }) do
			for _, npc in ipairs(folder:GetChildren()) do
				if npc:IsA("Model") and npc.Name:match("Boat Dealer$") then
					local cf = npc:GetPivot(); local key = tostring(cf.Position)
					if not controller.Boats[key] then candidates[#candidates + 1] = { NPC = npc, Position = cf, Key = key } end
				end
			end
		end
		table.sort(candidates, function(a, b)
			return (a.Position.Position - getRoot().Position).Magnitude < (b.Position.Position - getRoot().Position).Magnitude
		end)
		local target = candidates[1]
		SwordGet.SetStatus("CDK", "Good trial 1: visiting boat dealers")
		if not target then
			controller.BoatIndex = controller.BoatIndex or 1
			if not CDK.Approach(CFrame.new(CDK.BoatSpawns[controller.BoatIndex]), 10) then return end
			controller.BoatWait = controller.BoatWait or os.clock()
			if os.clock() - controller.BoatWait >= 3 then
				controller.BoatIndex = controller.BoatIndex % #CDK.BoatSpawns + 1; controller.BoatWait = nil
				if controller.BoatIndex == 1 then controller.Boats = {} end
			end
			return
		end
		if not CDK.Approach(target.Position, 8) then return end
		if os.clock() - (controller.LastBoat or -math.huge) < 2 then return end
		controller.LastBoat = os.clock()
		local eligible = invokeCommF("CDKQuest", "BoatQuest", target.NPC, "Check")
		if not workflowActive("CDK") then return end
		if eligible then invokeCommF("CDKQuest", "BoatQuest", target.NPC) end
		controller.Boats[target.Key] = true; controller.ProgressAt = -math.huge
	end

	function CDK.CastleMob(hints)
		return CDK.NearbyMob(CDK.Castle.Position, 1000, function(mob)
			return not mob.Name:find("Boss") and not mob.Name:find("Friend") and not mob.Name:find("Wraith")
				and mob.Name ~= "Oni2" and mob.Name ~= "rip_indra True Form"
		end, hints)
	end

	function CDK.CastleRaid()
		SwordGet.SetStatus("CDK", "Good trial 2: clearing Castle pirate raid")
		local mob = CDK.CastleMob()
		if mob then
			if controller.Request then SwordGet.Cancel("CDK") end
			controller.RaidWait = nil; controller.MissingSince = nil; fightMob(mob); return
		end
		stopFastAttack()
		local hint = CDK.CastleMob(true)
		if hint then
			if controller.Request then SwordGet.Cancel("CDK") end
			controller.RaidWait = nil; controller.MissingSince = nil; moveTo(hint.HumanoidRootPart.CFrame); return
		end
		if not CDK.Approach(CDK.Castle, 150) then return end
		controller.RaidWait = controller.RaidWait or os.clock()
		local remaining = 15 - (os.clock() - controller.RaidWait)
		if remaining > 0 then
			SwordGet.SetStatus("CDK", "Waiting for Castle Raid pirates (" .. math.ceil(remaining) .. "s before API hop)")
			return
		end
		controller.MissingSince = controller.RaidWait
		SwordGet.Hop("CDK", "CastleRaid")
	end

	function CDK.Dimension(name)
		local dimension = CDK.InDimension(name)
		if not dimension then return false end
		CDK.ClearDamage()
		local exit = dimension:FindFirstChild("Exit")
		local ready = exit and exit:IsA("BasePart") and (#exit:GetChildren() >= 2
			or exit.BrickColor == BrickColor.new(name == "HellDimension" and "Olivine" or "Cloudy grey"))
		if ready then
			stopFastAttack(); SwordGet.SetStatus("CDK", name .. ": leaving through exit"); CDK.Approach(exit.CFrame, 1); return true
		end
		local mob = CDK.NearbyMob(getRoot().Position, 1200)
		if mob then SwordGet.SetStatus("CDK", name .. ": clearing trial enemies"); fightMob(mob); return true end
		stopFastAttack()
		for i = 1, 3 do
			local torch = dimension:FindFirstChild("Torch" .. i)
			local prompt = torch and torch:FindFirstChildOfClass("ProximityPrompt")
			local particles = torch and torch:FindFirstChild("Particles")
			local main = particles and particles:FindFirstChild("Main")
			if prompt and prompt.Enabled and (not main or not main.Enabled) then
				SwordGet.SetStatus("CDK", name .. ": activating torch " .. i .. "/3"); CDK.Prompt(torch); return true
			end
		end
		SwordGet.SetStatus("CDK", name .. ": waiting for enemy wave / exit")
		return true
	end

	function CDK.Queen()
		if CDK.Dimension("HeavenlyDimension") then return end
		local boss = SwordGet.FindLive({ "Cake Queen" })
		local hint = not boss and SwordGet.FindHint({ "Cake Queen" })
		if boss or hint then
			if controller.Request then SwordGet.Cancel("CDK") end
			controller.MissingSince = nil
			SwordGet.SetStatus("CDK", "Good trial 3: defeating Cake Queen")
			if boss then
				controller.Target = boss; fightMob(boss)
			else moveTo(hint.HumanoidRootPart.CFrame * CFrame.new(Config.OrderOffset)) end
			return
		end
		if controller.Target and not isAlive(controller.Target) then
			controller.Target = nil; controller.DimensionWait = os.clock() + 8
		end
		stopFastAttack()
		if os.clock() < (controller.DimensionWait or 0) then
			cleanupMovement(); SwordGet.SetStatus("CDK", "Waiting for Heavenly Dimension teleport"); return
		end
		if not CDK.Approach(CDK.Spawn("Cake Queen", CDK.QueenSpawn), 100) then return end
		SwordGet.Hop("CDK", "CakeQueen")
	end

	function CDK.Haze()
		local quest = player:FindFirstChild("QuestHaze")
		if not quest then
			stopFastAttack(); cleanupMovement(); SwordGet.SetStatus("CDK", "Waiting for QuestHaze"); return
		end
		local targetNames = {}
		for _, value in ipairs(quest:GetChildren()) do
			if value:IsA("ValueBase") and (tonumber(value.Value) or 0) > 0 then
				targetNames[#targetNames + 1] = value.Name
			end
		end
		if #targetNames == 0 then stopFastAttack(); cleanupMovement(); controller.ProgressAt = -math.huge; return end
		local root = getRoot()
		local definition = { Names = targetNames }
		local mob = CDK.NearbyMob(root.Position, math.huge, function(enemy)
			return BossFarm.Matches(enemy.Name, definition) and enemy:FindFirstChild("HazeESP") ~= nil
		end)
		if mob then
			SwordGet.SetStatus("CDK", "Evil trial 2: clearing nearest Haze enemy: " .. mob.Name)
			fightMob(mob); return
		end
		stopFastAttack()
		local position, targetName, nearestDistance
		for _, name in ipairs(targetNames) do
			local spawn = CDK.Spawn(name)
			local distance = spawn and (root.Position - spawn.Position).Magnitude
			if distance and (not nearestDistance or distance < nearestDistance) then
				position, targetName, nearestDistance = spawn, name, distance
			end
		end
		if position then
			SwordGet.SetStatus("CDK", "Approaching nearest Haze spawn: " .. targetName)
			moveTo(position + Vector3.new(0, 18, 0))
		else
			cleanupMovement(); SwordGet.SetStatus("CDK", "Waiting for Haze enemy spawns")
		end
	end

	function CDK.Reaper(snapshot)
		if CDK.Dimension("HellDimension") then return end
		local reaper = SwordGet.FindLive({ "Soul Reaper" })
		if reaper then CDK.TakeDamage(reaper); return end
		CDK.ClearDamage(); stopFastAttack()
		if hasItem("Hallow Essence") then
			local detection = SwordGet.MapPart("Detection", CDK.Summoner.Position)
			local position = detection and detection.CFrame or CDK.Summoner
			SwordGet.SetStatus("CDK", "Evil trial 3: summoning Soul Reaper with Hallow Essence")
			if not CDK.Approach(position, 3) then return end
			assert(equipItem("Hallow Essence"), "Hallow Essence disappeared before summon")
			local fire = env.firetouchinterest or firetouchinterest
			if detection and type(fire) == "function" and os.clock() - (controller.LastSummon or -math.huge) >= 2 then
				controller.LastSummon = os.clock()
				fire(getRoot(), detection, 0); fire(getRoot(), detection, 1)
			end
			return
		end
		local hint = SwordGet.FindHint({ "Soul Reaper" })
		if hint then moveTo(hint.HumanoidRootPart.CFrame); SwordGet.SetStatus("CDK", "Waiting for Soul Reaper replication"); return end
		if os.clock() - (controller.BonesAt or -math.huge) >= 2 then
			controller.Bones = invokeCommF("Bones", "Check"); controller.BonesAt = os.clock()
		end
		local bones = controller.Bones
		if not workflowActive("CDK") then return end
		if type(bones) == "number" and bones >= 50 then
			SwordGet.SetStatus("CDK", "Rolling Bones for Hallow Essence")
			CDK.Remote("BonesRoll", "Bones", "Buy", 1, 1); return
		end
		TTK.FarmBones(snapshot, "Yama", nil, "CDK")
	end

	function CDK.FinalReady(progress)
		return type(progress) == "table" and type(progress.Good) == "number" and type(progress.Evil) == "number"
			and progress.Good >= 3 and progress.Evil >= 3
	end

	function CDK.FinalPartPosition(object)
		if not object then return nil end
		if object:IsA("BasePart") then return object.CFrame end
		if object:IsA("Model") then return object:GetPivot() end
	end

	function CDK.FinalDialogue(session)
		if os.clock() > (session.DialogueUntil or 0) or os.clock() < (session.NextDialogue or 0) then return end
		local gui = player:FindFirstChild("PlayerGui")
		local main = gui and gui:FindFirstChild("Main")
		local dialogue = main and main:FindFirstChild("Dialogue")
		if not dialogue or not dialogue.Visible then return end
		session.NextDialogue = os.clock() + 0.5
		local frame = dialogue:FindFirstChild("TextFrame") or dialogue
		local point = frame.AbsolutePosition + frame.AbsoluteSize / 2
		local input = game:GetService("VirtualUser")
		input:Button1Down(point)
		input:Button1Up(point)
	end

	function CDK.Final(snapshot, progress)
		if not workflowActive("CDK") then return end
		if snapshot.Owned["Cursed Dual Katana"] then SwordGet.Complete("CDK"); return end
		local character, root = player.Character, getRoot()
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not root or not humanoid or humanoid.Health <= 0 then return end
		progress = progress or CDK.Progress()
		if not workflowActive("CDK") or not CDK.FinalReady(progress) then return end
		local session = controller.Final
		if not session or session.JobId ~= game.JobId or session.Character ~= character or session.Epoch ~= controller.Epoch then
			stopFastAttack(); cleanupMovement()
			session = { JobId = game.JobId, Character = character, Epoch = controller.Epoch, Stage = "Scrolls" }
			controller.Final = session
		end
		local function active()
			return workflowActive("CDK") and controller.Final == session and controller.Epoch == session.Epoch
				and player.Character == character and getRoot() == root and humanoid.Health > 0
		end
		CDK.FinalDialogue(session)
		local sword = CDK.AvailableSwords()[1] or "Tushita"
		if not TTK.EnsureSword(snapshot, sword) or not active() then return end
		local boss = SwordGet.FindLive({ "Cursed Skeleton Boss" })
		if boss then
			session.Stage, session.Target, session.BossSeen = "Fight", boss, true
			session.MissingBossSince = nil
			SwordGet.SetStatus("CDK", "Final: fighting Cursed Skeleton Boss with " .. sword)
			fightMob(boss); return
		end
		stopFastAttack()
		local previousHumanoid = session.Target and session.Target:FindFirstChildOfClass("Humanoid")
		if session.BossSeen and previousHumanoid and previousHumanoid.Health <= 0 then
			session.Target, session.BossSeen = nil, nil
			session.Stage, session.RewardUntil = "Reward", os.clock() + 5
			TTK.ReadAt = -math.huge
		end
		if session.BossSeen then
			session.MissingBossSince = session.MissingBossSince or os.clock()
			if os.clock() - session.MissingBossSince < 10 then
				cleanupMovement(); SwordGet.SetStatus("CDK", "Final: waiting for boss replication / reward confirmation"); return
			end
			session.Target, session.BossSeen = nil, nil
			session.Stage = "Approach"
		end
		if session.Stage == "Reward" then
			cleanupMovement()
			SwordGet.SetStatus("CDK", "Final: checking inventory for Cursed Dual Katana")
			if os.clock() < session.RewardUntil then return end
			local owned = TTK.Snapshot(true)
			if not active() then return end
			if owned.Owned["Cursed Dual Katana"] then SwordGet.Complete("CDK"); return end
			session.Stage, session.NextStart = "Approach", os.clock() + 3
		end
		local room = CDK.Map("Cursed")
		if not room then
			SwordGet.SetStatus("CDK", "Final: loading cursed room behind the mansion")
			if CDK.Approach(CDK.Room, 8) and os.clock() >= (session.NextStream or 0) then
				session.NextStream = os.clock() + 8
				task.spawn(function() pcall(function() player:RequestStreamAroundAsync(CDK.Room.Position, 5) end) end)
			end
			return
		end
		for _, side in ipairs({ "Good", "Evil" }) do
			if progress[side] == 3 then
				session.Stage = "Scrolls"
				SwordGet.SetStatus("CDK", "Final: claiming last " .. side .. " scroll reward")
				local pedestal = room:FindFirstChild(side == "Good" and "Pedestal1" or "Pedestal2", true)
				if not CDK.Approach(CDK.FinalPartPosition(pedestal) or CDK.Room, 6) then return end
				if os.clock() < (session.NextScroll or 0) then return end
				session.NextScroll = os.clock() + 2
				local updated = CDK.Progress(true, side)
				if not active() then return end
				if updated[side] == 3 and CDK.Prompt(pedestal) then session.DialogueUntil = os.clock() + 5 end
				return
			end
		end
		local skeleton = SwordGet.FindLive({ "Cursed Skeleton" })
		local skeletonRoot = skeleton and skeleton:FindFirstChild("HumanoidRootPart")
		if skeletonRoot and (skeletonRoot.Position - CDK.BossRoom.Position).Magnitude <= 200 then
			SwordGet.SetStatus("CDK", "Final: clearing Cursed Skeletons in the boss chamber")
			fightMob(skeleton); return
		end
		local pedestal = room:FindFirstChild("Pedestal3", true)
		local position = CDK.FinalPartPosition(pedestal)
		if session.Stage == "Scrolls" then session.Stage = "Approach" end
		if session.Stage == "Approach" then
			SwordGet.SetStatus("CDK", "Final: approaching Alucard Gem pedestal")
			if not CDK.Approach(position or CDK.Room, 6) then return end
			if not pedestal then SwordGet.SetStatus("CDK", "Final: waiting for Pedestal3 replication"); return end
			if os.clock() < (session.NextStart or 0) then return end
			local result = CDK.Remote("BossTrial", "CDKQuest", "StartTrial", "Boss")
			if not active() then return end
			session.NextStart = os.clock() + 8
			if result == false then
				SwordGet.SetStatus("CDK", "Final: boss trial rejected; rechecking scroll rewards")
				controller.ProgressAt = -math.huge; return
			end
			session.Stage, session.StartedAt = "WaitDoor", os.clock()
			session.DialogueUntil = os.clock() + 5
		end
		local gem = room:FindFirstChild("PlacedGem", true)
		local placed = gem and gem:IsA("BasePart") and gem.Transparency < 0.05
		if gem and gem:IsA("Model") then
			for _, part in ipairs(gem:GetDescendants()) do
				if part:IsA("BasePart") and part.Transparency < 0.05 then placed = true; break end
			end
		end
		if session.Stage == "WaitDoor" then
			SwordGet.SetStatus("CDK", "Final: waiting for Alucard Gem / chamber opening")
			cleanupMovement()
			if placed then session.Stage = "Enter"
			elseif os.clock() >= session.NextStart then session.Stage = "Approach" end
			return
		end
		SwordGet.SetStatus("CDK", "Final: entering chamber / waiting for Cursed Skeleton Boss")
		if not CDK.Approach(CDK.BossRoom, 5) then return end
		if session.Stage == "Enter" then session.Stage, session.SpawnUntil = "WaitBoss", os.clock() + 20 end
		if os.clock() >= (session.SpawnUntil or 0) then
			session.Stage, session.NextStart = "Approach", os.clock() + 3
		end
	end

	function CDK.HopNeeded(mode)
		local progress = CDK.Progress(true)
		if CDK.InDimension("HellDimension") or CDK.InDimension("HeavenlyDimension") then return false end
		if mode == "CastleRaid" then return progress.Good == -4 and not CDK.CastleMob() and not CDK.CastleMob(true) end
		return mode == "CakeQueen" and progress.Good == -5
			and not SwordGet.FindLive({ "Cake Queen" }) and not SwordGet.FindHint({ "Cake Queen" })
	end

	CDK.Step = LPH_JIT(function(snapshot)
		local action, sword = CDK.Plan(snapshot, controller.Training, CDK.AvailableSwords())
		if action == "Complete" then SwordGet.Complete("CDK"); return end
		if action == "Missing" then
			stopFastAttack(); cleanupMovement()
			SwordGet.SetStatus("CDK", "Requires " .. sword .. "; obtain both Yama and Tushita first")
			notify("Auto Cursed Dual Katana requires Yama and Tushita.", "cdk-missing", 5); return
		end
		if action == "Mastery" then
			controller.Training = sword
			TTK.FarmBones(snapshot, sword, nil, "CDK"); return
		end
		if player.Data.Level.Value < 2200 then SwordGet.SetStatus("CDK", "CDK trials require level 2200 or higher"); return end
		if not CDK.OpenRoom(snapshot) then return end
		local progress = CDK.Progress()
		if not workflowActive("CDK") then return end
		local phase = tostring(progress.Good) .. ":" .. tostring(progress.Evil)
		if controller.Phase ~= phase then
			if controller.Request then SwordGet.Cancel("CDK") end
			CDK.ClearDamage(); controller.Phase = phase; controller.MissingSince = nil; controller.Target = nil
			controller.DimensionWait = nil; controller.RaidWait = nil
		end
		if CDK.FinalReady(progress) then CDK.ClearDamage(); CDK.Final(snapshot, progress); return end
		local side = (progress.Good ~= -2 and progress.Good < 4) and "Good" or "Evil"
		if not TTK.EnsureSword(snapshot, side == "Good" and "Tushita" or "Yama") then return end
		local value = progress[side]
		if value >= -2 then CDK.ClearDamage(); CDK.BeginTrial(side); return end
		if side == "Good" then
			CDK.ClearDamage()
			if value == -3 then CDK.Boats()
			elseif value == -4 then CDK.CastleRaid()
			elseif value == -5 then CDK.Queen() end
		elseif value == -3 then
			local mob = SwordGet.FindLive({ "Marine Commodore" })
			SwordGet.SetStatus("CDK", "Evil trial 1: Pain and Suffering")
			CDK.TakeDamage(mob, CDK.Spawn("Marine Commodore", CDK.PainSpawn))
		elseif value == -4 then CDK.ClearDamage(); CDK.Haze()
		elseif value == -5 then CDK.Reaper(snapshot) end
	end)
end

do
	function Haki.SetStatus(message)
		if Haki.Status == message then return end
		Haki.Status = message
		print("[Teddy Hub][Haki] " .. message)
	end

	function Haki.Canonical(name)
		if type(name) ~= "string" then return end
		name = name:gsub("^[Hh][Aa][Kk][Ii]%s*:%s*", ""):match("^%s*(.-)%s*$")
		for _, color in ipairs(Haki.Names) do if name:lower() == color:lower() then return color end end
	end

	function Haki.Read(force)
		if not force and Haki.Owned and os.clock() - (Haki.ReadAt or 0) < 1 then return Haki.Owned end
		if not itemService then
			itemService = require(ReplicatedStorage:WaitForChild("ItemReplicationService"))
			itemConfig = require(ReplicatedStorage:WaitForChild("ItemConfig"))
		end
		local items = itemService:GetItems(itemService.KEYS.IS_OWNED)
		assert(type(items) == "table", "Aura ownership inventory is unavailable")
		local owned = {}
		for _, item in pairs(items) do
			if item.Value == true then
				local config = itemConfig.match(item.ItemId)
				if type(config.asNullable) == "function" then config = config:asNullable()
				elseif type(config.unwrap) == "function" then config = config:unwrap() end
				if type(config) == "table" then
					local index, display = config.Index or {}, config.Display or {}
					if index.IdType == "Skin" and config.Skin and config.Skin.Type == "Aura" then
						local name = Haki.Canonical(index.StorageKey) or Haki.Canonical(display.Name)
						if name then owned[name] = true end
					end
				end
			end
		end
		Haki.Owned, Haki.ReadAt = owned, os.clock()
		return owned
	end

	function Haki.ReadCrafting(force)
		if not force and Haki.Crafting and os.clock() - (Haki.CraftingAt or 0) < 5 then return Haki.Crafting end
		Haki.JuiceRemote = Haki.JuiceRemote or require(ReplicatedStorage.Modules.Net):RemoteFunction("JuiceNetworkRF")
		local snapshot = Haki.JuiceRemote:InvokeServer({ Context = "GetRecipesAndMaterials" })
		assert(type(snapshot) == "table" and type(snapshot.Recipes) == "table"
			and type(snapshot.Materials) == "table", "Aura recipe/material inventory is unavailable")
		Haki.Crafting, Haki.CraftingAt = snapshot, os.clock()
		return snapshot
	end

	function Haki.Acquired(force)
		local owned, crafting = Haki.Read(force), Haki.ReadCrafting(force)
		local acquired = {}
		for _, name in ipairs(Haki.Names) do acquired[name] = owned[name] or crafting.Recipes[name] == true end
		return acquired
	end

	function Haki.NeedBerry(name, crafting)
		local recipe = require(ReplicatedStorage.Definitions.Skin.Recipe).match(name, "Skin"):unwrap()
		for id, amount in pairs(recipe.Ingredients) do
			local material = itemConfig.match(id):unwrap().Index.StorageKey
			local count = tonumber(crafting.Materials[material]) or 0
			if count < amount then return material, amount, count end
		end
	end

	function Haki.SelectColor(owned, crafting)
		local target = Haki.Canonical(Haki.Target)
		if target and not owned[target] and crafting.Recipes[target] == true then return target end
		local choices = {}
		for _, name in ipairs(Haki.Names) do
			if not owned[name] and crafting.Recipes[name] == true then choices[#choices + 1] = name end
		end
		Haki.Cancel(); cancelMovement()
		Haki.Target = #choices > 0 and choices[math.random(#choices)] or nil
		env.__CyborgCodexHakiTarget = Haki.Target
		Haki.BerryTarget, Haki.EmptySince, Haki.NextHop = nil, nil, nil
		return Haki.Target
	end

	function Haki.FindCraftNPC()
		local root = getRoot()
		local holder = workspace:FindFirstChild("NPCs")
		if not root or not holder then return end
		local closest, distance
		for _, npc in ipairs(holder:GetChildren()) do
			if npc.Name == "Barista" and npc:IsA("Model") and npc:GetAttribute("NPCLoaded") == true then
				local part = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
				if part then
					local d = (root.Position - part.Position).Magnitude
					if not distance or d < distance then closest, distance = npc, d end
				end
			end
		end
		return closest
	end

	function Haki.ApproachCrafter()
		local root, npc = getRoot(), Haki.FindCraftNPC()
		if not root then return false end
		if npc then
			local part = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
			if (root.Position - part.Position).Magnitude < 15 then return true end
			Haki.SetStatus("Approaching Barista to craft " .. Haki.Target)
			moveTo(part.CFrame * CFrame.new(0, 0, 5))
			return false
		end
		local position, distance
		for _, bar in ipairs(CollectionService:GetTagged("JuiceBar")) do
			local stand = bar:FindFirstChild("StandPart")
			if stand and stand:IsA("BasePart") then
				local d = (root.Position - stand.Position).Magnitude
				if not distance or d < distance then position, distance = stand.CFrame, d end
			end
		end
		Haki.SetStatus(position and ("Approaching JuiceBar / waiting for Barista: " .. Haki.Target)
			or "Waiting for Barista / JuiceBar to load")
		if position then moveTo(position + Vector3.new(0, 3, 0)) end
		return false
	end

	function Haki.Craft(owned, crafting)
		local name = Haki.SelectColor(owned, crafting)
		if not name or Haki.NeedBerry(name, crafting) then return false end
		Haki.Cancel(); Haki.BerryTarget = nil
		if os.clock() < (Haki.NextCraft or 0) or not workflowActive("Haki") then return true end
		if not Haki.ApproachCrafter() then return true end
		cleanupMovement()
		local latest = Haki.ReadCrafting(true)
		if not workflowActive("Haki") or Haki.Read(true)[name] or Haki.NeedBerry(name, latest) then return true end
		local root, npc = getRoot(), Haki.FindCraftNPC()
		local part = npc and (npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart)
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if not root or not part or not humanoid or humanoid.Health <= 0
			or (root.Position - part.Position).Magnitude >= 15 then return true end
		Haki.NextCraft = os.clock() + 15
		Haki.SetStatus("Crafting legendary Haki: " .. name)
		local result = Haki.JuiceRemote:InvokeServer({ Context = "Craft", StorageName = name })
		print("[Teddy Hub][Haki] Craft response: " .. tostring(result))
		Haki.ReadAt, Haki.CraftingAt = -math.huge, -math.huge
		if result then Haki.ConfirmUntil = os.clock() + 35
		else Haki.SetStatus("Craft rejected: " .. name .. "; retrying in 15 seconds") end
		return true
	end

	function Haki.BerryPosition(bush, slot, berry)
		local model = bush and bush.Parent
		if not model or bush:GetAttribute(slot) ~= berry then return end
		local origin, offset = model:GetAttribute("CFrame"), model:GetAttribute(slot)
		if typeof(origin) == "CFrame" and typeof(offset) == "CFrame" then return origin:ToWorldSpace(offset) end
	end

	function Haki.FindBerry(berry)
		local root = getRoot()
		if not root then return end
		local best, distance
		for _, bush in ipairs(CollectionService:GetTagged("BerryBush")) do
			for slot, value in pairs(bush:GetAttributes()) do
				if value == berry and slot:match("^_BerryCFrame%d+$") then
					local ignored = Haki.BerryIgnored[bush]
					local position = Haki.BerryPosition(bush, slot, berry)
					if position and (not ignored or os.clock() >= (ignored[slot] or 0)) then
						local d = (root.Position - position.Position).Magnitude
						if not distance or d < distance then
							best, distance = { Bush = bush, Slot = slot, Berry = berry, Position = position, Attempts = 0 }, d
						end
					end
				end
			end
		end
		return best
	end

	function Haki.CollectBerry(owned, crafting)
		local name = Haki.SelectColor(owned, crafting)
		if not name then return end
		local berry, required, count = Haki.NeedBerry(name, crafting)
		if not berry then Haki.Craft(owned, crafting); return end
		local target = Haki.BerryTarget
		if target and (target.Berry ~= berry or not Haki.BerryPosition(target.Bush, target.Slot, berry)) then
			cancelMovement(); Haki.BerryTarget = nil; target = nil
		end
		if not target then target = Haki.FindBerry(berry); Haki.BerryTarget = target end
		if not target then
			Haki.EmptySince = Haki.EmptySince or os.clock()
			cancelMovement()
			if os.clock() - Haki.EmptySince < 5 then Haki.SetStatus("No " .. berry .. " found; waiting for replication before API hop"); return end
			cancelMovement(); Haki.Hop("berry", berry); return
		end
		if Haki.Request then Haki.Cancel() end
		Haki.EmptySince = nil
		Haki.SetStatus("Collecting " .. berry .. " " .. count .. "/" .. required .. " for " .. name)
		if not moveTo(target.Position + Vector3.new(0, 2, 0)) then return end
		if os.clock() < (Haki.NextClaim or 0) or not workflowActive("Haki") then return end
		local position = Haki.BerryPosition(target.Bush, target.Slot, berry)
		if not position or (getRoot().Position - position.Position).Magnitude > 15 then return end
		Haki.NextClaim = os.clock() + 0.5
		Haki.ClaimRemote = Haki.ClaimRemote or require(ReplicatedStorage.Modules.Net):RemoteFunction("ClaimBerry")
		local result = Haki.ClaimRemote:InvokeServer(target.Bush.Parent.Name, target.Slot)
		Haki.CraftingAt = -math.huge
		target.Attempts += 1
		if result or target.Attempts >= 3 then
			local ignored = Haki.BerryIgnored[target.Bush] or {}
			Haki.BerryIgnored[target.Bush] = ignored
			ignored[target.Slot] = os.clock() + (result and 5 or 60)
			Haki.BerryTarget = nil
			if not result then print("[Teddy Hub][Haki] Berry claim rejected: " .. berry .. "; skipping slot temporarily") end
		end
	end

	function Haki.Complete(owned)
		for _, name in ipairs(Haki.Names) do if not owned[name] then return false end end
		return true
	end

	function Haki.Cancel()
		Haki.Epoch += 1
		if Haki.Request then state.HopPending = false end
		Haki.Request = nil
	end

	function Haki.CanHop(request)
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		local fragments = player.Data:FindFirstChild("Fragments")
		return workflowActive("Haki") and Haki.Request == request and Haki.Epoch == request.Epoch
			and (request.Slug ~= "berry" or Haki.Target == request.Target)
			and game.PlaceId == request.PlaceId and humanoid and humanoid.Health > 0
			and fragments and fragments.Value >= Haki.Price and not BossFarm.HasProtectedItem() and not hasItem("Holy Torch")
	end

	function Haki.Hop(slug, berry)
		slug = slug or "haki"
		if Haki.Request then
			if os.clock() - Haki.Request.Started >= BossFarm.TeleportTimeout then
				Haki.Cancel(); Haki.NextHop = os.clock() + BossFarm.RetrySeconds
				Haki.SetStatus("Haki API/teleport timed out; retrying")
			end
			return
		end
		if os.clock() < (Haki.NextHop or 0) then return end
		if BossFarm.HasProtectedItem() or hasItem("Holy Torch") then Haki.SetStatus("Hop paused: carrying a protected item"); return end
		local request = { Epoch = Haki.Epoch, PlaceId = game.PlaceId, Started = os.clock(),
			Slug = slug, Berry = berry, Target = Haki.Target }
		Haki.Request = request; state.HopPending = true
		Haki.SetStatus(slug == "berry" and ("Searching Berry API: " .. berry) or "Searching Haki API for missing legendary colors")
		task.spawn(function()
			local ok, message = xpcall(function()
				local servers = BossFarm.FetchServers(slug)
				if not Haki.CanHop(request) then return "Haki search cancelled" end
				local owned = Haki.Acquired(true)
				local candidates, aliases = {}, {}
				if slug == "berry" then
					aliases = { berry, "Berry: " .. berry }
					for _, server in ipairs(servers) do
						local name = type(server) == "table" and type(server.name) == "string" and
							server.name:gsub("^[Bb][Ee][Rr][Rr][Yy]%s*:%s*", ""):match("^%s*(.-)%s*$")
						if name and name:lower() == berry:lower() then candidates[#candidates + 1] = server end
					end
				else
					for _, name in ipairs(Haki.Names) do
						if not owned[name] then aliases[#aliases + 1] = name; aliases[#aliases + 1] = "Haki: " .. name end
					end
					for _, server in ipairs(servers) do
						local name = type(server) == "table" and Haki.Canonical(server.name)
						if name and not owned[name] then candidates[#candidates + 1] = server end
					end
				end
				local job = BossFarm.SelectServer(candidates, { Slug = slug, Names = aliases })
				if not job then return "No matching " .. slug .. " API server; retrying" end
				if not Haki.CanHop(request) then return "Haki search cancelled" end
				if slug == "berry" then
					if Haki.Read(true)[request.Target] or Haki.NeedBerry(request.Target, Haki.ReadCrafting(true)) ~= berry then
						return "Berry requirement already met; staying to craft"
					end
					if Haki.FindBerry(berry) then return "Matching berry found in current server; staying" end
				else
					owned = Haki.Acquired(true)
					if Haki.Complete(owned) then return "All legendary recipes already learned" end
					local dealer = Haki.Canonical(invokeCommF("ColorsDealer", "1"))
					if dealer and not owned[dealer] then return "Missing recipe found in current server; staying" end
				end
				if not Haki.CanHop(request) then return "Haki search cancelled" end
				local browser = ReplicatedStorage:FindFirstChild("__ServerBrowser")
				assert(browser and browser:IsA("RemoteFunction"), "Server browser is unavailable")
				queueResume()
				if not Haki.CanHop(request) then return "Haki search cancelled" end
				state.BossVisited[job] = os.time(); state.BossVisited[game.JobId] = os.time()
				request.Teleport = true; request.Started = os.clock()
				Haki.SetStatus(slug == "berry" and ("Hopping for " .. berry .. " / " .. request.Target) or "Hopping to a missing legendary Haki recipe")
				assert(browser:InvokeServer("teleport", job) ~= false, "Haki server teleport was rejected")
			end, debug.traceback)
			if state.Generation ~= generation or Haki.Request ~= request then return end
			if ok and request.Teleport then return end
			Haki.Request = nil; state.HopPending = false; Haki.NextHop = os.clock() + BossFarm.RetrySeconds
			Haki.SetStatus(ok and (message or "Haki search cancelled") or "Haki API error; see console")
			if not ok then reportControllerError(message, "Haki", "APIHop") end
		end)
	end

	Haki.Step = LPH_JIT(function()
		if not workflowActive("Haki") then return end
		local owned = Haki.Read()
		if Haki.Complete(owned) then
			Haki.Cancel(); cancelMovement(); Haki.Target = nil; env.__CyborgCodexHakiTarget = nil
			Haki.Completed = true; Haki.SetStatus("Completed: Pure Red, Winter Sky, Snow White owned"); return
		end
		if os.clock() < (Haki.ConfirmUntil or 0) then Haki.SetStatus("Waiting for Haki inventory confirmation"); return end
		local fragments = player.Data:FindFirstChild("Fragments")
		if not fragments then Haki.SetStatus("Waiting for fragment data"); return end
		if fragments.Value < Haki.Price then
			Haki.Cancel(); env.autohakilegendary = false
			Haki.SetStatus("Stopped: insufficient fragments (need 7500)")
			notify("Auto Haki Legendary stopped: not enough fragments (need 7500).", "haki-fragments", 5); return
		end
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if not getRoot() or not humanoid or humanoid.Health <= 0 then Haki.Cancel(); Haki.SetStatus("Waiting for character"); return end
		if currentSea() == 1 then Haki.SetStatus("Traveling to Sea 2 for Legendary Haki"); travelToSea2(); return end
		if currentSea() ~= 2 and currentSea() ~= 3 then Haki.SetStatus("Unsupported sea for Haki dealer"); return end
		local crafting = Haki.ReadCrafting()
		if not workflowActive("Haki") then return end
		if Haki.Complete(Haki.Acquired()) then Haki.CollectBerry(owned, crafting); return end
		if os.clock() - (Haki.DealerAt or -math.huge) >= 2 then
			Haki.Dealer = Haki.Canonical(invokeCommF("ColorsDealer", "1")); Haki.DealerAt = os.clock()
		end
		if not workflowActive("Haki") then return end
		if Haki.Dealer and not owned[Haki.Dealer] and crafting.Recipes[Haki.Dealer] ~= true then
			Haki.Cancel()
			if os.clock() - (Haki.LastBuy or -math.huge) < 5 then return end
			local offered = Haki.Canonical(invokeCommF("ColorsDealer", "1"))
			owned = Haki.Acquired(true)
			if not workflowActive("Haki") or not offered or owned[offered] or fragments.Value < Haki.Price then return end
			Haki.LastBuy = os.clock(); Haki.SetStatus("Buying legendary Haki recipe: " .. offered)
			local result = invokeCommF("ColorsDealer", "2")
			print("[Teddy Hub][Haki] Buy response: " .. tostring(result))
			Haki.ReadAt = -math.huge; Haki.CraftingAt = -math.huge; Haki.DealerAt = -math.huge
			if result == 1 or result == 2 then
				Haki.ReadCrafting(true)
				Haki.SetStatus(result == 2 and ("Recipe already learned: " .. offered) or ("Recipe learned: " .. offered))
			elseif result == 0 then
				Haki.SetStatus("Recipe purchase rejected: insufficient currency")
			else
				Haki.SetStatus("Dealer offer unavailable; checking again")
			end
			return
		end
		Haki.Hop()
	end)
end

local function soulGuitarOwned(counts)
	if state.SoulGuitarOwned or hasItem("Skull Guitar") or hasItem("Soul Guitar")
		or (counts["Skull Guitar"] or 0) > 0 or (counts["Soul Guitar"] or 0) > 0 then
		state.SoulGuitarOwned = true
		return true
	end
	if os.clock() - (state.LastRemote.SoulOwnership or -math.huge) >= 5 then
		state.LastRemote.SoulOwnership = os.clock()
		state.LastSoulBuyCheck = invokeCommF("soulGuitarBuy", true)
		state.SoulGuitarOwned = state.LastSoulBuyCheck == "[You already own this item.]"
	end
	return state.SoulGuitarOwned == true
end

local function puzzleComplete(progress)
	if type(progress) ~= "table" then return false end
	for _, stage in ipairs(PuzzleStages) do
		if progress[stage] ~= true then return false end
	end
	return true
end

local function soulGuitarPlan(owned, counts, progress, fragments)
	if owned then return "owned" end
	if (counts["Dark Fragment"] or 0) < 1 then return "dark-fragment" end
	if (counts.Ectoplasm or 0) < 250 then return "ectoplasm" end
	if (counts.Bones or 0) < 500 then return "bones" end
	if not puzzleComplete(progress) then return "puzzle" end
	if fragments < Config.MinSoulGuitarFragments then return "fragments" end
	return "buy"
end

local function getPuzzleProgress(force)
	if not force and state.PuzzleReadAt and os.clock() - state.PuzzleReadAt < 1 then
		return state.PuzzleProgress
	end
	local progress = invokeCommF("GuitarPuzzleProgress", "Check")
	assert(progress == nil or progress == false or type(progress) == "table", "Unexpected GuitarPuzzleProgress Check response")
	state.PuzzleProgress = progress
	state.PuzzleReadAt = os.clock()
	return progress
end

local function farmMaterial(name)
	local recipe = MaterialTargets[name]
	if recipe.Sea == 2 and not travelToSea2() then return end
	if recipe.Sea == 3 and not travelToSea3() then return end
	setStage("farm " .. name)
	local mob = findMob(recipe.Names)
	if mob then fightMob(mob); return end
	stopFastAttack()
	local now = os.clock()
	if state.MaterialName ~= name then
		state.MaterialName, state.MaterialSpawnIndex, state.MaterialSpawnAt = name, 1, now
	elseif now - state.MaterialSpawnAt > 12 then
		state.MaterialSpawnIndex = state.MaterialSpawnIndex % #recipe.Spawns + 1
		state.MaterialSpawnAt = now
	end
	moveTo(recipe.Spawns[state.MaterialSpawnIndex] * CFrame.new(0, 20, 0))
end

do
	function Ghoul.Owned()
		local data = player:FindFirstChild("Data")
		local race = data and data:FindFirstChild("Race")
		return race ~= nil and race.Value == "Ghoul"
	end

	function Ghoul.Trace(phase)
		if state.GhoulPhase == phase then return end
		state.GhoulPhase = phase
	end

	function Ghoul.CharacterReady()
		if not workflowActive("Ghoul") then return false end
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if getRoot() and humanoid and humanoid.Health > 0 then return true end
		BossFarm.Cancel()
		Ghoul.Trace("WaitCharacter")
		Ghoul.SetStatus("Waiting for character")
		return false
	end

	function Ghoul.ReadEctoplasm(force)
		Ghoul.Trace("ReadEctoplasm")
		local counts = inventoryCounts(force)
		if not Ghoul.CharacterReady() then return nil end
		local count = counts.Ectoplasm or 0
		assert(type(count) == "number" and count >= 0, "Ectoplasm quantity is invalid")
		state.GhoulCount = count
		return count
	end

	function Ghoul.FarmEctoplasm()
		if not Ghoul.CharacterReady() then return end
		Ghoul.Trace("FarmEctoplasm")
		if state.BossRequest then BossFarm.Cancel() end
		farmMaterial("Ectoplasm")
		Ghoul.SetStatus("Farming Ectoplasm " .. state.GhoulCount .. "/" .. Config.GhoulEctoplasmTarget)
	end

	function Ghoul.SetStatus(message)
		if state.GhoulStatus == message then return end
		state.GhoulStatus = message
		log("Ghoul: " .. message)
		if Ghoul.StatusChanged then
			local ok, err = xpcall(function() Ghoul.StatusChanged(message) end, debug.traceback)
			if not ok then reportControllerError(err, "Ghoul", "UIStatus") end
		end
	end

	function Ghoul.Complete()
		Ghoul.Trace("Completed")
		env.autoghoulrace = false
		BossFarm.Cancel()
		stopFastAttack()
		cleanupMovement()
		Ghoul.SetStatus("Ghoul Race acquired")
		notify("Ghoul Race acquired; workflow stopped.", "ghoul-owned", 5)
	end

	function Ghoul.HopAllowed()
		return workflowActive("Ghoul") and env.autofarmboss ~= true and not Ghoul.Owned() and not hasItem("Hellfire Torch")
			and (state.GhoulCount or 0) >= Config.GhoulEctoplasmTarget
			and os.clock() >= (state.GhoulRewardUntil or 0)
	end

	function Ghoul.CheckUnlocked()
		Ghoul.Trace("CheckUnlock")
		if os.clock() - (state.LastRemote.GhoulCheck or -math.huge) < 5 then return end
		local result = invokeCommF("Ectoplasm", "BuyCheck", 4)
		if not Ghoul.CharacterReady() then return end
		state.LastRemote.GhoulCheck = os.clock()
		if state.GhoulCheckResult ~= result then log("Ghoul BuyCheck response: " .. tostring(result)) end
		state.GhoulCheckResult = result
		state.GhoulUnlocked = result == 1
	end

	function Ghoul.Exchange(action)
		if not Ghoul.CharacterReady() then return end
		Ghoul.Trace("TravelToGhoulNPC")
		stopFastAttack()
		if state.BossRequest then BossFarm.Cancel() end
		Ghoul.SetStatus(action == "Change" and "Changing back to unlocked Ghoul Race" or "Exchanging Hellfire Torch for Ghoul Race")
		if not moveTo(Ghoul.NPC) then return end
		cleanupMovement()
		if os.clock() - (state.LastRemote.GhoulExchange or -math.huge) < 5 then return end
		local root = getRoot()
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not workflowActive("Ghoul") or not root or not humanoid or humanoid.Health <= 0
			or (root.Position - Ghoul.NPC.Position).Magnitude > 8 then return end
		if action == "Buy" then
			local count = Ghoul.ReadEctoplasm(true)
			if not count or not hasItem("Hellfire Torch") or count < Config.GhoulEctoplasmTarget then return end
		end
		if getRoot() ~= root or humanoid.Health <= 0 or (root.Position - Ghoul.NPC.Position).Magnitude > 8 then return end
		state.LastRemote.GhoulExchange = os.clock()
		Ghoul.Trace(action == "Buy" and "BuyGhoul" or "ChangeGhoul")
		local result = invokeCommF("Ectoplasm", action, 4)
		if not workflowActive("Ghoul") then return end
		state.InventoryReadAt = -math.huge
		if action == "Change" then state.GhoulChangeAttempted = true end
		state.GhoulExchangeAwaiting = os.clock() + 5
		log("Ghoul " .. action .. " response: " .. tostring(result))
		if Ghoul.Owned() then Ghoul.Complete() else Ghoul.SetStatus("Waiting for race confirmation / exchange retry") end
	end

	Ghoul.Step = LPH_JIT(function()
		if not workflowActive("Ghoul") then return end
		Ghoul.Trace("CheckRace")
		if Ghoul.Owned() then Ghoul.Complete(); return end
		if not Ghoul.CharacterReady() then return end
		if os.clock() < (state.GhoulExchangeAwaiting or 0) then
			Ghoul.Trace("ConfirmRace")
			stopFastAttack()
			cleanupMovement()
			Ghoul.SetStatus("Waiting for race confirmation")
			return
		end
		Ghoul.Trace("TravelSea2")
		if not travelToSea2() then return end
		Ghoul.CheckUnlocked()
		if not Ghoul.CharacterReady() then return end
		if Ghoul.Owned() then Ghoul.Complete(); return end
		if state.GhoulUnlocked and not hasItem("Hellfire Torch") and not state.GhoulChangeAttempted then
			Ghoul.Exchange("Change")
			return
		end
		local count = Ghoul.ReadEctoplasm()
		if not count then return end
		if count < Config.GhoulEctoplasmTarget then Ghoul.FarmEctoplasm(); return end
		if hasItem("Hellfire Torch") then Ghoul.Exchange("Buy"); return end
		Ghoul.FindTorch()
	end)

	function Ghoul.FindTorch()
		if not Ghoul.CharacterReady() then return end
		Ghoul.Trace("FindCaptain")
		local definition = BossFarm.Definitions["Cursed Captain"]
		local boss = BossFarm.FindActive(definition)
		if boss then
			if state.BossRequest then BossFarm.Cancel() end
			state.BossMissingSince = nil
			state.GhoulTarget = boss
			Ghoul.Trace("FightCaptain")
			Ghoul.SetStatus("Fighting Cursed Captain for Hellfire Torch")
			fightMob(boss)
			return
		end
		stopFastAttack()
		if state.GhoulTarget then
			state.GhoulTarget = nil
			state.GhoulRewardUntil = os.clock() + Ghoul.RewardGrace
			state.InventoryReadAt = -math.huge
		end
		if os.clock() < (state.GhoulRewardUntil or 0) then
			Ghoul.Trace("WaitDrops")
			cleanupMovement()
			Ghoul.SetStatus("Waiting for Cursed Captain drops")
			return
		end
		local hint = BossFarm.FindIn(ReplicatedStorage, definition)
		if hint then
			if state.BossRequest then BossFarm.Cancel() end
			state.BossMissingSince = nil
			Ghoul.Trace("WaitCaptainReplication")
			Ghoul.SetStatus("Approaching Cursed Captain / waiting for replication")
			moveTo(uprightCFrame(hint.HumanoidRootPart.CFrame) * CFrame.new(Config.OrderOffset))
			return
		end
		cleanupMovement()
		state.BossMissingSince = state.BossMissingSince or os.clock()
		if os.clock() - state.BossMissingSince < BossFarm.MissingGrace then
			Ghoul.Trace("CheckCaptainSpawn")
			Ghoul.SetStatus("Checking Cursed Captain spawn (" .. math.ceil(BossFarm.MissingGrace - (os.clock() - state.BossMissingSince)) .. "s)")
			return
		end
		if BossFarm.HasProtectedItem() then
			BossFarm.Cancel()
			Ghoul.SetStatus("Hop paused: carrying a protected item")
			return
		end
		local pending = state.BossRequest
		if pending then
			Ghoul.Trace(pending.Phase == "Teleport" and "APITeleport" or "APISearch")
			if os.clock() - pending.StartedAt >= BossFarm.TeleportTimeout then
				state.BossRequest = nil
				state.HopPending = false
				state.BossNextHopAt = os.clock() + BossFarm.RetrySeconds
				Ghoul.SetStatus("API / teleport timed out; waiting to retry")
			end
			return
		end
		if os.clock() < (state.BossNextHopAt or 0) then Ghoul.SetStatus(state.BossHopMessage or "Waiting for API retry"); return end
		Ghoul.Trace("APISearch")
		BossFarm.BeginHop(definition, "Ghoul")
	end
end

local function getDarkFragment()
	if not travelToSea2() then return end
	local boss = findMob({ "Darkbeard" })
	if boss then
		state.DarkbeardTarget = boss
		state.DarkbeardSummonUntil = nil
		setStage("fight Darkbeard for Dark Fragment")
		fightMob(boss)
		return
	end
	stopFastAttack()
	if state.DarkbeardTarget then
		state.DarkbeardTarget = nil
		state.DarkbeardSummonUntil = os.clock() + 3
		state.InventoryReadAt = -math.huge
	end
	if state.DarkbeardSummonUntil and os.clock() < state.DarkbeardSummonUntil then
		setStage("wait for Darkbeard summon/reward")
		cleanupMovement()
		return
	end
	if hasItem("Fist of Darkness") then
		setStage("summon Darkbeard with Fist of Darkness")
		local map = workspace:FindFirstChild("Map")
		local arena = map and map:FindFirstChild("DarkbeardArena")
		local summoner = arena and arena:FindFirstChild("Summoner")
		local detection = summoner and summoner:FindFirstChild("Detection")
		if not detection then
			moveTo(CFrame.new(3777.22266, 13.319315, -3496.96118))
			notify("Waiting for DarkbeardArena.Summoner.Detection to load.", "darkbeard-map", 5)
			return
		end
		if not moveTo(detection.CFrame) then return end
		if os.clock() - (state.LastRemote.DarkbeardSummon or 0) < 3 then return end
		assert(equipItem("Fist of Darkness"), "Cannot equip Fist of Darkness for Darkbeard")
		task.wait(0.3)
		if not workflowActive("SoulGuitar") then return end
		local character = player.Character
		local tool = character and character:FindFirstChild("Fist of Darkness")
		local handle = tool and tool:FindFirstChild("Handle")
		local root = getRoot()
		assert(handle and root, "Fist of Darkness Handle or character root is unavailable")
		local touch = env.firetouchinterest or _G.firetouchinterest
		assert(type(touch) == "function", "Executor firetouchinterest is unavailable")
		state.LastRemote.DarkbeardSummon = os.clock()
		for _, part in ipairs({ handle, root }) do
			if not workflowActive("SoulGuitar") then return end
			touch(part, detection, 0)
			touch(part, detection, 1)
		end
		state.DarkbeardSummonUntil = os.clock() + 10
		state.InventoryReadAt = -math.huge
		return
	end
	setStage("Soul Guitar: collect chests for Fist of Darkness")
	collectChest()
end

local function fullMoonNight()
	local lighting = game:GetService("Lighting")
	local sky = lighting:FindFirstChildOfClass("Sky")
	local full = lighting:GetAttribute("MoonPhase") == 5
		or (sky and sky.MoonTextureId == "http://www.roblox.com/asset/?id=9709149431")
	return full and (lighting.ClockTime > 16 or lighting.ClockTime < 5)
end

local function puzzleClick(part)
	assert(part, "Required Haunted Castle puzzle part is unavailable")
	local key = part:GetFullName()
	state.LastPuzzleClick = state.LastPuzzleClick or {}
	if os.clock() - (state.LastPuzzleClick[key] or 0) < 0.75 then return end
	if not workflowActive("SoulGuitar") then return end
	clickPart(part)
	state.LastPuzzleClick[key] = os.clock()
	state.PuzzleReadAt = -math.huge
end

local function swampPuzzle()
	local enemies = workspace:FindFirstChild("Enemies")
	local root = getRoot()
	if not enemies or not root then return end
	local swamp = PuzzlePositions.Swamp
	if (root.Position - swamp.Position).Magnitude > 50 then
		stopFastAttack()
		moveTo(swamp * CFrame.new(0, 20, 0))
		return
	end
	local zombies = {}
	for _, mob in ipairs(enemies:GetChildren()) do
		if isAlive(mob) and cleanMobName(mob.Name) == "Living Zombie"
			and (mob.HumanoidRootPart.Position - swamp.Position).Magnitude < 500 then
			zombies[#zombies + 1] = mob
		end
	end
	if #zombies < 6 then
		stopFastAttack()
		cleanupMovement()
		notify("Swamp puzzle: waiting for six living zombies before attacking.", "swamp-zombies", 5)
		return
	end
	local characters = workspace:FindFirstChild("Characters")
	if characters then
		for _, other in ipairs(characters:GetChildren()) do
			local otherRoot = other ~= player.Character and other:FindFirstChild("HumanoidRootPart")
			if otherRoot and (otherRoot.Position - swamp.Position).Magnitude <= 300 then
				stopFastAttack()
				notify("Swamp puzzle: another player is near the zombie group; waiting.", "swamp-authority", 5)
				return
			end
		end
	end
	if state.ZombieBatch then
		local valid = true
		for _, mob in ipairs(state.ZombieBatch) do if not isAlive(mob) then valid = false; break end end
		if not valid then stopFastAttack(); return end
		zombies = state.ZombieBatch
	else
		table.sort(zombies, function(a, b) return a.Humanoid.Health > b.Humanoid.Health end)
		while #zombies > 6 do table.remove(zombies) end
		state.ZombieBatch = zombies
	end
	state.PuzzleCollision = state.PuzzleCollision or setmetatable({}, { __mode = "k" })
	for _, mob in ipairs(zombies) do
		for _, part in ipairs(mob:GetDescendants()) do
			if part:IsA("BasePart") then
				if state.PuzzleCollision[part] == nil then state.PuzzleCollision[part] = part.CanCollide end
				part.CanCollide = false
			end
		end
		mob.HumanoidRootPart.CFrame = swamp * CFrame.new(0, 1, 1)
	end
	state.FastAttackTargets = zombies
	fightMob(zombies[1])
end

local function guitarPuzzleStep(progress)
	if not progress then
		stopFastAttack()
		if not fullMoonNight() then
			cleanupMovement()
			setStage("Soul Guitar: wait for full moon at night")
			notify("Soul Guitar puzzle needs a full moon at night; searching another server.", "soul-moon", 5)
			teleportToNewServer("moon")
			return
		end
		setStage("start Soul Guitar gravestone event")
		if not moveTo(PuzzlePositions.Grave) then return end
		if os.clock() - (state.LastRemote.GravestoneStart or 0) >= 5 and workflowActive("SoulGuitar") then
			state.LastRemote.GravestoneStart = os.clock()
			invokeCommF("gravestoneEvent", 2)
			if not workflowActive("SoulGuitar") then return end
			invokeCommF("gravestoneEvent", 2, true)
			state.PuzzleReadAt = -math.huge
		end
		return
	end
	local stage
	for _, name in ipairs(PuzzleStages) do
		if progress[name] ~= true then stage = name; break end
	end
	if not stage then return end
	setStage("Soul Guitar puzzle: " .. stage)
	if stage == "Swamp" then swampPuzzle(); return end
	stopFastAttack()
	local destination = PuzzlePositions[stage] or PuzzlePositions.Lab
	if not moveTo(destination) then return end
	if os.clock() - (state.LastRemote.PuzzleAdvance or 0) >= 3 and workflowActive("SoulGuitar") then
		state.LastRemote.PuzzleAdvance = os.clock()
		invokeCommF("GuitarPuzzleProgress", stage)
		state.PuzzleReadAt = -math.huge
		local updated = getPuzzleProgress(true)
		if not workflowActive("SoulGuitar") or (updated and updated[stage] == true) then return end
	end
	if stage == "Ghost" then return end
	local map = workspace:FindFirstChild("Map")
	local castle = map and map:FindFirstChild("Haunted Castle")
	assert(castle, "Map.Haunted Castle has not loaded at the puzzle location")
	if stage == "Gravestones" then
		local sides = { "Right", "Right", "Left", "Right", "Left", "Left", "Left" }
		state.PlacardIndex = state.PlacardIndex or 1
		local index = state.PlacardIndex
		local placard = castle:FindFirstChild("Placard" .. index)
		puzzleClick(placard and placard:FindFirstChild(sides[index]))
		state.PlacardIndex = index % #sides + 1
	elseif stage == "Trophies" then
		local tablet = castle:FindFirstChild("Tablet")
		assert(tablet, "Haunted Castle Tablet is unavailable")
		for _, name in ipairs(BlankTablets) do
			local segment = tablet:FindFirstChild(name)
			local line = segment and segment:FindFirstChild("Line")
			assert(line, "Blank tablet Line is unavailable: " .. name)
			if math.abs(line.Position.X + 9707.86328125) > 0.05 then puzzleClick(segment); return end
		end
		local trophies = castle:FindFirstChild("Trophies")
		local quest = trophies and trophies:FindFirstChild("Quest")
		assert(quest, "Haunted Castle Trophies.Quest is unavailable")
		for segmentName, trophyName in pairs(TrophyTablets) do
			local trophy = quest:FindFirstChild(trophyName)
			local handle = trophy and trophy:FindFirstChild("Handle")
			local segment = tablet:FindFirstChild(segmentName)
			local line = segment and segment:FindFirstChild("Line")
			assert(handle and line, "Trophy handle/tablet Line is unavailable: " .. trophyName)
			local _, _, _, r00 = handle.CFrame:GetComponents()
			local expected = math.abs(r00) > 0.9 and 90 or 0
			local angle = line.Rotation.Z % 180
			if math.abs(angle - expected) > 0.1 then puzzleClick(segment); return end
		end
	elseif stage == "Pipes" then
		local lab = castle:FindFirstChild("Lab Puzzle")
		local floor = lab and lab:FindFirstChild("ColorFloor")
		local model = floor and floor:FindFirstChild("Model")
		assert(model, "Haunted Castle Lab Puzzle.ColorFloor.Model is unavailable")
		for name, color in pairs(PipeColors) do
			local tile = model:FindFirstChild(name)
			assert(tile, "Pipe floor tile is unavailable: " .. name)
			if tile.BrickColor.Name ~= color then puzzleClick(tile); return end
		end
	end
end

local runStep = LPH_JIT(function()
	if state.Busy or not workflowActive("Cyborg") then return end
	if state.HopPending then
		if os.clock() - (state.LastRemote.Hop or 0) < 20 then return end
		state.HopPending = false
	end
	if os.clock() < state.NextAction then return end
	state.NextAction = os.clock() + Config.ActionDelay
	state.Busy = true
	local ok, err = xpcall(function()
		local owned, coreBrainSubmitted = checkRace()
		if not workflowActive("Cyborg") then return end
		if owned then
			state.CoreBrainSubmissionAwaiting = false
			setStage("Cyborg already owned")
			stopFastAttack()
			cleanupMovement()
			notify("Cyborg Race is already owned.", "owned", 5)
			return
		end
		if coreBrainSubmitted then
			state.CoreBrainSubmissionAwaiting = false
		end
		if state.CoreBrainSubmissionAwaiting then
			setStage("verify Core Brain submission")
			stopFastAttack()
			cleanupMovement()
			notify("Waiting for server confirmation of Core Brain submission.", "core-brain-check", 5)
			return
		end
		if coreBrainSubmitted then
			setStage("buy Cyborg Race")
			stopFastAttack()
			cleanupMovement()
			if getFragments() < Config.MinCyborgFragments then
				notify("Need at least 2500 Fragments to buy Cyborg Race.", "cyborg-fragments", 5)
				return
			end
			requestCyborgBuy()
			return
		end
		if not ensureTeam() then
			setStage("join team")
			return
		end
		if not travelToSea2() then return end
		if not (getRoot() and player.Character:FindFirstChildOfClass("Humanoid")) then return end

		local button = getRaidButton()
		if not button then return end
		if hasItem("Core Brain") then
			setStage("submit Core Brain and buy Cyborg")
			stopFastAttack()
			cleanupMovement()
			if (getRoot().Position - RaidButtonCFrame.Position).Magnitude > 14 then
				moveTo(RaidButtonCFrame)
				return
			end
			if os.clock() - (state.LastRemote.Submit or 0) >= 1 then
				if submitItem("Core Brain") then
					task.wait(0.4)
					if not hasItem("Core Brain") then
						state.CoreBrainSubmissionAwaiting = true
						state.LastRaceCheck = -math.huge
						state.LastRaceCheckOk = false
						state.LastRemote.Submit = os.clock()
						log("Core Brain consumed; waiting for CyborgTrainer Check=true.")
					else
						log("Core Brain was not consumed by RaidSummon; will retry.")
					end
				end
			end
			return
		end

		local raidUnlocked = isRaidUnlocked()
		if not workflowActive("Cyborg") then return end
		if not raidUnlocked then
			stopFastAttack()
			cleanupMovement()
			if hasItem("Fist of Darkness") then
				setStage("submit Fist of Darkness")
				if (getRoot().Position - RaidButtonCFrame.Position).Magnitude > 14 then
					moveTo(RaidButtonCFrame)
					return
				end
				if os.clock() - (state.LastRemote.Submit or 0) >= 1 and equipItem("Fist of Darkness") then
					task.wait(0.3)
					if not workflowActive("Cyborg") then return end
					interactWithRaidButton(button, true)
				end
				return
			end
			setStage("collect chests for Fist of Darkness")
			collectChest()
			return
		end

		local order = findOrder()
		if order then
			setStage("fight Order for Core Brain")
			fightOrder(order)
			return
		end
		stopFastAttack()
		cleanupMovement()
		if not hasItem("Microchip") then
			setStage("buy Law Microchip")
			buyLawChip()
			return
		end
		setStage("summon Order")
		if (getRoot().Position - RaidButtonCFrame.Position).Magnitude > 14 then
			moveTo(RaidButtonCFrame)
			return
		end
		if os.clock() - (state.LastRemote.Summon or 0) >= 5 then
			assert(equipItem("Microchip"), "Microchip could not be equipped")
			clickPart(button)
			state.LastRemote.Summon = os.clock()
		end
	end, debug.traceback)
	if state.Generation ~= generation then return end
	state.Busy = false
	if not ok then
		if os.clock() - (state.LastErrorLog or 0) >= 5 then
			state.LastErrorLog = os.clock()
			log(err)
			notify("Workflow error; see executor console.", "error", 5)
		end
	end
end)

local runSoulGuitarStep = LPH_JIT(function()
	if state.Busy or not workflowActive("SoulGuitar") then return end
	if state.HopPending then
		if os.clock() - (state.LastRemote.Hop or 0) < 20 then return end
		state.HopPending = false
	end
	if os.clock() < state.NextAction then return end
	state.NextAction = os.clock() + Config.ActionDelay
	state.Busy = true
	local ok, err = xpcall(function()
		if state.SoulGuitarOwned or hasItem("Skull Guitar") or hasItem("Soul Guitar") then
			state.SoulGuitarOwned = true
			setStage("Soul Guitar already owned")
			stopFastAttack()
			cleanupMovement()
			notify("Soul Guitar is already owned; completed.", "soul-owned", 5)
			return
		end
		local counts = inventoryCounts()
		local owned = soulGuitarOwned(counts)
		if not workflowActive("SoulGuitar") then return end
		if owned then
			setStage("Soul Guitar already owned")
			stopFastAttack()
			cleanupMovement()
			notify("Soul Guitar is already owned; completed.", "soul-owned", 5)
			return
		end
		if not ensureTeam() then setStage("join team"); return end
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not getRoot() or not humanoid or humanoid.Health <= 0 then
			stopFastAttack()
			cleanupMovement()
			return
		end
		local plan = soulGuitarPlan(false, counts, nil, getFragments())
		if plan == "dark-fragment" then getDarkFragment(); return end
		if plan == "ectoplasm" then farmMaterial("Ectoplasm"); return end
		if plan == "bones" then farmMaterial("Bones"); return end
		local data = player:FindFirstChild("Data")
		local level = data and data:FindFirstChild("Level")
		assert(level and type(level.Value) == "number", "Data.Level is unavailable")
		if level.Value < Config.MinSoulGuitarLevel then
			setStage("Soul Guitar: waiting for level 2300")
			stopFastAttack()
			cleanupMovement()
			notify("Soul Guitar puzzle requires level 2300; material farming is complete.", "soul-level", 5)
			return
		end
		if not travelToSea3() then return end
		local progress = getPuzzleProgress()
		if not workflowActive("SoulGuitar") then return end
		plan = soulGuitarPlan(false, counts, progress, getFragments())
		if plan == "puzzle" then guitarPuzzleStep(progress); return end
		stopFastAttack()
		cleanupMovement()
		if plan == "fragments" then
			setStage("Soul Guitar: waiting for 5000 Fragments")
			notify("Need at least 5000 Fragments to buy Soul Guitar.", "soul-fragments", 5)
			return
		end
		if plan == "buy" and os.clock() - (state.LastRemote.SoulBuy or 0) >= 5 then
			setStage("buy Soul Guitar")
			state.LastRemote.SoulBuy = os.clock()
			local response = invokeCommF("soulGuitarBuy")
			log("Soul Guitar buy response: " .. tostring(response))
			state.InventoryReadAt = -math.huge
			state.LastRemote.SoulOwnership = -math.huge
		end
	end, debug.traceback)
	if state.Generation ~= generation then return end
	state.Busy = false
	if not ok then
		stopFastAttack()
		cleanupMovement()
		if os.clock() - (state.LastSoulErrorLog or 0) >= 5 then
			state.LastSoulErrorLog = os.clock()
			log(err)
			notify("Soul Guitar workflow error; see executor console.", "soul-error", 5)
		end
	end
end)

assert(type(env) == "table", "getgenv() is unavailable")
assert(type(loadstring) == "function", "Executor loadstring is unavailable")
local bootstrapDeadline = os.clock() + 120
repeat
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	if remotes and remotes:FindFirstChild("CommF_") then ensureTeam() end
	if state.Generation ~= generation then return end
	if player:FindFirstChild("DataLoaded") and remotes and remotes:FindFirstChild("CommF_") then
		break
	end
	task.wait(0.5)
until os.clock() >= bootstrapDeadline
assert(player:FindFirstChild("DataLoaded"), "LocalPlayer.DataLoaded did not appear within 120 seconds")
assert(ReplicatedStorage:FindFirstChild("Remotes"), "ReplicatedStorage.Remotes is unavailable")
assert(ReplicatedStorage.Remotes:FindFirstChild("CommF_"), "ReplicatedStorage.Remotes.CommF_ is unavailable")

env.CyborgCodex = env.CyborgCodex or {}
env.CyborgCodex.Run = runStep
env.CyborgCodex.Start = function()
	env.cyborgrace = true
	log("Cyborg workflow enabled.")
end
env.CyborgCodex.Stop = function()
	env.cyborgrace = false
	if state.ActiveWorkflow == "Cyborg" then
		state.HopPending = false
		stopFastAttack()
		cleanupMovement()
	end
	log("Cyborg workflow disabled.")
end
env.SoulGuitarCodex = {
	Run = runSoulGuitarStep,
	Start = function() env.autosoulguitar = true; log("Soul Guitar workflow enabled.") end,
	Stop = function()
		env.autosoulguitar = false
		if state.ActiveWorkflow == "SoulGuitar" then
			state.HopPending = false
			stopFastAttack()
			cleanupMovement()
		end
		log("Soul Guitar workflow disabled.")
	end,
}

env.BossFarmCodex = {
	Run = BossFarm.Step,
	Start = function()
		env.autofarmboss = true
		BossFarm.Cancel()
		log("Boss farming enabled.")
	end,
	Stop = function()
		env.autofarmboss = false
		if state.ActiveWorkflow ~= "Ghoul" then BossFarm.Cancel(); BossFarm.SetStatus("Idle") end
	end,
}

env.GhoulCodex = {
	Run = Ghoul.Step,
	Start = function()
		env.autoghoulrace = true
		state.GhoulChangeAttempted = false
		state.GhoulExchangeAwaiting = nil
		state.GhoulCheckResult = nil
		state.LastRemote.GhoulCheck = nil
		Ghoul.Trace("Queued")
		Ghoul.SetStatus("Queued")
		log("Ghoul workflow enabled.")
	end,
	Stop = function()
		env.autoghoulrace = false
		if state.ActiveWorkflow == "Ghoul" then BossFarm.Cancel(); stopFastAttack(); cleanupMovement() end
		Ghoul.Trace("Stopped")
		Ghoul.SetStatus("Stopped")
		log("Ghoul workflow disabled.")
	end,
}

env.HakiCodex = {
	Run = Haki.Step,
	Start = function()
		env.autohakilegendary = true
		Haki.Cancel(); Haki.Completed = false; Haki.ReadAt = -math.huge; Haki.DealerAt = -math.huge
		Haki.CraftingAt = -math.huge
		Haki.NextHop = nil; Haki.ConfirmUntil = nil; Haki.SetStatus("Queued")
	end,
	Stop = function()
		env.autohakilegendary = false
		Haki.Cancel(); Haki.SetStatus("Stopped")
	end,
}

env.TTKCodex = {
	Run = TTK.Step,
	Start = function()
		env.autottk = true
		TTK.Cancel(); TTK.ReadAt = -math.huge; state.TTKCompleted = false
		TTK.SetStatus("Queued")
	end,
	Stop = function()
		env.autottk = false
		TTK.Cancel(); TTK.SetStatus("Stopped")
	end,
}

for name, controller in pairs(SwordGet.States) do
	local workflow, entry = name, controller
	env[name .. "Codex"] = {
		Run = function() SwordGet.Step(workflow) end,
		Start = function()
			env[entry.Flag] = true
			SwordGet.Cancel(workflow); entry.Completed = false; entry.RewardUntil = nil; entry.Target = nil
			if workflow == "Tushita" then entry.HydraReady = false end
			entry.ProgressAt = -math.huge; TTK.ReadAt = -math.huge
			SwordGet.SetStatus(workflow, "Queued")
		end,
		Stop = function()
			env[entry.Flag] = false
			SwordGet.Cancel(workflow); SwordGet.SetStatus(workflow, "Stopped")
		end,
	}
end

do
	function GameEvents.SetStatus(name, message)
		local entry = GameEvents.States[name]
		if entry.Status ~= message then entry.Status = message; log(name .. ": " .. message) end
	end

	function GameEvents.Cancel(name)
		local entry = GameEvents.States[name]
		entry.Epoch += 1
		if entry.Request then state.HopPending = false end
		entry.Request = nil
		entry.WaitSince, entry.Character, entry.Target = nil, nil, nil
		entry.PickupSince, entry.RewardUntil = nil, nil
		entry.NextHop = 0
	end

	function GameEvents.FruitKey(tool)
		if not tool or not tool:IsA("Tool") or not tool.Name:find("Fruit", 1, true) then return nil end
		local original = tool:GetAttribute("OriginalName")
		local value = tool:FindFirstChild("OriginalName")
		if type(original) ~= "string" and value and value:IsA("StringValue") then original = value.Value end
		local ok, fruitInfo = pcall(function() return require(ReplicatedStorage.FruitInfo) end)
		local list = ok and fruitInfo.List
		if not list then return nil end
		if type(original) == "string" and list[original] then return original end
		local name = tool.Name:gsub(" Fruit$", "")
		local key = name .. "-" .. name
		return list[key] and key or nil
	end

	function GameEvents.CarriedFruit()
		local fruits = {}
		for _, container in pairs({ player.Character, player:FindFirstChild("Backpack") }) do
			for _, tool in ipairs(container:GetChildren()) do
				if GameEvents.FruitKey(tool) then fruits[#fruits + 1] = tool end
			end
		end
		return fruits
	end

	GameEvents.StorageSnapshot = LPH_JIT(function(force)
		if not force and GameEvents.StorageCache and os.clock() - (GameEvents.StorageAt or 0) < 1 then return GameEvents.StorageCache end
		local ok, snapshot = pcall(function()
			local service = require(ReplicatedStorage.ItemReplicationService)
			local config = require(ReplicatedStorage.ItemConfig)
			local rows = service:GetItems(service.KEYS.QUANTITY)
			assert(type(rows) == "table", "Stored fruit quantities are unavailable")
			local counts = {}
			for _, item in pairs(rows) do
				assert(type(item.Value) == "number", "Stored fruit quantity is invalid")
				if item.Value > 0 then
					local info = config.match(item.ItemId):asNullable()
					assert(type(info) == "table", "Stored fruit item metadata is unavailable")
					if info.State and info.State.StorageMethod == "StoredFruits" then
						local key = info.Index and info.Index.StorageKey
						assert(type(key) == "string", "Stored fruit key is unavailable")
						counts[key] = (counts[key] or 0) + item.Value
					end
				end
			end
			local data = player:FindFirstChild("Data")
			local cap = data and data:FindFirstChild("FruitCap")
			local limit = cap and tonumber(cap.Value)
			return { Counts = counts, Limit = limit and limit >= 1 and limit or nil }
		end)
		if not ok then
			GameEvents.StorageCache = nil
			if os.clock() - (GameEvents.StorageErrorAt or -math.huge) >= 5 then
				GameEvents.StorageErrorAt = os.clock()
				reportControllerError(snapshot, "FruitSafe", "Inventory")
			end
			return nil
		end
		GameEvents.StorageCache, GameEvents.StorageAt = snapshot, os.clock()
		return snapshot
	end)

	GameEvents.PendingFruit = LPH_JIT(function(name, force)
		local carried = GameEvents.CarriedFruit()
		if #carried == 0 then return carried end
		local snapshot = GameEvents.StorageSnapshot(force)
		carried = GameEvents.CarriedFruit()
		local pending = {}
		for _, tool in ipairs(carried) do
			local key = GameEvents.FruitKey(tool)
			local count = snapshot and key and snapshot.Counts[key]
			local duplicate = (name == "Pirate" or name == "Factory") and count and count >= 1
			local full = count and snapshot.Limit and count >= snapshot.Limit
			if not duplicate and not full then pending[#pending + 1] = tool end
		end
		return pending
	end)

	GameEvents.StoreStep = LPH_JIT(function()
		if env.AutoStoreFruit ~= true or state.Generation ~= generation then return end
		local snapshot = GameEvents.StorageSnapshot()
		if not snapshot or not snapshot.Limit then return end
		for _, tool in ipairs(GameEvents.CarriedFruit()) do
			local key = GameEvents.FruitKey(tool)
			if not key then continue end
			if (snapshot.Counts[key] or 0) >= snapshot.Limit then continue end
			if os.clock() >= (GameEvents.StoreRetry[tool] or 0) then
				if env.AutoStoreFruit ~= true or state.Generation ~= generation then return end
				if tool.Parent ~= player.Character and tool.Parent ~= player:FindFirstChild("Backpack") then return end
				GameEvents.StoreRetry[tool] = os.clock() + 15
				local result = invokeCommF("StoreFruit", key, tool)
				GameEvents.StorageCache = nil
				log("Store Fruit: " .. key .. " | response " .. tostring(result))
				if tool.Parent == player.Character or tool.Parent == player:FindFirstChild("Backpack") then
					notify("Store requested for " .. key .. "; waiting for inventory confirmation.", "fruit-store-" .. key, 15)
				end
				return
			end
		end
	end)

	function GameEvents.FindFruit()
		local root = getRoot()
		if not root then return nil end
		local best, distance
		local candidates = workspace:GetChildren()
		local folder = workspace:FindFirstChild("Fruits")
		if folder and folder:IsA("Folder") then
			for _, fruit in ipairs(folder:GetChildren()) do candidates[#candidates + 1] = fruit end
		end
		for _, fruit in ipairs(candidates) do
			if (fruit:IsA("Tool") or fruit:IsA("Model")) and fruit.Name:find("Fruit", 1, true)
				and os.clock() >= (GameEvents.FruitIgnored[fruit] or 0) then
				local handle = fruit:FindFirstChild("Handle")
				if handle and handle:IsA("BasePart") then
					local delta = (root.Position - handle.Position).Magnitude
					if not distance or delta < distance then best, distance = fruit, delta end
				end
			end
		end
		return best
	end

	function GameEvents.FindTarget(name)
		if name == "Fruit" then return GameEvents.FindFruit() end
		if name == "Berry" then return GameEvents.States.Berry.Target or GameEvents.FindBerry(true) end
		if name == "Factory" then return BossFarm.FindIn(workspace:FindFirstChild("Enemies"), { Names = { "Core" } }) end
		local entry, root = GameEvents.States.Pirate, getRoot()
		local enemies = workspace:FindFirstChild("Enemies")
		if not enemies then return nil end
		local best, distance
		for _, mob in ipairs(enemies:GetChildren()) do
			local part = mob:FindFirstChild("HumanoidRootPart")
			local hum = mob:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 and part and (part.Position - GameEvents.Castle.Position).Magnitude <= 1000
				and not mob.Name:find("Boss", 1, true) and not mob.Name:find("Friend", 1, true)
				and not mob.Name:find("Wraith", 1, true) and not mob.Name:lower():find("rip_indra", 1, true)
				and mob.Name ~= "Oni2" then
				if mob == entry.Target then return mob end
				local delta = root and (part.Position - root.Position).Magnitude or 0
				if not distance or delta < distance then best, distance = mob, delta end
			end
		end
		return best
	end

	function GameEvents.FindBerry(includeDeferred)
		local root = getRoot()
		if not root then return nil end
		local best, distance
		for _, bush in ipairs(CollectionService:GetTagged("BerryBush")) do
			if bush:IsDescendantOf(workspace) then
				for slot, berry in pairs(bush:GetAttributes()) do
					if slot:match("^_BerryCFrame%d+$") and type(berry) == "string" and berry ~= "" then
						local position = Haki.BerryPosition(bush, slot, berry)
						local ignored = GameEvents.BerryIgnored[bush]
						local retryAt = ignored and ignored[slot] or 0
						if position and (includeDeferred or os.clock() >= retryAt) then
							local delta = (root.Position - position.Position).Magnitude
							if not distance or delta < distance then
								best, distance = { Bush = bush, BushId = bush.Parent.Name, Slot = slot, Berry = berry, Position = position, Attempts = 0 }, delta
							end
						end
					end
				end
			end
		end
		return best
	end

	GameEvents.BerryStep = LPH_JIT(function()
		local entry, root = GameEvents.States.Berry, getRoot()
		if not root or not workflowActive("Berry") then return end
		local target = entry.Target
		if not target then target = GameEvents.FindBerry(); entry.Target = target end
		if not target then
			cleanupMovement()
			if GameEvents.FindBerry(true) then
				entry.WaitSince = nil
				GameEvents.SetStatus("Berry", "Waiting to retry uncollected berries"); return
			end
			entry.WaitSince = entry.WaitSince or os.clock()
			if os.clock() - entry.WaitSince < 8 then
				GameEvents.SetStatus("Berry", "No berries found; waiting for replication"); return
			end
			GameEvents.Hop("Berry"); return
		end
		entry.WaitSince = nil
		if entry.Request then GameEvents.Cancel("Berry"); entry.Target = target end
		target.BushId = target.BushId or (target.Bush.Parent and target.Bush.Parent.Name)
		local bush = target.Bush
		if not bush:IsDescendantOf(workspace) then
			for _, candidate in ipairs(CollectionService:GetTagged("BerryBush")) do
				if candidate.Parent and candidate.Parent.Name == target.BushId and candidate:IsDescendantOf(workspace) then
					bush = candidate; target.Bush = candidate; break
				end
			end
		end
		local replicated = bush:IsDescendantOf(workspace) and Haki.BerryPosition(bush, target.Slot, target.Berry)
		if replicated then target.Position = replicated end
		local position = target.Position
		if (root.Position - position.Position).Magnitude > 10 then
			GameEvents.SetStatus("Berry", "Flying to " .. target.Berry)
			moveTo(position + Vector3.new(0, 2, 0)); return
		end
		cleanupMovement()
		if not replicated then
			if target.LastClaimSucceeded or (target.Attempts > 0 and bush:IsDescendantOf(workspace)
				and bush:GetAttribute(target.Slot) ~= target.Berry) then
				entry.Target = nil; return
			end
			target.MissingSince = target.MissingSince or os.clock()
			if not target.StreamRequested then
				target.StreamRequested = true
				task.spawn(function()
					local ok, err = pcall(function() player:RequestStreamAroundAsync(position.Position, 5) end)
					if not ok and workflowActive("Berry") then log("Berry streaming request: " .. tostring(err)) end
				end)
			end
			if os.clock() - target.MissingSince < 8 then
				GameEvents.SetStatus("Berry", "At berry position; waiting for bush replication"); return
			end
			GameEvents.SetStatus("Berry", "Berry no longer present at destination; checking next target")
			entry.Target = nil; return
		end
		target.MissingSince = nil
		GameEvents.SetStatus("Berry", "Collecting " .. target.Berry)
		if os.clock() < (entry.NextClaim or 0) or os.clock() < (target.VerifyUntil or 0) then return end
		if target.Attempts >= 3 then
			local ignored = GameEvents.BerryIgnored[target.Bush] or {}
			GameEvents.BerryIgnored[target.Bush] = ignored
			ignored[target.Slot] = os.clock() + 30
			entry.Target = nil
			GameEvents.SetStatus("Berry", "Collection not confirmed; retrying this berry in 30 seconds"); return
		end
		local epoch, character = entry.Epoch, player.Character
		GameEvents.ClaimRemote = GameEvents.ClaimRemote or require(ReplicatedStorage.Modules.Net):RemoteFunction("ClaimBerry")
		if not workflowActive("Berry") or getRoot() ~= root or not target.Bush.Parent then return end
		entry.NextClaim = os.clock() + 0.5
		target.Attempts += 1
		local result = GameEvents.ClaimRemote:InvokeServer(target.BushId, target.Slot)
		if not workflowActive("Berry") or entry.Epoch ~= epoch or player.Character ~= character then return end
		target.LastClaimSucceeded = result == true
		target.VerifyUntil = os.clock() + (result and 2 or 0.5)
	end)

	GameEvents.RandomStep = LPH_JIT(function()
		if env.AutoRandomFruit ~= true or state.Generation ~= generation or state.HopPending
			or os.clock() < (GameEvents.NextRandom or 0) then return end
		for _, entry in pairs(GameEvents.States) do if entry.Request then return end end
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 or not player.Team then return end
		GameEvents.NextRandom = os.clock() + 15
		local box = "ZiolesGacha"
		local bannerModule = ReplicatedStorage.Controllers:FindFirstChild("BannerClient")
		if bannerModule then
			local banner = require(bannerModule)
			if type(banner.TryGetBannerItemIfActiveAsync) == "function" then
				local item = banner.TryGetBannerItemIfActiveAsync()
				if type(item) == "table" and type(item.BoxName) == "string" then box = item.BoxName end
			end
		end
		GameEvents.GachaRemote = GameEvents.GachaRemote or require(ReplicatedStorage.Modules.Net):RemoteFunction("GachaNetworkRF")
		local check = GameEvents.GachaRemote:InvokeServer({ Context = "Check", BoxName = box,
			SpokeNPC = box == "ZiolesGacha" and "Blox Fruit Gacha" or nil })
		if type(check) ~= "table" or check.RequirementsMet ~= true then return end
		if env.AutoRandomFruit ~= true or state.Generation ~= generation or state.HopPending
			or player.Character ~= character or humanoid.Health <= 0 then return end
		for _, entry in pairs(GameEvents.States) do if entry.Request then return end end
		local result = GameEvents.GachaRemote:InvokeServer({ Context = "Purchase", BoxName = box })
		if state.Generation ~= generation then return end
		log("Random Fruit: " .. box .. " | response " .. tostring(result))
	end)

	function GameEvents.Position(value)
		local parts = type(value) == "table" and value or {}
		if type(value) == "string" then
		for number in value:gmatch("[^,%s]+") do
			local parsed = tonumber(number)
			if not parsed then return nil end
			parts[#parts + 1] = parsed
		end
		end
		if #parts < 3 then return nil end
		local x, y, z = tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3])
		if not x or not y or not z or x ~= x or y ~= y or z ~= z or math.abs(x) > 1000000 or math.abs(y) > 1000000 or math.abs(z) > 1000000 then return nil end
		return CFrame.new(x, y, z)
	end

	function GameEvents.SelectServer(data, name)
		local targetSea = GameEvents.States[name].Sea or currentSea()
		for job, visitedAt in pairs(state.BossVisited) do
			if type(visitedAt) ~= "number" or os.time() - visitedAt >= BossFarm.VisitedSeconds then state.BossVisited[job] = nil end
		end
		for _, server in ipairs(data) do
			if type(server) == "table" then
				local job = BossFarm.DecodeJobId(server.Jobid or server.JobId or server.Job_id or server.jobId)
				local place = tonumber(server.place_id or server.PlaceId or server.placeId)
				local playing, maximum = tostring(server.players or server.Players or ""):match("^(%d+)%s*/%s*(%d+)$")
				playing, maximum = tonumber(playing) or tonumber(server.playing), tonumber(maximum) or tonumber(server.maxPlayers)
				if job and job ~= game.JobId and not state.BossVisited[job] and SeaByPlaceId[place] == targetSea
					and (not playing or not maximum or playing < maximum) then
					return job, place, name == "Fruit" and GameEvents.Position(server.cframe or server.CFrame) or nil
				end
			end
		end
	end

	function GameEvents.CanHop(name, request)
		local entry = GameEvents.States[name]
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		local allowed = workflowActive(name) and entry.Request == request and entry.Epoch == request.Epoch
			and not GameEvents.RandomBusy
			and game.JobId == request.JobId and player.Character == request.Character
			and currentSea() == request.Sea and humanoid and humanoid.Health > 0
			and not BossFarm.HasProtectedItem() and not hasItem("Holy Torch")
			and #GameEvents.PendingFruit(name, true) == 0 and not GameEvents.FindTarget(name)
		return allowed and workflowActive(name) and entry.Request == request and entry.Epoch == request.Epoch
			and not GameEvents.RandomBusy
			and game.JobId == request.JobId and player.Character == request.Character and currentSea() == request.Sea
			and humanoid.Health > 0 and not BossFarm.HasProtectedItem() and not hasItem("Holy Torch")
	end

	function GameEvents.Hop(name)
		local entry = GameEvents.States[name]
		if name == "Berry" and entry.Target then return end
		if entry.Request or state.HopPending or GameEvents.RandomBusy or os.clock() < (entry.NextHop or 0) then return end
		if BossFarm.HasProtectedItem() or hasItem("Holy Torch") or #GameEvents.PendingFruit(name, true) > 0 then
			GameEvents.SetStatus(name, "Hop paused: store carried fruit / keep protected items safe"); return
		end
		if #GameEvents.CarriedFruit() > 0 then
			notify("Carried fruit is already stored or storage is full; continuing API hop. Unstored duplicates may be lost.", "event-fruit-duplicate-hop", 15)
		end
		local request = { Epoch = entry.Epoch, Sea = currentSea(), JobId = game.JobId, Character = player.Character }
		entry.Request = request
		entry.NextHop = os.clock() + 15
		GameEvents.SetStatus(name, "Searching " .. entry.Slug .. " server API")
		task.spawn(function()
			local ok, err = xpcall(function()
				local data = BossFarm.FetchServers(entry.Slug)
				if not GameEvents.CanHop(name, request) then return end
				local job, _, hint = GameEvents.SelectServer(data, name)
				if not job then GameEvents.SetStatus(name, "No available API server; retrying in 15 seconds"); return end
				if not GameEvents.CanHop(name, request) then return end
				local browser = ReplicatedStorage:FindFirstChild("__ServerBrowser")
				assert(browser and browser:IsA("RemoteFunction"), "ReplicatedStorage.__ServerBrowser is unavailable")
				if name == "Fruit" then entry.Hint = hint and { JobId = job, Position = { hint.X, hint.Y, hint.Z } } or nil end
				queueResume()
				if not GameEvents.CanHop(name, request) then return end
				state.BossVisited[job] = os.time()
				state.HopPending = true
				request.Teleporting = true
				GameEvents.SetStatus(name, "Joining event server")
				assert(browser:InvokeServer("teleport", job) ~= false, "Event server teleport rejected")
				task.delay(25, function()
					if state.Generation == generation and entry.Request == request then
						entry.Request = nil; state.HopPending = false
						GameEvents.SetStatus(name, "Transfer timed out; retrying")
					end
				end)
			end, debug.traceback)
			if entry.Request == request and (not ok or not request.Teleporting) then entry.Request = nil; state.HopPending = false end
			if not ok and state.Generation == generation then reportControllerError(err, name, "APIHop") end
		end)
	end

	function GameEvents.Pickup(fruit)
		local entry, root = GameEvents.States.Fruit, getRoot()
		local handle = fruit and fruit:FindFirstChild("Handle")
		if not handle or not root then return end
		if entry.Target ~= fruit then entry.Target = fruit; entry.PickupSince = nil end
		GameEvents.SetStatus("Fruit", "Collecting " .. fruit.Name)
		if (root.Position - handle.Position).Magnitude > 8 then moveTo(handle.CFrame); return end
		cleanupMovement()
		entry.PickupSince = entry.PickupSince or os.clock()
		local touch = env.firetouchinterest or firetouchinterest
		if type(touch) == "function" and os.clock() >= (entry.NextTouch or 0) then
			entry.NextTouch = os.clock() + 1
			touch(root, handle, 0); touch(root, handle, 1)
		elseif type(touch) ~= "function" then
			local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
			if humanoid then humanoid:MoveTo(handle.Position) end
		end
		if os.clock() - entry.PickupSince > 10 then
			GameEvents.FruitIgnored[fruit] = os.clock() + 30
			entry.Target, entry.PickupSince = nil, nil
			GameEvents.SetStatus("Fruit", "Pickup not confirmed; retrying this fruit later")
		end
	end

	GameEvents.FindIsland = LPH_JIT(function(name)
		local entry = GameEvents.States[name]
		local map = workspace:FindFirstChild("Map")
		local island = map and map:FindFirstChild(entry.Island)
		if island then return island end
		local origin = workspace:FindFirstChild("_WorldOrigin")
		local locations = origin and origin:FindFirstChild("Locations")
		return locations and locations:FindFirstChild(entry.Location)
	end)

	GameEvents.IslandDestination = LPH_JIT(function(name, island)
		local entry = GameEvents.States[name]
		local pivot = island:GetAttribute("CFrame")
		if typeof(pivot) ~= "CFrame" then
			if island:IsA("Model") then pivot = island:GetPivot()
			elseif island:IsA("BasePart") then pivot = island.CFrame end
		end
		if typeof(pivot) ~= "CFrame" then return nil end
		if name == "Kitsune" then
			local shrine = island:FindFirstChild("ShrineDialogPart", true)
			if shrine and shrine:IsA("BasePart") then return shrine.CFrame + Vector3.new(0, 4, 0), true end
			local inactive = island:FindFirstChild("ShrineInactive", true)
			if inactive and inactive:IsA("Model") then return inactive:GetPivot() + Vector3.new(0, 4, 0), true end
			return pivot + Vector3.new(0, 80, 0), false
		end
		local npcs = workspace:FindFirstChild("NPCs")
		local npc = npcs and npcs:FindFirstChild(entry.NPC)
		local part = npc and npc:FindFirstChild("HumanoidRootPart")
		if part and part:IsA("BasePart") and (part.Position - pivot.Position).Magnitude < 2500 then
			return part.CFrame * CFrame.new(0, 0, 6), true
		end
		local spawn = island:FindFirstChild(name == "Volcanic" and "FossilExpertSpawn" or entry.NPC, true)
		if spawn and spawn:IsA("BasePart") then return spawn.CFrame + Vector3.new(0, 4, 0), true end
		return pivot + Vector3.new(0, 80, 0), false
	end)

	GameEvents.IslandStep = LPH_JIT(function(name)
		local island = GameEvents.FindIsland(name)
		if not island then
			cleanupMovement()
			GameEvents.SetStatus(name, "Waiting for island to spawn in this server")
			return
		end
		local goal, landed = GameEvents.IslandDestination(name, island)
		local root = getRoot()
		if not goal or not root then
			cleanupMovement()
			GameEvents.SetStatus(name, "Waiting for island position replication")
			return
		end
		if (root.Position - goal.Position).Magnitude > 8 then
			GameEvents.SetStatus(name, landed and "Tweening to " .. (GameEvents.States[name].NPC or "Kitsune shrine") or "Approaching island; waiting for target replication")
			moveTo(goal)
		elseif landed then
			cleanupMovement()
			GameEvents.SetStatus(name, "Arrived at island")
		else
			cancelMovement()
			setNoClip(false)
			setFloat(true)
			GameEvents.SetStatus(name, "At island; waiting for target replication")
		end
	end)

	GameEvents.Step = LPH_JIT(function(name)
		if not workflowActive(name) then return end
		local entry, character = GameEvents.States[name], player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local root = getRoot()
		if not root or not humanoid or humanoid.Health <= 0 then GameEvents.Cancel(name); return end
		if entry.Character ~= character then GameEvents.Cancel(name); entry.Character = character end
		if state.HopPending then return end
		if entry.Island then GameEvents.IslandStep(name); return end
		if name == "Berry" then GameEvents.BerryStep(); return end
		if entry.Sea and currentSea() ~= entry.Sea then
			if #GameEvents.PendingFruit(name, true) > 0 or BossFarm.HasProtectedItem() then
				GameEvents.SetStatus(name, "Travel paused: store fruit / protect carried items"); return
			end
			GameEvents.SetStatus(name, "Traveling to Sea " .. entry.Sea)
			if entry.Sea == 2 then travelToSea2() else travelToSea3() end
			return
		end
		local target = GameEvents.FindTarget(name)
		if target then
			entry.WaitSince = nil
			if name == "Fruit" then GameEvents.Pickup(target)
			else
				entry.Target = target
				entry.RewardUntil = os.clock() + 5
				GameEvents.SetStatus(name, "Fighting " .. target.Name)
				fightMob(target)
			end
			return
		end
		stopFastAttack()
		if entry.RewardUntil and os.clock() < entry.RewardUntil then
			GameEvents.SetStatus(name, "Waiting for event reward"); return
		end
		if #GameEvents.PendingFruit(name) > 0 then
			cleanupMovement()
			GameEvents.SetStatus(name, env.AutoStoreFruit == true and "Waiting for fruit storage" or "Fruit collected; enable Auto Store Fruit before hopping")
			return
		end
		local goal = name == "Pirate" and GameEvents.Castle or name == "Factory" and GameEvents.Factory
		if name == "Fruit" and type(entry.Hint) == "table" and entry.Hint.JobId == game.JobId then goal = GameEvents.Position(entry.Hint.Position) end
		if goal and not entry.WaitSince then
			GameEvents.SetStatus(name, "Approaching " .. (name == "Pirate" and "Castle gate" or name == "Factory" and "Factory" or "API fruit position"))
			if (root.Position - goal.Position).Magnitude > 60 then moveTo(goal); return end
			cleanupMovement()
		end
		entry.WaitSince = entry.WaitSince or os.clock()
		local waitSeconds = name == "Pirate" and 15 or name == "Fruit" and goal and 15 or 8
		local remaining = waitSeconds - (os.clock() - entry.WaitSince)
		if remaining > 0 then GameEvents.SetStatus(name, "Waiting for event replication (" .. math.ceil(remaining) .. "s)"); return end
		GameEvents.Hop(name)
	end)

	env.EventFarmCodex = GameEvents
end

do
	PullLever.SetStatus = LPH_JIT(function(message)
		if PullLever.Status ~= message then
			PullLever.Status = message
			log("Auto Pull Level: " .. message)
		end
	end)

	PullLever.RestoreCamera = LPH_JIT(function()
		local saved = PullLever.Camera
		PullLever.Camera = nil
		PullLever.MoonSince = nil
		if saved and saved.Instance.Parent then
			saved.Instance.CameraType = saved.Type
			saved.Instance.CameraSubject = saved.Subject and saved.Subject.Parent and saved.Subject
				or (player.Character and player.Character:FindFirstChildOfClass("Humanoid"))
		end
	end)

	PullLever.ClearFakeV3 = LPH_JIT(function()
		local emitter = PullLever.FakeV3Emitter
		PullLever.FakeV3Emitter = nil
		if emitter then emitter:Destroy() end
	end)

	PullLever.FakeV3 = LPH_JIT(function()
		if not workflowActive("PullLever") then return nil end
		local root = getRoot()
		if not root then return nil end
		local existing = root:FindFirstChild("Agility")
		if existing then return existing end
		PullLever.ClearFakeV3()
		local emitter = Instance.new("ParticleEmitter")
		emitter.Acceleration = Vector3.new(0, 0, 0)
		emitter.Archivable = true
		emitter.Drag = 20
		emitter.EmissionDirection = Enum.NormalId.Top
		emitter.Enabled = true
		emitter.Lifetime = NumberRange.new(0, 0)
		emitter.LightInfluence = 0
		emitter.LockedToPart = true
		emitter.Name = "Agility"
		emitter.Rate = 500
		emitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 4) })
		emitter.RotSpeed = NumberRange.new(9999, 99999)
		emitter.Rotation = NumberRange.new(0, 0)
		emitter.Speed = NumberRange.new(30, 30)
		emitter.SpreadAngle = Vector2.new(0, 0)
		emitter.Texture = "rbxassetid://243098098"
		emitter.VelocityInheritance = 0
		emitter.ZOffset = 2
		emitter.Transparency = NumberSequence.new(0)
		emitter.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromRGB(0, 0, 0))
		PullLever.FakeV3Emitter = emitter
		emitter.Parent = root
		return emitter
	end)

	PullLever.Cancel = LPH_JIT(function()
		PullLever.Epoch += 1
		if PullLever.Request then state.HopPending = false end
		PullLever.Request, PullLever.WaitSince, PullLever.RewardUntil = nil, nil, nil
		PullLever.ActionPending = nil
		for _, call in pairs(PullLever.Calls) do
			if call.Thread and not call.Done then pcall(task.cancel, call.Thread) end
		end
		PullLever.Calls = {}
		PullLever.RestoreCamera()
		PullLever.ClearFakeV3()
		BossFarm.ClearMirror()
	end)

	PullLever.Poll = LPH_JIT(function(command, action)
		if not workflowActive("PullLever") then return false end
		local key = command .. ":" .. tostring(action)
		local now = os.clock()
		local call = PullLever.Calls[key]
		if call then
			if not call.Done and now - call.At >= 8 then
				if call.Thread then pcall(task.cancel, call.Thread) end
				call.Done, call.Ok, call.Error, call.FinishedAt = true, false, "Remote timed out: " .. key, now
				reportControllerError(call.Error, "PullLever", "Remote")
			end
			if not call.Done then return false end
			if now - call.FinishedAt < (call.Ok and 2 or 5) then return call.Ok, call.Value end
		end
		call = { At = now, Epoch = PullLever.Epoch }
		PullLever.Calls[key] = call
		call.Thread = task.spawn(function()
			if not workflowActive("PullLever") or call.Epoch ~= PullLever.Epoch then return end
			local ok, value = pcall(function()
				if action == nil then return invokeCommF(command) end
				return invokeCommF(command, action)
			end)
			if call.Done or state.Generation ~= generation or call.Epoch ~= PullLever.Epoch
				or PullLever.Calls[key] ~= call then return end
			call.Done, call.Ok, call.Value, call.FinishedAt = true, ok, value, os.clock()
			if not ok then reportControllerError(value, "PullLever", "Remote") end
		end)
		return false
	end)

	PullLever.Read = LPH_JIT(function()
		local progressReady, progress = PullLever.Poll("RaceV4Progress", "Check")
		local doorReady, door = PullLever.Poll("CheckTempleDoor")
		if not progressReady or not doorReady or not tonumber(progress) or type(door) ~= "boolean" then
			PullLever.SetStatus("Waiting for verified RaceV4Progress / CheckTempleDoor")
			return nil
		end
		return { Progress = tonumber(progress), Door = door }
	end)

	PullLever.Advance = LPH_JIT(function(action)
		stopFastAttack(); cleanupMovement()
		PullLever.ActionPending = action
		PullLever.Poll("RaceV4Progress", action)
	end)

	PullLever.AwaitTransition = LPH_JIT(function()
		if not PullLever.ActionPending then return false end
		local ready = PullLever.Poll("RaceV4Progress", PullLever.ActionPending)
		if not ready then
			PullLever.SetStatus("Waiting for ancient tablet transition: " .. PullLever.ActionPending)
			return true
		end
		PullLever.ActionPending = nil
		for _, key in ipairs({ "RaceV4Progress:Check", "CheckTempleDoor:nil" }) do
			local call = PullLever.Calls[key]
			if call and call.Thread and not call.Done then pcall(task.cancel, call.Thread) end
			PullLever.Calls[key] = nil
		end
		return true
	end)

	PullLever.Items = LPH_JIT(function(force)
		if not force and PullLever.Inventory and os.clock() - PullLever.InventoryAt < 2 then return PullLever.Inventory end
		local service = require(ReplicatedStorage.ItemReplicationService)
		local config = require(ReplicatedStorage.ItemConfig)
		local owned = { Helm = false, Fractal = false }
		for _, key in ipairs({ service.KEYS.IS_OWNED, service.KEYS.QUANTITY }) do
			local rows = service:GetItems(key)
			assert(type(rows) == "table", "Pull Level inventory is unavailable")
			for _, item in pairs(rows) do
				if item.Value == true or (type(item.Value) == "number" and item.Value > 0) then
					local data = config.match(item.ItemId):asNullable()
					assert(type(data) == "table" and type(data.Index) == "table", "Pull Level item metadata is unavailable")
					local name = data.Index.StorageKey
					if name == "Valkyrie Helm" then owned.Helm = true end
					if name == "Mirror Fractal" then owned.Fractal = true end
				end
			end
		end
		PullLever.Inventory, PullLever.InventoryAt = owned, os.clock()
		return owned
	end)

	PullLever.Plan = LPH_JIT_MAX(function(level, owned, progress, door, completed)
		if completed then return "Complete" end
		if level < 1500 then return "Level" end
		if door == true then return "Lever" end
		if not owned.Helm then return "Helm" end
		if not owned.Fractal then return "Fractal" end
		if progress == 1 then return "Begin" end
		if progress == 2 then return "Tree" end
		if progress == 3 then return "Continue" end
		if progress == 4 then return "Mirage" end
		return "Unknown"
	end)

	PullLever.Approach = LPH_JIT(function(goal, radius)
		local root = getRoot()
		if not root then return false end
		if (root.Position - goal.Position).Magnitude > (radius or 8) then
			moveTo(goal, false, radius)
			return false
		end
		cleanupMovement()
		return true
	end)

	PullLever.CanHop = LPH_JIT(function(request)
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not workflowActive("PullLever") or PullLever.Request ~= request or PullLever.Epoch ~= request.Epoch
			or game.JobId ~= request.JobId or currentSea() ~= 3 or character ~= request.Character
			or not humanoid or humanoid.Health <= 0 or not getRoot()
			or BossFarm.HasProtectedItem() or hasItem("Holy Torch") or #GameEvents.CarriedFruit() > 0 then return false end
		local items = PullLever.Items(true)
		if request.Goal == "Helm" then
			return not items.Helm and not BossFarm.FindActive(BossFarm.Definitions["Rip Indra"])
		elseif request.Goal == "Fractal" then
			return items.Helm and not items.Fractal and not BossFarm.FindActive(BossFarm.Definitions["Dough King"])
		end
		local door = PullLever.Calls["CheckTempleDoor:nil"]
		local progress = PullLever.Calls["RaceV4Progress:Check"]
		return items.Helm and items.Fractal and door and door.Done and door.Ok and door.Value == false
			and progress and progress.Done and progress.Ok and tonumber(progress.Value) == 4
			and not GameEvents.FindIsland("Mirage")
	end)

	PullLever.Hop = LPH_JIT(function(goal, slug)
		if PullLever.Request or state.HopPending or os.clock() < (PullLever.NextHop or 0) then return end
		local request = { Goal = goal, Epoch = PullLever.Epoch, JobId = game.JobId, Character = player.Character }
		PullLever.Request = request
		PullLever.NextHop = os.clock() + 15
		PullLever.SetStatus("Searching " .. slug .. " API")
		task.spawn(function()
			local ok, err = xpcall(function()
				if not PullLever.CanHop(request) then return end
				local data = BossFarm.FetchServers(slug)
				if not PullLever.CanHop(request) then return end
				local definition = goal == "Helm" and BossFarm.Definitions["Rip Indra"]
					or goal == "Fractal" and BossFarm.Definitions["Dough King"] or { Slug = "mirage", Names = { "Mirage", "Mirage Island" } }
				local job = BossFarm.SelectServer(data, definition)
				if not job then PullLever.SetStatus("No matching API server; retrying in 15s"); return end
				local browser = ReplicatedStorage:FindFirstChild("__ServerBrowser")
				assert(browser and browser:IsA("RemoteFunction"), "__ServerBrowser is unavailable")
				queueResume()
				if not PullLever.CanHop(request) then return end
				request.Teleporting = true
				state.HopPending = true
				state.BossVisited[job], state.BossVisited[game.JobId] = os.time(), os.time()
				PullLever.SetStatus("Joining " .. slug .. " server")
				assert(browser:InvokeServer("teleport", job) ~= false, "Pull Level teleport rejected")
				task.delay(25, function()
					if state.Generation == generation and PullLever.Request == request then
						PullLever.Request = nil; state.HopPending = false
						PullLever.SetStatus("Transfer timed out; retrying")
					end
				end)
			end, debug.traceback)
			if PullLever.Request == request and (not ok or not request.Teleporting) then
				PullLever.Request = nil; state.HopPending = false
			end
			if not ok and state.Generation == generation then reportControllerError(err, "PullLever", "APIHop") end
		end)
	end)

	PullLever.Boss = LPH_JIT(function(goal)
		local name = goal == "Helm" and "Rip Indra" or "Dough King"
		local definition = BossFarm.Definitions[name]
		local target = BossFarm.FindActive(definition)
		if target then
			PullLever.WaitSince = nil
			PullLever.RewardUntil = os.clock() + 5
			if not BossFarm.EnterMirror(definition, "PullLever") then return end
			PullLever.SetStatus("Fighting " .. name .. " for " .. (goal == "Helm" and "Valkyrie Helm" or "Mirror Fractal"))
			fightMob(target)
			return
		end
		stopFastAttack()
		if os.clock() < (PullLever.RewardUntil or 0) then PullLever.SetStatus("Waiting for boss reward replication"); return end
		if definition.Mirror and BossFarm.FindIn(ReplicatedStorage, definition) then
			if not BossFarm.EnterMirror(definition, "PullLever") then return end
			PullLever.WaitSince = PullLever.WaitSince or os.clock()
			PullLever.SetStatus("Waiting for Dough King replication inside Mirror Dimension")
			if os.clock() - PullLever.WaitSince < 8 then return end
			PullLever.Hop(goal, definition.Slug)
			return
		end
		local gate = goal == "Helm" and GameEvents.Castle or BossFarm.GetMirrorGate()
		PullLever.SetStatus("Approaching " .. (goal == "Helm" and "Castle gate" or "Cake Island gate"))
		if not PullLever.Approach(gate) then return end
		PullLever.WaitSince = PullLever.WaitSince or os.clock()
		if os.clock() - PullLever.WaitSince < 8 then return end
		PullLever.Hop(goal, definition.Slug)
	end)

	PullLever.FindGear = LPH_JIT(function(island)
		for _, part in ipairs(island:GetDescendants()) do
			if part:IsA("MeshPart") and part.MeshId:match("10153114969$") and part.Transparency < 1 and not part.CanCollide then return part end
		end
	end)

	PullLever.HighestPoint = LPH_JIT(function(island)
		local highest, height
		for _, part in ipairs(island:GetDescendants()) do
			if part:IsA("MeshPart") and part.MeshId:match("6745037796$") then return part.CFrame * CFrame.new(0, 211.88, 0) end
			if part:IsA("Model") and part.Name ~= "BiggTree" then
				local cf = part:GetPivot()
				if not height or cf.Y > height then highest, height = cf, cf.Y end
			end
		end
		return highest and highest + Vector3.new(0, 210, 0)
	end)

	PullLever.MoonVisible = LPH_JIT(function()
		local lighting = game:GetService("Lighting")
		return (lighting.ClockTime >= 18 or lighting.ClockTime < 6) and lighting:GetMoonDirection().Y > 0
	end)

	PullLever.LookMoon = LPH_JIT(function()
		if not PullLever.MoonVisible() then
			PullLever.RestoreCamera()
			PullLever.SetStatus("Waiting for the moon on Mirage Island")
			return
		end
		local camera = workspace.CurrentCamera
		if not camera then return end
		if not PullLever.Camera then
			PullLever.Camera = { Instance = camera, Type = camera.CameraType, Subject = camera.CameraSubject }
			PullLever.MoonSince = os.clock()
			camera.CameraType = Enum.CameraType.Scriptable
		end
		cancelMovement(); setNoClip(false); setFloat(true)
		PullLever.SetStatus("Locking moon / activating Race V3")
		if os.clock() - PullLever.MoonSince < 3 or os.clock() - (PullLever.LastV3 or -math.huge) < 40 then return end
		local ability
		for _, name in ipairs({ "Last Resort", "Agility", "Water Body", "Heavenly Blood", "Energy Core", "Heightened Senses" }) do
			if findCharacterTool(name) then ability = true; break end
		end
		if not ability then notify("Auto Pull Level requires Race V3 ability.", "pull-v3-required", 5); return end
		PullLever.LastV3 = os.clock()
		state.LastRaceV3Attempt = PullLever.LastV3
		pressGameKey(Enum.KeyCode.T)
		PullLever.FakeV3()
	end)

	PullLever.Mirage = LPH_JIT(function()
		local island = GameEvents.FindIsland("Mirage")
		if not island then
			PullLever.RestoreCamera()
			PullLever.SetStatus("Approaching Tiki Outpost gate before Mirage API hop")
			if PullLever.Approach(PullLever.Tiki) then PullLever.Hop("Mirage", "mirage") end
			return
		end
		local gear = PullLever.FindGear(island)
		if gear then
			PullLever.RestoreCamera()
			PullLever.ClearFakeV3()
			PullLever.SetStatus("Collecting Blue Gear; waiting for CheckTempleDoor confirmation")
			moveTo(gear.CFrame, false, 3)
			return
		end
		local peak = PullLever.HighestPoint(island)
		if not peak then
			PullLever.RestoreCamera()
			GameEvents.IslandStep("Mirage")
			PullLever.SetStatus("Approaching Mirage / waiting for peak and gear replication")
			return
		end
		if not getRoot() or (getRoot().Position - peak.Position).Magnitude > 8 then
			PullLever.RestoreCamera()
			PullLever.SetStatus("Tweening to highest Mirage point")
			moveTo(peak)
			return
		end
		PullLever.LookMoon()
	end)

	PullLever.TempleMap = LPH_JIT(function()
		local map = workspace:FindFirstChild("Map")
		local temple = map and map:FindFirstChild("Temple of Time")
		return temple and not temple:GetAttribute("ClientBorrowed") and temple or nil
	end)

	PullLever.Pulled = LPH_JIT(function(temple)
		local group = temple and temple:FindFirstChild("Lever")
		local lever = group and group:FindFirstChild("Lever")
		return lever and lever:IsA("BasePart") and math.abs(lever.Position.Z - PullLever.LeverClosedZ) <= 0.2 or false
	end)

	PullLever.Finish = LPH_JIT(function()
		PullLever.Completed = true
		PullLever.Cancel()
		stopFastAttack(); cleanupMovement()
		PullLever.SetStatus("Completed: Temple lever pulled")
		notify("Auto Pull Level completed: Temple lever pulled.", "pull-level-complete", 5)
	end)

	PullLever.CheckCompletion = LPH_JIT(function(progress)
		PullLever.RestoreCamera()
		PullLever.ClearFakeV3()
		stopFastAttack(); cleanupMovement()
		local temple = PullLever.TempleMap()
		if progress and progress.Door == true and PullLever.Pulled(temple) then
			PullLever.Finish()
			return
		end
		PullLever.SetStatus(temple and "Waiting for player to pull the lever; automatic pulling disabled"
			or "Gear unlocked; waiting for replicated player lever status; no automatic teleport or pull")
	end)

	PullLever.Step = LPH_JIT(function()
		if not workflowActive("PullLever") then return end
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 or not getRoot() then PullLever.Cancel(); return end
		if PullLever.Character ~= character then PullLever.Cancel(); PullLever.Character = character end
		local level = player:FindFirstChild("Data") and player.Data:FindFirstChild("Level")
		if not level or level.Value < 1500 then
			stopFastAttack(); cleanupMovement(); PullLever.SetStatus("Stopped: requires level 1500+")
			notify("Auto Pull Level requires level 1500 or higher.", "pull-level-required", 5)
			return
		end
		if currentSea() ~= 3 then PullLever.SetStatus("Traveling to Sea 3"); travelToSea3(); return end
		if state.HopPending then return end
		if PullLever.AwaitTransition() then return end
		local progress = PullLever.Read()
		if not progress then return end
		if progress.Door == true and PullLever.Pulled(PullLever.TempleMap()) then
			PullLever.Finish(); return
		end
		local owned = PullLever.Items()
		local goal = PullLever.Plan(level.Value, owned, progress.Progress, progress.Door, PullLever.Completed)
		if goal ~= PullLever.Goal then
			stopFastAttack(); cleanupMovement(); PullLever.RestoreCamera()
			PullLever.Goal, PullLever.WaitSince, PullLever.RewardUntil = goal, nil, nil
		end
		if goal == "Helm" or goal == "Fractal" then PullLever.Boss(goal)
		elseif goal == "Begin" or goal == "Continue" then
			PullLever.SetStatus("Ancient tablet: RaceV4Progress " .. goal)
			PullLever.Advance(goal)
		elseif goal == "Tree" then
			PullLever.SetStatus("Ancient tablet: approaching Great Tree")
			if PullLever.Approach(PullLever.Tree) then PullLever.Advance("Teleport") end
		elseif goal == "Mirage" then PullLever.Mirage()
		elseif goal == "Lever" then PullLever.CheckCompletion(progress)
		else PullLever.SetStatus("Unknown RaceV4Progress; no hop or trial action") end
	end)

	state.Connections[#state.Connections + 1] = RunService.RenderStepped:Connect(function()
		local saved = PullLever.Camera
		if not saved then return end
		if not workflowActive("PullLever") or not PullLever.MoonVisible() or not GameEvents.FindIsland("Mirage") then
			PullLever.RestoreCamera(); return
		end
		local direction = game:GetService("Lighting"):GetMoonDirection()
		saved.Instance.CFrame = CFrame.lookAt(saved.Instance.CFrame.Position, saved.Instance.CFrame.Position + direction)
	end)

	env.PullLevelCodex = {
		Run = PullLever.Step,
		Start = function()
			env.AutoPullLevel = true; PullLever.Cancel(); PullLever.Completed = false
			PullLever.NextHop, PullLever.Inventory = nil, nil; PullLever.SetStatus("Queued")
		end,
		Stop = function()
			env.AutoPullLevel = false; PullLever.Cancel()
			if state.ActiveWorkflow == "PullLever" then stopFastAttack(); cleanupMovement() end
			PullLever.SetStatus("Stopped")
		end,
	}
end

local function releaseWorkflow()
	PullLever.Cancel()
	BossFarm.Cancel()
	TTK.Cancel()
	Haki.Cancel()
	for name in pairs(GameEvents.States) do GameEvents.Cancel(name) end
	for name in pairs(SwordGet.States) do SwordGet.Cancel(name) end
	stopFastAttack()
	cleanupMovement()
	state.ActiveWorkflow = nil
	state.Stage = nil
	state.CurrentChest = nil
	state.CurrentChestSince = nil
	state.ZombieBatch = nil
	state.PuzzleReadAt = nil
	state.HopPending = false
	state.BossSelection = nil
	state.GhoulTarget = nil
	state.GhoulRewardUntil = nil
	state.GhoulExchangeAwaiting = nil
end

local SettingManager = {}
local fileAPI = {
	isfolder = env.isfolder or isfolder,
	makefolder = env.makefolder or makefolder,
	isfile = env.isfile or isfile,
	readfile = env.readfile or readfile,
	writefile = env.writefile or writefile,
}

function SettingManager:SetFolder(folder)
	for _, name in ipairs({ "isfolder", "makefolder", "isfile", "readfile", "writefile" }) do
		assert(type(fileAPI[name]) == "function", "Executor " .. name .. " is unavailable; cannot save config")
	end
	self.CurrentFolder = folder
	self.AutoSave = folder .. "/Main"
	self.Config = folder .. "/ConfigMain"
	self.AutoLoad = self.AutoSave .. "/" .. player.Name .. ".txt"
	self.AutoData = self.Config .. "/" .. player.Name .. ".json"
	self.AutoConfig = self.AutoData
	for _, directory in ipairs({ folder, self.AutoSave, self.Config }) do
		if not fileAPI.isfolder(directory) then fileAPI.makefolder(directory) end
	end
	self.Ready = true
end

function SettingManager:LoadAutoConfig()
	assert(self.Ready, "Config storage has not initialized")
	if not fileAPI.isfile(self.AutoLoad) then
		fileAPI.writefile(self.AutoLoad, self.AutoData)
	else
		local path = fileAPI.readfile(self.AutoLoad)
		assert(path == self.AutoData, "Unexpected CyborgCodex auto-load config path")
		self.AutoConfig = path
	end
	if not fileAPI.isfile(self.AutoConfig) then return nil end
	local data = HttpService:JSONDecode(fileAPI.readfile(self.AutoConfig))
	assert(type(data) == "table" and type(data.Setting) == "table", "Invalid CyborgCodex config schema")
	for _, key in ipairs({ "cyborgrace", "autosoulguitar" }) do
		assert(type(data.Setting[key]) == "boolean", "Config " .. key .. " must be boolean")
	end
	for _, key in ipairs({ "autofarmboss", "autofarmbosshop", "autoghoulrace", "autottk", "autoyama", "autotushita", "autocdk", "autohakilegendary",
		"autofactoryhop", "autopirateraidhop", "autofruithop", "autoberryhop", "AutoRandomFruit", "AutoStoreFruit", "TeleportMirageIsland", "TeleportVolcanicIsland", "TeleportKitsuneIsland", "AutoPullLevel" }) do
		if data.Setting[key] == nil then data.Setting[key] = false end
		assert(type(data.Setting[key]) == "boolean", "Config " .. key .. " must be boolean")
	end
	if data.Setting.SelectedWeapon == nil then data.Setting.SelectedWeapon = "Melee" end
	if data.Setting.Team == nil then data.Setting.Team = "Marines" end
	assert(data.Setting.Team == "Pirates" or data.Setting.Team == "Marines", "Config Team is invalid")
	assert(table.find({ "Melee", "Sword", "Fruit", "Gun" }, data.Setting.SelectedWeapon), "Config SelectedWeapon is invalid")
	for _, key in ipairs({ "AutoBuso", "TurnOnRaceV3", "TurnOnRaceV4", "TurnOnObservationHaki" }) do
		if data.Setting[key] == nil then data.Setting[key] = key == "AutoBuso" end
		assert(type(data.Setting[key]) == "boolean", "Config " .. key .. " must be boolean")
	end
	if data.Setting.selectedboss == nil then data.Setting.selectedboss = BossFarm.List[1] end
	assert(BossFarm.Definitions[data.Setting.selectedboss], "Config selectedboss is invalid")
	return data
end

function SettingManager:Save()
	assert(self.Ready, "Config storage is unavailable")
	assert(type(env.cyborgrace) == "boolean" and type(env.autosoulguitar) == "boolean", "Workflow flags must be boolean")
	assert(type(env.autofarmboss) == "boolean" and type(env.autofarmbosshop) == "boolean", "Boss flags must be boolean")
	assert(type(env.autoghoulrace) == "boolean", "Ghoul flag must be boolean")
	assert(type(env.autottk) == "boolean", "TTK flag must be boolean")
	assert(type(env.autoyama) == "boolean" and type(env.autotushita) == "boolean", "Sword workflow flags must be boolean")
	assert(type(env.autocdk) == "boolean", "CDK flag must be boolean")
	assert(type(env.autohakilegendary) == "boolean", "Haki flag must be boolean")
	for _, key in ipairs({ "autofactoryhop", "autopirateraidhop", "autofruithop", "autoberryhop", "AutoRandomFruit", "AutoStoreFruit", "TeleportMirageIsland", "TeleportVolcanicIsland", "TeleportKitsuneIsland", "AutoPullLevel" }) do
		assert(type(env[key]) == "boolean", key .. " must be boolean")
	end
	assert(BossFarm.Definitions[env.selectedboss], "Boss selection is invalid")
	assert(env.Team == "Pirates" or env.Team == "Marines", "Team selection is invalid")
	assert(table.find({ "Melee", "Sword", "Fruit", "Gun" }, env.SelectedWeapon), "Weapon selection is invalid")
	for _, key in ipairs({ "AutoBuso", "TurnOnRaceV3", "TurnOnRaceV4", "TurnOnObservationHaki" }) do
		assert(type(env[key]) == "boolean", key .. " must be boolean")
	end
	fileAPI.writefile(self.AutoData, HttpService:JSONEncode({
		Setting = { Team = env.Team, cyborgrace = env.cyborgrace, autosoulguitar = env.autosoulguitar,
			autoghoulrace = env.autoghoulrace, autottk = env.autottk,
			autoyama = env.autoyama, autotushita = env.autotushita,
			autocdk = env.autocdk,
			autohakilegendary = env.autohakilegendary,
			autofactoryhop = env.autofactoryhop, autopirateraidhop = env.autopirateraidhop,
			autofruithop = env.autofruithop, AutoStoreFruit = env.AutoStoreFruit,
			autoberryhop = env.autoberryhop, AutoRandomFruit = env.AutoRandomFruit,
			TeleportMirageIsland = env.TeleportMirageIsland, TeleportVolcanicIsland = env.TeleportVolcanicIsland,
			TeleportKitsuneIsland = env.TeleportKitsuneIsland,
			AutoPullLevel = env.AutoPullLevel,
			autofarmboss = env.autofarmboss, autofarmbosshop = env.autofarmbosshop, selectedboss = env.selectedboss,
			SelectedWeapon = env.SelectedWeapon, AutoBuso = env.AutoBuso, TurnOnRaceV3 = env.TurnOnRaceV3,
			TurnOnRaceV4 = env.TurnOnRaceV4, TurnOnObservationHaki = env.TurnOnObservationHaki },
	}))
	fileAPI.writefile(self.AutoLoad, self.AutoData)
end

local ui
local function withUIContext(callback)
	local getter = env.getthreadidentity or getthreadidentity or getidentity
	local setter = env.setthreadidentity or setthreadidentity or setidentity
	local previous
	if ui and ui.Identity and type(getter) == "function" and type(setter) == "function" then
		previous = getter()
		setter(ui.Identity)
	end
	local ok, result = xpcall(callback, debug.traceback)
	if previous ~= nil then setter(previous) end
	if not ok then error(result, 0) end
	return result
end
local function saveUISettings()
	local ok, err = pcall(function() SettingManager:Save() end)
	if not ok then
		log("Config save failed: " .. tostring(err))
		notify("Config save failed; see executor console.", "config-save-error", 5)
	end
	return ok
end

local function sharedWorkflowStatus()
	local owner=state.ActiveWorkflow
	if not owner then return "TEDDY HUB  ·  READY","idle" end
	local title,message
	if owner=="Ghoul" then title,message="AUTO GHOUL",state.GhoulStatus
	elseif owner=="PullLever" then title,message="AUTO PULL LEVEL",PullLever.Status
	elseif owner=="Haki" then title,message="AUTO HAKI LEGENDARY",Haki.Status
	elseif owner=="Boss" then title,message="BOSS FARM",state.BossStatus
	elseif GameEvents.States[owner] then title,message=GameEvents.States[owner].Title,GameEvents.States[owner].Status
	elseif owner=="TTK" then title,message="AUTO TTK",TTK.Status
	elseif SwordGet.States[owner] then title,message="AUTO "..string.upper(owner),SwordGet.States[owner].Status
	elseif owner=="Cyborg" or owner=="SoulGuitar" then
		title=owner=="Cyborg" and "AUTO CYBORG" or "AUTO SOUL GUITAR"
		message=state.Stage
	end
	message=tostring(message or state.Stage or "Starting")
	local lower=string.lower(message)
	local kind="active"
	if lower:find("error",1,true) or lower:find("failed",1,true) or lower:find("cannot",1,true) then kind="error"
	elseif lower:find("wait",1,true) or lower:find("idle",1,true) or lower:find("checking",1,true)
		or lower:find("need ",1,true) or lower:find("not found",1,true) then kind="waiting"
	elseif lower:find("complete",1,true) or lower:find("owned",1,true) or lower:find("success",1,true) then kind="success" end
	return title.."  ·  "..message,kind
end

local function createDynamicStatusIsland()
	local playerGui=player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui",10)
	if not playerGui then return nil end
	local old=playerGui:FindFirstChild("CyborgCodexDynamicIsland")
	if old then old:Destroy() end
	local displayOrder=1
	for _,child in ipairs(playerGui:GetChildren()) do
		if child:IsA("ScreenGui") then displayOrder=math.max(displayOrder,child.DisplayOrder+1) end
	end
	local gui=Instance.new("ScreenGui")
	gui.Name="CyborgCodexDynamicIsland"
	gui.ResetOnSpawn=false
	gui.IgnoreGuiInset=true
	gui.ScreenInsets=Enum.ScreenInsets.None
	gui.DisplayOrder=displayOrder
	gui.Parent=playerGui
	local pill=Instance.new("Frame")
	pill.Name="StatusIsland"
	pill.AnchorPoint=Vector2.new(.5,0)
	pill.Position=UDim2.new(.5,0,0,8)
	pill.Size=UDim2.fromOffset(124,30)
	pill.BackgroundColor3=Color3.fromRGB(18,18,18)
	pill.BorderSizePixel=0
	pill.ClipsDescendants=true
	pill.Parent=gui
	Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
	local stroke=Instance.new("UIStroke",pill)
	stroke.Color=Color3.fromRGB(65,65,65)
	stroke.Thickness=1
	local dot=Instance.new("Frame",pill)
	dot.Name="StatusDot"
	dot.Position=UDim2.fromOffset(12,11)
	dot.Size=UDim2.fromOffset(8,8)
	dot.BorderSizePixel=0
	Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
	local label=Instance.new("TextLabel",pill)
	label.Name="StatusText"
	label.Position=UDim2.fromOffset(30,0)
	label.Size=UDim2.new(1,-42,1,0)
	label.BackgroundTransparency=1
	label.TextColor3=Color3.fromRGB(238,238,242)
	label.Font=Enum.Font.GothamBold
	label.TextSize=10
	label.TextXAlignment=Enum.TextXAlignment.Center
	label.TextTruncate=Enum.TextTruncate.AtEnd
	local colors={idle=Color3.fromRGB(145,145,150),active=Color3.fromRGB(190,65,255),
		waiting=Color3.fromRGB(245,185,80),success=Color3.fromRGB(85,220,150),error=Color3.fromRGB(255,100,110)}
	local textService=game:GetService("TextService")
	local lastText,lastKind,sizeTween,colorTween
	local function refresh()
		if not gui.Parent then return end
		local text,kind=sharedWorkflowStatus()
		if text~=lastText then
			lastText=text;label.Text=text
			local measured=textService:GetTextSize(text,10,Enum.Font.GothamBold,Vector2.new(1000,30))
			local camera=workspace.CurrentCamera
			local maxWidth=math.max(150,math.min(420,(camera and camera.ViewportSize.X or 480)-24))
			local width=math.clamp(math.ceil(measured.X)+54,124,maxWidth)
			if sizeTween then sizeTween:Cancel() end
			sizeTween=TweenService:Create(pill,TweenInfo.new(.2,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(width,30)})
			sizeTween:Play()
		end
		if kind~=lastKind then
			lastKind=kind;dot.BackgroundColor3=colors[kind]
			if colorTween then colorTween:Cancel() end
			colorTween=TweenService:Create(stroke,TweenInfo.new(.2),{Color=kind=="idle" and Color3.fromRGB(65,65,65) or colors[kind]})
			colorTween:Play()
		end
	end
	local elapsed=0
	local connection=RunService.Heartbeat:Connect(function(dt)
		elapsed+=dt
		if elapsed>=.15 then elapsed=0;refresh() end
	end)
	gui.Destroying:Connect(function()
		connection:Disconnect()
		if sizeTween then sizeTween:Cancel() end
		if colorTween then colorTween:Cancel() end
	end)
	refresh()
	return gui
end

local syncUISettings = LPH_JIT(function()
	if not ui or ui.Fluent.Unloaded then return end
	local changed = false
	ui.Syncing = true
	local ok, err = xpcall(function() withUIContext(function()
		for key, toggle in pairs(ui.Toggles) do
			local value = env[key] == true
			if toggle.Value ~= value then toggle:SetValue(value) end
			if ui.LastFlags[key] ~= value then changed = true end
			ui.LastFlags[key] = value
		end
		if ui.WeaponDropdown and ui.WeaponDropdown.Value ~= env.SelectedWeapon then
			ui.WeaponDropdown:SetValue(env.SelectedWeapon)
			changed = true
		end
		if ui.TeamDropdown and ui.TeamDropdown.Value ~= env.Team then
			ui.TeamDropdown:SetValue(env.Team)
			changed = true
		end
		if ui.BossDropdown and BossFarm.Definitions[env.selectedboss] then
			if ui.BossDropdown.Value ~= env.selectedboss then ui.BossDropdown:SetValue(env.selectedboss) end
			if ui.LastBoss ~= env.selectedboss then changed = true end
			ui.LastBoss = env.selectedboss
		end
	end) end, debug.traceback)
	ui.Syncing = false
	if not ok then error(err) end
	if changed then saveUISettings() end
end)

do
	function ServerPanel.Duration(seconds)
		seconds = math.max(0, math.floor(seconds or 0))
		return string.format("%02d:%02d:%02d", math.floor(seconds / 3600), math.floor(seconds / 60) % 60, seconds % 60)
	end

	function ServerPanel.ReadStatus()
		local origin = workspace:FindFirstChild("_WorldOrigin")
		local locations = origin and origin:FindFirstChild("Locations")
		local map = workspace:FindFirstChild("Map")
		local earliest
		if locations then
			for _, location in ipairs(locations:GetChildren()) do
				local timeIn = location:GetAttribute("TimeIn")
				if type(timeIn) == "number" and (not earliest or timeIn < earliest) then earliest = timeIn end
			end
		end
		local age = earliest and math.max(0, workspace:GetServerTimeNow() - earliest)
		local sky = game:GetService("Lighting"):FindFirstChildOfClass("Sky")
		local moonId = sky and sky.MoonTextureId:match("(%d+)$")
		local moon = moonId == "9709149431" and "Full Moon" or moonId == "9709149052" and "Next Night" or "Other Phase"
		local clock = game:GetService("Lighting").ClockTime
		local present = function(container, name) return container and container:FindFirstChild(name) and "Present" or "Not found" end
		local elites = {}
		for _, name in ipairs(SwordGet.Elites) do
			if BossFarm.FindIn(workspace:FindFirstChild("Enemies"), { Names = { name } }) then elites[#elites + 1] = name end
		end
		local eyes, found = 0, 0
		local tiki = map and map:FindFirstChild("TikiOutpost")
		for index = 1, 4 do
			local eye = tiki and tiki:FindFirstChild("Eye" .. index, true)
			if eye and eye:IsA("BasePart") then found += 1; if eye.Transparency == 1 then eyes += 1 end end
		end
		local status = {
			Timer = ServerPanel.Duration(os.clock() - ServerPanel.Started),
			ServerTimer = age and (ServerPanel.Duration(age) .. " (location estimate)") or "Unavailable",
			NextSpawn = age and (ServerPanel.Duration(14400 - age % 14400) .. " (4-hour estimate)") or "Unavailable",
			Elite = #elites > 0 and table.concat(elites, ", ") or "Not found",
			Tyrant = currentSea() == 3 and (found > 0 and (eyes .. "/4 eyes") or "Island not loaded") or "Sea 3 only",
			CakePrince = "Sea 3 only", Leviathan = "Sea 3 only", AncientOne = "Sea 3 only",
			Mirage = present(map, "MysticIsland"), Prehistoric = present(map, "PrehistoricIsland"),
			Frozen = present(locations, "Frozen Dimension"),
			Moon = moon .. string.format(" | %02d:%02d | %s", math.floor(clock), math.floor(clock % 1 * 60),
				(clock >= 18 or clock < 5) and "Night" or "Day"),
			Server = string.format("Sea %s | %d players\nPlaceId: %s\nJobId: %s", tostring(currentSea()), #Players:GetPlayers(), tostring(game.PlaceId), game.JobId),
		}
		if currentSea() == 3 then
			local ok, cake = pcall(invokeCommF, "CakePrinceSpawner", true)
			status.CakePrince = ok and type(cake) == "string" and (cake:match("%d+") and (cake:match("%d+") .. " mobs remaining")
				or cake:gsub("<[^>]+>", "")) or "Unavailable"
			local spyOK, spy = pcall(invokeCommF, "InfoLeviathan", "1")
			status.Leviathan = spyOK and spy == 5 and "Ready to search" or spyOK and type(spy) == "number"
				and (spy == -1 and "Unavailable" or ("Spy progress: " .. spy .. "/5")) or "Unavailable"
			local character = player.Character
			status.AncientOne = "Race V4 not unlocked"
			if character and character:FindFirstChild("RaceTransformed") then
				local raceOK, code, sessions, price = pcall(invokeCommF, "UpgradeRace", "Check")
				if raceOK then
					if code == 0 then status.AncientOne = "Ready for trial"
					elseif code == 2 or code == 4 or code == 7 then status.AncientOne = "Can buy gear: " .. tostring(price or 0) .. " fragments"
					elseif code == 5 then status.AncientOne = "Race upgrades completed"
					elseif code == 8 then status.AncientOne = tostring(math.max(0, 10 - (sessions or 0))) .. " training sessions remaining"
					elseif code == 6 then status.AncientOne = tostring((sessions or 2) - 2) .. "/3 upgrades; train more"
					else status.AncientOne = "More training required" end
				else status.AncientOne = "Unavailable" end
			end
		end
		return status
	end

	ServerPanel.RefreshStatus = LPH_JIT(function()
		local values = ServerPanel.ReadStatus()
		withUIContext(function()
			for key, value in pairs(values) do
				local label = ServerPanel.Labels[key]
				if label and ServerPanel.LastStatus[key] ~= value then label:SetDesc(value); ServerPanel.LastStatus[key] = value end
			end
		end)
	end)

	function ServerPanel.Fetch(reset)
		if ServerPanel.Fetching then return end
		if not reset and ServerPanel.Finished then return end
		if os.clock() < (ServerPanel.RetryAt or 0) then error("Server API cooldown; try again shortly") end
		ServerPanel.Fetching = true
		local ok, result = xpcall(function()
			local request = (env.syn and env.syn.request) or env.http_request or env.request or http_request or request
			local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId)
			if not reset and ServerPanel.Cursor then url ..= "&cursor=" .. HttpService:UrlEncode(ServerPanel.Cursor) end
			local body
			if type(request) == "function" then
				local response = request({ Url = url, Method = "GET", Timeout = 10 })
				assert(type(response) == "table", "Server API returned no response")
				local code = tonumber(response.StatusCode or response.Status)
				if code == 429 then ServerPanel.RetryAt = os.clock() + 30 end
				assert(not code or code >= 200 and code < 300, "Server API HTTP " .. tostring(code))
				body = response.Body
			else body = game:HttpGet(url) end
			local decoded = HttpService:JSONDecode(body)
			assert(type(decoded.data) == "table", "Invalid server API response")
			if state.Generation ~= generation then return end
			if reset then ServerPanel.Servers = {}; ServerPanel.Seen = {} end
			ServerPanel.Seen = ServerPanel.Seen or {}
			for _, server in ipairs(decoded.data) do
				if BossFarm.IsJobId(server.id) and server.id ~= game.JobId and tonumber(server.playing) and tonumber(server.maxPlayers)
					and server.playing < server.maxPlayers and not ServerPanel.Seen[server.id] then
					ServerPanel.Seen[server.id] = true; ServerPanel.Servers[#ServerPanel.Servers + 1] = server
				end
			end
			ServerPanel.Cursor = decoded.nextPageCursor
			ServerPanel.Finished = not ServerPanel.Cursor or ServerPanel.Cursor == ""
			ServerPanel.RenderServers()
		end, debug.traceback)
		ServerPanel.Fetching = false
		if not ok then error(result, 0) end
	end

	function ServerPanel.RenderServers()
		table.sort(ServerPanel.Servers, function(a, b)
			local x, y = ServerPanel.Sort == "Lowest Ping" and (tonumber(a.ping) or math.huge) or a.playing,
				ServerPanel.Sort == "Lowest Ping" and (tonumber(b.ping) or math.huge) or b.playing
			return x == y and a.id < b.id or x < y
		end)
		local values, choices = {}, {}
		for index, server in ipairs(ServerPanel.Servers) do
			if index > 50 then break end
			local label = string.format("%d/%d | %s ms | %s", server.playing, server.maxPlayers, tostring(server.ping or "?"), server.id:sub(1, 8))
			values[#values + 1] = label; choices[label] = server.id
		end
		ServerPanel.Choices = choices
		withUIContext(function()
			ServerPanel.Dropdown:SetValues(values)
			local selection
			for label, id in pairs(choices) do if id == ServerPanel.Selected then selection = label end end
			ServerPanel.Dropdown:SetValue(selection or values[1])
			ServerPanel.BrowserLabel:SetDesc(#ServerPanel.Servers .. " available servers | " .. (ServerPanel.Finished and "All pages loaded" or "More pages available"))
		end)
	end

	function ServerPanel.Join(value, targetPlace)
		local job = BossFarm.DecodeJobId(value)
		assert(job, "Invalid or unsupported JobId")
		local place = tonumber(targetPlace) or game.PlaceId
		assert(SeaByPlaceId[place], "Unsupported server PlaceId")
		local browser = ReplicatedStorage:FindFirstChild("__ServerBrowser")
		assert(browser and browser:IsA("RemoteFunction"), "ReplicatedStorage.__ServerBrowser is unavailable")
		if state.HopPending then notify("A server transfer is already pending.", "manual-hop-busy", 5); return end
		queueResume(true)
		state.HopPending = true
		local ok, err = pcall(function()
			assert(browser:InvokeServer("teleport", job) ~= false, "Server teleport rejected")
		end)
		if not ok then state.HopPending = false; error(err) end
		task.delay(30, function() if state.Generation == generation then state.HopPending = false end end)
	end

	function ServerPanel.Action(callback)
		task.spawn(function()
			if state.Generation ~= generation then return end
			local ok, err = xpcall(callback, debug.traceback)
			if not ok then reportControllerError(err, "Server", "Action"); notify("Server action failed; see console.", "server-action-error", 5) end
		end)
	end

	ServerPanel.HopEvents = {
		{ "berry", "Berry", "cherry" },
		{ "prehistoric", "Prehistoric Island", "mountain" },
		{ "fullmoon", "Full Moon", "moon" },
		{ "nearmoon", "Near Full Moon", "moon" },
		{ "mirage", "Mirage Island", "compass" },
		{ "kitsune", "Kitsune Island", "flame" },
		{ "fruit", "Fruit Spawns", "apple" },
		{ "haki", "Legendary Haki", "sparkles" },
		{ "sword", "Legendary Sword", "swords" },
		{ "castleraid", "Castle Raid", "castle" },
		{ "factory", "Factory Raid", "factory" },
		{ "4hours", "4 Hours Server", "clock" },
		{ "doughking", "Dough King", "crown" },
		{ "ripindra", "Rip Indra", "swords" },
		{ "cakeprince", "Cake Prince", "crown" },
		{ "soulreaper", "Soul Reaper", "skull" },
		{ "cursedcaptain", "Cursed Captain", "ship" },
		{ "tyrant", "Tyrant of the Skies", "bird" },
		{ "darkbeard", "Darkbeard", "skull" },
		{ "elite", "Elite Hunter", "swords" },
	}
	ServerPanel.HopLists = {}

	function ServerPanel.NormalizeEventServers(data)
		local rows, seen, skipped = {}, {}, 0
		local function escape(value)
			return tostring(value):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
		end
		for _, server in ipairs(data) do
			if type(server) == "table" then
				local job = BossFarm.DecodeJobId(server.Jobid or server.Job_id or server.jobId or server.JobId or server.jobid or server.id)
				local seaText = tostring(server.map or server.MAP or server.Sea or server.sea or "")
				local sea = tonumber(seaText) or tonumber(seaText:lower():match("sea%s*(%d)"))
				local rawPlace = server.place_id or server.placeId or server.PlaceId or server.placeid
				local place = tonumber(rawPlace)
				if not rawPlace then
					if sea and sea ~= currentSea() then
						place = ({ [1] = 2753915549, [2] = 4442272183, [3] = 7449423635 })[sea]
					else place = game.PlaceId end
				end
				sea = SeaByPlaceId[place] or sea
				if job and place and SeaByPlaceId[place] and not seen[job] then
					seen[job] = true
					local name = tostring(server.name or server.Name or "Server")
					local players = tostring(server.players or server.Players or "?")
					local color = sea == currentSea() and "#00FF88" or "#FF3333"
					rows[#rows + 1] = {
						JobId = job, PlaceId = place,
						Title = string.format("[%d] %s%s", #rows + 1, name, job == game.JobId and " [Current]" or ""),
						Description = string.format("Name: %s\nPlayers: %s\nSea: %s\nPlaceId: <font color=\"%s\">%s</font>\nJobId: %s",
							escape(name), escape(players), tostring(sea), color, tostring(place), job),
					}
				elseif not job or not place or not SeaByPlaceId[place] then skipped += 1 end
			else skipped += 1 end
		end
		return rows, skipped
	end

	function ServerPanel.RefreshEvent(entry)
		if entry.Busy or os.clock() < (entry.NextRefresh or 0) then return end
		entry.Busy = true
		entry.NextRefresh = os.clock() + 3
		local ok, err = xpcall(function()
			withUIContext(function() entry.Status:SetDesc("Loading server list...") end)
			local data = BossFarm.FetchServers(entry.Slug)
			if state.Generation ~= generation or not ui or ui.Fluent.Unloaded then return end
			local rows, skipped = ServerPanel.NormalizeEventServers(data)
			for index, server in ipairs(rows) do
				if state.Generation ~= generation or ui.Fluent.Unloaded then return end
				withUIContext(function()
					local item = entry.Buttons[index]
					if not item then
						item = {}
						entry.Buttons[index] = item
						item.Button = entry.Tab:AddButton({ Title = server.Title, Description = server.Description,
							Callback = function()
								local selected = item.Server
								if selected then ServerPanel.Action(function()
									if selected.JobId == game.JobId then
										notify("You are already in this server.", "manual-hop-current", 3)
									else ServerPanel.Join(selected.JobId, selected.PlaceId) end
								end) end
							end,
						})
						item.Button.DescLabel.RichText = true
						item.Button.TitleLabel.RichText = false
					end
					item.Server = server
					item.Button:SetTitle(server.Title)
					item.Button:SetDesc(server.Description)
					item.Button.Frame.Visible = true
				end)
				if index % 12 == 0 then task.wait() end
			end
			withUIContext(function()
				for index = #rows + 1, #entry.Buttons do
					entry.Buttons[index].Server = nil
					entry.Buttons[index].Button.Frame.Visible = false
				end
				entry.Tab.ContainerFrame.CanvasPosition = Vector2.zero
				entry.Status:SetDesc(string.format("%d servers | %d unsupported entries skipped", #rows, skipped))
			end)
			notify(#rows > 0 and string.format("Loaded %d servers for %s.", #rows, entry.Title)
				or "No servers found for " .. entry.Title .. ".", "hop-list-" .. entry.Slug, 3)
		end, debug.traceback)
		entry.Busy = false
		if not ok and state.Generation == generation and ui and not ui.Fluent.Unloaded then
			withUIContext(function() entry.Status:SetDesc("Refresh failed. Previous list retained; see console.") end)
			reportControllerError(err, "Server", entry.Slug)
			notify("Could not load " .. entry.Title .. " servers; see console.", "hop-list-error-" .. entry.Slug, 4)
		end
	end

	function ServerPanel.SetupHopTab(tab, slug, title)
		local entry = { Tab = tab, Slug = slug, Title = title, Buttons = {} }
		ServerPanel.HopLists[slug] = entry
		tab:AddSection(title .. " - Server List")
		tab:AddButton({ Title = "Refresh Server", Description = "Reload server list",
			Callback = function() ServerPanel.Action(function() ServerPanel.RefreshEvent(entry) end) end })
		entry.Status = tab:AddParagraph({ Title = "Server List", Content = "Not loaded" })
		return entry
	end

	function ServerPanel.BuildHopTabs(group)
		for _, event in ipairs(ServerPanel.HopEvents) do
			local tab = group:AddTab({ Title = event[2], Icon = "" })
			ServerPanel.SetupHopTab(tab, event[1], event[2])
		end
	end

	function ServerPanel.Build(window)
		local tab = window:AddTab({ Title = "Status And Server", Icon = "server" })
		ServerPanel.Tab = tab; ServerPanel.LastStatus = {}; ServerPanel.Labels = {}
		tab:AddSection("Status")
		for _, entry in ipairs({ {"Timer", "Session Timer"}, {"ServerTimer", "Server Timer"},
			{"NextSpawn", "Next Fist of Darkness / God's Chalice"}, {"Elite", "Elite Hunter"}, {"Tyrant", "Tyrant Eyes"},
			{"CakePrince", "Cake Prince"}, {"Leviathan", "Leviathan / Spy"}, {"Mirage", "Mirage Island"},
			{"Prehistoric", "Prehistoric Island"}, {"Frozen", "Frozen Dimension"}, {"Moon", "Moon Phase"}, {"AncientOne", "Ancient One"} }) do
			ServerPanel.Labels[entry[1]] = tab:AddParagraph({ Title = entry[2], Content = "Loading..." })
		end
		tab:AddSection("Server")
		ServerPanel.Labels.Server = tab:AddParagraph({ Title = "Current Server", Content = "Loading..." })
		tab:AddInput("ServerJobId", { Title = "Input JobId", Default = "", Placeholder = "JobId", Finished = true,
			Callback = function(value) ServerPanel.Input = tostring(value):match("^%s*(.-)%s*$") end })
		tab:AddButton({ Title = "Join JobId", Callback = function() ServerPanel.Action(function() ServerPanel.Join(ServerPanel.Input) end) end })
		tab:AddButton({ Title = "Copy JobId", Callback = function()
			ServerPanel.Action(function()
				local copy = env.setclipboard or setclipboard or env.toclipboard or toclipboard
				assert(type(copy) == "function", "Clipboard is unavailable"); copy(game.JobId)
				notify("JobId copied.", "jobid-copied", 2)
			end)
		end })
		tab:AddButton({ Title = "Rejoin Server", Callback = function() ServerPanel.Action(function() ServerPanel.Join(game.JobId) end) end })
		ServerPanel.BrowserLabel = tab:AddParagraph({ Title = "Server Browser", Content = "Not loaded" })
		local sort = tab:AddDropdown("ServerSort", { Title = "Sort Servers", Values = { "Lowest Players", "Lowest Ping" }, Multi = false, Default = "Lowest Players" })
		ServerPanel.Dropdown = tab:AddDropdown("ServerSelection", { Title = "Selected Server", Values = {}, Multi = false })
		ServerPanel.Dropdown:OnChanged(function(value) ServerPanel.Selected = ServerPanel.Choices[value] end)
		sort:OnChanged(function(value) ServerPanel.Sort = value; ServerPanel.RenderServers() end)
		for _, entry in ipairs({ {"Open Server Browser / Refresh", true}, {"Load More Servers", false} }) do
			local reset = entry[2]
			tab:AddButton({ Title = entry[1], Callback = function() ServerPanel.Action(function() ServerPanel.Fetch(reset) end) end })
		end
		tab:AddButton({ Title = "Join Selected Server", Callback = function() ServerPanel.Action(function() ServerPanel.Join(ServerPanel.Selected) end) end })
		for _, title in ipairs({ "Hop Server", "Hop Server Less People" }) do
			local less = title == "Hop Server Less People"
			tab:AddButton({ Title = title, Callback = function() ServerPanel.Action(function()
				ServerPanel.Sort = "Lowest Players"; ServerPanel.Fetch(true)
				assert(#ServerPanel.Servers > 0, "No available server found")
				ServerPanel.Join(ServerPanel.Servers[less and 1 or math.random(#ServerPanel.Servers)].id)
			end) end })
		end
		task.spawn(function()
			while state.Generation == generation and ui and not ui.Fluent.Unloaded do
				local ok, err = xpcall(ServerPanel.RefreshStatus, debug.traceback)
				if not ok then reportControllerError(err, "Status", "Refresh") end
				task.wait(5)
			end
		end)
	end
end

local function installSidebarSections(window, fluent)
	if window.Section then return end
	local holder, manager = window.TabHolder, window.TabManager
	assert(holder and manager, "Fluent sidebar extension is unavailable")
	local tweenService = game:GetService("TweenService")
	local layout = holder:FindFirstChildOfClass("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	local groups, connections, order = {}, {}, 0
	local info = TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	local function connect(signal, callback)
		local connection = signal:Connect(callback)
		connections[#connections + 1] = connection
		return connection
	end
	local function new(class, properties, parent)
		local object = Instance.new(class)
		for key, value in pairs(properties) do object[key] = value end
		object.Parent = parent
		return object
	end
	local function refresh()
		if holder.Parent then
			holder.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 4)
			window:RefreshTabSelector()
		end
	end
	local originalPosition = manager.GetCurrentTabPos
	manager.GetCurrentTabPos = function(self)
		local tab = self.Tabs[self.SelectedTab]
		if not tab then return 0 end
		local group = groups[tab]
		local frame = group and not group.Opened and group.Header or tab.Frame
		return frame.AbsolutePosition.Y - holder.AbsolutePosition.Y
	end
	local originalSelect = manager.SelectTab
	manager.SelectTab = function(self, index)
		local tab = self.Tabs[index]
		assert(tab, "Invalid Fluent tab index")
		local group = groups[tab]
		if group and not group.Opened then group:SetOpened(true) end
		return originalSelect(self, index)
	end
	connect(layout:GetPropertyChangedSignal("AbsoluteContentSize"), refresh)
	local originalAddTab = window.AddTab
	window.AddTab = function(self, options)
		local tab = originalAddTab(self, options)
		order += 1
		tab.Frame.LayoutOrder = order
		connect(tab.Frame:GetPropertyChangedSignal("AbsolutePosition"), refresh)
		return tab
	end
	function window:Section(options)
		assert(type(options.Title) == "string", "Section requires a Title")
		local icon = fluent:GetIcon(options.Icon)
		order += 1
		local group = { Opened = options.Opened ~= false, Tabs = {}, Tweens = {} }
		group.Frame = new("Frame", {
			Name = "SidebarSection", BackgroundTransparency = 1, BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 30), LayoutOrder = order, ClipsDescendants = true,
		}, holder)
		group.Header = new("TextButton", {
			Name = "Header", Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
			BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 30),
		}, group.Frame)
		group.Icon = new("ImageLabel", {
			BackgroundTransparency = 1, Size = UDim2.fromOffset(16, 16),
			Position = UDim2.fromOffset(8, 7), Image = icon or "", Visible = icon ~= nil,
			ImageColor3 = Color3.fromRGB(210, 210, 220),
		}, group.Header)
		group.Label = new("TextLabel", {
			BackgroundTransparency = 1, Text = options.Title, TextSize = 12,
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
			TextColor3 = Color3.fromRGB(210, 210, 220), TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd, Size = UDim2.new(1, icon and -54 or -36, 1, 0),
			Position = UDim2.fromOffset(icon and 30 or 12, 0),
		}, group.Header)
		group.Chevron = new("ImageLabel", {
			BackgroundTransparency = 1, Image = assert(fluent:GetIcon("chevron-right")),
			Size = UDim2.fromOffset(14, 14), Position = UDim2.new(1, -20, 0, 8),
			Rotation = group.Opened and 90 or 0, ImageColor3 = group.Label.TextColor3,
		}, group.Header)
		group.Body = new("Frame", {
			BackgroundTransparency = 1, BorderSizePixel = 0,
			Position = UDim2.fromOffset(8, 34), Size = UDim2.new(1, -8, 0, 0),
		}, group.Frame)
		new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, group.Body)
		function group:SetOpened(value, instant)
			self.Opened = value == true
			for _, tween in ipairs(self.Tweens) do tween:Cancel() end
			self.Tweens = {}
			local height = #self.Tabs > 0 and 34 + #self.Tabs * 38 - 4 or 30
			local size = UDim2.new(1, 0, 0, self.Opened and height or 30)
			local rotation = self.Opened and 90 or 0
			if instant then
				self.Frame.Size, self.Chevron.Rotation = size, rotation
			else
				self.Tweens = {
					tweenService:Create(self.Frame, info, { Size = size }),
					tweenService:Create(self.Chevron, info, { Rotation = rotation }),
				}
				for _, tween in ipairs(self.Tweens) do tween:Play() end
			end
			refresh()
		end
		function group:AdoptTab(tab)
			assert(not groups[tab], "Tab already belongs to a sidebar section")
			self.Tabs[#self.Tabs + 1] = tab
			groups[tab] = self
			tab.Frame.Parent, tab.Frame.LayoutOrder = self.Body, #self.Tabs
			local label = tab.Frame:FindFirstChildOfClass("TextLabel")
			if label then
				label.Size = UDim2.new(1, -label.Position.X.Offset - 6, 1, 0)
				label.TextTruncate = Enum.TextTruncate.AtEnd
				local function theme()
					self.Label.TextColor3 = label.TextColor3
					self.Icon.ImageColor3, self.Chevron.ImageColor3 = label.TextColor3, label.TextColor3
				end
				theme()
				connect(label:GetPropertyChangedSignal("TextColor3"), theme)
			end
			self.Body.Size = UDim2.new(1, -8, 0, #self.Tabs * 38 - 4)
			connect(tab.Frame:GetPropertyChangedSignal("AbsolutePosition"), refresh)
			self:SetOpened(self.Opened, true)
			return tab
		end
		function group:AddTab(tabOptions)
			return self:AdoptTab(originalAddTab(window, tabOptions))
		end
		connect(group.Header.Activated, function() group:SetOpened(not group.Opened) end)
		self.SidebarSections[#self.SidebarSections + 1] = group
		return group
	end
	window.SidebarSections = {}
	connect(window.Root.Destroying, function()
		for _, group in ipairs(window.SidebarSections) do
			for _, tween in ipairs(group.Tweens) do tween:Cancel() end
		end
		for _, connection in ipairs(connections) do connection:Disconnect() end
	end)
end

local function initializeUI()
	local ok, err = xpcall(function()
		SettingManager:SetFolder("CyborgCodex")
		local saved = SettingManager:LoadAutoConfig()
		if saved then
			for _, key in ipairs({ "cyborgrace", "autosoulguitar", "autoghoulrace", "autottk", "autoyama", "autotushita", "autocdk", "autohakilegendary", "autofarmboss", "autofarmbosshop", "selectedboss",
				"autofactoryhop", "autopirateraidhop", "autofruithop", "autoberryhop", "AutoRandomFruit", "AutoStoreFruit", "TeleportMirageIsland", "TeleportVolcanicIsland", "TeleportKitsuneIsland", "AutoPullLevel",
				"Team", "SelectedWeapon", "AutoBuso", "TurnOnRaceV3", "TurnOnRaceV4", "TurnOnObservationHaki" }) do
				if not explicitFlags[key] then env[key] = saved.Setting[key] end
			end
		end
	end, debug.traceback)
	if not ok then
		log("Config load failed: " .. tostring(err))
		notify("Config could not load; current workflow flags are unchanged.", "config-load-error", 5)
	end
	local _nSrc = game:HttpGet("https://raw.githubusercontent.com/idrisvale-dev/Scripts/refs/heads/master/Library/NoctraLibrary.luau")
	local _nChunk = assert(loadstring(_nSrc, "Noctra"))
	local Noctra = _nChunk()
	assert(type(Noctra) == "table" and type(Noctra.CreateWindow) == "function", "Noctra failed to load")
	local fluent = { Unloaded = false }
	function fluent:CreateWindow(opts)
		local w = Noctra:CreateWindow({
			Name = opts.Title or "Hub",
			Status = opts.SubTitle or "",
			Width = (opts.Size and opts.Size.X.Offset) or 480,
			Height = (opts.Size and opts.Size.Y.Offset) or 360,
			ToggleKey = opts.MinimizeKey or Enum.KeyCode.RightShift,
			Logo = "T",
		})
		local FW = { _w = w, Unloaded = false }
		function FW:Minimize() w:SetVisible(not w.Visible) end
		function FW:Destroy() w:Destroy(); self.Unloaded = true; fluent.Unloaded = true end
		function FW:AddTab(to)
			local t = w:AddTab({ Name = to.Title or to.Name or "Tab", Icon = to.Icon })
			local FT = { _t = t }
			function FT:AddSection(title)
				local titleStr = type(title) == "string" and title or (title and title.Title) or ""
				local s = t:AddSection({ Title = titleStr })
				local FS = {}
				function FS:AddToggle(key, o)
					o = o or {}
					local tog = s:AddToggle({ Name = o.Title or key, Flag = key, Default = o.Default, Callback = o.Callback })
					local proxy = setmetatable({}, {
						__index = function(_, k)
							if k == "Value" then return tog:Get() end
							if k == "OnChanged" then return { Connect = function() end } end
						end,
						__newindex = function(_, k, v) if k == "Value" then tog:Set(v, true) end end,
					})
					function proxy:SetValue(v) tog:Set(v, true) end
					function proxy:Get() return tog:Get() end
					return proxy
				end
				function FS:AddDropdown(key, o)
					o = o or {}
					local dd = s:AddDropdown({ Name = o.Title or key, Flag = key, Options = o.Values or {}, Multi = o.Multi, Default = o.Default, Callback = o.Callback })
					local proxy = setmetatable({}, {
						__index = function(_, k)
							if k == "Value" then return dd:Get() end
						end,
					})
					function proxy:SetValue(v) dd:Set(v, true) end
					function proxy:SetValues(list) dd:SetOptions(list, false) end
					function proxy:Get() return dd:Get() end
					return proxy
				end
				function FS:AddButton(o)
					o = o or {}
					return s:AddButton({ Text = o.Title or o.Text or "Run", Callback = o.Callback })
				end
				function FS:AddInput(key, o)
					o = o or {}
					return s:AddInput({ Name = o.Title or key, Flag = key, Default = o.Default or "", Placeholder = o.Placeholder or "", Callback = o.Callback })
				end
				function FS:AddParagraph(o)
					o = o or {}
					local heading = o.Title or ""
					local lbl = s:AddLabel(heading .. (o.Content and (": " .. o.Content) or ""))
					local prx = {}
					function prx:SetDesc(txt)
						lbl:SetText(heading ~= "" and (heading .. ": " .. (txt or "")) or (txt or ""))
					end
					return prx
				end
				return FS
			end
			return FT
		end
		return FW
	end
	function fluent.Destroy() end
	ui = { Fluent = fluent, Toggles = {}, LastFlags = {}, Syncing = true, SettingManager = SettingManager }
	local identityGetter = env.getthreadidentity or getthreadidentity or getidentity
	if type(identityGetter) == "function" then ui.Identity = identityGetter() end
	env.CyborgCodexUI = ui
	local window = fluent:CreateWindow({
		Title = "Teddy Hub",
		SubTitle = "discord.gg/YYeRQnhQH5",
		TabWidth = 140,
		Size = UDim2.fromOffset(480, 360),
		Acrylic = false,
		Theme = "Dark",
		MinimizeKey = Enum.KeyCode.LeftControl,
	})
	assert(window, "Fluent did not create the window")
	ui.Window = window
	local coreGui = game:GetService("CoreGui")
	local oldButton = coreGui:FindFirstChild("UIBUTTON")
	if oldButton then oldButton:Destroy() end
	local buttonGui = Instance.new("ScreenGui")
	buttonGui.Name = "UIBUTTON"
	buttonGui.ResetOnSpawn = false
	buttonGui.DisplayOrder = 20
	buttonGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	buttonGui.Parent = coreGui
	ui.ToggleGui = buttonGui
	local buttonFrame = Instance.new("Frame")
	buttonFrame.BackgroundTransparency = 1
	buttonFrame.Position = UDim2.new(0.15, 0, 0.16, 0)
	buttonFrame.Size = UDim2.fromOffset(50, 50)
	buttonFrame.Parent = buttonGui
	local imageButton = Instance.new("ImageButton")
	imageButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	imageButton.BorderSizePixel = 0
	imageButton.Size = UDim2.fromScale(1, 1)
	imageButton.Image = "rbxassetid://136103435617044"
	imageButton.Active = true
	imageButton.Draggable = false
	imageButton.Parent = buttonFrame
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = imageButton
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 3
	stroke.Color = Color3.fromRGB(128, 0, 128)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = imageButton
	local inputService = game:GetService("UserInputService")
	local pointer, pointerStart, frameStart, dragged, releaseConnection
	imageButton.InputBegan:Connect(function(input)
		if pointer or (input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch) then return end
		pointer, pointerStart, frameStart, dragged = input, input.Position, buttonFrame.Position, false
		releaseConnection = input.Changed:Connect(function()
			if input.UserInputState ~= Enum.UserInputState.End
				and input.UserInputState ~= Enum.UserInputState.Cancel then return end
			local clicked = not dragged and input.UserInputState == Enum.UserInputState.End
			pointer = nil
			releaseConnection:Disconnect()
			releaseConnection = nil
			if not clicked or state.Generation ~= generation or fluent.Unloaded then return end
			local ok, err = pcall(function() withUIContext(function() window:Minimize() end) end)
			if not ok then reportControllerError(err, "UI", "ToggleButton") end
		end)
	end)
	local dragConnection = inputService.InputChanged:Connect(function(input)
		if not pointer then return end
		if input ~= pointer and not (pointer.UserInputType == Enum.UserInputType.MouseButton1
			and input.UserInputType == Enum.UserInputType.MouseMovement) then return end
		local delta = input.Position - pointerStart
		if delta.Magnitude > 6 then dragged = true end
		if dragged then
			buttonFrame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X,
				frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
		end
	end)
	buttonGui.Destroying:Connect(function()
		dragConnection:Disconnect()
		if releaseConnection then releaseConnection:Disconnect() end
	end)
	installSidebarSections(window, fluent)
	ServerPanel.Build(window)
	local generalGroup = window:Section({ Title = "General Tab", Icon = "", Opened = true })
	local hopGroup = window:Section({ Title = "Hop Tab", Icon = "bird", Opened = false })
	ui.StatusGui = createDynamicStatusIsland()
	local farmTab = generalGroup:AddTab({ Title = "Farm", Icon = "layers" })
	local tab = generalGroup:AddTab({ Title = "Auto Get", Icon = "scroll" })
	for _, option in ipairs({
		{ Key = "AutoPullLevel", Title = "Auto Pull Level", Controller = env.PullLevelCodex },
		{ Key = "cyborgrace", Title = "Auto Cyborg Race", Controller = env.CyborgCodex },
		{ Key = "autosoulguitar", Title = "Auto Soul Guitar", Controller = env.SoulGuitarCodex },
		{ Key = "autoghoulrace", Title = "Auto Ghoul Race", Controller = env.GhoulCodex },
		{ Key = "autottk", Title = "Auto Get TTK", Controller = env.TTKCodex },
		{ Key = "autoyama", Title = "Auto Yama", Controller = env.YamaCodex },
		{ Key = "autotushita", Title = "Auto Tushita", Controller = env.TushitaCodex },
		{ Key = "autocdk", Title = "Auto Cursed Dual Katana", Controller = env.CDKCodex },
		{ Key = "autohakilegendary", Title = "Auto Haki Legendary", Controller = env.HakiCodex },
	}) do
		local key, controller = option.Key, option.Controller
		local toggle = tab:AddToggle(key, { Title = option.Title, Default = env[key] == true })
		ui.Toggles[key] = toggle
		ui.LastFlags[key] = env[key] == true
		toggle:OnChanged(function(value)
			if state.Generation ~= generation or ui.Syncing then return end
			if value then controller.Start() else controller.Stop() end
			ui.LastFlags[key] = value
			saveUISettings()
		end)
	end
	ui.FarmTab = farmTab
	ui.BossDropdown = farmTab:AddDropdown("selectedboss", {
		Title = "Selected Boss", Values = BossFarm.List, Multi = false, Default = env.selectedboss,
	})
	ui.LastBoss = env.selectedboss
	ui.BossDropdown:OnChanged(function(value)
		if state.Generation ~= generation or ui.Syncing or not BossFarm.Definitions[value] then return end
		env.selectedboss = value
		if state.ActiveWorkflow ~= "Ghoul" then BossFarm.Cancel() end
		ui.LastBoss = value
		saveUISettings()
	end)
	for _, option in ipairs({
		{ Key = "autofarmboss", Title = "Auto Farm Boss" },
		{ Key = "autofarmbosshop", Title = "Auto Farm Boss [Hop]" },
	}) do
		local key = option.Key
		local toggle = farmTab:AddToggle(key, { Title = option.Title, Default = env[key] == true })
		ui.Toggles[key] = toggle
		ui.LastFlags[key] = env[key] == true
		toggle:OnChanged(function(value)
			if state.Generation ~= generation or ui.Syncing then return end
			if key == "autofarmboss" then
				if value then env.BossFarmCodex.Start() else env.BossFarmCodex.Stop() end
			else
				env.autofarmbosshop = value
				if state.ActiveWorkflow ~= "Ghoul" then BossFarm.Cancel() end
			end
			ui.LastFlags[key] = value
			saveUISettings()
		end)
	end
	local eventSection = farmTab:AddSection("Event Game")
	for _, name in ipairs({ "Factory", "Pirate", "Fruit", "Berry" }) do
		local entry = GameEvents.States[name]
		local key = entry.Flag
		local toggle = eventSection:AddToggle(key, { Title = entry.Title, Default = env[key] == true })
		ui.Toggles[key], ui.LastFlags[key] = toggle, env[key] == true
		toggle:OnChanged(function(value)
			if state.Generation ~= generation or ui.Syncing then return end
			env[key] = value == true
			GameEvents.Cancel(name)
			if state.ActiveWorkflow == name and not value then stopFastAttack(); cleanupMovement() end
			GameEvents.SetStatus(name, value and "Queued" or "Stopped")
			ui.LastFlags[key] = env[key]
			saveUISettings()
		end)
	end
	local safeSection = farmTab:AddSection("Fruit Safe")
	local randomToggle = safeSection:AddToggle("AutoRandomFruit", { Title = "Auto Random Fruit", Default = env.AutoRandomFruit == true })
	ui.Toggles.AutoRandomFruit, ui.LastFlags.AutoRandomFruit = randomToggle, env.AutoRandomFruit == true
	randomToggle:OnChanged(function(value)
		if state.Generation ~= generation or ui.Syncing then return end
		env.AutoRandomFruit = value == true
		GameEvents.NextRandom = 0
		ui.LastFlags.AutoRandomFruit = env.AutoRandomFruit
		saveUISettings()
	end)
	local storeToggle = safeSection:AddToggle("AutoStoreFruit", { Title = "Auto Store Fruit", Default = env.AutoStoreFruit == true })
	ui.Toggles.AutoStoreFruit, ui.LastFlags.AutoStoreFruit = storeToggle, env.AutoStoreFruit == true
	storeToggle:OnChanged(function(value)
		if state.Generation ~= generation or ui.Syncing then return end
		env.AutoStoreFruit = value == true
		ui.LastFlags.AutoStoreFruit = env.AutoStoreFruit
		saveUISettings()
	end)
	local islandSection = farmTab:AddSection("Island")
	for _, name in ipairs({ "Mirage", "Volcanic", "Kitsune" }) do
		local entry = GameEvents.States[name]
		local key = entry.Flag
		local toggle = islandSection:AddToggle(key, { Title = entry.Title, Default = env[key] == true })
		ui.Toggles[key], ui.LastFlags[key] = toggle, env[key] == true
		toggle:OnChanged(function(value)
			if state.Generation ~= generation or ui.Syncing then return end
			env[key] = value == true
			GameEvents.Cancel(name)
			if state.ActiveWorkflow == name then releaseWorkflow(); state.ActiveWorkflow = nil end
			ui.LastFlags[key] = env[key]
			saveUISettings()
		end)
	end
	local settingTab = generalGroup:AddTab({ Title = "Setting", Icon = "settings" })
	ui.TeamDropdown = settingTab:AddDropdown("SelectedTeam", {
		Title = "Selected Team", Values = { "Pirates", "Marines" }, Multi = false,
		Default = env.Team,
	})
	ui.TeamDropdown:OnChanged(function(value)
		if state.Generation ~= generation or ui.Syncing
			or (value ~= "Pirates" and value ~= "Marines") then return end
		env.Team = value
		Config.Team = value
		state.LastRemote.Team = nil
		saveUISettings()
		task.spawn(ensureTeam)
	end)
	ui.WeaponDropdown = settingTab:AddDropdown("SelectedWeapon", {
		Title = "Selected Weapon", Values = { "Melee", "Sword", "Fruit", "Gun" }, Multi = false,
		Default = env.SelectedWeapon,
	})
	ui.WeaponDropdown:OnChanged(function(value)
		if state.Generation ~= generation or ui.Syncing
			or not table.find({ "Melee", "Sword", "Fruit", "Gun" }, value) then return end
		env.SelectedWeapon = value
		saveUISettings()
	end)
	for _, option in ipairs({
		{ Key = "AutoBuso", Title = "Auto Buso" },
		{ Key = "TurnOnRaceV3", Title = "Turn On Race V3" },
		{ Key = "TurnOnRaceV4", Title = "Turn On Race V4" },
		{ Key = "TurnOnObservationHaki", Title = "Auto Turn On Observation" },
	}) do
		local key = option.Key
		local toggle = settingTab:AddToggle(key, { Title = option.Title, Default = env[key] == true })
		ui.Toggles[key] = toggle
		ui.LastFlags[key] = env[key] == true
		toggle:OnChanged(function(value)
			if state.Generation ~= generation or ui.Syncing then return end
			env[key] = value == true
			if key == "TurnOnRaceV3" then state.LastRaceV3Attempt = -math.huge end
			if key == "TurnOnRaceV4" then state.LastRaceV4Attempt = -math.huge end
			ui.LastFlags[key] = env[key]
			saveUISettings()
		end)
	end
	tab:AddButton({ Title = "Save Config", Callback = function()
		if state.Generation ~= generation then return end
		syncUISettings()
		if saveUISettings() then notify("Configuration saved.", "config-saved", 5) end
	end })
	window:SelectTab(1)
	ui.Syncing = false
	ServerPanel.BuildHopTabs(hopGroup)
	local currentUI = ui
	currentUI.Worker = task.spawn(function()
		while state.Generation == generation and ui == currentUI and not currentUI.Fluent.Unloaded do
			local ok, err = xpcall(syncUISettings, debug.traceback)
			if not ok then reportControllerError(err, "UI", "Sync") end
			task.wait(0.2)
		end
		if currentUI.StatusGui and currentUI.StatusGui.Parent then currentUI.StatusGui:Destroy() end
		if currentUI.ToggleGui then currentUI.ToggleGui:Destroy() end
	end)
end

env.CyborgCodex.StopAll = function()
	env.cyborgrace = false
	env.autosoulguitar = false
	env.autoghoulrace = false
	env.autottk = false
	env.autoyama = false
	env.autotushita = false
	env.autocdk = false
	env.autohakilegendary = false
	env.autofarmboss = false
	env.autofarmbosshop = false
	env.autofactoryhop = false
	env.autopirateraidhop = false
	env.autofruithop = false
	env.autoberryhop = false
	env.AutoRandomFruit = false
	env.AutoStoreFruit = false
	env.AutoPullLevel = false
	env.TeleportMirageIsland = false
	env.TeleportVolcanicIsland = false
	env.TeleportKitsuneIsland = false
	state.Enabled = false
	releaseWorkflow()
end
env.CyborgCodex.Shutdown = function()
	state.Enabled = false
	releaseWorkflow()
	state.Generation += 1
	for _, connection in ipairs(state.Connections) do connection:Disconnect() end
	state.Connections = {}
	if ui then
		local ok, err = pcall(function() ui.Fluent:Destroy() end)
		if not ok then log("Fluent cleanup failed: " .. tostring(err)) end
		if ui.StatusGui and ui.StatusGui.Parent then ui.StatusGui:Destroy() end
		if ui.ToggleGui then ui.ToggleGui:Destroy() end
		if env.CyborgCodexUI == ui then env.CyborgCodexUI = nil end
	end
end

state.Connections[#state.Connections + 1] = RunService.Heartbeat:Connect(function()
	if state.Generation ~= generation then return end
	if state.ActiveWorkflow and not workflowActive(state.ActiveWorkflow) then releaseWorkflow() end
	if state.CombatFollow then
		local ok, err = pcall(updateCombatFollow)
		if not ok then
			stopFastAttack()
			cleanupMovement()
			reportControllerError(err, "Combat", "Follow")
		end
	end
end)

local resumed = env.__CyborgCodexResume == true
env.__CyborgCodexResume = false
if resumed then
	state.ChestCount = 0
	state.SeenChests = {}
end
local uiOk, uiError = xpcall(initializeUI, debug.traceback)
if not uiOk then
	if ui then
		local ok, err = pcall(function() ui.Fluent:Destroy() end)
		if not ok then log("Fluent cleanup failed: " .. tostring(err)) end
		if ui.StatusGui and ui.StatusGui.Parent then ui.StatusGui:Destroy() end
		if ui.ToggleGui then ui.ToggleGui:Destroy() end
		if env.CyborgCodexUI == ui then env.CyborgCodexUI = nil end
		ui = nil
	end
	log("Fluent UI startup failed: " .. tostring(uiError))
	notify("Fluent UI failed to load; see executor console.", "ui-error", 5)
end
state.Worker = true
task.spawn(function()
	while state.Generation == generation do
		local ok, err = xpcall(function()
			local cyborgEnabled, soulEnabled = env.cyborgrace == true, env.autosoulguitar == true
			local bossEnabled = env.autofarmboss == true
			local ghoulEnabled = env.autoghoulrace == true
			local ttkEnabled = env.autottk == true
			local yamaEnabled, tushitaEnabled = env.autoyama == true, env.autotushita == true
			local cdkEnabled = env.autocdk == true
			local hakiEnabled = env.autohakilegendary == true
			state.Enabled = cyborgEnabled or soulEnabled or bossEnabled or ghoulEnabled or (ttkEnabled and not state.TTKCompleted)
				or (yamaEnabled and not SwordGet.States.Yama.Completed) or (tushitaEnabled and not SwordGet.States.Tushita.Completed)
				or (cdkEnabled and not SwordGet.States.CDK.Completed)
				or (hakiEnabled and not Haki.Completed)
				or env.autofactoryhop == true or env.autopirateraidhop == true or env.autofruithop == true or env.autoberryhop == true
				or env.TeleportMirageIsland == true or env.TeleportVolcanicIsland == true
				or env.TeleportKitsuneIsland == true
				or (env.AutoPullLevel == true and not PullLever.Completed)
			if env.AutoPullLevel == true and PullLever.Completed then
				notify("Auto Pull Level completed: Temple lever pulled.", "pull-level-complete", 5)
			end
			if hakiEnabled and Haki.Completed then
				notify("Auto Haki Legendary completed: Pure Red, Winter Sky and Snow White are owned.", "haki-complete", 5)
			end
			if ttkEnabled and state.TTKCompleted then notify("Auto Get TTK completed: True Triple Katana is owned.", "ttk-complete", 5) end
			for name, controller in pairs(SwordGet.States) do
				local item = controller.InventoryKey or name
				if env[controller.Flag] == true and not controller.Completed and TTK.Snapshot().Owned[item] then SwordGet.Complete(name) end
				if env[controller.Flag] == true and controller.Completed then notify("Completed: " .. item .. " is already owned.", name .. "-complete", 5) end
			end
			local data = player:FindFirstChild("Data")
			local race = data and data:FindFirstChild("Race")
			local cyborgOwned = race ~= nil and race.Value == "Cyborg"
			local owner = chooseWorkflow(cyborgEnabled, soulEnabled, cyborgOwned, bossEnabled, ghoulEnabled, ttkEnabled, yamaEnabled, tushitaEnabled, cdkEnabled, hakiEnabled)
			if owner ~= state.ActiveWorkflow or (owner == "Boss" and state.BossSelection ~= env.selectedboss) then
				releaseWorkflow()
				state.ActiveWorkflow = owner
				state.NextAction = 0
				if owner == "Boss" then state.BossSelection = env.selectedboss end
			end
			if not ensureTeam() then
				if owner == "Boss" then BossFarm.SetStatus("Waiting to join " .. Config.Team) end
				return
			end
			if cyborgEnabled and cyborgOwned then notify("Cyborg Race is already owned; completed.", "owned", 5) end
			if ghoulEnabled and owner ~= "Ghoul" then
				Ghoul.Trace("WaitingWorkflow")
				Ghoul.SetStatus("Waiting for " .. tostring(owner) .. " workflow")
			end
			if owner ~= "Boss" and owner ~= "Ghoul" then BossFarm.SetStatus("Idle") end
			for name, controller in pairs(SwordGet.States) do
				if env[controller.Flag] == true and not controller.Completed and owner ~= name then SwordGet.SetStatus(name, "Waiting for " .. tostring(owner) .. " workflow") end
			end
			for name, entry in pairs(GameEvents.States) do
				if env[entry.Flag] == true and owner ~= name then GameEvents.SetStatus(name, "Waiting for " .. tostring(owner) .. " workflow") end
			end
			if owner == "PullLever" then
				PullLever.Step()
			elseif GameEvents.States[owner] then
				GameEvents.Step(owner)
			elseif owner == "Haki" then
				Haki.Step()
			elseif owner == "Yama" or owner == "Tushita" or owner == "CDK" then
				SwordGet.Step(owner)
			elseif owner == "TTK" then
				TTK.Step()
			elseif owner == "Boss" then
				BossFarm.Step()
			elseif owner == "Ghoul" then
				Ghoul.Step()
			elseif owner == "Cyborg" then
				if soulEnabled then notify("Soul Guitar is waiting for the active Cyborg workflow.", "soul-priority", 5) end
				runStep()
			elseif owner == "SoulGuitar" then
				runSoulGuitarStep()
			end
		end, debug.traceback)
		if not ok then
			reportControllerError(err)
			local cleanupOk, cleanupErr = pcall(function() stopFastAttack(); cleanupMovement() end)
			if not cleanupOk then print("[Teddy Hub][ERROR][Cleanup] " .. tostring(cleanupErr)) end
			notify("Controller error; full traceback printed in console.", "controller-error", 5)
		end
		task.wait(Config.ActionDelay)
	end
	if state.Generation == generation then state.Worker = false end
end)
task.spawn(function()
	while state.Generation == generation do
		GameEvents.RandomBusy = true
		local randomOk, randomError = xpcall(GameEvents.RandomStep, debug.traceback)
		GameEvents.RandomBusy = false
		if not randomOk then reportControllerError(randomError, "FruitSafe", "Random") end
		local ok, err = xpcall(GameEvents.StoreStep, debug.traceback)
		if not ok then reportControllerError(err, "FruitSafe", "Store") end
		task.wait(1)
	end
end)
--log("Standalone controller ready. Controls: cyborgrace / autosoulguitar / autoghoulrace / autottk / autoyama / autotushita / autocdk / autohakilegendary / autofarmboss / autofarmbosshop / selectedboss / autofactoryhop / autopirateraidhop / autofruithop / AutoStoreFruit.")
-------
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer
local Backpack = LP.Backpack
local Enemies = Workspace:WaitForChild("Enemies")
local Characters = Workspace:WaitForChild("Characters")
local Net = RS.Modules.Net
local atk = Net["RE/RegisterAttack"]
local hit = Net["RE/RegisterHit"]
local Remote, RemoteId
for _, v in next, {RS.Util, RS.Common, RS.Remotes, RS.Assets, RS.FX} do
    for _, x in next, v:GetChildren() do
        if x:IsA("RemoteEvent") and x:GetAttribute("Id") then
            Remote = x
            RemoteId = x:GetAttribute("Id")
        end
    end
    state.Connections[#state.Connections + 1] = v.ChildAdded:Connect(function(x)
        if x:IsA("RemoteEvent") and x:GetAttribute("Id") then
            Remote = x
            RemoteId = x:GetAttribute("Id")
        end
    end)
end

local FastHit = {Rate = 0.036}
function FastHit:GetMob(c, f)
    local p = c:GetPivot().Position
    local t = {}
    for _, m in next, f:GetChildren() do
        local h = m:FindFirstChild("Humanoid")
        local r = m:FindFirstChild("HumanoidRootPart")
        if isAttackTarget(m) and h and r and h.Health > 0 and (r.Position - p).Magnitude <= 60 then
            t[#t + 1] = m
        end
    end
    return t
end
function FastHit:Collect(c)
    local t = {}
    local a = self:GetMob(c, Enemies)
    local b = self:GetMob(c, Characters)
    for i = 1, #a do t[#t + 1] = a[i] end
    for i = 1, #b do t[#t + 1] = b[i] end
    return t
end
function FastHit:Fast()
    if not attackActive() then return end
    local c = LP.Character
    if not c then return end
    local list = self:Collect(c)
    if #list < 1 then return end
    local parts = {}
    for i = 1, #list do
        local h = list[i]:FindFirstChild("Head") or list[i].PrimaryPart
        if h then parts[#parts + 1] = {list[i], h} end
    end
    if #parts < 1 then return end
    atk:FireServer(FastHit.Rate)
    hit:FireServer(parts[1][2], parts)
end

local function pmtHit()
    if not attackActive() then return end
    local c = LP.Character
    if not c then return end
    local r = c:FindFirstChild("HumanoidRootPart")
    if not r then return end
    local gather = {}
    local function scan(f)
        for _, m in next, f:GetChildren() do
            local h = m:FindFirstChild("Humanoid")
            local hr = m:FindFirstChild("HumanoidRootPart")
            if isAttackTarget(m) and h and hr and h.Health > 0 and m ~= c and (hr.Position - r.Position).Magnitude <= 60 then
                for _, v in next, m:GetChildren() do
                    if v:IsA("BasePart") then gather[#gather + 1] = {m, v} end
                end
            end
        end
    end
    scan(Enemies)
    scan(Characters)
    if #gather < 1 then return end
    local seed = Net.seed:InvokeServer()
    if not attackActive() or LP.Character ~= c then return end
    for _, entry in ipairs(gather) do
        if not isAttackTarget(entry[1]) then return end
    end
    atk:FireServer()
    local head = gather[1][1]:FindFirstChild("Head")
    if not head then return end
    hit:FireServer(head, gather, {})
    if Remote then
        local n = math.floor(Workspace:GetServerTimeNow() / 10 % 10) + 1
        Remote:FireServer(("RE/RegisterHit"):gsub(".", function(s) return string.char(bit32.bxor(s:byte(), n)) end), bit32.bxor(RemoteId + 909090, seed * 2), head, gather)
    end
end

local cameraStopped = false

task.spawn(function()
    while state.Generation == generation and task.wait(FastHit.Rate) do
        if not attackActive() or not state.FastAttackTarget then continue end
        if not cameraStopped then
            local ok, err = pcall(function() require(RS.Util.CameraShaker):Stop() end)
            cameraStopped = true
            if not ok then log("CameraShaker stop failed: " .. tostring(err)) end
        end
        local ok, err = pcall(function() FastHit:Fast() end)
        if not ok and os.clock() - (state.LastSupplementalError or 0) >= 5 then
            state.LastSupplementalError = os.clock()
            log("Supplemental FastHit failed: " .. tostring(err))
        end
    end
end)

state.Connections[#state.Connections + 1] = RunService.Heartbeat:Connect(function()
    if state.Generation ~= generation or not attackActive() or not state.FastAttackTarget then return end
    local ok, err = pcall(pmtHit)
    if not ok and os.clock() - (state.LastSeedAttackError or 0) >= 5 then
        state.LastSeedAttackError = os.clock()
        log("Seed fast attack failed: " .. tostring(err))
    end
end)

task.spawn(function()
    while state.Generation == generation and task.wait() do
        if not attackActive() or not state.FastAttackTarget then continue end
        local c = LP.Character
        if not c then continue end
        local r = c:FindFirstChild("HumanoidRootPart")
        if not r then continue end
        local id = tostring(LP.UserId):sub(2, 4) .. tostring(coroutine.running()):sub(11, 15)
        local fired = false
        for _, m in next, Enemies:GetChildren() do
            local h = m:FindFirstChild("HumanoidRootPart")
            local u = m:FindFirstChild("Humanoid")
            if isAttackTarget(m) and h and u and u.Health > 0 and (h.Position - r.Position).Magnitude <= 60 then
                if not fired then atk:FireServer(); fired = true end
                hit:FireServer(h, {{m, h}}, nil, nil, id)
            end
        end
    end
end)
----
]=], "CyborgCodex-Standalone")

if not chunk then
	error("[Teddy Hub] Compile failed: " .. tostring(v))
end

chunk()
assert(genv.CyborgCodexUI and genv.CyborgCodexUI.Toggles.TeleportMirageIsland and genv.CyborgCodexUI.Toggles.TeleportVolcanicIsland and genv.CyborgCodexUI.Toggles.TeleportKitsuneIsland and genv.CyborgCodexUI.Toggles.AutoPullLevel and genv.CyborgCodexUI.Toggles.AutoRandomFruit and genv.CyborgCodexUI.Toggles.AutoStoreFruit, "IslandUpdated: Island / Pull Level / Berry / Random Fruit toggles failed to initialize; check UI startup errors")
