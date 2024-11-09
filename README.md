# `moveable_model`


---
The `moveable_model` entity gives map creators a moveable model with customizable properties and animations. It can be set to be interactable by a specified player or all players, and it has different settings for movement types (toss or bounce) and interactions such as attack pull and attack push.

## Entity Definition

### `moveable_model`

The `moveable_model` entity comes with the following properties:

| Property         | Type             | Description                                                                                     | Default Value           |
|------------------|------------------|-------------------------------------------------------------------------------------------------|-------------------------|
| `targetname`     | `target_destination` | The name of the entity.                                                                          |                         |
| `model`          | `studio`         | Path to the model file.                                                                          | `models/recruit.mdl`    |
| `scale`          | `string`         | Scale of the model.                                                                              | `1`                     |
| `canmove`        | `choices`        | Whether the model can be moved.                                                                  |                         |
|                  |                  | - `1`: Yes                                                                                       |                         |
|                  |                  | - `0`: No                                                                                        |                         |
| `allowedtarget`  | `string`         | Name of players allowed to move this model. Leave empty to allow everyone.                       |                         |
| `anim`           | `integer`        | Animation sequence number to play on use.                                                        | `0`                     |
| `sequence`       | `integer`        | Editor sequence number for previewing animations in the map editor.                              | `0`                     |
| `min_size`       | `string`         | Minimum size of the bounding box.                                                                | `-12 -12 0`             |
| `max_size`       | `string`         | Maximum size of the bounding box.                                                                | `12 12 72`              |
| `usebounce`      | `choices`        | Movement type of the model.                                                                      |                         |
|                  |                  | - `0`: Toss (`MOVETYPE_TOSS`)                                                                    |                         |
|                  |                  | - `1`: Bounce (`MOVETYPE_BOUNCE`)                                                                |                         |
| `effect_friction`| `string`         | Friction modifier (percentage).                                                                  | `100.0`                 |
| `attack_pull`    | `choices`        | Allows attack pull.                                                                              |                         |
|                  |                  | - `1`: Yes                                                                                       |                         |
|                  |                  | - `0`: No                                                                                        |                         |
| `attack_push`    | `choices`        | Allows attack push.                                                                              |                         |
|                  |                  | - `1`: Yes                                                                                       |                         |
|                  |                  | - `0`: No                                                                                        |                         |
| `sync_angles`    | `choices`        | Synchronizes model's angles with the player’s.                                                   |                         |
|                  |                  | - `1`: Yes                                                                                       |                         |
|                  |                  | - `0`: No                                                                                        |                         |

---

### FGD

The `.fgd` file defines the entity `moveable_model`, designed for use in Sven Co-op maps. The entity allows for a moveable model with animation capabilities, making it customizable for mappers.

---

## Usage

### Adding the `.fgd` File to Your Map Editor

To use this `.fgd` file, include it in your map editor’s configuration. Then, place the `moveable_model` entity in your map and configure its properties as needed.
### CFG file
To include the script in a map's .cfg file, add the following line to your map's .cfg file:

`map_script your_map/your_mapinit`

Replace `your_map` with the name of your map's script folder and `your_mapinit` with the name of your map's initialization script. This will ensure that the `moveable_model` is registered and ready to be used in your map.

### Registering the Script

To register the script for this entity in a `MapInit()` function, include the following code in your initialization script:

```cpp
#include "moveable_model"

void MapInit()
{
    MoveableModel::Register();
}
