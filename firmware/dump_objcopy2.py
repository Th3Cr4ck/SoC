import re
from pathlib import Path

# Crear la carpeta simulation si no existe
Path("simulation").mkdir(parents=True, exist_ok=True)

with open("firmware/diss.txt") as fin, \
     open("simulation/trace.mem", "w") as fout:

    for line in fin:

        m = re.match(
            r'\s*([0-9a-f]+):\s+[0-9a-f]+\s+(.+)',
            line
        )

        if m:

            pc = int(m.group(1), 16)

            instr = m.group(2).strip()

            instr = instr.replace(" ", "_")
            instr = instr.replace(",", "_")
            instr = instr.replace("(", "")
            instr = instr.replace(")", "")

            fout.write(f"{pc:08x}|{instr}\n")
