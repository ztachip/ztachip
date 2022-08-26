onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -L xilinx_vip -L xpm -L xil_defaultlib -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -lib xil_defaultlib xil_defaultlib.mig_7series_0 xil_defaultlib.glbl

do {wave.do}

view wave
view structure
view signals

do {mig_7series_0.udo}

run -all

quit -force
