RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX = /opt/riscv

CFLAGS=
ICARUS_SUFFIX =
IVERILOG = iverilog$(ICARUS_SUFFIX)
VVP = vvp$(ICARUS_SUFFIX)
PYTHON = python3

NAME := PICORV32_Module# := se usa para valores constantes
BASICBLOCKS := ../mods/basicblocks
MODULES= modules
HDL := hdl
AIP := hdl/AIP
FIRMWARE := firmware
SIM := simulation

TEST_OBJS = $(addsuffix .o,$(basename $(wildcard tests/*.S)))
FIRMWARE_OBJS = $(FIRMWARE)/start.o $(FIRMWARE)/irq.o $(FIRMWARE)/print.o
GCC_WARNS  = -Wall -Wextra -Wshadow -Wundef -Wpointer-arith -Wcast-qual -Wcast-align -Wwrite-strings
GCC_WARNS += -Wredundant-decls -Wstrict-prototypes -Wmissing-prototypes -pedantic # -Wconversion
TOOLCHAIN_PREFIX = $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)/bin/riscv64-unknown-elf-
COMPRESSED_ISA = C

synth_pwm: $(HDL)/pwm.v $(HDL)/tb_ID00005010.v $(HDL)/ID00005010* $(HDL)/prescaler.v $(AIP)/*.v
	$(IVERILOG) $^ -o $(SIM)/pwm.vvp

sim_pwm: synth_pwm
	vvp $(SIM)/pwm.vvp
	mv Test_id00005010.vcd $(SIM)/Test_id00005010.vcd

synth_soc: $(HDL)/*.v #testbench_TOP_SOC.v pico_mini_soc.v pico_mini.v simpleuart.v picorv32_Small.v picorv32.v
	#-- Compilar
	$(IVERILOG) $^ -o $(SIM)/$(NAME)_tb.out

sim_soc: *.out
	#-- Simular
	vvp $(SIM)/$(NAME)_tb.out
	
fpga_sections.lds: sections.lds
	$(TOOLCHAIN_PREFIX)cpp -P -DICEBREAKER -o $@ $^

main_fw.elf: $(FIRMWARE)/fpga_sections.lds $(FIRMWARE)/print.c $(FIRMWARE)/irqb.c $(FIRMWARE)/start.S $(FIRMWARE)/main.s
	$(TOOLCHAIN_PREFIX)gcc $(CFLAGS) -DICEBREAKER -mabi=ilp32 -march=rv32i -Wl,-Bstatic,-T,$(FIRMWARE)/fpga_sections.lds,--strip-debug -ffreestanding -nostartfiles -o $(FIRMWARE)/main_fw.o $(FIRMWARE)/start.S $(FIRMWARE)/irqb.c $(FIRMWARE)/print.c $(FIRMWARE)/main.s -Os
	$(TOOLCHAIN_PREFIX)gcc $(CFLAGS) -DICEBREAKER -mabi=ilp32 -march=rv32i -Wl,-Bstatic,-T,$(FIRMWARE)/fpga_sections.lds,--strip-debug -ffreestanding -nostartfiles -o $(FIRMWARE)/main_fw.elf $(FIRMWARE)/start.S $(FIRMWARE)/irqb.c $(FIRMWARE)/print.c $(FIRMWARE)/main.s -Os
	$(TOOLCHAIN_PREFIX)gcc $(CFLAGS) -DICEBREAKER -mabi=ilp32 -march=rv32i -Wl,-Bstatic,-T,$(FIRMWARE)/fpga_sections.lds,--strip-debug -ffreestanding -nostartfiles -S $(FIRMWARE)/irqb.c -o $(FIRMWARE)/irqb.s
	#$(TOOLCHAIN_PREFIX)gcc $(CFLAGS) -DICEBREAKER -mabi=ilp32 -march=rv32i -Wl,-Bstatic,-T,$(FIRMWARE)/fpga_sections.lds,--strip-debug -ffreestanding -nostartfiles -S $(FIRMWARE)/main.c -o $(FIRMWARE)/main.s # DEscomentar si el archivo main no es .s

main_fw.hex: main_fw.elf
	$(TOOLCHAIN_PREFIX)objcopy -O verilog $(FIRMWARE)/main_fw.elf $(FIRMWARE)/main_fw.hex

main_fw.bin: $(FIRMWARE)/main_fw.elf
	$(TOOLCHAIN_PREFIX)objcopy -O binary $(FIRMWARE)/main_fw.elf $(FIRMWARE)/main_fw.bin

memtarce: diss
	$(PYTHON) $(FIRMWARE)/dump_objcopy2.py

main_fw.txt: main_fw.hex diss memtarce
	$(PYTHON) $(FIRMWARE)/hextoMEM_v3.py $(FIRMWARE)/main_fw.hex $(FIRMWARE)/main_fw.txt 8192 

diss:
	$(TOOLCHAIN_PREFIX)objdump -d $(FIRMWARE)/main_fw.o > $(FIRMWARE)/diss.txt

clean:

	rm -f testbench.vvp testbench.vcd *.out main.s irq.s *.config *.json *.pnr.log *.svf *.o *.mem
	rm -f $(FIRMWARE)/*.hex $(FIRMWARE)/*.elf $(FIRMWARE)/*.bin $(FIRMWARE)/*.txt $(FIRMWARE)/*.o
	rm -vrf $(FIRMWARE_OBJS) $(TEST_OBJS) check.smt2 check.vcd synth.v synth.log \
                $(FIRMWARE)/*.elf $(FIRMWARE)/*.bin $(FIRMWARE)/*.hex $(FIRMWARE)/*.txt $(FIRMWARE)/*.map \
                testbench.vvp \
                *.vvp *.vvp testbench.vcd *.trace 
	find $(SIM) -maxdepth 1 -type f ! -name "*.gtkw" -delete


