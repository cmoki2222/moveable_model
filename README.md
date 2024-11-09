# moveable_model FGD

This `.fgd` file defines a custom entity called `moveable_model` with various properties and settings. The entity is designed to be a moveable model with animation capabilities for use in maps.

## Entity Definition

### moveable_model

The `moveable_model` entity is defined with the following properties:

- **targetname (target_destination)**: The name of the entity.
- **model (studio)**: The path to the model file. Default is `models/recruit.mdl`.
- **scale (string)**: Scale of the model. Default is `1`.
- **canmove (choices)**: Whether the model can be moved. Choices are:
  - `1`: Yes
  - `0`: No
- **allowedtarget (string)**: The name of players who are allowed to move this model. Leave empty to allow everyone.
- **anim (integer)**: The animation sequence number to play on use. Default is `0`.
- **sequence (integer)**: The editor sequence number to use, overriding the sequence name. Default is `0`.
- **min_size (string)**: Minimum size of the bounding box. Default is `-12 -12 0`.
- **max_size (string)**: Maximum size of the bounding box. Default is `12 12 72`.
- **usebounce (choices)**: The move type of the model. Choices are:
  - `0`: Toss (MOVETYPE_TOSS)
  - `1`: Bounce (MOVETYPE_BOUNCE)
- **effect_friction (string)**: Friction modifier in percentage. Default is `100.0`.
- **attack_pull (choices)**: Whether attack pull is allowed. Choices are:
  - `1`: Yes
  - `0`: No
- **attack_push (choices)**: Whether attack push is allowed. Choices are:
  - `1`: Yes
  - `0`: No
- **sync_angles (choices)**: Whether to synchronize the model's angles with the player's angles. Choices are:
  - `1`: Yes
  - `0`: No

### Description

This entity allows map creators to place a moveable model with customizable properties and animations. It can be configured to only be moveable by specific players or by everyone. Additionally, the model can be set to have different move types (toss or bounce) and various interactions like attack pull and attack push.

## Usage

To use this `.fgd` file, include it in your map editor's configuration and place the `moveable_model` entity in your map. Customize the properties as needed to achieve the desired behavior.

