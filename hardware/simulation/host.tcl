source sim.tcl

set StdArithNoWarnings 1
set NumericStdNoWarnings 1

ztaInit "../../software/target/builds/ztachip_sim.hex"

for {set i 0} {$i < 32} {incr i} {
   ztaMemWriteInt16 [expr 2*($i)] [expr $i]
}

### Set message to MCORE
ztaMsgWriteInt 0x5
ztaMsgWriteInt 0
ztaMsgWriteInt 0 
ztaMsgWriteInt 0
ztaMsgWriteInt 0
ztaMsgWriteInt [expr 0]

set result [ztaMsgReadInt]
set result [ztaMsgReadInt]
set result [ztaMsgReadInt]

### Verify result ###
for {set i 0} {$i < 32} {incr i} {
   set result [ztaMemReadInt16 [expr (2*$i)]]
   puts $result
   if {$result != [expr ($i+1)]} {
      error "Wrong arithmetic results=$result"
   }
}
puts "SUCCESSFUL"

