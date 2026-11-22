# StateMachine.lua

A lightweight **finite state machine** for Lua and Roblox (Luau). Each state gets its own `enter`, `exit` and `update` hooks, so your logic stays organised instead of turning into a pile of `if` statements.

**Author:** Bhavish Krish Purgaus · **License:** MIT

---

## ✨ Features

- 🔁 **`enter` / `exit` / `update` hooks** for every state
- 🧭 **Knows where you came from:** `enter` is given the previous state
- 📦 **Pass data on a switch:** `sm:Set("hitstun", 0.4)`
- 🛡️ **Catches mistakes:** switching to a state that doesn't exist throws a clear error
- 🚫 **No duplicate switches:** setting the state you're already in does nothing

---

## Why I made it

While building my Roblox games, my character code kept turning into this:

```lua
if isAttacking and not isStunned and not isBlocking and onGround then
```

Every new mechanic added another flag, and the flags started fighting each other. A character could end up attacking and blocking at the same time, or get stuck because one flag never reset.

A state machine fixes this. **A character is in exactly one state at a time.** Each state owns its own logic, and switching state cleans up the old one automatically. I wanted something small that I fully understood and could reuse in every project, so I wrote my own.

---

## How it works

You give it a table of states. Each state can have up to three functions:

| Hook | When it runs | Arguments |
|---|---|---|
| `enter` | When you switch **into** the state | `(sm, previousState, ...extra)` |
| `exit` | When you switch **out of** the state | `(sm, nextState)` |
| `update` | Every time you call `sm:Update(dt)` | `(sm, dt)` |

### API

```lua
local sm = StateMachine.new(states, "initialState")

sm:Set("stateName", ...)  -- switch state (extra args go to enter)
sm:Update(dt)             -- run the current state's update
sm:Is("stateName")        -- true if that is the current state
sm.current                -- name of the current state
```

When you call `Set`, it:
1. Checks the state exists
2. Runs the **old** state's `exit`
3. Updates `current`
4. Runs the **new** state's `enter`

---

## Used in: TOKKI FIGHTING EX

**TOKKI FIGHTING EX** is my 2.5D Roblox fighting game, inspired by Street Fighter and Tekken. Fighting games are basically giant state machines: a fighter is always idle, attacking, blocking, in hitstun or knocked down, and the rules about what you can do depend entirely on which of those you're in.

Here's a simplified version of how a fighter is set up:

```lua
local StateMachine = require(ReplicatedStorage.Modules.StateMachine)

local fighter = StateMachine.new({
	idle = {
		enter = function(sm) playAnim("Idle") end,
		update = function(sm)
			if input.attack then sm:Set("attack", "LightPunch") end
			if input.block then sm:Set("block") end
		end,
	},

	attack = {
		enter = function(sm, from, move)
			sm.timer = Moves[move].duration
			playAnim(move)
			enableHitbox(move)
		end,
		update = function(sm, dt)
			sm.timer -= dt
			if sm.timer <= 0 then sm:Set("idle") end
		end,
		exit = function(sm) disableHitbox() end, -- always cleaned up, even if interrupted
	},

	block = {
		enter = function(sm) playAnim("Block") end,
		update = function(sm)
			if not input.block then sm:Set("idle") end
		end,
	},

	hitstun = {
		enter = function(sm, from, stunTime)
			sm.timer = stunTime
			playAnim("Hurt")
			showComicBubble() -- Japanese comic reaction bubble on hit
		end,
		update = function(sm, dt)
			sm.timer -= dt
			if sm.timer <= 0 then sm:Set("idle") end
		end,
	},
}, "idle")

RunService.Heartbeat:Connect(function(dt)
	fighter:Update(dt)
end)

-- When the fighter gets hit:
fighter:Set("hitstun", 0.4)
```

### What it fixed

- **Hitboxes never get stuck on.** If a player is hit mid-attack, `attack.exit` still runs and turns the hitbox off.
- **No impossible actions.** You can't attack while in hitstun, because the `hitstun` state simply doesn't read attack input.
- **Adding moves is easy.** New mechanics like air dashes, throws and knockdowns are just new states. Nothing else has to change.
- **Easier debugging.** Printing `fighter.current` shows exactly what a fighter is doing at any moment.

---

## Installation

**Roblox:** put `StateMachine.lua` in a ModuleScript (for example in `ReplicatedStorage.Modules`), then:
```lua
local StateMachine = require(ReplicatedStorage.Modules.StateMachine)
```

**Plain Lua:**
```lua
local StateMachine = require("StateMachine")
```

---

## License

MIT © 2026 Bhavish Krish Purgaus
