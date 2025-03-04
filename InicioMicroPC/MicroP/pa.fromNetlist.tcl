
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name MicroP -dir "C:/Users/alvar/Documents/InicioMicroPC/MicroP/planAhead_run_1" -part xc6slx16ftg256-2
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "C:/Users/alvar/Documents/InicioMicroPC/MicroP/Reg_array.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {C:/Users/alvar/Documents/InicioMicroPC/MicroP} }
set_property target_constrs_file "Reg_array.ucf" [current_fileset -constrset]
add_files [list {Reg_array.ucf}] -fileset [get_property constrset [current_run]]
link_design
