# vivado -mode batch -source scripts/run_sim.tcl
# The testbench terminates at 360 ns; its watchdog fails at 1 us.
source [file join [file dirname [info script]] create_project.tcl]
launch_simulation -simset sim_1 -mode behavioral
close_sim

set sim_dir [file join $project_dir cmod_a7_half_adder.sim sim_1 behav xsim]
set transcript_path [file join $sim_dir simulate.log]
set transcript_file [open $transcript_path r]
set transcript [read $transcript_file]
close $transcript_file

# Vivado can return normally even when a testbench calls $fatal.
# Require the terminal marker and reject simulator failures explicitly.
file copy -force $transcript_path [file join $artifact_dir simulation.log]
foreach log_name {xvlog.log elaborate.log} {
    file copy -force [file join $sim_dir $log_name] [file join $artifact_dir $log_name]
}
if {![regexp {TEST_PASS: 36 checks; 4 input combinations; 16 ordered transitions} $transcript] \
    || [regexp {(?im)TEST_FAIL|TEST_TIMEOUT|^\s*(fatal|error)\s*:} $transcript]} {
    error "SIMULATION_FAILED: inspect artifacts/simulation.log"
}
puts "SIMULATION_PASS: 36 checks completed; transcript and WDB saved in artifacts"
