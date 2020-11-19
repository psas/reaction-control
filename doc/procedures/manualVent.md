# Venting Procedure
## Notes
- The vent system definitely needs a choke, and probably a rudimentary diffuser.
    - The choke would limit the rate of discharge.
        - This would reduce damage from any FOD, thrust during venting, and limit expansion cooling to the choke.
        - It might be a good idea to put a cold sink on the choke.
        - During testing, we would defninitely want to monitor the temperature of the choke.
    - The diffuser would minimize the thrust produced by the venting procedure.
- On the vent system, we may want to add a pressure gauge between the coupling and the choke.

## Nomenclature
- "Caution" = potential damage to equipment
- "Danger" = potential damage to people (and potentially equipment).
- "FOD" = Foreign Object Debris (anything that shouldn't be there, e.g., dirt, metal shavings, grease, water, stray tools)
- "PPE" = Personal Protective Equipment
- "NOID" = NO IDentifier
    - Anything marked with NOID needs an identifier in the procedure and system-level illustration.

## Required Materials
| Quantity | Part Name | Identifier | Part Number
| -------- | --------- | ---------- | -----------
| 1 | Reaction Control System |  |  
| 1 | RCS Venting System |  |  
| 1 | impact-resistant safety goggles (TODO: ANSI standard) |  |  
| 1 | heavy hearing protection (TODO: ANSI standard) |  |  
| 1 | dry cloth |  |  
| 1 |  |  |  
| 1 |  |  |  

## General Precautions
- The internal components of the RCS and its venting system are sensitive to FOD.
    - It's important to keep work areas clean to avoid contamination.
- The RCS is nominally pressurized to 238 atmospheres and stores an equivalent energy of 27.1 g TNT.
    - This is enough to (TODO: look up medical hazards) and eject FOD/shrapnel.
    - People must wear the above-listed PPE when within (TODO: safe radius) of the RCS when it is pressurized.

## Operations
### Preparation
1. Preparing the vent system:
    1. Ensure `BV-VTA` is closed. (TODO: orientation?)
    1. Ensure `NV-01` is closed. (TODO: orientation/instructions?)
    1. Remove the dust covers on both ends of the vent system.
    1. Ensure both ends are free of FOD. (TODO: cleaning procedure)
- Danger: 
    - When pressurized the RCS stores energy equivalent to (TODO: better calculation than naive pressure x volume) 27.1 g of TNT. (safe radius (TODO) ?? m)
    - Anyone within (TODO) SAFE RADIUS must wear (TODO) REQUIRED PPE:
        - Impact-resistant safety goggles. (TODO: ANSI standard)
1. Preparing the RCS system:
    1. Remove the dust cover from `HC-01`.
    1. Ensure `HC-01` is free of FOD. (TODO: cleaning procedure)
- Danger: 
    - Once the vent system is attached, it will be pressurized.
    - If `BV-VTA` is not closed, it may act like a thruster.
1. Attaching the vent system to the RCS:
    1. Couple `HC-02` to `HC-01` such that there is an audible click. (TODO: update labels)
    1. Tug gently on `HC-02` to confirm the connection.
    1. Ensure the outlet(s) of the vent system (NOID), are not facing any people.

### Venting Proper
1. Ensure the outlet(s) of the vent system (NOID), are not facing any people.
- Danger: 
    - If `NV-01` is not closed by the next step, the vent system may act like a thruster.
    - If the vent system contains FOD, the FOD may be violently discharged and/or damage internal components.
2. Open `BV-VTA`. (TODO: orientation)
3. Open `NV-01` slowly until a moderate hissing noise is heard. (TODO: direction/instructions, number of turns)
4. Retreat beyond (TODO) SAFE RADIUS from the RCS.
5. Wait for the hissing noise to stop.
6. Approach the RCS.
7. Repeat steps 2 through 5 of the "Venting Proper" procedure until `NV-01` is fully open and no hissing is heard.

### Tidying Up
1. Ensure the down-stream-end of the venting system and its dust cover are free of FOD. (TODO: cleaning procedure)
1. Cover the down-stream end of the venting system with its dust cover.
1. Close `HV-VTA`. (TODO: orientation)
1. Close `NV-01`. (TODO: direction/instructions)
1. If `HC-01` and `HC-01` covered in ice, wait for it to thaw and wipe off the moisture. 
   (NOID: the sides of the couplings need separate identifiers)
1. Ensure the dust covers for `HC-01` and `HC-01` are free of FOD. (NOID)
- Danger: 
    - If pressure remains in the system, the next step may eject `HC-01` and/or any FOD present.
1. Decouple `HC-01` from `HC-01`.
1. Ensure `HC-01` and `HC-01` are free of FOD. (TODO: cleaning instructions)
1. Replace the dust covers on `HC-01` and `HC-01`.
