
// Compilar: g++ -std=c++17 -O2 -o asm_compiler asm_compiler.cpp

#include <bits/stdc++.h>
#include "asm.h"
#include "asm_directive.h"

using namespace std;

static std::unordered_map<std::string, DirectiveHandler> directive_table = {
    {".SECT", handle_sect},
    {".DB", handle_db}};

static const std::unordered_map<std::string, InstrInfo> opcode_table = {
    {"ADD", {0x0, "R,ANY"}}, // ANY = IMM8 or R
    {"SUB", {0x1, "R,ANY"}},
    {"CMP", {0x2, "R,ANY"}},
    {"SBB", {0x3, "R,ANY"}},
    {"XOR", {0x4, "R,ANY"}},
    {"NOR", {0x5, "R,ANY"}},
    {"MOV", {0x6, "R,ANY"}},
    {"LDR", {0x7, "R,ADDR"}},
    {"STR", {0x8, "ADDR,R"}},
    {"JNZ", {0x9, "IMM16_OR_REG"}},
    {"ADC", {0xA, "R,ANY"}},
    {"LEA", {0xB, "R,ADDR"}},
    {"SHL", {0xC, "R"}},
    {"SHR", {0xC, "R"}},
    {"PUSHF", {0xD, "IMM8_OR_REG"}},
    {"PUSH", {0xE, "IMM8_OR_REG"}},
    {"POP", {0xF, "R"}},
    {"POPF", {0xF, "R"}}};

static const std::unordered_map<std::string, int> reg_map = {
    {"R0", 0}, {"R1", 1}, {"R2", 2}, {"R3", 3}, {"R4", 4}, {"R5", 5}, {"IP", 6}, {"SP", 7}, {"R6", 6}, {"R7", 7}};

int main(int argc, char **argv)
{
    if (argc < 3)
    {
        cerr << "Uso: " << argv[0] << " input.asm output.bin\n";
        return 1;
    }

    AsmContext Gctx;
    string inname = argv[1];
    string outname = argv[2];

    // read lines
    ifstream fi(inname);
    if (!fi)
    {
        cerr << "No puedo abrir " << inname << "\n";
        return 1;
    }
    vector<string> lines;
    string line;
    while (getline(fi, line))
        lines.push_back(line);
    fi.close();

    // First pass: strip comments, find directives, find Gctx.labels and compute addresses

    Gctx.pc = 0;
    Gctx.current_section_size = 0;
    for (size_t i = 0; i < lines.size(); ++i)
    {
        string l = lines[i];

        string up = l;

        for (char &c : up)
            c = toupper(c);
        // remove comments (semicolon or //)
        rem_comments(up);

        if (up.empty())
            continue;

        if (up.front() == '.')
        {
            std::stringstream ss(up);
            std::vector<std::string> tokens;
            std::string t;
            while (ss >> t)
                tokens.push_back(t);

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

        if (Gctx.sections.empty())
        {
            cerr << "Error en linea " << i + 1 << ": no se ha definido seccion antes de codigo/etiquetas\n";
            return 1;
        }

        // Gctx.labels: end with :
        if (up.back() == ':')
        {
            string lab = trim(up.substr(0, up.size() - 1));
            if(Gctx.labels.find(lab) == Gctx.labels.end())
                Gctx.labels[lab] = Gctx.pc;
            else
            {
                std::cerr << "Error en linea " << i + 1 << ": etiqueta '" << lab << "' repetida " << "\n";
                return 1;
            }
            continue;
        }

        Gctx.clean.push_back(up);
        Gctx.clean_line_no.push_back(i + 1);
        // quick estimate of instruction length to advance Gctx.pc
        // parse mnemonic:

        string mnem;
        {
            stringstream ss(up);
            ss >> mnem;
        }
        auto it = opcode_table.find(mnem);
        if (it == opcode_table.end())
        {
            cerr << "Error en Linea " << i + 1 << ": mnemotico desconocido: " << mnem << "\n";
            return 1;
        }
        // rough size guess (we'll do exact on 2nd pass)
        // For safety, assume max 3 bytes
        // But better do a small parse to differentiate imm8/16/reg.
        // Simple heuristic:
        string args = trim(up.substr(mnem.size()));
        vector<string> toks = tokenize(args);

        if (args.size() == 0)
        {

            cerr << "Error en Linea " << i + 1 << ": Todos los opcode deben tener argumentos " << "\n";
            return 1;
        }
        else
        {

            size_t openPos = args.find('[');
            size_t closePos = args.find(']', openPos);

            if (openPos != string::npos)
            {
                if (closePos == string::npos)
                {
                    cerr << "Error en linea " << i + 1 << ": corchete abierto sin cerrar\n";
                    return 1;
                }

                // extraer lo que está dentro de los corchetes
                std::string inside = trim(args.substr(openPos + 1, closePos - openPos - 1));

                // incrementar PC y sección según la instrucción
                if (mnem == "LDR" || mnem == "STR")
                {
                    if (reg_code(inside) >= 0)
                    {
                        Gctx.pc += 2;
                        Gctx.current_section_size += 2;
                    }
                    else
                    {
                        Gctx.pc += 3;
                        Gctx.current_section_size += 3;
                    }
                }
                else
                {
                    cerr << "Error en Linea " << i + 1 << ": Uso de corchetes no permitido en '" << mnem << "'\n";
                    return 1;
                }
            }
            else
            {

                if (mnem == "JNZ" || mnem == "LEA")
                {

                    string op = mnem == "JNZ" ? toks[0] : toks[1];

                    // Caso: JNZ/LEA reg (salta a la dirección contenida en un registro)
                    if (op.front() == 'R' && reg_code(op) >= 0)
                    {
                        Gctx.pc += 2;
                        Gctx.current_section_size += 2;
                    }
                    else
                    {
                        // Caso: JNZ/LEA imm16 (saltos a una dirección inmediata)

                        Gctx.pc += 3;
                        Gctx.current_section_size += 3;
                    }
                }
                else
                {
                    Gctx.pc += 2;
                    Gctx.current_section_size += 2;
                }
            }
        }
    }

    if (Gctx.sections.find("TEXT") == Gctx.sections.end())
    {
        std::cerr << "ERROR: Seccion '" << "TEXT" << "' no encontrada.\n";
        std::cerr << "El programa requiere una seccion 'TEXT' como punto de inicio.\n";
        return 1;
    }

    // Second pass: generate bytes
    // vector<uint8_t> out;
    //Gctx.pc = Gctx.sections.at("TEXT").start_addr;
    for (size_t idx = 0; idx < Gctx.clean.size(); ++idx)
    {
        string l = Gctx.clean[idx];
        int orig_line = Gctx.clean_line_no[idx];

        string lcopy = l;

        if (l.front() == '.')
        {
            std::stringstream ss(l);
            std::vector<std::string> tokens;
            std::string t;
            while (ss >> t)
                tokens.push_back(t);

            auto it = directive_table.find(tokens[0]);
            if (it != directive_table.end())
            {
                if (it->second(tokens, orig_line, Gctx, true) != 0)
                    return 1;
            }
            else
            {
                std::cerr << "Error en linea " << orig_line << ": directiva desconocida " << tokens[0] << "\n";
                return 1;
            }
            continue;
        }
        else
        {
            // split mnemonic and args
            string mnem;
            {
                stringstream ss(l);
                ss >> mnem;
            }
            string up = mnem;

            // fetch instruction info
            auto it = opcode_table.find(up);
            if (it == opcode_table.end())
            {
                cerr << "Error en linea " << orig_line << ": Instruccion desconocida: " << up << "\n";
                return 1;
            }
            InstrInfo info = it->second;

            string args = trim(lsubstr(lcopy, mnem.size()));
            // Tokenize arguments
            vector<string> toks = tokenize(args);

            // Build bytes according to mnemonic and args
            uint8_t opcode = info.opcode & 0x0F;

            // now handle by mnemonic
            if (up == "ADD" || up == "SUB" || up == "CMP" || up == "SBB" || up == "XOR" || up == "NOR" || up == "MOV" || up == "ADC")
            {
                // expect "reg, src" where src can be reg or immediate
                if (toks.size() < 2)
                {
                    cerr << "Error en linea " << orig_line << ": " << up << " requiere dos operandos en linea: " << l << "\n";
                    return 1;
                }
                int dst = reg_code(toks[0]);
                if (dst < 0)
                {
                    cerr << "Error en linea " << orig_line << ": " << "Destino no es registro valido: " << toks[0] << "\n";
                    return 1;
                }
                // detect src
                if (toks[1].front() == 'R' || reg_code(toks[1]) >= 0)
                {
                    int src = reg_code(toks[1]);
                    emit_first(1, dst, opcode, Gctx.sections.at(Gctx.current_section).data, Gctx.pc);
                    emit_first(1, src, opcode, Gctx.sections.at(Gctx.current_section).data, Gctx.pc);
                }
                else
                {
                    // immediate (8-bit)
                    int val;
                    if (!resolve_val(toks[1], val, Gctx.labels))
                    {
                        cerr << "Error en linea " << orig_line << ": " << "Imposible resolver immed: " << toks[1] << "\n";
                        return 1;
                    }
                    emit_first(0, dst, opcode, Gctx.sections.at(Gctx.current_section).data, Gctx.pc);
                    uint8_t imm8 = val & 0xFF;
                    Gctx.sections.at(Gctx.current_section).data.push_back(imm8);
                    Gctx.pc += 1;
                }
            }
            else if (up == "LDR")
            {
                // LDR reg, [imm16/reg]
                if (toks.size() < 2)
                {
                    cerr << "Error en linea " << orig_line << ": " << "LDR requiere dos operandos\n";
                    return 1;
                }
                int dst = reg_code(toks[0]);
                if (dst < 0)
                {
                    cerr << "Error en linea " << orig_line << ": " << "LDR dst no reg: " << toks[0] << "\n";
                    return 1;
                }
                string src = toks[1];
                if (src.front() == '[' && src.back() == ']')
                {
                    string inner = src.substr(1, src.size() - 2);
                    // if register inside brackets -> reg form
                    if (reg_code(inner) >= 0)
                    {
                        int rsrc = reg_code(inner);
                        emit_first(1, rsrc, opcode, Gctx.sections.at(Gctx.current_section).data, Gctx.pc);
                        emit_first(1, dst, opcode, Gctx.sections.at(Gctx.current_section).data, Gctx.pc);
                    }
                    else
                    {
                        int val;
                        if (!resolve_val(src, val, Gctx.labels))
                        {
                            cerr << "Error en linea " << orig_line << ": " << "LDR: imposible resolver addr " << src << "\n";
                            return 1;
                        }
                        emit_first(0, dst, opcode, Gctx.sections.at(Gctx.current_section).data, Gctx.pc);
                        Gctx.sections.at(Gctx.current_section).data.push_back(uint8_t(val & 0xFF));
                        Gctx.sections.at(Gctx.current_section).data.push_back(uint8_t((val >> 8) & 0xFF));
                        Gctx.pc += 2;
                    }
                }
                else
                {
                    cerr << "Error en linea " << orig_line << ": " << "LDR: segundo operando debe ser memoria entre []\n";
                    return 1;
                }
            }
            else if (up == "STR")
            {
                // STR [imm16/reg], reg
                if (toks.size() < 2)
                {
                    cerr << "Error en linea " << orig_line << ": " << "STR requiere dos operandos\n";
                    return 1;
                }
                string a0 = toks[0];
                string a1 = toks[1];
                int src = reg_code(a1);
                if (src < 0)
                {
                    cerr << "Error en linea " << orig_line << ": " << "STR: segundo operando debe ser registro: " << a1 << "\n";
                    return 1;
                }
                if (a0.front() == '[' && a0.back() == ']')
                {
                    string inner = a0.substr(1, a0.size() - 2);
                    if (reg_code(inner) >= 0)
                    {
                        int raddr = reg_code(inner);
                        emit_first(1, src, opcode, Gctx.sections.at(Gctx.current_section).data, Gctx.pc);
                        emit_first(1, raddr, opcode, Gctx.sections.at(Gctx.current_section).data, Gctx.pc);
                    }
                    else
                    {
                        int val;
                        if (!resolve_val(a0, val, Gctx.labels))
                        {
                            cerr << "Error en linea " << orig_line << ": " << "STR: imposible resolver addr " << a0 << "\n";
                            return 1;
                        }
                        emit_first(0, src, opcode, Gctx.sections.at(Gctx.current_section).data, Gctx.pc); // here Z holds reg? ambiguous, we use src in z field
                        // But better place dst as 0, we'll put reg in second byte. Use convention: Z = src reg (reg storing data)
                        // To keep consistent we encode as first byte with Z=src, then imm16
                        // We already emitted first with z=src.
                        Gctx.sections.at(Gctx.current_section).data.push_back(uint8_t(val & 0xFF));
                        Gctx.sections.at(Gctx.current_section).data.push_back(uint8_t((val >> 8) & 0xFF));
                        Gctx.pc += 2;
                    }
                }
                else
                {
                    cerr << "Error en linea " << orig_line << ": " << "STR: primer operando debe ser memoria entre []\n";
                    return 1;
                }
            }
            else if (up == "JNZ")
            {
                // JNZ imm16 or JNZ reg (set IP = imm16/reg if Z==0)
                if (toks.size() < 1)
                {
                    cerr << "Error en linea " << orig_line << ": " << "JNZ requiere operando\n";
                    return 1;
                }
                string op = toks[0];

                // Caso: JNZ reg (salta a la dirección contenida en un registro)
                if (op.front() == 'R' && reg_code(op) >= 0)
                {
                    int r = reg_code(op);
                    // Y = 1 (arg is reg), Z = 6
                    emit_first(1, r, opcode, Gctx.sections.at(Gctx.current_section).data, Gctx.pc);
                    emit_first(1, 6, opcode, Gctx.sections.at(Gctx.current_section).data, Gctx.pc);
                }
                else
                {
                    // Caso: JNZ imm16 (saltos a una dirección inmediata)
                    int val;
                    if (!resolve_val(op, val, Gctx.labels))
                    {
                        cerr << "Error en linea " << orig_line << ": " << "JNZ: no puedo resolver " << op << "\n";
                        return 1;
                    }
                    // IMPORTANTE: para JNZ con inmediato, Z debe ser IP (6)
                    emit_first(0, 6, opcode, Gctx.sections.at(Gctx.current_section).data, Gctx.pc);    // Y = 0 (imm), Z = 6 (IP)
                    Gctx.sections.at(Gctx.current_section).data.push_back(uint8_t(val & 0xFF));        // LSB
                    Gctx.sections.at(Gctx.current_section).data.push_back(uint8_t((val >> 8) & 0xFF)); // MSB
                    Gctx.pc += 2;
                }
            }
            else if (up == "LEA")
            {
                // LEA reg, imm16/reg - if used with IP acts as JMP
                if (toks.size() < 2)
                {
                    cerr << "Error en linea " << orig_line << ": " << "LEA requiere dos operandos\n";
                    return 1;
                }
                int dst = reg_code(toks[0]);
                if (dst < 0)
                {
                    cerr << "Error en linea " << orig_line << ": " << "LEA dst no reg\n";
                    return 1;
                }
                string op = toks[1];

                if (reg_code(op) >= 0)
                {
                    int r = reg_code(op);
                    emit_first(1, r, opcode, Gctx.sections.at(Gctx.current_section).data, Gctx.pc);
                    emit_first(1, dst, opcode, Gctx.sections.at(Gctx.current_section).data, Gctx.pc);
                }
                else
                {
                    int v;
                    if (!resolve_val(op, v, Gctx.labels))
                    {
                        cerr << "Error en línea " << orig_line << ": " << "LEA: no puedo resolver " << op << "\n";
                        return 1;
                    }
                    emit_first(0, dst, opcode, Gctx.sections.at(Gctx.current_section).data, Gctx.pc);
                    Gctx.sections.at(Gctx.current_section).data.push_back(uint8_t(v & 0xFF));
                    Gctx.sections.at(Gctx.current_section).data.push_back(uint8_t((v >> 8) & 0xFF));
                    Gctx.pc += 2;
                }
            }
            else if (up == "SHL")
            {
                // single reg operand
                if (toks.size() < 1)
                {
                    cerr << "Error en línea " << orig_line << ": " << "SHL necesita registro\n";
                    return 1;
                }
                int r = reg_code(toks[0]);
                if (r < 0)
                {
                    cerr << "Error en línea " << orig_line << ": " << "SHL operand no reg\n";
                    return 1;
                }
                emit_first(0, r, opcode, Gctx.sections.at(Gctx.current_section).data, Gctx.pc);
                Gctx.sections.at(Gctx.current_section).data.push_back(0x00);
                Gctx.pc += 1; // padding
            }
            else if (up == "SHR")
            {
                // single reg operand
                if (toks.size() < 1)
                {
                    cerr << "Error en línea " << orig_line << ": " << "SHR necesita registro\n";
                    return 1;
                }
                int r = reg_code(toks[0]);
                if (r < 0)
                {
                    cerr << "Error en línea " << orig_line << ": " << "SHR operand no reg\n";
                    return 1;
                }
                emit_first(1, r, opcode, Gctx.sections.at(Gctx.current_section).data, Gctx.pc);
                Gctx.sections.at(Gctx.current_section).data.push_back(0x00);
                Gctx.pc += 1; // padding
            }
            else if (up == "PUSHF" || up == "PUSH")
            {
                if (toks.size() < 1)
                {
                    cerr << "Error en línea " << orig_line << ": " << "PUSH/PUSHF necesita operando\n";
                    return 1;
                }
                string op = toks[0];
                if (op.front() == 'R' && reg_code(op) >= 0)
                {
                    int r = reg_code(op);
                    emit_first(1, r, opcode, Gctx.sections.at(Gctx.current_section).data, Gctx.pc);
                    Gctx.sections.at(Gctx.current_section).data.push_back(uint8_t(r & 0x07));
                    Gctx.pc += 1;
                }
                else
                {
                    int v;
                    if (!resolve_val(op, v, Gctx.labels))
                    {
                        cerr << "Error en línea " << orig_line << ": " << "PUSH: no puedo resolver " << op << "\n";
                        return 1;
                    }
                    emit_first(0, 0, opcode, Gctx.sections.at(Gctx.current_section).data, Gctx.pc);
                    Gctx.sections.at(Gctx.current_section).data.push_back(uint8_t(v & 0xFF));
                    Gctx.pc += 1;
                }
            }
            else if (up == "POP")
            {
                // POP with reg -> pop into reg, POP without reg? use single byte
                if (toks.size() == 0)
                {
                    // POP no arg -> single byte
                    emit_first(0, 0, opcode, Gctx.sections.at(Gctx.current_section).data, Gctx.pc);
                }
                else
                {
                    int r = reg_code(toks[0]);
                    if (r < 0)
                    {
                        cerr << "Error en línea " << orig_line << ": " << "POP operand no reg\n";
                        return 1;
                    }
                    emit_first(0, r, opcode, Gctx.sections.at(Gctx.current_section).data, Gctx.pc);
                    Gctx.sections.at(Gctx.current_section).data.push_back(uint8_t(0));
                    Gctx.pc += 1;
                }
            }
            else if (up == "POPF")
            {
                // POP with reg -> pop into reg, POP without reg? use single byte
                if (toks.size() == 0)
                {
                    // POPF no arg -> single byte
                    emit_first(0, 0, opcode, Gctx.sections.at(Gctx.current_section).data, Gctx.pc);
                }
                else
                {
                    int r = reg_code(toks[0]);
                    if (r < 0)
                    {
                        cerr << "Error en línea " << orig_line << ": " << "POPF operand no reg\n";
                        return 1;
                    }
                    emit_first(1, r, opcode, Gctx.sections.at(Gctx.current_section).data, Gctx.pc);
                    Gctx.sections.at(Gctx.current_section).data.push_back(uint8_t(0));
                    Gctx.pc += 1;
                }
            }
            else
            {
                cerr << "Error en línea " << orig_line << ": " << "Mnemotico no soportado aun: " << up << "\n";
                return 1;
            }
        }
    }

    // =================== GENERAR ARCHIVOS SALIDA ===========================
    // archivo binario
    // ofstream fo_bin(outname, ios::binary);
    // fo_bin.write(reinterpret_cast<char *>(out.data()), out.size());
    // fo_bin.close();

    // archivo hexdump
    ofstream fo_txt(outname + ".txt");
    for (const auto &sec_pair : Gctx.sections)
    {
        const std::string &sec_name = sec_pair.first;
        const SectionInfo &sec_info = sec_pair.second;

        fo_txt << "Sección " << sec_name << " empieza en 0x"
               << std::hex << sec_info.start_addr << "\n";

        for (size_t i = 0; i < sec_info.data.size(); i++)
        {
            int addr = sec_info.start_addr + i;
            if (i % 16 == 0)
                fo_txt << std::setw(8) << std::setfill('0') << std::hex << std::uppercase << addr << ": ";
            fo_txt << std::setw(2) << std::setfill('0') << std::hex << std::uppercase << (int)sec_info.data[i] << " ";
            if (i % 16 == 15)
                fo_txt << "\n";
        }
        fo_txt << "\n";
    }

    fo_txt << "\n";
    fo_txt.close();

    // ===== Generar archivo VHDL =====
    string vhdlfile = outname + ".vhd";
    ofstream fvhdl(vhdlfile);
    if (!fvhdl)
    {
        cerr << "No puedo abrir salida " << vhdlfile << "\n";
        return 1;
    }

    fvhdl << "library ieee;\n";
    fvhdl << "use ieee.std_logic_1164.all;\n";
    fvhdl << "use ieee.numeric_std.all;\n\n";

    fvhdl << "package prog_mem is\n";
    fvhdl << "    type RAM_Array is array (0 to 32767) of std_logic_vector(7 downto 0);\n";
    fvhdl << "    constant RAM_INIT : RAM_Array := (\n";

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
                  << setw(3) << setfill('0') << hex << uppercase << addr
                  << "# => X\""
                  << setw(2) << setfill('0') << hex << uppercase << (int)sec_info.data[i]
                  << "\"";

            if (addr < 32767)
                fvhdl << ",";
            fvhdl << " -- " << dec << addr << "\n";
        }
    }

    // rellenar huecos restantes con 0
    fvhdl << "        others => (others => '0')\n";
    fvhdl << "    );\n";
    fvhdl << "end package;\n";
    fvhdl.close();

    std::cout << "Archivos generados\n";

    return 0;
}

void rem_comments(std::string &l)
{

    size_t p = l.find(';');
    size_t p2 = l.find("//");
    size_t cpos = string::npos;
    if (p != string::npos)
        cpos = p;
    if (p2 != string::npos)
        cpos = min(cpos == string::npos ? p2 : cpos, p2);
    if (cpos != string::npos)
        l = l.substr(0, cpos);
    l = trim(l);
}

// helper: safe substring
std::string lsubstr(const std::string &s, size_t pos)
{
    if (pos >= s.size())
        return "";
    return trim(s.substr(pos));
}

bool resolve_val(const string &tok, int &val, const unordered_map<string, int> &labels)
{
    string t = trim(tok);
    if (t.size() == 0)
        return false;
    // label?
    if (labels.count(t))
    {
        val = labels.at(t);
        return true;
    }
    // if bracketed like [0xFFF4], remove []
    if (t.front() == '[' && t.back() == ']')
    {
        string inner = t.substr(1, t.size() - 2);
        if (labels.count(inner))
        {
            val = labels.at(inner);
            return true;
        }
        try
        {
            val = parse_number(inner);
            return true;
        }
        catch (...)
        {
            return false;
        }
    }
    try
    {
        val = parse_number(t);
        return true;
    }
    catch (...)
    {
        return false;
    }
}

// Helper: emit first byte with y and z
void emit_first(int y, int z, uint8_t opcode, std::vector<uint8_t> &out, int &pc)
{
    uint8_t fb = (opcode << 4) | ((y & 1) << 3) | (z & 0x07);
    out.push_back(fb);
    pc += 1;
};

int reg_code(const string &r)
{
    string s = r;
    for (char &c : s)
        c = toupper(c);
    auto it = reg_map.find(s);
    return (it != reg_map.end()) ? it->second : -1;
}

std::string trim(const std::string &s)
{
    auto a = s.find_first_not_of(" \t\r\n");
    if (a == string::npos)
        return "";
    auto b = s.find_last_not_of(" \t\r\n");
    return s.substr(a, b - a + 1);
}

std::vector<std::string> tokenize(const std::string &line)
{
    vector<string> toks;
    string cur;
    bool inbr = false;
    for (char c : line)
    {
        if (c == '[')
        {
            inbr = true;
            cur.push_back(c);
        }
        else if (c == ']')
        {
            inbr = false;
            cur.push_back(c);
        }
        else if (!inbr && (c == ',' || isspace((unsigned char)c)))
        {
            if (!cur.empty())
            {
                toks.push_back(trim(cur));
                cur.clear();
            }
            if (c == ',')
            {
            }
        }
        else
        {
            cur.push_back(c);
        }
    }
    if (!cur.empty())
        toks.push_back(trim(cur));
    return toks;
}

int parse_number(const std::string &s)
{
    // TODO: SOLTAR ERROR PARA NUMEROS COMO 0xFFFFHOLA1235
    string t = s;
    if (t.size() > 0 && t[0] == '\'')
        return -1;
    if (is_hex(t))
    {
        return stoi(t, nullptr, 0);
    }
    if (t.size() > 0 && t.back() == 'h')
    { // allow 1Ah style optionally
        return stoi(t.substr(0, t.size() - 1), nullptr, 16);
    }
    return stoi(t, nullptr, 10);
}
