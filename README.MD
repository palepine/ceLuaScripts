# Cheat Engine Lua Scripts
Various lua scripts extending Cheat Engine's UX

## Scripts
- Compact Menu
  - adds a toggle to remove scanner view and footer of the main application window
- Extras menu
  - Memory View shortcut
  - Auto Assemble shortcut
  - Add New Address shortcut
  - Struct Dissect shortcut
  - Lua Engine shortcut
  - Write Process Name to clipboard
  - Assembly scanner clipboard

- Custom PopUp menu commands
  - Flatten pointers (multi-level to one-line pointers form)
  - Create headers from selected records (make hide children & collapsable)
  - Copy the currently shown address (calculated final)
  - Add New Address
  - Create Dissect Struct Form for the selected addresses
  - Add a spacer/separator with no checkbox
  - Set the last offset as a symbol: class.field (field from memrec description)

- Auto Assemble scripts
  - RIP Relative Address Resolution
  - Register mono class fields as symbols
  - get Auto Assemble structs for mono classes

## Usage
1. Install [Cheat Engine](https://github.com/cheat-engine/cheat-engine).
2. Copy-merge `autorun` folder from the repo into `Cheat Engine` root directory
