
// Compilar: g++ -std=c++17 -O2 -o asm_compiler asm_compiler.cpp

#include "asm.h"
#include "asm_directive.h"
#include "asm_op_handlers.h"
#include "asm_utilities.h"

static std::unordered_map<std::string, InstHandler> directive_table = {
    {".SECT", handle_sect},
    {".DB", handle_db}};

static const std::unordered_map<std::string, InstHandler> opcode_table = {
    {"ADD", handle_R_OR_ANY /*{0x0, "R,ANY"}*/}, // ANY = IMM8 or R
    {"SUB", handle_R_OR_ANY /*{0x1, "R,ANY"}*/},
    {"CMP", handle_R_OR_ANY /*{0x2, "R,ANY"}*/},
    {"SBB", handle_R_OR_ANY /*{0x3, "R,ANY"}*/},
    {"XOR", handle_R_OR_ANY /*{0x4, "R,ANY"}*/},
    {"NOR", handle_R_OR_ANY /*{0x5, "R,ANY"}*/},
    {"MOV", handle_R_OR_ANY /*{0x6, "R,ANY"}*/},
    {"LDR", handle_LDR /*{0x7, "R,ADDR"}*/},
    {"STR", handle_STR /*{0x8, "ADDR,R"}*/},
    {"JNZ", handle_JNZ /*{0x9, "IMM16_OR_REG"}*/},
    {"ADC", handle_R_OR_ANY /*{0xA, "R,ANY"}*/},
    {"LEA", handle_LEA /*{0xB, "R,ADDR"}*/},
    {"SHL", handle_SHL /*{0xC, "R"}*/},
    {"SHR", handle_SHR /*{0xC, "R"}*/},
    {"PUSHF", handle_PUSH_S /*{0xD, "IMM8_OR_REG"}*/},
    {"PUSH", handle_PUSH_S /*{0xE, "IMM8_OR_REG"}*/},
    {"POP", handle_POP /*{0xF, "R"}*/},
    {"POPF", handle_POPF /*{0xF, "R"}*/}};

int main(int argc, char **argv)
{
    if (argc < 3)
    {
        std::cerr << "Uso: " << argv[0] << " input.asm output.bin\n";
        return 1;
    }

    AsmContext Gctx;
    std::string inname = argv[1];
    std::string outname = argv[2];

    // read lines
    std::ifstream fi(inname);
    if (!fi)
    {
        std::cerr << "No puedo abrir " << inname << "\n";
        return 1;
    }
    std::vector<std::string> lines;
    std::string line;
    while (getline(fi, line))
        lines.push_back(line);
    fi.close();

    // First pass: strip comments, find directives, find Gctx.labels and compute addresses

    Gctx.pc = 0;
    Gctx.current_section_size = 0;
    for (size_t i = 0; i < lines.size(); ++i)
    {
        std::string l = lines[i];
        std::string up = l;

        // Normalize line: uppercase + remove comments
        for (char &c : up)
            c = toupper(c);
        rem_comments(up);
        if (up.empty())
            continue;

        // Tokenize line
        std::vector<std::string> tokens = tokenize(up);
        if (tokens.empty())
            continue;

        // Handle directives
        if (tokens[0].front() == '.')
        {
            auto it = directive_table.find(tokens[0]);
            if (it != directive_table.end())
            {
                if (it->second(tokens, i + 1, Gctx, false) != 0)
                    return 1;
            }
            else
            {
                std::cerr << "Error en linea " << i + 1 << ": directiva desconocida " << tokens[0] << "\n";
                return 1;
            }

            Gctx.clean.push_back(up);
            Gctx.clean_line_no.push_back(i + 1);
            continue;
        }

        // Check section exists
        if (Gctx.sections.empty())
        {
            std::cerr << "Error en linea " << i + 1 << ": no se ha definido seccion antes de codigo/etiquetas\n";
            return 1;
        }

        // Handle labels
        if (up.back() == ':')
        {
            std::string lab = trim(up.substr(0, up.size() - 1));
            if (Gctx.labels.count(lab))
            {
                std::cerr << "Error en linea " << i + 1 << ": etiqueta '" << lab << "' repetida\n";
                return 1;
            }
            Gctx.labels[lab] = Gctx.pc;
            continue;
        }

        // Store clean line
        Gctx.clean.push_back(up);
        Gctx.clean_line_no.push_back(i + 1);

        // Handle instruction using the handler table with emit_byte=false
        auto iit = opcode_table.find(tokens[0]);
        if (iit != opcode_table.end())
        {
            if (iit->second(tokens, i + 1, Gctx, false) != 0)
            {
                std::cerr << "Error en linea " << i + 1 << ": fallo procesando instruccion '" << tokens[0] << "'\n";
                return 1;
            }
        }
        else
        {
            std::cerr << "Error en linea " << i + 1 << ": instrucción/directiva desconocida " << tokens[0] << "\n";
            return 1;
        }
    }

    if (Gctx.sections.find("TEXT") == Gctx.sections.end())
    {
        std::cerr << "ERROR: Seccion '" << "TEXT" << "' no encontrada.\n";
        std::cerr << "El programa requiere una seccion 'TEXT' como punto de inicio.\n";
        return 1;
    }

    // Second pass: generate bytes
    // std::vector<uint8_t> out;
    // Gctx.pc = Gctx.sections.at("TEXT").start_addr;
    for (size_t idx = 0; idx < Gctx.clean.size(); ++idx)
    {
        std::string l = Gctx.clean[idx];
        int orig_line = Gctx.clean_line_no[idx];

        // Tokenizar linea completa
        std::vector<std::string> tokens;
        tokens = tokenize(l);

        // primero probamos si es directiva
        auto dit = directive_table.find(tokens[0]);
        if (dit != directive_table.end())
        {
            if (dit->second(tokens, orig_line, Gctx, true) != 0)
            {
                std::cerr << "Error en linea " << orig_line << ": " << "directiva '" << tokens[0] << "' no encontrada\n";
                return 1;
            }
        }
        else
        {
            // no es directiva: buscamos en la tabla de instrucciones
            auto iit = opcode_table.find(tokens[0]);
            if (iit != opcode_table.end())
            {
                // llamamos al handler de la instrucción
                if (iit->second(tokens, orig_line, Gctx, true) != 0)
                {
                    std::cerr << "Error en linea " << orig_line << ": " << "operacion '" << tokens[0] << "' no encontrada\n";
                    return 1;
                }
            }
            else
            {
                std::cerr << "Error en linea " << orig_line
                          << ": instrucción/directiva desconocida "
                          << tokens[0] << "\n";
                return 1;
            }
        }
    }

    // =================== GENERAR ARCHIVOS SALIDA ===========================

    // Prefijo LEA R6, inicio de .TEXT
    SectionInfo &text_sec = Gctx.sections.at("TEXT");
    uint16_t text_start_addr = text_sec.start_addr;
    uint8_t lea_opcode = 0xB6;
    uint8_t addr_lsb = text_start_addr & 0xFF;
    uint8_t addr_msb = (text_start_addr >> 8) & 0xFF;

    size_t max_addr = 0;
    for (const auto &sec_pair : Gctx.sections)
    {
        const SectionInfo &sec_info = sec_pair.second;
        max_addr = std::max(max_addr, sec_info.start_addr + sec_info.data.size());
    }

    // Consideramos los 3 bytes iniciales (LEA)
    max_addr = std::max(max_addr, size_t(3));

    // Creamos buffer con ceros
    std::vector<uint8_t> buffer(max_addr, 0);

    // Escribimos los bytes iniciales
    buffer[0] = lea_opcode;
    buffer[1] = addr_lsb;
    buffer[2] = addr_msb;

    // Copiamos cada sección en su dirección correcta
    for (const auto &sec_pair : Gctx.sections)
    {
        const SectionInfo &sec_info = sec_pair.second;
        std::copy(sec_info.data.begin(), sec_info.data.end(), buffer.begin() + sec_info.start_addr);
    }

    // Guardamos a binario
    std::ofstream fo_bin(outname, std::ios::binary);
    if (!fo_bin)
    {
        throw std::runtime_error("No se pudo abrir el archivo para escribir");
    }
    fo_bin.write(reinterpret_cast<const char *>(buffer.data()), buffer.size());
    fo_bin.close();

    // archivo hexdump
    std::ofstream fo_txt(outname + ".txt");

    // Imprime cabecera tipo hexdump
    fo_txt << std::setw(8) << std::setfill('0') << std::hex << std::uppercase << 0 << ": "
           << std::setw(2) << std::setfill('0') << std::hex << std::uppercase << (int)lea_opcode << " "
           << std::setw(2) << std::setfill('0') << std::hex << std::uppercase << (int)addr_lsb << " "
           << std::setw(2) << std::setfill('0') << std::hex << std::uppercase << (int)addr_msb << "\n\n";

    for (const auto &sec_pair : Gctx.sections)
    {
        const std::string &sec_name = sec_pair.first;
        const SectionInfo &sec_info = sec_pair.second;

        fo_txt << "SECTION ." << sec_name << "\n";

        for (size_t i = 0; i < sec_info.data.size(); i++)
        {
            int addr = sec_info.start_addr + i;
            if (i % 16 == 0)
                fo_txt << std::setw(8) << std::setfill('0') << std::hex << std::uppercase << addr << ": ";

            fo_txt << std::setw(2) << std::setfill('0') << std::hex << std::uppercase << (int)sec_info.data[i] << " ";

            if (i % 16 == 15 || i == sec_info.data.size() - 1)
                fo_txt << "\n";
        }
        fo_txt << "\n";
    }

    fo_txt << "\n";
    fo_txt.close();

    // ===== Generar archivo VHDL =====
    std::string vhdlfile = outname + ".vhd";
    std::ofstream fvhdl(vhdlfile);
    if (!fvhdl)
    {
        std::cerr << "No puedo abrir salida " << vhdlfile << "\n";
        return 1;
    }

    fvhdl << "library ieee;\n";
    fvhdl << "use ieee.std_logic_1164.all;\n";
    fvhdl << "use ieee.numeric_std.all;\n\n";

    fvhdl << "package prog_mem is\n";
    fvhdl << "    type RAM_Array is array (0 to 32767) of std_logic_vector(7 downto 0);\n";
    fvhdl << "    constant RAM_INIT : RAM_Array := (\n";

    fvhdl << "        -- LEA R6, start of .TEXT\n";
    fvhdl << "        16#000# => X\""
          << std::setw(2) << std::setfill('0') << std::hex << std::uppercase << (int)lea_opcode
          << "\", -- opcode LEA R6\n";

    fvhdl << "        16#001# => X\""
          << std::setw(2) << std::setfill('0') << std::hex << std::uppercase << (int)addr_lsb
          << "\", -- LSB address\n";

    fvhdl << "        16#002# => X\""
          << std::setw(2) << std::setfill('0') << std::hex << std::uppercase << (int)addr_msb
          << "\", -- MSB address\n\n";

    // recorremos todas las secciones
    for (const auto &sec_pair : Gctx.sections)
    {
        const std::string &sec_name = sec_pair.first;
        const SectionInfo &sec_info = sec_pair.second;
        fvhdl << "        -- SECTION ." << sec_name << "\n";

        for (size_t i = 0; i < sec_info.data.size(); i++)
        {
            int addr = sec_info.start_addr + i;
            fvhdl << "        16#"
                  << std::setw(3) << std::setfill('0') << std::hex << std::uppercase << addr
                  << "# => X\""
                  << std::setw(2) << std::setfill('0') << std::hex << std::uppercase << (int)sec_info.data[i]
                  << "\"" << ",";
            fvhdl << " -- " << std::dec << addr << "\n";
        }

        fvhdl << "\n";
    }

    // rellenar huecos restantes con 0
    fvhdl << "        others => (others => '0')\n";
    fvhdl << "    );\n";
    fvhdl << "end package;\n";
    fvhdl.close();

    std::cout << "Archivos generados\n";

    return 0;
}
