set_global_assignment -entity "vga_pll" -library "lib_vga_pll" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "vga_pll" -library "lib_vga_pll" -name IP_TOOL_VERSION "16.0"
set_global_assignment -entity "vga_pll" -library "lib_vga_pll" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_vga_pll" -name SPD_FILE [file join $::quartus(sip_path) "vga_pll.spd"]

set_global_assignment -library "lib_vga_pll" -name MISC_FILE [file join $::quartus(sip_path) "vga_pll_sim/vga_pll.vo"]
