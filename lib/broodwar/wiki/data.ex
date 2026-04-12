defmodule Broodwar.Wiki.Data do
  @moduledoc """
  Static reference data for StarCraft: Brood War races, units, and buildings.

  All data is hardcoded — BW's game data has been stable since patch 1.16 (2008).
  """

  # ---------------------------------------------------------------------------
  # Races
  # ---------------------------------------------------------------------------

  @races [
    %{
      slug: "terran",
      name: "Terran",
      letter: "T",
      tagline: "Adaptable human forces with strong defensive capabilities",
      description:
        "The Terran are human exiles from Earth, scraping by on the fringes of the galaxy. " <>
          "Their military combines conventional ballistic weaponry, powered armor, and nuclear technology. " <>
          "Terran buildings can lift off and relocate, and many units can be repaired by SCVs. " <>
          "The faction excels at positional play, turtling behind bunkers and siege tanks, then " <>
          "transitioning into powerful late-game armies with Battlecruisers or mech compositions.",
      playstyle:
        "Terran is the most mechanically flexible race. Players can wall off with supply depots, " <>
          "siege up behind tanks, harass with vulture speed, or go for bio pushes with marine/medic. " <>
          "Strong macro play and multi-pronged attacks are hallmarks of top Terran players.",
      strengths: [
        "Buildings can lift off and fly to new locations",
        "Siege tanks provide devastating area control",
        "Mechanical units can be repaired to full health",
        "ComSat Station provides instant map vision anywhere",
        "Strong defensive options with bunkers and turrets"
      ],
      weaknesses: [
        "Slow early-game expansion compared to Zerg",
        "Supply depots are vulnerable and require space",
        "Most units are relatively slow without upgrades",
        "Late-game transitions can be difficult to execute"
      ]
    },
    %{
      slug: "protoss",
      name: "Protoss",
      letter: "P",
      tagline: "Ancient psionic warriors with powerful but costly technology",
      description:
        "The Protoss are an ancient alien race with immense psionic abilities and advanced technology. " <>
          "Their units are individually powerful but expensive, protected by regenerating plasma shields " <>
          "on top of their base hit points. Protoss buildings must be placed within power fields generated " <>
          "by Pylons, making power management a critical aspect of play. Their warp-in mechanic means " <>
          "buildings construct themselves once warped in, freeing Probes to keep mining.",
      playstyle:
        "Protoss units are expensive but powerful — quality over quantity. Gateway units like Zealots " <>
          "and Dragoons form the backbone, while tech units like High Templar (Psionic Storm) and Reavers " <>
          "(Scarab drops) provide game-ending splash damage. Protoss excels at timing attacks and " <>
          "decisive engagements where superior unit quality overwhelms opponents.",
      strengths: [
        "Plasma shields regenerate over time on all units and buildings",
        "Probes can warp in buildings and immediately return to mining",
        "Powerful splash damage options (Psionic Storm, Scarabs, Archons)",
        "Observers provide permanent cloaked detection",
        "Recall and Stasis Field offer unique tactical options"
      ],
      weaknesses: [
        "Most expensive units in the game",
        "Dependent on Pylon power fields for building placement",
        "Losing Pylons can disable groups of buildings",
        "Limited early-game harassment options",
        "Poor at fighting in small chokes with large unit models"
      ]
    },
    %{
      slug: "zerg",
      name: "Zerg",
      letter: "Z",
      tagline: "Relentless swarm that overwhelms through numbers and adaptation",
      description:
        "The Zerg are a ravenous insectoid swarm driven by the Overmind to achieve genetic perfection " <>
          "by assimilating other species. All Zerg units are biological, produced from larvae at Hatcheries. " <>
          "The Zerg economy revolves around Hatcheries — each one produces larvae, so expanding gives both " <>
          "resources and production capacity. Creep spreads from Hatcheries and Creep Colonies, and most " <>
          "Zerg buildings must be placed on creep.",
      playstyle:
        "Zerg is the macro race — fast expansion, high larva production, and swarming the opponent " <>
          "with waves of units. Zerg players must constantly scout to react appropriately: morphing the " <>
          "right units at the right time is key, since larvae are a shared resource between workers and " <>
          "army. The best Zerg players combine relentless aggression with greedy economic play.",
      strengths: [
        "Fastest expansion rate — each Hatchery provides both economy and production",
        "All units produced from larvae, allowing rapid tech switches",
        "Burrowing allows ambushes and hidden unit positioning",
        "Cheapest units enable cost-efficient trades",
        "Overlords provide supply and mobile detection (with upgrade)"
      ],
      weaknesses: [
        "Units are individually weak compared to other races",
        "Must sacrifice a Drone to build each structure",
        "Dependent on creep for building placement",
        "Limited anti-air options in the early game",
        "Overlords are slow and vulnerable, losing them costs supply"
      ]
    }
  ]

  def races, do: @races
  def race(slug), do: Enum.find(@races, &(&1.slug == slug))

  # ---------------------------------------------------------------------------
  # Units
  # ---------------------------------------------------------------------------

  @units [
    # -- Terran --
    %{
      slug: "scv",
      name: "SCV",
      race: "terran",
      type: :ground,
      minerals: 50,
      gas: 0,
      supply: 1,
      hp: 60,
      armor: 0,
      damage: 5,
      built_from: "command-center",
      description:
        "The Space Construction Vehicle is the Terran worker unit. SCVs harvest minerals and vespene gas, " <>
          "construct buildings, and can repair mechanical units and structures. Unlike Probes, SCVs must " <>
          "remain present for the entire duration of construction."
    },
    %{
      slug: "marine",
      name: "Marine",
      race: "terran",
      type: :ground,
      minerals: 50,
      gas: 0,
      supply: 1,
      hp: 40,
      armor: 0,
      damage: 6,
      built_from: "barracks",
      description:
        "The backbone of the Terran infantry. Marines are cheap, versatile, and can attack both ground " <>
          "and air units. With Stim Pack researched, they gain a burst of attack and movement speed at the " <>
          "cost of 10 HP. Marines are effective in large numbers, especially when paired with Medics."
    },
    %{
      slug: "firebat",
      name: "Firebat",
      race: "terran",
      type: :ground,
      minerals: 50,
      gas: 25,
      supply: 1,
      hp: 50,
      armor: 1,
      damage: 8,
      built_from: "barracks",
      description:
        "Heavy infantry equipped with flame throwers. Firebats deal concussive splash damage, making " <>
          "them effective against small units like Zerglings. They can use Stim Pack and benefit from " <>
          "bunker placement. Requires an Academy."
    },
    %{
      slug: "medic",
      name: "Medic",
      race: "terran",
      type: :ground,
      minerals: 50,
      gas: 25,
      supply: 1,
      hp: 60,
      armor: 1,
      damage: 0,
      built_from: "barracks",
      description:
        "Support infantry that heals nearby biological units. Medics are essential in marine-based " <>
          "compositions, dramatically increasing the staying power of bio armies. They can also use " <>
          "Restoration to remove negative effects and Optical Flare to blind detector units."
    },
    %{
      slug: "ghost",
      name: "Ghost",
      race: "terran",
      type: :ground,
      minerals: 25,
      gas: 75,
      supply: 1,
      hp: 45,
      armor: 0,
      damage: 10,
      built_from: "barracks",
      description:
        "Elite covert operative with personal cloaking and powerful abilities. Ghosts can call down " <>
          "Nuclear Strikes for massive area damage, use Lockdown to disable mechanical units, and cloak " <>
          "to move invisibly. Requires a Covert Ops attached to a Science Facility."
    },
    %{
      slug: "vulture",
      name: "Vulture",
      race: "terran",
      type: :ground,
      minerals: 75,
      gas: 0,
      supply: 2,
      hp: 80,
      armor: 0,
      damage: 20,
      built_from: "factory",
      description:
        "Fast hover bike that excels at harassment and map control. Vultures deal concussive damage " <>
          "(less effective against large units) and can plant Spider Mines — burrowed explosives that " <>
          "detonate when enemies approach. Their speed makes them ideal for worker harassment."
    },
    %{
      slug: "siege-tank",
      name: "Siege Tank",
      race: "terran",
      type: :ground,
      minerals: 150,
      gas: 100,
      supply: 2,
      hp: 150,
      armor: 1,
      damage: 30,
      built_from: "factory",
      description:
        "Heavy assault vehicle that can switch between mobile tank mode (30 damage) and stationary " <>
          "siege mode (70 explosive splash damage with 12 range). Siege tanks are the cornerstone of " <>
          "Terran positional play, creating kill zones that are extremely difficult to push into."
    },
    %{
      slug: "goliath",
      name: "Goliath",
      race: "terran",
      type: :ground,
      minerals: 100,
      gas: 50,
      supply: 2,
      hp: 125,
      armor: 1,
      damage: 12,
      built_from: "factory",
      description:
        "Bipedal mech walker with twin autocannons and anti-air missile launchers. Goliaths provide " <>
          "strong anti-air support for mech armies, with 20 explosive damage against air targets (22 " <>
          "range with Charon Boosters). Requires an Armory."
    },
    %{
      slug: "wraith",
      name: "Wraith",
      race: "terran",
      type: :air,
      minerals: 150,
      gas: 100,
      supply: 2,
      hp: 120,
      armor: 0,
      damage: 8,
      built_from: "starport",
      description:
        "Light air superiority fighter with ground attack capability. Wraiths can cloak with the " <>
          "Apollo Reactor upgrade, making them effective for harassment. Their air-to-air attack deals " <>
          "20 explosive damage, making them decent dogfighters."
    },
    %{
      slug: "dropship",
      name: "Dropship",
      race: "terran",
      type: :air,
      minerals: 100,
      gas: 100,
      supply: 2,
      hp: 150,
      armor: 1,
      damage: 0,
      built_from: "starport",
      description:
        "Armored transport that can carry up to 8 supply worth of ground units. Dropships enable " <>
          "multi-pronged attacks, cliff drops, and harassment strategies. Essential for tank drops " <>
          "and marine/medic drops in the mid and late game."
    },
    %{
      slug: "valkyrie",
      name: "Valkyrie",
      race: "terran",
      type: :air,
      minerals: 250,
      gas: 125,
      supply: 3,
      hp: 200,
      armor: 2,
      damage: 6,
      built_from: "starport",
      description:
        "Heavy anti-air frigate that fires volleys of Halo Rockets. Each attack launches 8 missiles " <>
          "that deal splash damage, making Valkyries devastating against groups of air units like " <>
          "Mutalisks or Scourge. Requires a Control Tower and an Armory."
    },
    %{
      slug: "science-vessel",
      name: "Science Vessel",
      race: "terran",
      type: :air,
      minerals: 100,
      gas: 225,
      supply: 2,
      hp: 200,
      armor: 1,
      damage: 0,
      built_from: "starport",
      description:
        "Flying detector and support caster. Science Vessels can use Defensive Matrix (absorbs 250 " <>
          "damage on a target unit), EMP Shockwave (drains shields and energy in an area), and " <>
          "Irradiate (deals damage over time to biological units). Essential for detection and countering " <>
          "Protoss shields."
    },
    %{
      slug: "battlecruiser",
      name: "Battlecruiser",
      race: "terran",
      type: :air,
      minerals: 400,
      gas: 300,
      supply: 6,
      hp: 500,
      armor: 3,
      damage: 25,
      built_from: "starport",
      description:
        "The Terran capital ship. Battlecruisers have massive HP, strong attacks against both ground " <>
          "and air, and can be equipped with the Yamato Cannon — a devastating 260-damage single-target " <>
          "ability. Expensive and slow to build, but extremely powerful in numbers."
    },

    # -- Protoss --
    %{
      slug: "probe",
      name: "Probe",
      race: "protoss",
      type: :ground,
      minerals: 50,
      gas: 0,
      supply: 1,
      hp: 20,
      shields: 20,
      armor: 0,
      damage: 5,
      built_from: "nexus",
      description:
        "The Protoss worker unit. Probes harvest resources and warp in buildings by initiating a " <>
          "dimensional recall — once started, the Probe is free to return to work while the building " <>
          "constructs itself. This gives Protoss an economic advantage during construction."
    },
    %{
      slug: "zealot",
      name: "Zealot",
      race: "protoss",
      type: :ground,
      minerals: 100,
      gas: 0,
      supply: 2,
      hp: 100,
      shields: 60,
      armor: 1,
      damage: 8,
      built_from: "gateway",
      description:
        "Psionic warrior that attacks twice per swing for 16 total damage. Zealots are the frontline " <>
          "of Protoss armies, absorbing damage with their high HP and shields. With the Leg Enhancements " <>
          "upgrade from the Citadel of Adun, they gain a significant speed boost."
    },
    %{
      slug: "dragoon",
      name: "Dragoon",
      race: "protoss",
      type: :ground,
      minerals: 125,
      gas: 50,
      supply: 2,
      hp: 100,
      shields: 80,
      armor: 1,
      damage: 20,
      built_from: "gateway",
      description:
        "Ranged assault walker piloted by a mortally wounded Protoss warrior. Dragoons deal 20 " <>
          "explosive damage and can attack both ground and air. Their Singularity Charge upgrade " <>
          "extends their range to 6. They are the workhorse of Protoss armies but have notoriously " <>
          "poor pathfinding."
    },
    %{
      slug: "high-templar",
      name: "High Templar",
      race: "protoss",
      type: :ground,
      minerals: 50,
      gas: 150,
      supply: 2,
      hp: 40,
      shields: 40,
      armor: 0,
      damage: 0,
      built_from: "gateway",
      description:
        "Powerful psionic caster. High Templar are fragile but carry one of the most devastating " <>
          "abilities in the game: Psionic Storm, which deals 112 damage over 3 seconds in an area. " <>
          "They can also cast Hallucination to create decoy units. Two High Templar can merge into an Archon."
    },
    %{
      slug: "dark-templar",
      name: "Dark Templar",
      race: "protoss",
      type: :ground,
      minerals: 125,
      gas: 100,
      supply: 2,
      hp: 80,
      shields: 40,
      armor: 1,
      damage: 40,
      built_from: "gateway",
      description:
        "Permanently cloaked melee assassin with extremely high damage. Dark Templar deal 40 damage " <>
          "per hit and can only be seen by detectors. They are devastating in the early-mid game before " <>
          "opponents have reliable detection. Two Dark Templar can merge into a Dark Archon."
    },
    %{
      slug: "archon",
      name: "Archon",
      race: "protoss",
      type: :ground,
      minerals: 100,
      gas: 300,
      supply: 4,
      hp: 10,
      shields: 350,
      armor: 0,
      damage: 30,
      built_from: "merge",
      description:
        "A being of pure psionic energy formed by merging two High Templar. Archons have massive " <>
          "shields (350) but only 10 HP, and deal 30 splash damage. They are excellent against " <>
          "biological units and mutalisk flocks. Their shields regenerate, making them very durable."
    },
    %{
      slug: "dark-archon",
      name: "Dark Archon",
      race: "protoss",
      type: :ground,
      minerals: 250,
      gas: 200,
      supply: 4,
      hp: 25,
      shields: 200,
      armor: 1,
      damage: 0,
      built_from: "merge",
      description:
        "Formed by merging two Dark Templar. Dark Archons are spellcasters with unique abilities: " <>
          "Mind Control permanently converts an enemy unit, Maelstrom freezes biological units in an area, " <>
          "and Feedback deals damage equal to a target's remaining energy. Rarely seen but powerful."
    },
    %{
      slug: "reaver",
      name: "Reaver",
      race: "protoss",
      type: :ground,
      minerals: 200,
      gas: 100,
      supply: 4,
      hp: 100,
      shields: 80,
      armor: 0,
      damage: 100,
      built_from: "robotics-facility",
      description:
        "Slow-moving siege unit that launches Scarabs — autonomous drones that deal 100 splash damage. " <>
          "Reavers are devastating when dropped from Shuttles into mineral lines or army flanks. " <>
          "Scarabs must be built individually (15 minerals each) and can sometimes miss or be destroyed."
    },
    %{
      slug: "shuttle",
      name: "Shuttle",
      race: "protoss",
      type: :air,
      minerals: 200,
      gas: 0,
      supply: 2,
      hp: 60,
      shields: 60,
      armor: 1,
      damage: 0,
      built_from: "robotics-facility",
      description:
        "Protoss transport ship. Shuttles carry up to 8 supply of ground units and are essential " <>
          "for Reaver drops, one of Protoss's most powerful harassment strategies. Speed upgrade " <>
          "from the Robotics Support Bay makes them significantly faster."
    },
    %{
      slug: "observer",
      name: "Observer",
      race: "protoss",
      type: :air,
      minerals: 25,
      gas: 75,
      supply: 1,
      hp: 40,
      shields: 20,
      armor: 0,
      damage: 0,
      built_from: "robotics-facility",
      description:
        "Permanently cloaked flying detector. Observers are essential for scouting and detecting " <>
          "cloaked/burrowed units. They are fragile but invisible, making them perfect for keeping " <>
          "tabs on opponent expansions and army movements."
    },
    %{
      slug: "corsair",
      name: "Corsair",
      race: "protoss",
      type: :air,
      minerals: 150,
      gas: 100,
      supply: 2,
      hp: 100,
      shields: 80,
      armor: 1,
      damage: 5,
      built_from: "stargate",
      description:
        "Fast air-to-air interceptor with splash damage. Corsairs excel at destroying groups of " <>
          "Mutalisks and Overlords. They can also cast Disruption Web, which prevents ground units " <>
          "and buildings beneath it from attacking — powerful for neutering static defenses."
    },
    %{
      slug: "scout",
      name: "Scout",
      race: "protoss",
      type: :air,
      minerals: 275,
      gas: 125,
      supply: 3,
      hp: 150,
      shields: 100,
      armor: 0,
      damage: 8,
      built_from: "stargate",
      description:
        "Heavy air unit with strong anti-air capabilities. Scouts have 28 explosive damage against air " <>
          "targets but weak ground attack. Despite their stats on paper, Scouts are rarely used in " <>
          "competitive play because other options (Corsairs, Carriers) are more cost-efficient."
    },
    %{
      slug: "carrier",
      name: "Carrier",
      race: "protoss",
      type: :air,
      minerals: 350,
      gas: 250,
      supply: 6,
      hp: 300,
      shields: 150,
      armor: 4,
      damage: 6,
      built_from: "stargate",
      description:
        "Protoss capital ship that launches up to 8 Interceptors (25 minerals each). Each Interceptor " <>
          "deals 6 damage, for a potential 48 damage per volley. Carriers are powerful in numbers and " <>
          "can kite effectively, but require significant investment to reach critical mass."
    },
    %{
      slug: "arbiter",
      name: "Arbiter",
      race: "protoss",
      type: :air,
      minerals: 100,
      gas: 350,
      supply: 4,
      hp: 200,
      shields: 150,
      armor: 1,
      damage: 10,
      built_from: "stargate",
      description:
        "Support capital ship with a passive cloaking field that hides all friendly units beneath it. " <>
          "Arbiters can cast Recall (teleports units to the Arbiter's location) and Stasis Field " <>
          "(freezes all units in an area, making them invulnerable and unable to act). Game-changing " <>
          "in late-game engagements."
    },

    # -- Zerg --
    %{
      slug: "drone",
      name: "Drone",
      race: "zerg",
      type: :ground,
      minerals: 50,
      gas: 0,
      supply: 1,
      hp: 40,
      armor: 0,
      damage: 5,
      built_from: "hatchery",
      description:
        "The Zerg worker unit. Drones harvest resources and morph into buildings — the Drone is " <>
          "consumed in the process, unlike other races' workers. This means each building costs an " <>
          "additional worker, making Zerg building decisions more impactful."
    },
    %{
      slug: "zergling",
      name: "Zergling",
      race: "zerg",
      type: :ground,
      minerals: 50,
      gas: 0,
      supply: 1,
      hp: 35,
      armor: 0,
      damage: 5,
      built_from: "hatchery",
      description:
        "Fast, cheap melee attacker produced two at a time from a single larva. Zerglings are the " <>
          "backbone of early aggression and remain useful throughout the game for run-bys and surrounds. " <>
          "Adrenal Glands (from Hive) makes them attack nearly twice as fast, turning them deadly."
    },
    %{
      slug: "hydralisk",
      name: "Hydralisk",
      race: "zerg",
      type: :ground,
      minerals: 75,
      gas: 25,
      supply: 1,
      hp: 80,
      armor: 0,
      damage: 10,
      built_from: "hatchery",
      description:
        "Ranged attacker that fires needle spines at ground and air targets. Hydralisks are versatile " <>
          "and efficient, forming the core of many Zerg compositions. They can morph into Lurkers " <>
          "with the Lurker Aspect upgrade. Speed and range upgrades are essential."
    },
    %{
      slug: "lurker",
      name: "Lurker",
      race: "zerg",
      type: :ground,
      minerals: 125,
      gas: 125,
      supply: 2,
      hp: 125,
      armor: 1,
      damage: 20,
      built_from: "hydralisk",
      description:
        "Morphed from Hydralisks, Lurkers burrow into the ground and attack with subterranean spines " <>
          "that deal 20 splash damage in a line. They can only attack while burrowed, making detection " <>
          "essential for opponents. Lurkers are the Zerg's primary area-denial unit."
    },
    %{
      slug: "mutalisk",
      name: "Mutalisk",
      race: "zerg",
      type: :air,
      minerals: 100,
      gas: 100,
      supply: 2,
      hp: 120,
      armor: 0,
      damage: 9,
      built_from: "hatchery",
      description:
        "Agile flying attacker whose Glave Wurm bounces to hit up to 3 targets (9, 3, 1 damage). " <>
          "Mutalisks are the premier Zerg harassment unit, fast enough to pick off workers and retreat " <>
          "before the opponent can respond. They can morph into Guardians or Devourers at a Greater Spire."
    },
    %{
      slug: "scourge",
      name: "Scourge",
      race: "zerg",
      type: :air,
      minerals: 25,
      gas: 75,
      supply: 1,
      hp: 25,
      armor: 0,
      damage: 110,
      built_from: "hatchery",
      description:
        "Kamikaze flying unit produced two per larva. Scourge fly into enemy air units and detonate " <>
          "for 110 damage. They are cheap and devastating against capital ships and transports, but " <>
          "fragile and easily killed before reaching their target."
    },
    %{
      slug: "queen",
      name: "Queen",
      race: "zerg",
      type: :air,
      minerals: 100,
      gas: 100,
      supply: 2,
      hp: 120,
      armor: 0,
      damage: 0,
      built_from: "hatchery",
      description:
        "Support caster with unique abilities. Spawn Broodling instantly kills a non-robotic ground " <>
          "unit and spawns two Broodlings. Ensnare slows all units in an area and reveals cloaked units. " <>
          "Parasite attaches to a unit, sharing its vision with the Zerg player permanently."
    },
    %{
      slug: "ultralisk",
      name: "Ultralisk",
      race: "zerg",
      type: :ground,
      minerals: 200,
      gas: 200,
      supply: 4,
      hp: 400,
      armor: 1,
      damage: 20,
      built_from: "hatchery",
      description:
        "Massive armored beast — the Zerg's heavy ground unit. Ultralisks have 400 HP and can be " <>
          "upgraded with Chitinous Plating for +2 base armor, making them extremely durable. They deal " <>
          "splash damage in melee. Effective as damage sponges that protect fragile Zerg units behind them."
    },
    %{
      slug: "defiler",
      name: "Defiler",
      race: "zerg",
      type: :ground,
      minerals: 50,
      gas: 150,
      supply: 2,
      hp: 80,
      armor: 1,
      damage: 0,
      built_from: "hatchery",
      description:
        "Late-game spellcaster with two of the most powerful abilities in the game. Dark Swarm creates " <>
          "a cloud that blocks all ranged attacks against ground units underneath — devastating against " <>
          "marines and dragoons. Plague deals 295 damage to all units in an area (cannot kill, leaves 1 HP). " <>
          "Consume sacrifices a friendly Zerg unit to restore energy."
    },
    %{
      slug: "guardian",
      name: "Guardian",
      race: "zerg",
      type: :air,
      minerals: 150,
      gas: 200,
      supply: 2,
      hp: 150,
      armor: 2,
      damage: 20,
      built_from: "mutalisk",
      description:
        "Evolved from Mutalisks at a Greater Spire. Guardians are slow-moving air units with " <>
          "devastating long-range ground attacks (range 8). They cannot attack air units, so they " <>
          "require escort. Used for breaking entrenched positions from safe distance."
    },
    %{
      slug: "devourer",
      name: "Devourer",
      race: "zerg",
      type: :air,
      minerals: 250,
      gas: 150,
      supply: 2,
      hp: 250,
      armor: 2,
      damage: 25,
      built_from: "mutalisk",
      description:
        "Evolved from Mutalisks at a Greater Spire. Devourers are heavy air-to-air attackers that " <>
          "apply Acid Spores to targets, reducing their armor and making them vulnerable. Each hit " <>
          "stacks the debuff. Rarely seen in competitive play due to cost and limited utility."
    },
    %{
      slug: "overlord",
      name: "Overlord",
      race: "zerg",
      type: :air,
      minerals: 100,
      gas: 0,
      supply: 0,
      hp: 200,
      armor: 0,
      damage: 0,
      built_from: "hatchery",
      description:
        "Flying unit that provides 8 supply and serves as the Zerg's detector (with the Antennae " <>
          "upgrade). Overlords can also transport units with the Ventral Sacs upgrade. They are slow " <>
          "and vulnerable but essential — losing Overlords means losing supply capacity."
    },
    %{
      slug: "infested-terran",
      name: "Infested Terran",
      race: "zerg",
      type: :ground,
      minerals: 100,
      gas: 50,
      supply: 1,
      hp: 60,
      armor: 0,
      damage: 500,
      built_from: "infested-command-center",
      description:
        "Suicide unit produced from an Infested Command Center. Infested Terrans deal 500 explosive " <>
          "splash damage on detonation. They are rarely seen because obtaining an Infested Command Center " <>
          "requires a Queen to infest a heavily damaged Terran Command Center."
    }
  ]

  def units, do: @units
  def unit(slug), do: Enum.find(@units, &(&1.slug == slug))
  def units_for_race(race_slug), do: Enum.filter(@units, &(&1.race == race_slug))

  # ---------------------------------------------------------------------------
  # Buildings
  # ---------------------------------------------------------------------------

  @buildings [
    # -- Terran --
    %{
      slug: "command-center",
      name: "Command Center",
      race: "terran",
      minerals: 400,
      gas: 0,
      hp: 1500,
      description:
        "The primary Terran structure. Produces SCVs and serves as the center of a Terran base. " <>
          "Can lift off and relocate. Add-ons: ComSat Station (scanner sweep for map vision) or " <>
          "Nuclear Silo (produces nuclear missiles for Ghosts).",
      produces: ["scv"]
    },
    %{
      slug: "barracks",
      name: "Barracks",
      race: "terran",
      minerals: 150,
      gas: 0,
      hp: 1000,
      description:
        "Produces Terran infantry: Marines, Firebats, Medics, and Ghosts. The Barracks is the " <>
          "first military production building and can lift off. Required for Factory construction.",
      produces: ["marine", "firebat", "medic", "ghost"]
    },
    %{
      slug: "factory",
      name: "Factory",
      race: "terran",
      minerals: 200,
      gas: 100,
      hp: 1250,
      description:
        "Produces Terran mechanical ground units: Vultures, Siege Tanks, and Goliaths. " <>
          "Can be upgraded with a Machine Shop add-on for Siege Mode, Spider Mines, and " <>
          "Ion Thrusters research. Can lift off.",
      produces: ["vulture", "siege-tank", "goliath"]
    },
    %{
      slug: "starport",
      name: "Starport",
      race: "terran",
      minerals: 150,
      gas: 100,
      hp: 1300,
      description:
        "Produces Terran air units: Wraiths, Dropships, Valkyries, Science Vessels, and " <>
          "Battlecruisers. Requires a Control Tower add-on for advanced units. Can lift off.",
      produces: ["wraith", "dropship", "valkyrie", "science-vessel", "battlecruiser"]
    },
    %{
      slug: "academy",
      name: "Academy",
      race: "terran",
      minerals: 150,
      gas: 0,
      hp: 600,
      description:
        "Enables Firebat and Medic production at the Barracks. Researches Stim Pack, " <>
          "U-238 Shells (marine range), and Medic abilities (Restoration, Optical Flare).",
      produces: []
    },
    %{
      slug: "engineering-bay",
      name: "Engineering Bay",
      race: "terran",
      minerals: 125,
      gas: 0,
      hp: 850,
      description:
        "Researches infantry weapon and armor upgrades. Also required to build Missile Turrets " <>
          "for anti-air defense and detection. Can lift off.",
      produces: []
    },
    %{
      slug: "armory",
      name: "Armory",
      race: "terran",
      minerals: 100,
      gas: 50,
      hp: 750,
      description:
        "Researches vehicle and ship weapon and armor upgrades. Required for Goliath and Valkyrie " <>
          "production. Enables level 2-3 infantry upgrades at the Engineering Bay.",
      produces: []
    },
    %{
      slug: "science-facility",
      name: "Science Facility",
      race: "terran",
      minerals: 100,
      gas: 150,
      hp: 850,
      description:
        "Advanced tech building required for Science Vessels and Battlecruisers. Add-ons: " <>
          "Physics Lab (Battlecruiser tech, Yamato Cannon) or Covert Ops (Ghost tech, " <>
          "Cloaking Field, Lockdown, Nuclear Strike).",
      produces: []
    },
    %{
      slug: "bunker",
      name: "Bunker",
      race: "terran",
      minerals: 100,
      gas: 0,
      hp: 350,
      description:
        "Defensive structure that garrisons up to 4 infantry units, increasing their range " <>
          "and providing protection. Garrisoned marines gain +1 range. Bunkers can be salvaged " <>
          "for a 75% mineral refund.",
      produces: []
    },
    %{
      slug: "missile-turret",
      name: "Missile Turret",
      race: "terran",
      minerals: 75,
      gas: 0,
      hp: 200,
      description:
        "Anti-air defense structure and detector. Missile Turrets attack air units with " <>
          "20 explosive damage and reveal cloaked/burrowed units in their radius. " <>
          "Requires an Engineering Bay.",
      produces: []
    },

    # -- Protoss --
    %{
      slug: "nexus",
      name: "Nexus",
      race: "protoss",
      minerals: 400,
      gas: 0,
      hp: 750,
      shields: 750,
      description:
        "The primary Protoss structure. Produces Probes and serves as the center of a Protoss " <>
          "base. Provides psionic matrix power in a small radius. The Nexus is where resource " <>
          "gathering begins and expansions are established.",
      produces: ["probe"]
    },
    %{
      slug: "pylon",
      name: "Pylon",
      race: "protoss",
      minerals: 100,
      gas: 0,
      hp: 300,
      shields: 300,
      description:
        "Power structure that provides 8 supply and generates a psionic matrix. Most Protoss " <>
          "buildings must be placed within a Pylon's power field. Losing a Pylon can disable " <>
          "nearby buildings, making Pylon placement a critical strategic consideration.",
      produces: []
    },
    %{
      slug: "gateway",
      name: "Gateway",
      race: "protoss",
      minerals: 150,
      gas: 0,
      hp: 500,
      shields: 500,
      description:
        "Produces Protoss ground combat units: Zealots, Dragoons, High Templar, and Dark Templar. " <>
          "The Gateway is the primary production building and the first military structure. " <>
          "Multiple Gateways are needed for sustained unit production.",
      produces: ["zealot", "dragoon", "high-templar", "dark-templar"]
    },
    %{
      slug: "forge",
      name: "Forge",
      race: "protoss",
      minerals: 150,
      gas: 0,
      hp: 550,
      shields: 550,
      description:
        "Researches ground weapon and armor upgrades for Protoss units. Also required to build " <>
          "Photon Cannons. The Forge is sometimes built before the Gateway in a 'Forge Fast Expand' " <>
          "opening to enable cannon-based defense.",
      produces: []
    },
    %{
      slug: "cybernetics-core",
      name: "Cybernetics Core",
      race: "protoss",
      minerals: 200,
      gas: 0,
      hp: 500,
      shields: 500,
      description:
        "Enables Dragoon production at the Gateway and researches Singularity Charge (Dragoon range). " <>
          "Also researches air weapon and armor upgrades. Required for Stargate, Citadel of Adun, " <>
          "and Robotics Facility.",
      produces: []
    },
    %{
      slug: "robotics-facility",
      name: "Robotics Facility",
      race: "protoss",
      minerals: 200,
      gas: 200,
      hp: 500,
      shields: 500,
      description:
        "Produces Shuttles, Reavers, and Observers. The Robotics Facility enables the Reaver " <>
          "drop strategy and provides access to detection via Observers. Can be upgraded with " <>
          "a Robotics Support Bay for Reaver capacity and Shuttle speed.",
      produces: ["shuttle", "reaver", "observer"]
    },
    %{
      slug: "stargate",
      name: "Stargate",
      race: "protoss",
      minerals: 150,
      gas: 150,
      hp: 600,
      shields: 600,
      description:
        "Produces Protoss air units: Corsairs, Scouts, Carriers, and Arbiters. Requires a " <>
          "Cybernetics Core. Fleet Beacon add-on enables Carriers and advanced air upgrades. " <>
          "Arbiter Tribunal enables Arbiter production.",
      produces: ["corsair", "scout", "carrier", "arbiter"]
    },
    %{
      slug: "citadel-of-adun",
      name: "Citadel of Adun",
      race: "protoss",
      minerals: 150,
      gas: 100,
      hp: 450,
      shields: 450,
      description:
        "Researches Leg Enhancements for Zealots, giving them a significant speed boost. " <>
          "Required to build the Templar Archives. A key timing building for Zealot-based strategies.",
      produces: []
    },
    %{
      slug: "templar-archives",
      name: "Templar Archives",
      race: "protoss",
      minerals: 150,
      gas: 200,
      hp: 500,
      shields: 500,
      description:
        "Enables High Templar and Dark Templar production at the Gateway. Researches Psionic Storm, " <>
          "Hallucination, Mind Control, Maelstrom, and other Templar abilities.",
      produces: []
    },
    %{
      slug: "photon-cannon",
      name: "Photon Cannon",
      race: "protoss",
      minerals: 150,
      gas: 0,
      hp: 100,
      shields: 100,
      description:
        "Defensive structure that attacks ground and air units with 20 damage. Also serves as a " <>
          "detector, revealing cloaked and burrowed units. Requires a Forge and Pylon power. " <>
          "Often used for base defense and cannon rush strategies.",
      produces: []
    },

    # -- Zerg --
    %{
      slug: "hatchery",
      name: "Hatchery",
      race: "zerg",
      minerals: 300,
      gas: 0,
      hp: 1250,
      description:
        "The primary Zerg structure. Produces larvae (up to 3 at a time), which morph into all " <>
          "Zerg units. Each Hatchery provides both production capacity and 1 supply (2 as Lair, " <>
          "2 as Hive). Upgrades to Lair, then Hive for tech access.",
      produces: ["drone", "zergling", "hydralisk", "mutalisk", "scourge", "queen", "ultralisk", "defiler", "overlord"]
    },
    %{
      slug: "spawning-pool",
      name: "Spawning Pool",
      race: "zerg",
      minerals: 200,
      gas: 0,
      hp: 750,
      description:
        "Enables Zergling production from the Hatchery. Researches Metabolic Boost (Zergling speed) " <>
          "and Adrenal Glands (Zergling attack speed, requires Hive). The timing of the Spawning Pool " <>
          "defines many Zerg openings — pool first, hatch first, or overpool.",
      produces: []
    },
    %{
      slug: "hydralisk-den",
      name: "Hydralisk Den",
      race: "zerg",
      minerals: 100,
      gas: 50,
      hp: 850,
      description:
        "Enables Hydralisk production from the Hatchery. Researches Muscular Augments (Hydralisk speed) " <>
          "and Grooved Spines (Hydralisk range). Also researches Lurker Aspect, allowing Hydralisks " <>
          "to morph into Lurkers.",
      produces: []
    },
    %{
      slug: "spire",
      name: "Spire",
      race: "zerg",
      minerals: 200,
      gas: 150,
      hp: 600,
      description:
        "Enables Mutalisk and Scourge production from the Hatchery. Researches Zerg air attack " <>
          "and armor upgrades. Upgrades to Greater Spire (requires Hive) to enable Guardian and " <>
          "Devourer morphing.",
      produces: []
    },
    %{
      slug: "queens-nest",
      name: "Queen's Nest",
      race: "zerg",
      minerals: 150,
      gas: 100,
      hp: 850,
      description:
        "Enables Queen production from the Hatchery. Required to upgrade a Lair to a Hive. " <>
          "Researches Spawn Broodling, Ensnare, and Parasite abilities for Queens.",
      produces: []
    },
    %{
      slug: "ultralisk-cavern",
      name: "Ultralisk Cavern",
      race: "zerg",
      minerals: 150,
      gas: 200,
      hp: 600,
      description:
        "Enables Ultralisk production from the Hatchery. Researches Chitinous Plating (+2 Ultralisk " <>
          "armor) and Anabolic Synthesis (Ultralisk speed). Requires a Hive.",
      produces: []
    },
    %{
      slug: "defiler-mound",
      name: "Defiler Mound",
      race: "zerg",
      minerals: 100,
      gas: 100,
      hp: 850,
      description:
        "Enables Defiler production from the Hatchery. Researches Consume (sacrifice a Zerg unit " <>
          "to restore Defiler energy), Plague, and Dark Swarm abilities. Requires a Hive.",
      produces: []
    },
    %{
      slug: "evolution-chamber",
      name: "Evolution Chamber",
      race: "zerg",
      minerals: 75,
      gas: 0,
      hp: 750,
      description:
        "Researches Zerg ground melee attack, ranged attack, and carapace upgrades. Required to " <>
          "build Spore Colonies. Equivalent to the Terran Engineering Bay or Protoss Forge.",
      produces: []
    },
    %{
      slug: "creep-colony",
      name: "Creep Colony",
      race: "zerg",
      minerals: 75,
      gas: 0,
      hp: 400,
      description:
        "Base defensive structure that morphs into either a Sunken Colony (ground defense, 40 damage) " <>
          "or Spore Colony (anti-air defense and detection, 15 damage). Must be built on creep. " <>
          "Sunken Colonies require a Spawning Pool; Spore Colonies require an Evolution Chamber.",
      produces: []
    },
    %{
      slug: "extractor",
      name: "Extractor",
      race: "zerg",
      minerals: 50,
      gas: 0,
      hp: 750,
      description:
        "Built on a vespene geyser to enable gas harvesting. Like all Zerg buildings, building an " <>
          "Extractor consumes the Drone. The 'Extractor trick' is a well-known technique where a " <>
          "player builds then cancels an Extractor to temporarily exceed the supply cap.",
      produces: []
    }
  ]

  def buildings, do: @buildings
  def building(slug), do: Enum.find(@buildings, &(&1.slug == slug))
  def buildings_for_race(race_slug), do: Enum.filter(@buildings, &(&1.race == race_slug))

  # ---------------------------------------------------------------------------
  # Abilities
  # ---------------------------------------------------------------------------

  @abilities [
    # -- Terran --
    %{
      slug: "stim-pack",
      name: "Stim Pack",
      race: "terran",
      caster: "marine",
      energy: 0,
      hp_cost: 10,
      description:
        "Increases the attack speed and movement speed of Marines and Firebats for a short " <>
          "duration, at the cost of 10 HP. Stim Pack is one of the most important Terran upgrades — " <>
          "stimmed marines have dramatically higher DPS and can kite effectively. Researched at the Academy."
    },
    %{
      slug: "siege-mode",
      name: "Siege Mode",
      race: "terran",
      caster: "siege-tank",
      energy: 0,
      description:
        "Transforms the Siege Tank into a stationary artillery platform. In Siege Mode, the tank's " <>
          "damage increases from 30 to 70 explosive splash damage with 12 range, but it cannot move or " <>
          "attack units adjacent to it. The cornerstone of Terran positional play. Researched at the Machine Shop."
    },
    %{
      slug: "spider-mines",
      name: "Spider Mines",
      race: "terran",
      caster: "vulture",
      energy: 0,
      description:
        "Vultures can plant up to 3 Spider Mines (burrowed explosive drones) that detonate when " <>
          "enemy ground units approach, dealing 125 splash damage. Spider Mines are excellent for map " <>
          "control, denying expansions, and protecting flanks. Researched at the Machine Shop."
    },
    %{
      slug: "lockdown",
      name: "Lockdown",
      race: "terran",
      caster: "ghost",
      energy: 100,
      description:
        "Disables a target mechanical unit for 130 frames (~8.5 seconds), preventing it from " <>
          "moving, attacking, or using abilities. Extremely effective against expensive units like " <>
          "Battlecruisers, Carriers, and Siege Tanks. Researched at the Covert Ops."
    },
    %{
      slug: "nuclear-strike",
      name: "Nuclear Strike",
      race: "terran",
      caster: "ghost",
      energy: 0,
      description:
        "The Ghost designates a target location for a nuclear missile, dealing 500 damage (or 2/3 " <>
          "of a unit's max HP, whichever is greater) in a large area. The Ghost must remain stationary " <>
          "and alive during the targeting sequence. Requires a Nuclear Silo with an armed nuke."
    },
    %{
      slug: "cloaking-field",
      name: "Cloaking Field",
      race: "terran",
      caster: "ghost",
      energy: 25,
      description:
        "Renders the Ghost invisible to units without detection. Cloaking drains energy over time — " <>
          "0.9 energy per frame. Cloaked Ghosts are used for scouting and setting up Nuclear Strikes " <>
          "or Lockdowns. Available to Wraiths as well. Researched at the Covert Ops."
    },
    %{
      slug: "defensive-matrix",
      name: "Defensive Matrix",
      race: "terran",
      caster: "science-vessel",
      energy: 100,
      description:
        "Creates a protective shield on a target unit that absorbs up to 250 damage. The matrix " <>
          "lasts until the damage is absorbed or the duration expires. Useful for protecting key " <>
          "units during engagements or keeping a damaged unit alive during a retreat."
    },
    %{
      slug: "emp-shockwave",
      name: "EMP Shockwave",
      race: "terran",
      caster: "science-vessel",
      energy: 100,
      description:
        "Releases an electromagnetic pulse that drains all energy and shields from units in the " <>
          "target area. Devastating against Protoss (removes shields) and spellcasters (removes energy). " <>
          "One of the most impactful abilities in TvP. Researched at the Science Facility."
    },
    %{
      slug: "irradiate",
      name: "Irradiate",
      race: "terran",
      caster: "science-vessel",
      energy: 75,
      description:
        "Exposes a target unit to radiation, dealing 250 damage over time to it and nearby " <>
          "biological units. Does not affect mechanical units. Extremely effective against Overlords, " <>
          "Mutalisks, and groups of biological units. Researched at the Science Facility."
    },
    %{
      slug: "yamato-cannon",
      name: "Yamato Cannon",
      race: "terran",
      caster: "battlecruiser",
      energy: 150,
      description:
        "Fires a concentrated plasma blast dealing 260 damage to a single target. The Yamato Cannon " <>
          "has 10 range and can destroy most units and structures in one or two shots. Essential for " <>
          "Battlecruiser-based strategies. Researched at the Physics Lab."
    },
    %{
      slug: "restoration",
      name: "Restoration",
      race: "terran",
      caster: "medic",
      energy: 50,
      description:
        "Removes all negative status effects from a target unit, including Plague, Ensnare, " <>
          "Irradiate, Lockdown, Optical Flare, Parasite, and Acid Spores. A versatile counter to " <>
          "many opponent abilities. Researched at the Academy."
    },
    %{
      slug: "optical-flare",
      name: "Optical Flare",
      race: "terran",
      caster: "medic",
      energy: 75,
      description:
        "Permanently reduces a target unit's sight range to 1. Most effective against detector " <>
          "units like Overlords and Observers, effectively blinding them. Researched at the Academy."
    },

    # -- Protoss --
    %{
      slug: "psionic-storm",
      name: "Psionic Storm",
      race: "protoss",
      caster: "high-templar",
      energy: 75,
      description:
        "Unleashes a devastating psionic energy storm in the target area, dealing 112 damage over " <>
          "about 3 seconds to all units caught within it. Storms do not stack — multiple storms on the " <>
          "same area do not increase damage. One of the most powerful and iconic abilities in the game. " <>
          "Researched at the Templar Archives."
    },
    %{
      slug: "hallucination",
      name: "Hallucination",
      race: "protoss",
      caster: "high-templar",
      energy: 100,
      description:
        "Creates two illusory copies of a target friendly unit. Hallucinations look identical to real " <>
          "units but deal no damage and take double damage. Used for scouting, confusing opponents about " <>
          "army composition, and absorbing fire. Researched at the Templar Archives."
    },
    %{
      slug: "mind-control",
      name: "Mind Control",
      race: "protoss",
      caster: "dark-archon",
      energy: 150,
      description:
        "Permanently takes control of a target enemy unit. The Dark Archon's shields are reduced to " <>
          "0 upon casting. Mind Control can steal workers (enabling multi-race production), detectors, " <>
          "or expensive units. One of the rarest but most dramatic abilities in competitive play. " <>
          "Researched at the Templar Archives."
    },
    %{
      slug: "maelstrom",
      name: "Maelstrom",
      race: "protoss",
      caster: "dark-archon",
      energy: 100,
      description:
        "Freezes all biological units in the target area for about 3 seconds, preventing movement, " <>
          "attacking, and ability use. Does not affect mechanical or robotic units. Extremely powerful " <>
          "against Zerg armies. Researched at the Templar Archives."
    },
    %{
      slug: "feedback",
      name: "Feedback",
      race: "protoss",
      caster: "dark-archon",
      energy: 50,
      description:
        "Drains all remaining energy from a target unit and deals damage equal to the energy " <>
          "drained. Can instantly kill spellcasters with full energy. No research required — " <>
          "available as soon as the Dark Archon is created."
    },
    %{
      slug: "disruption-web",
      name: "Disruption Web",
      race: "protoss",
      caster: "corsair",
      energy: 125,
      description:
        "Projects an energy web onto the ground that prevents any ground unit or building beneath " <>
          "it from attacking. Affected units can still move out of the area. Devastating for disabling " <>
          "static defenses like Sunken Colonies or Missile Turrets. Researched at the Fleet Beacon."
    },
    %{
      slug: "recall",
      name: "Recall",
      race: "protoss",
      caster: "arbiter",
      energy: 150,
      description:
        "Instantly teleports all friendly units in a target area to the Arbiter's location. " <>
          "Enables surprise attacks by warping an army across the map. One of the most powerful " <>
          "strategic abilities in the game, enabling instant multi-pronged assaults. " <>
          "Researched at the Arbiter Tribunal."
    },
    %{
      slug: "stasis-field",
      name: "Stasis Field",
      race: "protoss",
      caster: "arbiter",
      energy: 100,
      description:
        "Freezes all units (friend and foe) in the target area in time, making them invulnerable " <>
          "but unable to move, attack, or be targeted. Lasts about 40 seconds. Used to temporarily " <>
          "remove part of an enemy army from a fight. Researched at the Arbiter Tribunal."
    },

    # -- Zerg --
    %{
      slug: "burrow",
      name: "Burrow",
      race: "zerg",
      caster: "zergling",
      energy: 0,
      description:
        "Allows most Zerg ground units to burrow underground, becoming invisible to units without " <>
          "detection. Burrowed units cannot move or attack (except Lurkers). Used for ambushes, hiding " <>
          "units, and dodging attacks. Researched at the Hatchery/Lair/Hive."
    },
    %{
      slug: "dark-swarm",
      name: "Dark Swarm",
      race: "zerg",
      caster: "defiler",
      energy: 100,
      description:
        "Creates a dark cloud that blocks all ranged attacks against ground units underneath it. " <>
          "Units inside Dark Swarm can still attack normally, and melee units are unaffected. " <>
          "This is arguably the most powerful Zerg ability — it completely negates Marine, Dragoon, " <>
          "and Hydralisk fire. Researched at the Defiler Mound."
    },
    %{
      slug: "plague",
      name: "Plague",
      race: "zerg",
      caster: "defiler",
      energy: 150,
      description:
        "Infects all units in the target area with a disease that deals 295 damage over time. " <>
          "Plague cannot kill units — it reduces HP to a minimum of 1. Devastating for softening " <>
          "up armies before engagement and stripping shields from Protoss units. Researched at the Defiler Mound."
    },
    %{
      slug: "consume",
      name: "Consume",
      race: "zerg",
      caster: "defiler",
      energy: 0,
      description:
        "Instantly kills a friendly Zerg unit to restore 50 energy to the Defiler. Essential for " <>
          "sustaining Dark Swarm and Plague usage in extended engagements. Zerglings are the typical " <>
          "sacrifice due to their low cost. Researched at the Defiler Mound."
    },
    %{
      slug: "spawn-broodling",
      name: "Spawn Broodling",
      race: "zerg",
      caster: "queen",
      energy: 150,
      description:
        "Instantly kills a target non-robotic ground unit and spawns two Broodlings in its place. " <>
          "Can instantly destroy high-value targets like Siege Tanks and Ultralisks. Broodlings are " <>
          "temporary units that die after a short time. Researched at the Queen's Nest."
    },
    %{
      slug: "ensnare",
      name: "Ensnare",
      race: "zerg",
      caster: "queen",
      energy: 75,
      description:
        "Slows all units in the target area and reveals cloaked units. Ensnared units have " <>
          "reduced movement and attack speed. Useful for slowing enemy armies before engagement " <>
          "and countering cloaked units like Dark Templar or Wraiths. Researched at the Queen's Nest."
    },
    %{
      slug: "parasite",
      name: "Parasite",
      race: "zerg",
      caster: "queen",
      energy: 75,
      description:
        "Attaches a parasitic organism to a target unit, permanently sharing its vision with " <>
          "the Zerg player. The affected unit's owner may not even realize their unit is parasited. " <>
          "Useful for scouting and tracking army movements. Cannot be removed except by Restoration."
    }
  ]

  def abilities, do: @abilities
  def ability(slug), do: Enum.find(@abilities, &(&1.slug == slug))
  def abilities_for_race(race_slug), do: Enum.filter(@abilities, &(&1.race == race_slug))

  def abilities_for_unit(unit_slug) do
    Enum.filter(@abilities, &(&1.caster == unit_slug))
  end

  # ---------------------------------------------------------------------------
  # Maps
  # ---------------------------------------------------------------------------

  @maps [
    %{
      slug: "fighting-spirit",
      name: "Fighting Spirit",
      dimensions: "128x128",
      tileset: "Jungle World",
      players: 4,
      spawn_positions: "1, 5, 7, 11",
      era: "2008-present",
      description:
        "One of the most played maps in BW history. Fighting Spirit is a 4-player jungle map " <>
          "with a relatively standard layout — natural expansions with narrow ramps, a central open " <>
          "area, and multiple attack paths. Its balanced design has made it a tournament staple for " <>
          "over a decade. The map rewards both aggressive and defensive play styles equally."
    },
    %{
      slug: "circuit-breaker",
      name: "Circuit Breaker",
      dimensions: "128x128",
      tileset: "Space Platform",
      players: 4,
      spawn_positions: "1, 5, 7, 11",
      era: "2010-present",
      description:
        "A 4-player space platform map created by Earthattack (김응서). Circuit Breaker features " <>
          "a distinctive layout with cliffed natural expansions and multiple pathways. The space " <>
          "platform tileset gives it a unique visual identity. Widely used in ASL and other modern " <>
          "tournaments."
    },
    %{
      slug: "python",
      name: "Python",
      dimensions: "128x128",
      tileset: "Jungle World",
      players: 4,
      spawn_positions: "1, 2, 7, 8",
      era: "2007-2012",
      description:
        "A legendary 4-player jungle map with rotational symmetry and a central plateau. Python " <>
          "was a cornerstone of competitive BW during the golden age of Korean pro leagues. Its " <>
          "large main bases, ramp-protected naturals, and open center allow for diverse strategies. " <>
          "The 1.3 revision is the most commonly played version."
    },
    %{
      slug: "polypoid",
      name: "Polypoid",
      dimensions: "128x128",
      tileset: "Jungle World",
      players: 4,
      spawn_positions: "2, 5, 7, 10",
      era: "2022-present",
      description:
        "A modern 4-player jungle map featured in recent ASL seasons. Polypoid has rotational " <>
          "symmetry with naturals positioned at varying distances, creating interesting strategic " <>
          "decisions about expansion timing and attack angles. One of the key maps in the current " <>
          "competitive map pool."
    },
    %{
      slug: "sylphid",
      name: "Sylphid",
      dimensions: "128x128",
      tileset: "Jungle World",
      players: 3,
      spawn_positions: "4, 8, 12",
      era: "2020-present",
      description:
        "A 3-player jungle map with a circular layout. The three spawn positions sit on a circle " <>
          "centered on the map, with the center area serving as an intensive battleground. The lack " <>
          "of resources in the center forces players to expand outward. Featured in modern ASL seasons."
    },
    %{
      slug: "aztec",
      name: "Aztec",
      dimensions: "128x128",
      tileset: "Jungle World",
      players: 3,
      spawn_positions: "5, 8, 12",
      era: "2019-present",
      description:
        "A 3-player jungle map with distinctive terrain features. Aztec's asymmetric spawn positions " <>
          "create unique matchup dynamics depending on starting locations. The map has become a " <>
          "staple in modern ASL and BSL tournaments, known for producing exciting games."
    },
    %{
      slug: "butter",
      name: "Butter",
      dimensions: "112x128",
      tileset: "Desert",
      players: 2,
      spawn_positions: "1, 5",
      era: "2022-present",
      description:
        "A 2-player desert map with a vertical layout. Butter features a straightforward path " <>
          "between the two bases with expansion opportunities on the sides. The desert tileset gives " <>
          "it a distinct appearance. As a 2-player map, it eliminates spawn randomness, making it " <>
          "popular for deciding games in tournament sets."
    },
    %{
      slug: "heartbreak-ridge",
      name: "Heartbreak Ridge",
      dimensions: "128x96",
      tileset: "Jungle World",
      players: 2,
      spawn_positions: "4, 10",
      era: "2008-present",
      description:
        "A classic 2-player jungle map with a horizontal layout. Heartbreak Ridge is one of the " <>
          "longest-running competitive maps in BW, known for its relatively short rush distance and " <>
          "cliffable natural expansion. The map favors aggressive play and has produced countless " <>
          "memorable tournament games."
    },
    %{
      slug: "destination",
      name: "Destination",
      dimensions: "128x96",
      tileset: "Badlands",
      players: 2,
      spawn_positions: "5, 11",
      era: "2007-2012",
      description:
        "A 2-player badlands map from the golden era of Korean BW. Destination features a " <>
          "distinctive layout with a mineral-only natural and a gas expansion further from the main. " <>
          "The map was known for producing strategic, macro-oriented games and was a favorite in " <>
          "OSL and MSL tournaments."
    },
    %{
      slug: "la-mancha",
      name: "La Mancha",
      dimensions: "128x128",
      tileset: "Desert",
      players: 4,
      spawn_positions: "1, 5, 7, 11",
      era: "2019-present",
      description:
        "A 4-player desert map with a distinctive open center. La Mancha features wide ramps " <>
          "and open terrain that favors mobile armies. The desert tileset and open layout make it " <>
          "particularly interesting for mech vs bio dynamics in TvT and mobile Zerg strategies."
    },
    %{
      slug: "benzene",
      name: "Benzene",
      dimensions: "128x112",
      tileset: "Space Platform",
      players: 2,
      spawn_positions: "1, 7",
      era: "2010-2016",
      description:
        "A 2-player space platform map with a hexagonal ring structure inspired by the benzene " <>
          "molecule. The map features multiple paths between bases, cliffable positions, and " <>
          "interesting high-ground dynamics. Its unique layout creates diverse game types across " <>
          "all matchups."
    },
    %{
      slug: "lost-temple",
      name: "Lost Temple",
      dimensions: "128x128",
      tileset: "Jungle World",
      players: 4,
      spawn_positions: "12, 2, 6, 8",
      era: "1998-2008",
      description:
        "The original competitive BW map. Lost Temple shipped with StarCraft and was the default " <>
          "competitive map for years. Its island expansion, temple in the center, and simple layout " <>
          "defined early BW strategy. While long retired from competitive play, it remains the most " <>
          "iconic and recognizable map in StarCraft history."
    },
    %{
      slug: "blue-storm",
      name: "Blue Storm",
      dimensions: "128x96",
      tileset: "Twilight",
      players: 2,
      spawn_positions: "1, 7",
      era: "2008-2012",
      description:
        "A 2-player twilight map known for its atmospheric visuals and balanced gameplay. Blue Storm " <>
          "features a relatively standard 2-player layout with natural expansions protected by ramps " <>
          "and a contested center area. The twilight tileset gives it a distinctive purple-blue aesthetic."
    },
    %{
      slug: "longinus",
      name: "Longinus",
      dimensions: "128x128",
      tileset: "Jungle World",
      players: 3,
      spawn_positions: "3, 7, 11",
      era: "2008-2014",
      description:
        "A 3-player jungle map with wide-open spaces and long distances between bases. Longinus " <>
          "was a key tournament map during the later years of the Korean pro leagues, known for " <>
          "producing long, strategic games. The large map size favors economic play and late-game armies."
    },
    %{
      slug: "tau-cross",
      name: "Tau Cross",
      dimensions: "128x128",
      tileset: "Ice",
      players: 3,
      spawn_positions: "1, 5, 9",
      era: "2009-2014",
      description:
        "A 3-player ice map shaped like the Greek letter tau (T). The distinctive layout creates " <>
          "asymmetric spawn dynamics where different positions have different strategic advantages. " <>
          "The ice tileset makes it one of the most visually distinctive competitive maps."
    },
    %{
      slug: "andromeda",
      name: "Andromeda",
      dimensions: "128x128",
      tileset: "Space Platform",
      players: 4,
      spawn_positions: "2, 4, 8, 10",
      era: "2008-2012",
      description:
        "A 4-player space platform map that was a major tournament staple during the golden age " <>
          "of Korean BW. Andromeda features wide main bases, ramp-protected naturals, and a relatively " <>
          "open center. Its balanced design across all matchups made it one of the most respected " <>
          "competitive maps."
    },
    %{
      slug: "match-point",
      name: "Match Point",
      dimensions: "112x128",
      tileset: "Space Platform",
      players: 2,
      spawn_positions: "1, 7",
      era: "2009-2014",
      description:
        "A 2-player space platform map with a vertical layout. Match Point features a central " <>
          "high-ground area and multiple attack paths. The relatively compact design leads to " <>
          "aggressive, action-packed games. Popular in both Korean and international tournaments."
    }
  ]

  def wiki_maps, do: @maps
  def wiki_map(slug), do: Enum.find(@maps, &(&1.slug == slug))
end
