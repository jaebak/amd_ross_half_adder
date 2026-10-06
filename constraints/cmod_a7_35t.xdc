# Cmod A7-35T, xc7a35tcpg236-1.
# Pin assignments from Digilent's official Cmod A7 master constraints:
# https://github.com/Digilent/digilent-xdc/blob/master/Cmod-A7-Master.xdc
# Buttons and the two individual LEDs are active high.

# Bank 0 is powered from VCC3V3, and CFGBVS is pulled up to VCC3V3.
# Digilent Cmod A7 schematic, configuration and FPGA power sheets (2 and 4):
# https://digilent.com/reference/_media/reference/programmable-logic/cmod-a7/cmod_a7_sch_rev_c0.pdf
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

set_property -dict {PACKAGE_PIN A18 IOSTANDARD LVCMOS33} [get_ports {btn[0]}]
set_property -dict {PACKAGE_PIN B18 IOSTANDARD LVCMOS33} [get_ports {btn[1]}]
set_property -dict {PACKAGE_PIN A17 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN C16 IOSTANDARD LVCMOS33} [get_ports {led[1]}]

set_property SLEW SLOW [get_ports {led[*]}]
set_property DRIVE 8 [get_ports {led[*]}]

# This is an asynchronous, combinational button-to-LED circuit: no clock.
# Budget 20 ns for propagation through the FPGA; this is an internal
# input-to-output delay limit, not a model of mechanical button debounce.
set_max_delay 20.000 -from [get_ports {btn[*]}] -to [get_ports {led[*]}]
