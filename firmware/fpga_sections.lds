MEMORY
{
    FLASH (rx)      : ORIGIN = 0x00000000, LENGTH = 0x8000 /* 2048 words 8192 Bytes */
    RAM (xrw)       : ORIGIN = 0x20000000, LENGTH = 0x2000
}
SECTIONS {
    .text :
    {
        . = ALIGN(4);
        *(.text)
        *(.text*)
        *(.rodata)
        *(.rodata*)
        *(.srodata)
        *(.srodata*)
        . = ALIGN(4);
        _etext = .;
        _sidata = _etext;
    } >FLASH

    .data : AT ( _sidata )
    {
        . = ALIGN(4);
        _sdata = .;
        _ram_start = .;
        . = ALIGN(4);
        *(.data)
        *(.data*)
        *(.sdata)
        *(.sdata*)
        . = ALIGN(4);
        _edata = .;
    } >RAM

    .bss :
    {
        . = ALIGN(4);
        _sbss = .;
        *(.bss)
        *(.bss*)
        *(.sbss)
        *(.sbss*)
        *(COMMON)
        . = ALIGN(4);
        _ebss = .;
    } >RAM

    
    .irq :
    {
        . = ALIGN(0x200);   
        irq_regs_start = .;
        KEEP(*(.irq_regs))  
        irq_stack_start = .;
        KEEP(*(.irq_stack)) 
        irq_stack_end = .;
    } > RAM

    .heap :
    {
        . = ALIGN(4);
        _heap_start = .;
    } >RAM

    _stack_top = ORIGIN(RAM) + LENGTH(RAM); 
}
