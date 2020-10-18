ENTRY(_start)
STARTUP(crt0.o)
OUTPUT_FORMAT("elf32-bigmips","elf32-bigmips","elf32-littlemips")
GROUP(-lc -lidt -lgcc)
SEARCH_DIR(./mips-elf/lib)
__DYNAMIC  =  0;
PROVIDE (hardware_exit_hook = 0);
PROVIDE (hardware_hazard_hook = 0);
PROVIDE (hardware_init_hook = 0);
PROVIDE (software_init_hook = 0);
SECTIONS
{
. = 0x00000200;
.gcc_except_table : { *(.gcc_except_table) }
.jcr : { KEEP (*(.jcr)) }
.ctors :
{
KEEP (*crtbegin.o(.ctors))
KEEP (*(EXCLUDE_FILE (*crtend.o) .ctors))
KEEP (*(SORT(.ctors.*)))
KEEP (*(.ctors))
}.dtors :
{
KEEP (*crtbegin.o(.dtors))
KEEP (*(EXCLUDE_FILE (*crtend.o) .dtors))
KEEP (*(SORT(.dtors.*)))
KEEP (*(.dtors))
}
. = . + 0x400;
PROVIDE (__stack = .);
.rodata : {
*(.rdata)
*(.rodata)
*(.rodata.*)
*(.gnu.linkonce.r.*)
}
_fdata = ALIGN(16);
.data : {
*(.data)
*(.data.*)
*(.gnu.linkonce.d.*)
}
. = ALIGN(8);
_gp = . + 0x100;
__global = _gp;
.lit8 : {
*(.lit8)
}
.lit4 : {
*(.lit4)
}
.sdata : {
*(.sdata)
*(.sdata.*)
*(.gnu.linkonce.s.*)
}
. = ALIGN(4);
PROVIDE (edata  =  .);
_edata  =  .;
_fbss = .;
.sbss : {
*(.sbss)
*(.sbss.*)
*(.gnu.linkonce.sb.*)
*(.scommon)
}
.bss : {
_bss_start = . ;
*(.bss)
*(.bss.*)
*(.gnu.linkonce.b.*)
*(COMMON)
}
PROVIDE (end = .);
_end = .;
}
SECTIONS
{
. = 0x00F00010;
.text : {
_ftext = . ;
PROVIDE (eprol = .);
*(EXCLUDE_FILE (
../apps/nn/kernels/conv.o
../apps/nn/kernels/fcn.o
../apps/color/kernels/color.o
../apps/resize/kernels/resize.o
../apps/equalize/kernels/equalize.o
../apps/gaussian/kernels/gaussian.o
../apps/canny/kernels/canny.o
../apps/harris/kernels/harris.o
../apps/of/kernels/of.o
).text*)
}
.init : {
KEEP (*(.init))
}
.fini : {
KEEP (*(.fini))
}
.rel.sdata : {
PROVIDE (__runtime_reloc_start = .);
*(.rel.sdata)
PROVIDE (__runtime_reloc_stop = .);
}
PROVIDE (zta_ox_begin = .);
OVERLAY : AT (0x00F80000)
{
.text0 {../apps/nn/kernels/conv.o(.text)}
.text1 {../apps/nn/kernels/fcn.o(.text)}
.text2 {../apps/color/kernels/color.o(.text)}
.text3 {../apps/resize/kernels/resize.o(.text)}
.text4 {../apps/equalize/kernels/equalize.o(.text)}
.text5 {../apps/gaussian/kernels/gaussian.o(.text)}
.text6 {../apps/canny/kernels/canny.o(.text)}
.text7 {../apps/harris/kernels/harris.o(.text)}
.text8 {../apps/of/kernels/of.o(.text)}
}
PROVIDE (zta_o0_end = 0x00F00000+SIZEOF(.text0));
PROVIDE (zta_o1_end = 0x00F00000+SIZEOF(.text1));
PROVIDE (zta_o2_end = 0x00F00000+SIZEOF(.text2));
PROVIDE (zta_o3_end = 0x00F00000+SIZEOF(.text3));
PROVIDE (zta_o4_end = 0x00F00000+SIZEOF(.text4));
PROVIDE (zta_o5_end = 0x00F00000+SIZEOF(.text5));
PROVIDE (zta_o6_end = 0x00F00000+SIZEOF(.text6));
PROVIDE (zta_o7_end = 0x00F00000+SIZEOF(.text7));
PROVIDE (zta_o8_end = 0x00F00000+SIZEOF(.text8));
PROVIDE (etext = .);
_etext  =  .;
}
