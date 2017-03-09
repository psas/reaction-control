reaction-control
================

## Overview
We want active stabilization for LV3, but wish to escape the vexxing dynamic pressure limitations of the present aerodyamic canard based [roll-control system](https://github.com/psas/roll-control) used on LV2.3.

The concept:
* Cold-gas rocket propulsion
* 8 N thrust (roll), 11 N (pitch x, y)
* Nitrogen tank at 4500 psi
* 8x 3D-printed bell nozzles
* PWM throttling
* "Robust control"

![](https://github.com/psas/reaction-control/blob/master/module_render.png)

Rao bells (e.g. nearly ideal nozzles) are hard to machine c.f. conical nozzles, but easy to 3D print. This also enables “plug & play” optimal expansion ratios for any trajectory. Here is the basic workflow:
* Determine flight envelope from simulation (for instance, using [OpenRocket](https://github.com/psas/lv3.0-airframe/tree/master/sim/ORK))
* Run `nozzle_sizing.m` script to determine nozzle design parameters
* Plug expansion ratio into parametric solid model and export `.stl`
* Print nozzles, install in carrier ring
* ???
* Fly!

This repo includes mathematical models, matlab and python controller scripts, eagle files for a custom MOSFET relay board, solenoid PWD test data for transfer functions, system test deata and bode analysis, and CAD drawings for the LV3 Reaction Control System.

## Suplimentary Links
[Link to AIAA SPACE 2015 presentation slides](https://docs.google.com/presentation/d/1vfhgjRymidfKbpzjqC0tfAL57iSsNFOEQSFTw5_EEGs/edit?usp=sharing)

[Link to AIAA SPACE 2015 conference proceedings paper](https://github.com/psas/reaction-control/blob/master/pubs/AIAA%20RCS%20Manuscript_FINAL2.pdf)
