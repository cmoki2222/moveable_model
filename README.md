# `moveable_model`

The `moveable_model` entity gives Sven Co-op mappers a reusable animated prop that players can pick up, carry, push, pull, and drop. It is designed as a lightweight standalone entity that can be reused across different maps and projects.

## Demo

https://github.com/user-attachments/assets/f2c9672e-af36-4879-a150-c4fad8e9161f

## Highlights

- Pick up and drop a model with `+use`
- Held models follow the player’s aim point
- Optional LMB push / RMB pull distance adjustment while held
- Basic wall trace keeps held models from being placed directly through geometry
- Optional yaw syncing with the holder
- Toss or bounce movement after dropping
- Configurable bounding box, scale, animation, friction, and allowed player targetname

## What Changed

- Improved held-model positioning so props follow the player’s aim more cleanly
- Added optional push and pull controls while carrying an object
- Added wall tracing to reduce direct clipping through level geometry
- Added optional yaw syncing for models that should rotate with the holder
- Improved drop behavior with configurable toss or bounce movement
- Preserved scale-aware bounding boxes for resized models
- Refined the script structure and documentation for easier reuse

## Entity Definition

### `moveable_model`

| Property | Type | Description | Default |
|---|---|---|---|
| `targetname` | string | Entity name | |
| `model` | studio | Model path | `models/recruit.mdl` |
| `scale` | float | Model scale; bounding box scales with it | `1` |
| `canmove` | choices | Whether players can move it | `1` |
| `allowedtarget` | string | Only players with this targetname can move/push it; blank allows everyone | |
| `anim` | integer | Animation sequence played in-game | `0` |
| `sequence` | integer | Editor preview sequence value | `0` |
| `min_size` | string | Bounding box minimums | `-12 -12 0` |
| `max_size` | string | Bounding box maximums | `12 12 72` |
| `usebounce` | choices | `0` Toss, `1` Bounce | `0` |
| `effect_friction` | string | Friction modifier percentage | `100.0` |
| `attack_pull` | choices | Allow RMB to pull held model closer | `0` |
| `attack_push` | choices | Allow LMB to push held model farther | `0` |
| `sync_angles` | choices | Match model yaw to the holder’s view yaw | `0` |

## Usage

### Add the FGD to your editor

Include `moveable_model.fgd` in your map editor configuration, then place a `moveable_model` point entity and configure the properties you need.

### Register the script

Use the included `moveable_model_register.as`, or include the entity directly in your map script:

```cpp
#include "moveable_model"

void MapInit()
{
    MoveableModel::Register();
}
```

### Map CFG example

```text
map_script your_map/your_mapinit
```

## Notes

- `allowedtarget` is checked for both using and physical player pushes.
- Held props automatically drop if the holder releases `+use`, dies, disconnects, or becomes invalid.
- The entity is intended to remain flexible and reusable for a wide range of Sven Co-op mapping setups.
