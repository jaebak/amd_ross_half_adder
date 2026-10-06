# vivado -mode batch -source scripts/build_bitstream.tcl
# Open the project created by scripts/run_sim.tcl or create_project.tcl.
set project_root [file normalize [file join [file dirname [info script]] ..]]
set project_dir [file join $project_root build vivado]
set artifact_dir [file join $project_root artifacts]
file mkdir $artifact_dir

if {[current_project -quiet] eq ""} {
    open_project [file join $project_dir cmod_a7_half_adder.xpr]
}
if {[get_property PART [current_project]] ne "xc7a35tcpg236-1" \
    || [get_property TOP [get_filesets sources_1]] ne "cmod_a7_half_adder"} {
    error "Expected the Cmod A7-35T half-adder project"
}

launch_runs synth_1 -jobs 2
wait_on_run synth_1
if {[get_property PROGRESS [get_runs synth_1]] ne "100%"} {
    error "Synthesis did not complete: [get_property STATUS [get_runs synth_1]]"
}
launch_runs impl_1 -to_step write_bitstream -jobs 2
wait_on_run impl_1
if {[get_property PROGRESS [get_runs impl_1]] ne "100%"} {
    error "Implementation did not complete: [get_property STATUS [get_runs impl_1]]"
}

open_run impl_1
report_utilization -file [file join $artifact_dir utilization.rpt]
report_timing_summary -file [file join $artifact_dir timing_summary.rpt]
report_drc -file [file join $artifact_dir drc.rpt]
file copy -force \
    [file join $project_dir cmod_a7_half_adder.runs impl_1 cmod_a7_half_adder.bit] \
    [file join $artifact_dir cmod_a7_half_adder.bit]
puts "BITSTREAM_READY: [file join $artifact_dir cmod_a7_half_adder.bit]"
