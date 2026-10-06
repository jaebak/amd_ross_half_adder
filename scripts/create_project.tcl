# Run in a fresh Vivado session, or source from run_sim.tcl.
set project_root [file normalize [file join [file dirname [info script]] ..]]
set project_dir [file join $project_root build vivado]
set artifact_dir [file join $project_root artifacts]
file mkdir $artifact_dir

create_project -force cmod_a7_half_adder $project_dir -part xc7a35tcpg236-1
set_property target_language Verilog [current_project]
set_property target_simulator XSim [current_project]
add_files -norecurse [list \
    [file join $project_root rtl half_adder.v] \
    [file join $project_root rtl cmod_a7_half_adder.v]]
add_files -fileset constrs_1 -norecurse [file join $project_root constraints cmod_a7_35t.xdc]
add_files -fileset sim_1 -norecurse [file join $project_root sim tb_cmod_a7_half_adder.sv]
set_property top cmod_a7_half_adder [get_filesets sources_1]
set_property top tb_cmod_a7_half_adder [get_filesets sim_1]
set_property xsim.simulate.runtime 1us [get_filesets sim_1]
set_property xsim.simulate.log_all_signals true [get_filesets sim_1]
set_property xsim.simulate.wdb [file join $artifact_dir half_adder.wdb] [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "PROJECT_READY: [get_property NAME [current_project]]"
puts "PART: [get_property PART [current_project]]"
puts "SIMULATOR: [get_property target_simulator [current_project]]"
puts "SIM_TOP: [get_property TOP [get_filesets sim_1]]"
puts "SIM_SOURCES: [get_files -compile_order sources -used_in simulation]"
