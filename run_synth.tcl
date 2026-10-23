open_project /home/user/riscv_pipeline/riscv_pipeline.xpr
set_property top riscv_pipeline [current_fileset]
update_compile_order -fileset sources_1
reset_run synth_1
launch_runs synth_1 -jobs 4
wait_on_run synth_1
open_run synth_1 -name synth_1
report_utilization -file /home/user/riscv_pipeline/utilization_synth.rpt
report_timing_summary -file /home/user/riscv_pipeline/timing_synth.rpt
puts "SYNTHESIS COMPLETED SUCCESSFULLY"
exit
