#!/usr/bin/env bash

set -e

cd $(dirname "$0")

ZTACHIP_RTL=../../HW/src

rm -r -f build

rm -f *.v

mkdir -p build

# Import sources
ghdl -i --std=08 --work=work --workdir=build -Pbuild \
  "$ZTACHIP_RTL"/*.vhd \
  "$ZTACHIP_RTL"/alu/*.vhd \
  "$ZTACHIP_RTL"/dp/*.vhd \
  "$ZTACHIP_RTL"/ialu/*.vhd \
  "$ZTACHIP_RTL"/pcore/*.vhd \
  "$ZTACHIP_RTL"/soc/axi/*.vhd \
  "$ZTACHIP_RTL"/soc/peripherals/time.vhd \
  "$ZTACHIP_RTL"/soc/peripherals/gpio.vhd \
  "$ZTACHIP_RTL"/soc/peripherals/uart.vhd \
  "$ZTACHIP_RTL"/soc/peripherals/vga.vhd \
  "$ZTACHIP_RTL"/soc/peripherals/camera.vhd \
  "$ZTACHIP_RTL"/util/shifter_l.vhd \
  "$ZTACHIP_RTL"/util/shifter.vhd \
  "$ZTACHIP_RTL"/util/multiplier.vhd \
  "$ZTACHIP_RTL"/util/delayv.vhd \
  "$ZTACHIP_RTL"/util/delayi.vhd \
  "$ZTACHIP_RTL"/util/delay.vhd \
  "$ZTACHIP_RTL"/util/arbiter.vhd \
  "$ZTACHIP_RTL"/util/adder.vhd \
  "$ZTACHIP_RTL"/util/afifo.vhd \
  "$ZTACHIP_RTL"/util/afifo2.vhd \
  "$ZTACHIP_RTL"/util/ram2r1w.vhd \
  "$ZTACHIP_RTL"/util/ramw2.vhd \
  "$ZTACHIP_RTL"/util/ramw.vhd \
  "$ZTACHIP_RTL"/util/fifo.vhd \
  "$ZTACHIP_RTL"/util/fifow.vhd \
  "$ZTACHIP_RTL"/soc/*.vhd \
  "$ZTACHIP_RTL"/top/*.vhd

# Top entity
ghdl -m --std=08 --work=work --workdir=build soc_base 

# Synthesize: generate Verilog output
ghdl synth --std=08 --work=work --workdir=build -Pbuild --out=verilog soc_base > soc.v
