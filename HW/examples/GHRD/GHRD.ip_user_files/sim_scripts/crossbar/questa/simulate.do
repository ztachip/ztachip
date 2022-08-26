onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib crossbar_opt

do {wave.do}

view wave
view structure
view signals

do {crossbar.udo}

run -all

quit -force
