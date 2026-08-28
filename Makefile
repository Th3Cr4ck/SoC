RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX = /opt/riscv

CFLAGS=
ICARUS_SUFFIX =
IVERILOG = iverilog$(ICARUS_SUFFIX)
VVP = vvp$(ICARUS_SUFFIX)
PYTHON = python3

# ":=" se usa para valores constantes
NAME := PICORV32_Module
HDL := hdl
AIP := hdl/AIP
CORDIC := hdl/cordic
TESTS := hdl/testbench
FIRMWARE := firmware
FIRM_QUARTUS := Quartus/firmware
SIM := simulation

HDL_FILES = $(shell find $(HDL) -path $(TESTS) -prune -o -type f \( -name "*.v" -o -name "*.sv" \) -print)

TEST_OBJS = $(addsuffix .o,$(basename $(wildcard tests/*.S)))
FIRMWARE_OBJS = $(FIRMWARE)/start.o $(FIRMWARE)/irq.o $(FIRMWARE)/print.o
GCC_WARNS  = -Wall -Wextra -Wshadow -Wundef -Wpointer-arith -Wcast-qual -Wcast-align -Wwrite-strings
GCC_WARNS += -Wredundant-decls -Wstrict-prototypes -Wmissing-prototypes -pedantic # -Wconversion
TOOLCHAIN_PREFIX = $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)/bin/riscv64-unknown-elf-
COMPRESSED_ISA = C

synth_pwm: $(HDL)/pwm.v $(TESTS)/tb_ID00005010.v $(HDL)/ID00005010* $(HDL)/prescaler.v $(AIP)/*.v
	$(IVERILOG) $^ -o $(SIM)/pwm.vvp

sim_pwm: synth_pwm
	vvp $(SIM)/pwm.vvp
	mv Test_id00005010.vcd $(SIM)/Test_id00005010.vcd

synth_gpio: $(HDL)/gpio_port.v $(TESTS)/tb_ID00005020.v $(HDL)/ID00005020* $(AIP)/*.v $(HDL)/simple_dual_port_ram_single_clk.v
	$(IVERILOG) $^ -o $(SIM)/gpio.vvp

sim_gpio: synth_gpio
	vvp $(SIM)/gpio.vvp
	mv Test_id00005020.vcd $(SIM)/Test_id00005020.vcd

synth_cordic: $(CORDIC)/*.v $(CORDIC)/*.sv $(HDL)/ID00005030* $(TESTS)/tb_ID00005030.v $(AIP)/*.v $(HDL)/simple_dual_port_ram_single_clk.v
	$(IVERILOG) -g2012 $^ -o $(SIM)/cordic.vvp

sim_cordic: synth_cordic
	vvp $(SIM)/cordic.vvp
	mv Test_id00005030.vcd $(SIM)/Test_id00005030.vcd

synth_soc: $(HDL_FILES) $(TESTS)/testbench_TOP_SOC.v
	#-- Compilar
	$(IVERILOG) -g2012 $^ -o $(SIM)/$(NAME)_tb.out

sim_soc: $(SIM)/$(NAME)_tb.out	
	#-- Simular
	vvp $(SIM)/$(NAME)_tb.out
	mv Testbench_soc.vcd $(SIM)/Testbench_soc.vcd
	
fpga_sections.lds: sections.lds
	$(TOOLCHAIN_PREFIX)cpp -P -DICEBREAKER -o $@ $^

main_fw.elf: $(FIRMWARE)/fpga_sections.lds $(FIRMWARE)/print.c $(FIRMWARE)/irqb.c $(FIRMWARE)/start.S $(FIRMWARE)/aip.c $(FIRMWARE)/*.c $(FIRMWARE)/main.c
	$(TOOLCHAIN_PREFIX)gcc $(CFLAGS) -DICEBREAKER -mabi=ilp32 -march=rv32i -Wl,-Bstatic,-T,$(FIRMWARE)/fpga_sections.lds,--strip-debug -ffreestanding -nostartfiles -o $(FIRMWARE)/main_fw.o $(FIRMWARE)/start.S $(FIRMWARE)/irqb.c $(FIRMWARE)/print.c $(FIRMWARE)/aip.c $(FIRMWARE)/id000050*.c $(FIRMWARE)/main.c -Os
	$(TOOLCHAIN_PREFIX)gcc $(CFLAGS) -DICEBREAKER -mabi=ilp32 -march=rv32i -Wl,-Bstatic,-T,$(FIRMWARE)/fpga_sections.lds,--strip-debug -ffreestanding -nostartfiles -o $(FIRMWARE)/main_fw.elf $(FIRMWARE)/start.S $(FIRMWARE)/irqb.c $(FIRMWARE)/print.c $(FIRMWARE)/aip.c $(FIRMWARE)/id000050*.c $(FIRMWARE)/main.c -Os
	$(TOOLCHAIN_PREFIX)gcc $(CFLAGS) -DICEBREAKER -mabi=ilp32 -march=rv32i -Wl,-Bstatic,-T,$(FIRMWARE)/fpga_sections.lds,--strip-debug -ffreestanding -nostartfiles -S $(FIRMWARE)/irqb.c -o $(FIRMWARE)/irqb.s
	$(TOOLCHAIN_PREFIX)gcc $(CFLAGS) -DICEBREAKER -mabi=ilp32 -march=rv32i -Wl,-Bstatic,-T,$(FIRMWARE)/fpga_sections.lds,--strip-debug -ffreestanding -nostartfiles -S $(FIRMWARE)/main.c -o $(FIRMWARE)/main.s

main_fw.hex: main_fw.elf
	$(TOOLCHAIN_PREFIX)objcopy -O verilog $(FIRMWARE)/main_fw.elf $(FIRMWARE)/main_fw.hex

main_fw.bin: $(FIRMWARE)/main_fw.elf
	$(TOOLCHAIN_PREFIX)objcopy -O binary $(FIRMWARE)/main_fw.elf $(FIRMWARE)/main_fw.bin

memtarce: diss
	$(PYTHON) $(FIRMWARE)/dump_objcopy2.py

diss:
	$(TOOLCHAIN_PREFIX)objdump -d $(FIRMWARE)/main_fw.o > $(FIRMWARE)/diss.txt

main_fw.txt: main_fw.hex diss memtarce
	$(PYTHON) $(FIRMWARE)/hextoMEM_v3.py $(FIRMWARE)/main_fw.hex $(FIRMWARE)/main_fw.txt 8192 

main_fw.elf.fpga: $(FIRMWARE)/fpga_sections.lds $(FIRMWARE)/print.c $(FIRMWARE)/irqb.c $(FIRMWARE)/start.S $(FIRM_QUARTUS)/main_quartus.c $(FIRMWARE)/aip.c $(FIRMWARE)/id*.c
	$(TOOLCHAIN_PREFIX)gcc $(CFLAGS) -DICEBREAKER -mabi=ilp32 -march=rv32i -I$(FIRMWARE) -Wl,-Bstatic,-T,$(FIRMWARE)/fpga_sections.lds,--strip-debug -ffreestanding -nostartfiles -o $(FIRM_QUARTUS)/main_fw.o $(FIRMWARE)/start.S $(FIRMWARE)/irqb.c $(FIRMWARE)/print.c $(FIRM_QUARTUS)/gpio_uart.c $(FIRMWARE)/aip.c $(FIRMWARE)/id*.c $(FIRM_QUARTUS)/main_quartus.c -Os
	$(TOOLCHAIN_PREFIX)gcc $(CFLAGS) -DICEBREAKER -mabi=ilp32 -march=rv32i -I$(FIRMWARE) -Wl,-Bstatic,-T,$(FIRMWARE)/fpga_sections.lds,--strip-debug -ffreestanding -nostartfiles -o $(FIRM_QUARTUS)/main_fw.elf $(FIRMWARE)/start.S $(FIRMWARE)/irqb.c $(FIRMWARE)/print.c $(FIRM_QUARTUS)/gpio_uart.c $(FIRMWARE)/aip.c $(FIRMWARE)/id*.c $(FIRM_QUARTUS)/main_quartus.c -Os
	$(TOOLCHAIN_PREFIX)gcc $(CFLAGS) -DICEBREAKER -mabi=ilp32 -march=rv32i -Wl,-Bstatic,-T,$(FIRMWARE)/fpga_sections.lds,--strip-debug -ffreestanding -nostartfiles -S $(FIRMWARE)/irqb.c -o $(FIRMWARE)/irqb.s
	$(TOOLCHAIN_PREFIX)gcc $(CFLAGS) -DICEBREAKER -mabi=ilp32 -march=rv32i -I$(FIRMWARE) -Wl,-Bstatic,-T,$(FIRMWARE)/fpga_sections.lds,--strip-debug -ffreestanding -nostartfiles -S $(FIRM_QUARTUS)/main_quartus.c -o $(FIRM_QUARTUS)/main.s

main_fw.hex.fpga: main_fw.elf.fpga
	$(TOOLCHAIN_PREFIX)objcopy -O verilog $(FIRM_QUARTUS)/main_fw.elf $(FIRM_QUARTUS)/main_fw.hex

main_fw.bin.fpga: $(FIRM_QUARTUS)/main_fw.elf
	$(TOOLCHAIN_PREFIX)objcopy -O binary $(FIRM_QUARTUS)/main_fw.elf $(FIRM_QUARTUS)/main_fw.bin

diss.fpga:
	$(TOOLCHAIN_PREFIX)objdump -d $(FIRM_QUARTUS)/main_fw.o > $(FIRMWARE)/diss.txt

memtarce.fpga: diss.fpga
	$(PYTHON) $(FIRM_QUARTUS)/dump_objcopy2.py
	mv $(FIRMWARE)/diss.txt $(FIRM_QUARTUS)/diss.txt

main_fw_fpga: main_fw.hex.fpga diss.fpga memtarce.fpga
	$(PYTHON) $(FIRM_QUARTUS)/hextoMEM_v3.py $(FIRM_QUARTUS)/main_fw.hex $(FIRM_QUARTUS)/main_fw.txt 8192 

clean:

	rm -f testbench.vvp testbench.vcd *.out main.s irq.s *.config *.json *.pnr.log *.svf *.o *.mem
	rm -f $(FIRMWARE)/*.hex $(FIRMWARE)/*.elf $(FIRMWARE)/*.bin $(FIRMWARE)/*.txt $(FIRMWARE)/*.o
	rm -vrf $(FIRMWARE_OBJS) $(TEST_OBJS) check.smt2 check.vcd synth.v synth.log \
                $(FIRMWARE)/*.elf $(FIRMWARE)/*.bin $(FIRMWARE)/*.hex $(FIRMWARE)/*.txt $(FIRMWARE)/*.map \
                testbench.vvp \
                *.vvp *.vvp testbench.vcd *.trace 
	rm -f $(FIRM_QUARTUS)/*.hex $(FIRM_QUARTUS)/*.elf $(FIRM_QUARTUS)/*.bin $(FIRM_QUARTUS)/*.txt $(FIRM_QUARTUS)/*.o
	find $(SIM) -maxdepth 1 -type f ! -name "*.gtkw" -delete


