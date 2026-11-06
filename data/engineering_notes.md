# Engineering notes

**Illustrative Educational Simulation — not a validated reservoir simulator.**

The experience communicates physical cause and effect with an intentionally small natural-flow model. Artwork compresses distances and time for storytelling. Animated drilling and travel speeds are presentation choices; they are not drilling-rate or fluid-transit-time predictions.

## Units and illustrative inputs

The implementation is `scripts/engineering_model.gd`. Its default assumptions are:

| Quantity | Symbol | Assumed value |
| --- | --- | --- |
| Reservoir pressure | Pr | 280 bar |
| Reservoir depth / vertical liquid column | H | 2,400 m |
| Reservoir temperature | T | 85 °C |
| Receiving separator pressure | Psep | 15 bar |
| Oil bubble-point pressure | Pb | 140 bar |
| Constant liquid density | ρ | 800 kg/m³ |
| Gravitational acceleration | g | 9.81 m/s² |
| Productivity index | J | 5 m³/day/bar |
| Lumped tubing friction coefficient | Kt | 0.00020 bar/(m³/day)² |
| Fully open choke coefficient | Kc | 0.00012 bar/(m³/day)² |

Pressure values use a consistent absolute-pressure basis. These values are invented, explicitly illustrative inputs, not measurements from a field. Choke opening `c` is a dimensionless presentation control from 0 to 1; its relationship to resistance is not a calibrated valve characteristic.

## How choke opening changes production

Reservoir inflow uses a linear productivity-index approximation:

```text
Q = J × max(Pr − Pwf, 0)
```

For an open choke, the model matches this inflow to an illustrative outflow relation:

```text
Pwf = Psep + ρgH / 100000 + (Kt + Kc / c²) × Q²
```

`Q` is liquid production in m³/day and `Pwf` is flowing bottomhole pressure in bar. The factor 100000 converts pascals to bar. The positive root of the resulting quadratic gives the target flow. At the default depth, the hydrostatic term is approximately **188.35 bar**.

Opening the choke reduces its modeled resistance. This changes flowing bottomhole pressure and flow rate; **reservoir pressure remains fixed** throughout the short demonstration. A closed choke sets production to zero and lets the model represent bottomhole pressure as reservoir pressure. Flow animation eases toward the open-choke target for visual readability; that easing is not a transient wellbore model.

As an example at the stated default inputs, a 45% opening approaches about **209.4 m³/day**, with `Pwf ≈ 238.1 bar`. A fully open choke approaches about **268.2 m³/day**, with `Pwf ≈ 226.4 bar`. These examples describe this equation only, not a real well's capacity.

Natural flow is unavailable if:

```text
Pr ≤ Psep + ρgH / 100000
```

The flow then remains zero. Real wells require a more complete inflow/outflow assessment; artificial lift may be needed when natural-flow pressure is insufficient. This project does not simulate artificial lift.

## Gas, temperature, and depth

The model estimates wellhead pressure from separator pressure plus choke loss. During the animated ascent, local pressure is interpolated between flowing bottomhole pressure and that wellhead pressure. Ghazi is shown only while production is flowing and this estimated local pressure falls below the assumed bubble point. This illustrates a condition for gas evolution from oil; it does not calculate gas volume, gas/oil ratio, bubble nucleation, or an equation of state.

The local pressure interpolation is a storytelling approximation, not a pressure-gradient calculation. Gas appearance does not feed back into the constant-density liquid flow equation. Displayed depth follows journey progress; displayed temperature interpolates from 85 °C at reservoir depth to an assumed 30 °C at the surface. The thermal interpolation is also illustrative.

## Physical distinctions preserved by the story

- Oil occupies connected **pores in reservoir rock**, rather than an underground cavern of oil.
- **Drilling** makes the wellbore. **Completion** prepares the equipment and production pathway. Production tubing is distinct from the drilled hole.
- The pressure difference between reservoir and flowing bottomhole conditions drives reservoir inflow. Opening a surface choke does not instantaneously depressurize the entire reservoir.
- The three-phase separator uses a simplified gravity-separation picture: gas occupies the top region, oil forms the lighter liquid layer, and the denser water settles below. Actual separators also depend on residence time, internals, droplet behavior, emulsions, and operating conditions.
- **Separation is not refining.** Refinery processing occurs later. Plastics require petrochemical feedstock preparation, chemical processing and polymerization, then shaping; crude oil does not become plastic directly.
- Asphalt paving uses bitumen binder mixed with aggregate. Aviation and road fuels require appropriate processing and product specifications.

## Limits

The model omits reservoir depletion, reservoir heterogeneity, compressibility, transient pressure diffusion, detailed completion behavior, multiphase PVT, gas expansion, water cut, heat transfer, calibrated choke flow, and separator sizing. Its coefficients are not suitable for operational decisions. Character motion, particle density, and the 300 m³/day visual reference are animation parameters rather than engineering outputs.

For teaching, the useful comparison is directional: a closed production path stops flow; opening it can permit natural flow when sufficient driving pressure exists; greater opening lowers modeled resistance; and local pressure conditions influence whether free gas can appear.
