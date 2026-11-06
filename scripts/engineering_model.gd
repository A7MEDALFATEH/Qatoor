class_name EngineeringModel
extends RefCounted
## Illustrative educational natural-flow model. Not a validated reservoir simulator.
## Constant reservoir pressure, incompressible oil PI and a lumped vertical pressure loss.
## Pressures are bar; liquid flow is m³/day; depth is m; temperature is °C.

var reservoir_pressure: float = 280.0
var bubble_point: float = 140.0
var depth: float = 2400.0
var temperature: float = 85.0
var choke: float = 0.0
var flowing_bottomhole_pressure: float = 280.0
var flow_rate: float = 0.0
var local_pressure: float = 280.0
var wellhead_pressure: float = 15.0
var travel_fraction: float = 0.0
var natural_flow_available: bool = true

# All constants below are illustrative assumptions, not measured field data.
const OIL_DENSITY: float = 800.0 # kg/m³
const GRAVITY: float = 9.81
const SEPARATOR_PRESSURE: float = 15.0 # bar absolute, simplified receiving pressure
const PRODUCTIVITY_INDEX: float = 5.0 # m³/day/bar, undersaturated linear PI approximation
const TUBING_FRICTION: float = 0.00020 # bar / (m³/day)²
const CHOKE_RESISTANCE: float = 0.00012 # bar / (m³/day)² at fully open
const REFERENCE_FLOW: float = 300.0 # animation scale only

func set_choke(value: float) -> void:
	choke = clampf(value, 0.0, 1.0)
	if choke <= 0.001:
		flow_rate = 0.0
		flowing_bottomhole_pressure = reservoir_pressure

func update(delta: float, travel: float = 0.0) -> void:
	travel_fraction = clampf(travel, 0.0, 1.0)
	var hydrostatic: float = OIL_DENSITY * GRAVITY * depth / 100000.0
	var available_head: float = reservoir_pressure - SEPARATOR_PRESSURE - hydrostatic
	natural_flow_available = available_head > 0.0
	var target_rate: float = 0.0
	if choke > 0.001 and natural_flow_available:
		# Match reservoir inflow q = J(Pr-Pwf) to an illustrative tubing/choke curve:
		# Pwf = Psep + rho*g*H + (Kt + Kc/choke²)q².
		var loss_coefficient: float = TUBING_FRICTION + CHOKE_RESISTANCE / (choke * choke)
		var inverse_pi: float = 1.0 / PRODUCTIVITY_INDEX
		target_rate = (-inverse_pi + sqrt(inverse_pi * inverse_pi + 4.0 * loss_coefficient * available_head)) / (2.0 * loss_coefficient)
	# Smooth startup is an animation timescale, not a transient wellbore prediction.
	flow_rate = lerpf(flow_rate, target_rate, 1.0 - exp(-maxf(delta, 0.0) * 2.4))
	if target_rate <= 0.0:
		flow_rate = 0.0
	flowing_bottomhole_pressure = reservoir_pressure - flow_rate / PRODUCTIVITY_INDEX
	if choke > 0.001:
		wellhead_pressure = SEPARATOR_PRESSURE + CHOKE_RESISTANCE * flow_rate * flow_rate / (choke * choke)
	else:
		wellhead_pressure = maxf(SEPARATOR_PRESSURE, reservoir_pressure - hydrostatic)
	local_pressure = lerpf(flowing_bottomhole_pressure, wellhead_pressure, travel_fraction)

func snapshot() -> Dictionary:
	return {
		"reservoir_pressure": reservoir_pressure,
		"flowing_bottomhole_pressure": flowing_bottomhole_pressure,
		"bottomhole_pressure": flowing_bottomhole_pressure,
		"wellhead_pressure": wellhead_pressure,
		"local_pressure": local_pressure,
		"bubble_point": bubble_point,
		"temperature": lerpf(temperature, 30.0, travel_fraction),
		"reservoir_temperature": temperature,
		"depth": depth * (1.0 - travel_fraction),
		"reservoir_depth": depth,
		"flow_rate": flow_rate,
		"flow_ratio": clampf(flow_rate / REFERENCE_FLOW, 0.0, 1.0),
		"choke": choke,
		"gas_visible": flow_rate > 0.1 and local_pressure < bubble_point,
		"natural_flow_available": natural_flow_available,
		"status": "Closed" if choke <= 0.001 else ("Producing" if natural_flow_available else "Insufficient pressure head"),
		"simulation_label": "Illustrative Educational Simulation",
		"equation": "Q = J × max(Pr − Pwf, 0)",
		"assumptions": "Pr 280 bar; J 5 m³/day/bar; oil 800 kg/m³; H 2400 m; receiving pressure 15 bar; bubble point 140 bar. Constant Pr; lumped friction/choke loss; no gas-volume prediction."
	}
