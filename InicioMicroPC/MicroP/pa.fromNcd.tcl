
# PlanAhead Launch Script for Post PAR Floorplanning, created by Project Navigator

create_project -name MicroP -dir "C:/Users/alvar/Documents/InicioMicroPC/MicroP/planAhead_run_1" -part xc6slx16ftg256-2
set srcset [get_property srcset [current_run -impl]]
set_property design_mode GateLvl $srcset
set_property edif_top_file "C:/Users/alvar/Documents/InicioMicroPC/MicroP/ALU.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {C:/Users/alvar/Documents/InicioMicroPC/MicroP} }
set_property target_constrs_file "ALU.ucf" [current_fileset -constrset]
add_files [list {ALU.ucf}] -fileset [get_property constrset [current_run]]
link_design
read_xdl -file "C:/Users/alvar/Documents/InicioMicroPC/MicroP/ALU.ncd"
if {[catch {read_twx -name results_1 -file "C:/Users/alvar/Documents/InicioMicroPC/MicroP/ALU.twx"} eInfo]} {
   puts "WARNING: there was a problem importing \"C:/Users/alvar/Documents/InicioMicroPC/MicroP/ALU.twx\": $eInfo"
}
