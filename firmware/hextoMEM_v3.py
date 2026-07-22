#!/usr/bin/env python3
"""
hextoMEM_v3.py
Convierte un archivo .hex (formato con direcciones @ADDR y bytes en little-endian)
a un archivo .txt de palabras de 32 bits para inicialización de memorias FPGA.

Uso:
  hextoMEM_v3.py <input.hex> <output.txt> <mem_length>
  hextoMEM_v3.py                                          ← defaults: main_fw.hex / main_fw.txt / 2048

Parámetros:
  input.hex    Archivo fuente en formato .hex con etiquetas @ADDRESS.
  output.txt   Archivo de salida con una palabra de 32 bits por línea.
  mem_length   Tamaño de la memoria de programa en palabras de 32 bits.
               El firmware DEBE caber completamente dentro de este rango.
               El archivo de salida tendrá exactamente mem_length líneas.

Formato del .hex:
  @XXXXXXXX  → dirección base en hexadecimal (unidades de palabras de 32 bits)
  BB BB BB BB [...]  → bytes en little-endian (1 a 4 palabras de 32 bits por línea)

Códigos de salida:
  0 → OK
  1 → Error de uso / archivo no encontrado
  2 → El firmware no cabe en la memoria especificada
"""

import os
import sys

# ──────────────────────────────────────────────────────────────────────────────
# Constantes
# ──────────────────────────────────────────────────────────────────────────────

DEFAULT_INPUT      = 'firmware/main_fw.hex'
DEFAULT_OUTPUT     = 'firmware/main_fw.txt'
DEFAULT_MEM_LENGTH = 2048          # palabras de 32 bits

# ──────────────────────────────────────────────────────────────────────────────
# Helpers de conversión
# ──────────────────────────────────────────────────────────────────────────────

def bytes_to_word32_le(b0: str, b1: str, b2: str, b3: str) -> str:
    """4 bytes en little-endian → palabra de 32 bits (string hex de 8 chars)."""
    return f"{b3}{b2}{b1}{b0}".upper()


def parse_byte_tokens(line: str) -> list:
    """Línea de bytes separados por espacios → lista de strings hex de 2 chars."""
    return line.strip().split()


def tokens_to_words(byte_tokens: list) -> list:
    """
    Lista de tokens de bytes hex → lista de palabras de 32 bits (little-endian).
    Si el número de bytes no es múltiplo de 4 se rellena con '00'.
    """
    tokens = list(byte_tokens)
    while len(tokens) % 4 != 0:
        tokens.append('00')
    words = []
    for i in range(0, len(tokens), 4):
        words.append(bytes_to_word32_le(tokens[i], tokens[i+1], tokens[i+2], tokens[i+3]))
    return words

# ──────────────────────────────────────────────────────────────────────────────
# Parser del .hex
# ──────────────────────────────────────────────────────────────────────────────

def parse_hex_file(input_file: str) -> dict:
    """
    Lee el archivo .hex y retorna un diccionario:
        { word_address (int) : word_value (str 8-char hex) }
    """
    memory       = {}
    current_addr = 0
    first_line   = True

    with open(input_file, 'r') as f:
        for raw_line in f:
            line = raw_line.strip()
            if not line:
                continue

            if line.startswith('@'):
                # Etiqueta de dirección
                current_addr = int(line[1:], 16)
                first_line   = False
                continue

            if first_line:
                # Primera línea sin '@': asumimos datos desde dirección 0
                first_line = False

            byte_tokens = parse_byte_tokens(line)
            if not byte_tokens:
                continue

            for word in tokens_to_words(byte_tokens):
                memory[current_addr] = word
                current_addr += 1

    return memory

# ──────────────────────────────────────────────────────────────────────────────
# Validación de tamaño
# ──────────────────────────────────────────────────────────────────────────────

def validate_fit(memory: dict, mem_length: int) -> tuple:
    """
    Verifica que el firmware quepa en la memoria de programa.

    Retorna (ok: bool, info: dict) donde info contiene métricas de uso.
    """
    if not memory:
        return False, {}

    min_addr   = min(memory.keys())
    max_addr   = max(memory.keys())
    span       = max_addr - min_addr + 1   # palabras que ocupa el rango del fw
    used_words = len(memory)               # palabras con datos reales
    free_words = mem_length - (max_addr + 1)  # palabras libres al final

    # El firmware cabe si la dirección más alta + 1 no supera mem_length
    fits = (max_addr + 1) <= mem_length

    info = {
        'min_addr'   : min_addr,
        'max_addr'   : max_addr,
        'span'       : span,
        'used_words' : used_words,
        'fill_words' : span - used_words,
        'mem_length' : mem_length,
        'free_words' : free_words if fits else 0,
        'overflow'   : (max_addr + 1) - mem_length if not fits else 0,
        'usage_pct'  : ((max_addr + 1) / mem_length) * 100,
    }
    return fits, info

# ──────────────────────────────────────────────────────────────────────────────
# Reporte de memoria
# ──────────────────────────────────────────────────────────────────────────────

BAR_WIDTH = 40

def memory_bar(used: int, total: int, width: int = BAR_WIDTH) -> str:
    """Barra visual de uso de memoria."""
    filled = round((used / total) * width)
    filled = max(0, min(width, filled))
    return '[' + '█' * filled + '░' * (width - filled) + ']'


def print_report(info: dict, fits: bool):
    sep = '─' * 56
    print()
    print('┌' + sep + '┐')
    print('│{:^56}│'.format('  REPORTE DE MEMORIA DE PROGRAMA  '))
    print('├' + sep + '┤')

    min_a  = info['min_addr']
    max_a  = info['max_addr']
    span   = info['span']
    used   = info['used_words']
    fill   = info['fill_words']
    mem_l  = info['mem_length']
    pct    = info['usage_pct']

    rows = [
        ('Dirección base (firmware)',   f'0x{min_a:08X}  ({min_a})'),
        ('Dirección tope (firmware)',   f'0x{max_a:08X}  ({max_a})'),
        ('Rango ocupado por el fw',     f'{span} palabras  (0x{span:X})'),
        ('Palabras con datos reales',   f'{used}'),
        ('Palabras rellenas (gaps)',     f'{fill}'),
        ('Tamaño de memoria objetivo',  f'{mem_l} palabras  (0x{mem_l:X})'),
    ]

    if fits:
        rows.append(('Palabras libres al final', f'{info["free_words"]}'))
    else:
        rows.append(('Desbordamiento',           f'{info["overflow"]} palabras  ← OVERFLOW'))

    for label, value in rows:
        print(f'│  {label:<30} {value:<22}│')

    print('├' + sep + '┤')
    bar = memory_bar(max_a + 1, mem_l)
    print(f'│  Uso: {pct:5.1f}%  {bar} │')
    print('├' + sep + '┤')

    if fits:
        status = f'  ✓  FIRMWARE CABE EN LA MEMORIA  ({pct:.1f}% utilizado)'
        print('│\033[32m{:^56}\033[0m│'.format(status))
    else:
        status = f'  ✗  FIRMWARE NO CABE EN LA MEMORIA  (overflow: {info["overflow"]} palabras)'
        print('│\033[31m{:^56}\033[0m│'.format(status))

    print('└' + sep + '┘')
    print()

# ──────────────────────────────────────────────────────────────────────────────
# Escritura del archivo de salida
# ──────────────────────────────────────────────────────────────────────────────

def write_output(memory: dict, output_file: str, mem_length: int, min_addr: int):
    """
    Escribe el archivo de salida con exactamente mem_length líneas.
    Las direcciones sin dato se rellenan con 00000000.
    El mapa empieza siempre desde la dirección 0.
    """
    with open(output_file, 'w') as f_out:
        for addr in range(mem_length):
            word = memory.get(addr, '00000000')
            f_out.write(word + '\n')

# ──────────────────────────────────────────────────────────────────────────────
# Conversión principal
# ──────────────────────────────────────────────────────────────────────────────

def convert(input_file: str, output_file: str, mem_length: int) -> int:
    """
    Orquesta la conversión completa.
    Retorna 0 si OK, 2 si el firmware no cabe.
    """
    # 1. Parsear
    print(f"Leyendo '{input_file}' ...")
    memory = parse_hex_file(input_file)

    if not memory:
        print("ERROR: No se encontraron datos válidos en el archivo de entrada.")
        return 1

    # 2. Validar
    fits, info = validate_fit(memory, mem_length)

    # 3. Reporte
    print_report(info, fits)

    if not fits:
        print(f"ERROR: El firmware requiere {info['max_addr'] + 1} palabras pero la "
              f"memoria solo tiene {mem_length}. Corrija mem_length o reduzca el firmware.")
        return 2

    # 4. Escribir salida
    write_output(memory, output_file, mem_length, info['min_addr'])
    print(f"Archivo generado : '{output_file}'")
    print(f"Líneas escritas  : {mem_length}  (memoria completa, 0x{mem_length:X} palabras)")
    print("Listo.")
    return 0

# ──────────────────────────────────────────────────────────────────────────────
# Entry point
# ──────────────────────────────────────────────────────────────────────────────

USAGE = """
Uso:
  hextoMEM_v3.py <input.hex> <output.txt> <mem_length>
  hextoMEM_v3.py                           ← defaults: main_fw.hex / main_fw.txt / 2048

  mem_length : tamaño de la memoria de programa en palabras de 32 bits (entero decimal).
               Ejemplo: 2048  →  memoria de 8 KB (2048 × 4 bytes).
"""

def main():
    args = sys.argv[1:]

    if len(args) == 0:
        input_file  = DEFAULT_INPUT
        output_file = DEFAULT_OUTPUT
        mem_length  = DEFAULT_MEM_LENGTH

    elif len(args) == 3:
        input_file  = args[0]
        output_file = args[1]
        try:
            mem_length = int(args[2])
            if mem_length <= 0:
                raise ValueError
        except ValueError:
            print(f"ERROR: mem_length debe ser un entero positivo (recibido: '{args[2]}')")
            print(USAGE)
            sys.exit(1)

    else:
        print(USAGE)
        sys.exit(1)

    if not os.path.exists(input_file):
        print(f"ERROR: No se encuentra el archivo '{input_file}'")
        sys.exit(1)

    exit_code = convert(input_file, output_file, mem_length)
    sys.exit(exit_code)


if __name__ == '__main__':
    main()
