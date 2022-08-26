onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib mig_7series_0_opt

do {wave.do}

view wave
view structure
view signals

do {mig_7series_0.udo}

run -all

quit -force
