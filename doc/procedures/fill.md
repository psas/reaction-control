# RCS Fill Procedure
## Notes
- The fill system definitely needs a choke to prevent over-filling the RCS and reduce the fill rate.
    - We may want to put a cold sink on that choke and monitor its temperature during testing.
- We probably want to define a standard way to clean fittings and dust covers,
  so we aren't repeating it in the procedure.
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
| 1 | Compressed Gaseous Nitrogen Tank |  |  
| 1 | RCS Fill System |  |  
| 1 | impact-resistant safety goggles (TODO: ANSI standard) |  |  
| 1 | heavy hearing protection (TODO: ANSI standard) |  |  
| 1 | dry cloth |  |  
| 1 | fill tank transportation cart |  |  
| 1 |  |  |  
| 1 |  |  |  
| 1 |  |  |  
| 1 |  |  |  

## General Precautions
- The internal components of the RCS and its fill system are sensitive to FOD.
    - It's important to keep work areas clean to avoid contamination.
- The fill tank is nominally pressurized to (TODO) atmospheres and stores an equivalent energy of (TODO) kg TNT.
    - This is enough to (TODO: look up medical hazards) and eject FOD/shrapnel.
    - People must wear the above-listed PPE when within (TODO: safe radius) of the fill tank when it is pressurized.
- The RCS is nominally pressurized to 238 atmospheres and stores an equivalent energy of 27.1 g TNT.
    - This is enough to (TODO: look up medical hazards) and eject FOD/shrapnel.
    - People must wear the above-listed PPE when within (TODO: safe radius) of the RCS when it is pressurized.
- If you get unexpected results at any point during this procedure, stop and reevaluate what's happening.

## Operations
### Fetching the Supply Tank
1. TODO: instructions on how to remove the tank from its storage location.
1. TODO: instructions on how to transport the tank.

### Installing the Supply Tank
1. TODO: instructions on how to secure the tank to the fill system.
1. Remove the protective cap from the fill tank.
1. Ensure (NOID: tank connector) is free of FOD. (TODO: cleaning)
1. Remove the dust cover from (NOID: supply end of fill sys) on the fill system.
1. Ensure (NOID: supply end of fill sys) is free of FOD. (TODO: cleaning)
1. Connect (NOID: tank connector) to (NOID: supply end of fill sys). (TODO: specific instructions)

### Connecting to the RCS
1. Remove the dust cover from (NOID: RCS side of fill sys).
1. Ensure (NOID: RCS side of fill sys) is free of FOD.
1. Remove the dust cover on (NOID: RCS fill port).
1. Ensure (NOID: RCS fill port).
1. Connect (NOID: RCS side of fill sys) to (NOID: RCS fill port) such that there is an audible click.

### Filling Proper
1. Ensure `Reg-02` is fully closed. (TODO: direction/instructions)
- Danger: 
    - The next step will pressurize part of the fill system to the same pressure as the fill tank.
    - If `Reg-02` is not closed, it may over-pressure the RCS tank, damaging or exploding it.
    - If the couplings of the fill system aren't secure, they may turn into thrusters.
2. Open `HV`. (TODO: expected feedback?)
    - You should not see any pressure rise in (NOID: RCS-side gauge).
    1. If you see a pressure rise in (NOID: RCS-side gauge), close `HV` immediately and reassess.
- Danger: 
    - If you open `Reg-02` by too much in the next step, it could over-pressure the RCS tank, damaging or exploding it.
3. Open `Reg-02` by 0.25 turn. (TODO: good increment?)
    - You should hear a hissing sound from the regulator.
4. Wait for the reading of (NOID: RCS-side gauge) to stabilize.
    - The hissing sound should stop as the pressure stabilizes.
    1. If you hear `PRV-02` start hissing or you see (NOID: RCS-side gauge) exceed 3500 psi:
        1. Close `Reg-02` immediately.
        1. Close `HV` immediately.
        1. Reassess.
        1. Return to step 1 of "Filling Proper"
5. If the reading of `Reg-02` is below 3400 psi, repeat steps 3 through 5 of "Filling Proper".
    - (NOID: RCS-side gauge) should now read between 3400 and 3500 psi.
1. Close `Reg-02` completely. (TODO: direction?)
1. Close `HV` completely. (TODO: direction?)

### Disconnecting
1. Ensure the dust covers for (NOID: RCS-side of fill sys) and (NOID: RCS fill port) are free of FOD.
- Danger: If `HV` is not closed, the next step may turn (NOID: RCS-side of fill sys) into a thruster.
1. Loosen (NOID: RCS-side of fill sys) from (NOID: RCS fill port), but do not disconnect them.
    - You should hear a hissing sound.
1. Wait for the pressure in (NOID: RCS-side gauge) to drop to 0 psi.
    - The hissing sound should stop.
1. Open `Reg-02` slowly until you hear a hissing sound.
1. Wait for the pressure in (NOID: fill-side gauge) to drop to 0 psi. (TODO: is there some residual pressure left by Reg-02?)
    - The hissing sound should stop.
1. Disconnect (NOID: RCS-side of fill sys) from (NOID: RCS fill port).
1. Replace the dust covers of (NOID: RCS-side of fill sys) and (NOID: RCS fill port).


### Returning the Supply Tank
1. Ensure the dust cover of (NOID: supply-side of fill sys) is free of FOD.
1. Disconnect (NOID: supply-side of fill sys).
1. Replace the dust cover on (NOID: supply-side of fill sys).
1. Replace the protective cap on the supply tank.
1. TODO: instructions for moving the supply tank to the cart

### Fetching the Supply Tank
1. TODO: instructions on how to transport the tank.
1. TODO: instructions on how to secure the tank in its storage location.
