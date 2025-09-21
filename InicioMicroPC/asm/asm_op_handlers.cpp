#include "asm_op_handlers.h"

static const std::unordered_map<std::string, uint8_t> opcode_byte_table = {
    {"ADD", 0x0 /*{0x0, "R,ANY"}*/}, // ANY = IMM8 or R
    {"SUB", 0x1 /*{0x1, "R,ANY"}*/},
    {"CMP", 0x2 /*{0x2, "R,ANY"}*/},
    {"SBB", 0x3 /*{0x3, "R,ANY"}*/},
    {"XOR", 0x4 /*{0x4, "R,ANY"}*/},
    {"NOR", 0x5 /*{0x5, "R,ANY"}*/},
    {"MOV", 0x6 /*{0x6, "R,ANY"}*/},
    {"LDR", 0x7 /*{0x7, "R,ADDR"}*/},
    {"STR", 0x8 /*{0x8, "ADDR,R"}*/},
    {"JNZ", 0x9 /*{0x9, "IMM16_OR_REG"}*/},
    {"ADC", 0xA /*{0xA, "R,ANY"}*/},
    {"LEA", 0xB /*{0xB, "R,ADDR"}*/},
    {"SHL", 0xC /*{0xC, "R"}*/},
    {"SHR", 0xC /*{0xC, "R"}*/},
    {"PUSHF", 0xD /*{0xD, "IMM8_OR_REG"}*/},
    {"PUSH", 0xE /*{0xE, "IMM8_OR_REG"}*/},
    {"POP", 0xF /*{0xF, "R"}*/},
    {"POPF", 0xF /*{0xF, "R"}*/}};

//================================= HANDLERS ===========================

int handle_R_OR_ANY(const std::vector<std::string> &tokens, size_t line_no, AsmContext &ctx, bool emit_byte)
{
    uint8_t opcode = opcode_byte_table.at(tokens[0]);
    if (tokens.size() != 3)
    {
        std::cerr << "Error en linea " << line_no << ": " << tokens[0] << " requiere dos operandos\n";
        return 1;
    }
    int dst = reg_code(tokens[1]);
    if (dst < 0)
    {
        std::cerr << "Error en linea " << line_no << ": " << "Destino no es registro valido: " << tokens[1] << "\n";
        return 1;
    }
    // detect src
    if (tokens[2].front() == 'R' || reg_code(tokens[2]) >= 0)
    {
        if (emit_byte)
        {
            int src = reg_code(tokens[2]);
            emit_first(1, dst, opcode, ctx.sections.at(ctx.current_section).data, ctx.pc);
            emit_first(1, src, opcode, ctx.sections.at(ctx.current_section).data, ctx.pc);
        }
        else
            ctx.pc += 2;
    }
    else
    {
        // immediate (8-bit)
        if (emit_byte)
        {
            int val;
            if (!resolve_val(tokens[2], val, ctx.labels))
            {
                std::cerr << "Error en linea " << line_no << ": " << "Imposible resolver immed: " << tokens[2] << "\n";
                return 1;
            }

            emit_first(0, dst, opcode, ctx.sections.at(ctx.current_section).data, ctx.pc);
            uint8_t imm8 = val & 0xFF;
            ctx.sections.at(ctx.current_section).data.push_back(imm8);
            ctx.pc += 1;
        }
        else
            ctx.pc += 2;
    }
    return 0;
}

int handle_LDR(const std::vector<std::string> &tokens, size_t line_no, AsmContext &ctx, bool emit_byte)
{
    uint8_t opcode = opcode_byte_table.at(tokens[0]);
    if (tokens.size() != 3)
    {
        std::cerr << "Error en linea " << line_no << ": " << "LDR requiere dos operandos\n";
        return 1;
    }
    int dst = reg_code(tokens[1]);
    if (dst < 0)
    {
        std::cerr << "Error en linea " << line_no << ": " << "LDR dst no reg: " << tokens[1] << "\n";
        return 1;
    }
    std::string src = tokens[2];
    if (src.front() == '[' && src.back() == ']')
    {
        std::string inner = src.substr(1, src.size() - 2);
        // if register inside brackets -> reg form
        if (reg_code(inner) >= 0)
        {
            if (emit_byte)
            {
                int rsrc = reg_code(inner);
                emit_first(1, rsrc, opcode, ctx.sections.at(ctx.current_section).data, ctx.pc);
                emit_first(1, dst, opcode, ctx.sections.at(ctx.current_section).data, ctx.pc);
            }
            else
                ctx.pc += 2;
        }
        else
        {
            if (emit_byte)
            {
                int val;
                if (!resolve_val(src, val, ctx.labels))
                {
                    std::cerr << "Error en linea " << line_no << ": " << "LDR: imposible resolver addr " << src << "\n";
                    return 1;
                }

                emit_first(0, dst, opcode, ctx.sections.at(ctx.current_section).data, ctx.pc);
                ctx.sections.at(ctx.current_section).data.push_back(uint8_t(val & 0xFF));
                ctx.sections.at(ctx.current_section).data.push_back(uint8_t((val >> 8) & 0xFF));
                ctx.pc += 2;
            }
            else
                ctx.pc += 3;
        }
    }
    else
    {
        std::cerr << "Error en linea " << line_no << ": " << "LDR: segundo operando debe ser memoria entre []\n";
        return 1;
    }
    return 0;
}

int handle_STR(const std::vector<std::string> &tokens, size_t line_no, AsmContext &ctx, bool emit_byte)
{
    uint8_t opcode = opcode_byte_table.at(tokens[0]);
    if (tokens.size() != 3)
    {
        std::cerr << "Error en linea " << line_no << ": " << "STR requiere dos operandos\n";
        return 1;
    }
    std::string a0 = tokens[1];
    std::string a1 = tokens[2];
    int src = reg_code(a1);
    if (src < 0)
    {
        std::cerr << "Error en linea " << line_no << ": " << "STR: segundo operando debe ser registro: " << a1 << "\n";
        return 1;
    }
    if (a0.front() == '[' && a0.back() == ']')
    {
        std::string inner = a0.substr(1, a0.size() - 2);
        if (reg_code(inner) >= 0)
        {
            if (emit_byte)
            {
                int raddr = reg_code(inner);
                emit_first(1, src, opcode, ctx.sections.at(ctx.current_section).data, ctx.pc);
                emit_first(1, raddr, opcode, ctx.sections.at(ctx.current_section).data, ctx.pc);
            }
            else
                ctx.pc += 2;
        }
        else
        {
            if (emit_byte)
            {
                int val;
                if (!resolve_val(a0, val, ctx.labels))
                {
                    std::cerr << "Error en linea " << line_no << ": " << "STR: imposible resolver addr " << a0 << "\n";
                    return 1;
                }

                emit_first(0, src, opcode, ctx.sections.at(ctx.current_section).data, ctx.pc);
                ctx.sections.at(ctx.current_section).data.push_back(uint8_t(val & 0xFF));
                ctx.sections.at(ctx.current_section).data.push_back(uint8_t((val >> 8) & 0xFF));
                ctx.pc += 2;
            }
            else
                ctx.pc += 3;
        }
    }
    else
    {
        std::cerr << "Error en linea " << line_no << ": " << "STR: primer operando debe ser memoria entre []\n";
        return 1;
    }
    return 0;
}

int handle_JNZ(const std::vector<std::string> &tokens, size_t line_no, AsmContext &ctx, bool emit_byte)
{
    uint8_t opcode = opcode_byte_table.at(tokens[0]);
    if (tokens.size() != 2)
    {
        std::cerr << "Error en linea " << line_no << ": " << "JNZ requiere operando\n";
        return 1;
    }
    std::string op = tokens[1];

    // Caso: JNZ reg (salta a la dirección contenida en un registro)
    if (op.front() == 'R' && reg_code(op) >= 0)
    {
        if (emit_byte)
        {
            int r = reg_code(op);
            // Y = 1 (arg is reg), Z = 6
            emit_first(1, r, opcode, ctx.sections.at(ctx.current_section).data, ctx.pc);
            emit_first(1, 6, opcode, ctx.sections.at(ctx.current_section).data, ctx.pc);
        }
        else
            ctx.pc += 2;
    }
    else
    {
        // Caso: JNZ imm16 (saltos a una dirección inmediata)
        if (emit_byte)
        {
            int val;
            if (!resolve_val(op, val, ctx.labels))
            {
                std::cerr << "Error en linea " << line_no << ": " << "JNZ: no puedo resolver " << op << "\n";
                return 1;
            }

            emit_first(0, 6, opcode, ctx.sections.at(ctx.current_section).data, ctx.pc);     // Y = 0 (imm), Z = 6 (IP)
            ctx.sections.at(ctx.current_section).data.push_back(uint8_t(val & 0xFF));        // LSB
            ctx.sections.at(ctx.current_section).data.push_back(uint8_t((val >> 8) & 0xFF)); // MSB
            ctx.pc += 2;
        }
        else
            ctx.pc += 3;
    }
    return 0;
}

int handle_LEA(const std::vector<std::string> &tokens, size_t line_no, AsmContext &ctx, bool emit_byte)
{
    uint8_t opcode = opcode_byte_table.at(tokens[0]);
    if (tokens.size() != 3)
    {
        std::cerr << "Error en linea " << line_no << ": " << "LEA requiere dos operandos\n";
        return 1;
    }
    int dst = reg_code(tokens[1]);
    if (dst < 0)
    {
        std::cerr << "Error en linea " << line_no << ": " << "LEA dst no reg\n";
        return 1;
    }
    std::string op = tokens[2];

    if (reg_code(op) >= 0)
    {
        if (emit_byte)
        {
            int r = reg_code(op);
            emit_first(1, r, opcode, ctx.sections.at(ctx.current_section).data, ctx.pc);
            emit_first(1, dst, opcode, ctx.sections.at(ctx.current_section).data, ctx.pc);
        }
        else
            ctx.pc += 2;
    }
    else
    {
        if (emit_byte)
        {
            int v;

            if (!resolve_val(op, v, ctx.labels))
            {
                std::cerr << "Error en linea " << line_no << ": " << "LEA: no puedo resolver " << op << "\n";
                return 1;
            }

            emit_first(0, dst, opcode, ctx.sections.at(ctx.current_section).data, ctx.pc);
            ctx.sections.at(ctx.current_section).data.push_back(uint8_t(v & 0xFF));
            ctx.sections.at(ctx.current_section).data.push_back(uint8_t((v >> 8) & 0xFF));
            ctx.pc += 2;
        }
        else
            ctx.pc += 3;
    }
    return 0;
}

int handle_SHL(const std::vector<std::string> &tokens, size_t line_no, AsmContext &ctx, bool emit_byte)
{
    uint8_t opcode = opcode_byte_table.at(tokens[0]);
    if (tokens.size() != 2)
    {
        std::cerr << "Error en linea " << line_no << ": " << "SHL necesita registro\n";
        return 1;
    }
    int r = reg_code(tokens[1]);
    if (r < 0)
    {
        std::cerr << "Error en linea " << line_no << ": " << "SHL operand no reg\n";
        return 1;
    }
    if (emit_byte)
    {
        emit_first(0, r, opcode, ctx.sections.at(ctx.current_section).data, ctx.pc);
        ctx.sections.at(ctx.current_section).data.push_back(0x00);
        ctx.pc += 1; // padding
    }
    else
        ctx.pc += 2;
    return 0;
}

int handle_SHR(const std::vector<std::string> &tokens, size_t line_no, AsmContext &ctx, bool emit_byte)
{
    uint8_t opcode = opcode_byte_table.at(tokens[0]);
    if (tokens.size() != 2)
    {
        std::cerr << "Error en linea " << line_no << ": " << "SHR necesita registro\n";
        return 1;
    }
    int r = reg_code(tokens[1]);
    if (r < 0)
    {
        std::cerr << "Error en linea " << line_no << ": " << "SHR operand no reg\n";
        return 1;
    }
    if (emit_byte)
    {
        emit_first(1, r, opcode, ctx.sections.at(ctx.current_section).data, ctx.pc);
        ctx.sections.at(ctx.current_section).data.push_back(0x00);
        ctx.pc += 1; // padding
    }
    else
        ctx.pc += 2;
    return 0;
}

int handle_PUSH_S(const std::vector<std::string> &tokens, size_t line_no, AsmContext &ctx, bool emit_byte)
{
    uint8_t opcode = opcode_byte_table.at(tokens[0]);
    if (tokens.size() != 2)
    {
        std::cerr << "Error en linea " << line_no << ": " << tokens[0] << " necesita operando\n";
        return 1;
    }
    std::string op = tokens[1];
    if (op.front() == 'R' && reg_code(op) >= 0)
    {
        if (emit_byte)
        {
            int r = reg_code(op);
            emit_first(1, r, opcode, ctx.sections.at(ctx.current_section).data, ctx.pc);
            ctx.sections.at(ctx.current_section).data.push_back(uint8_t(r & 0x07));
            ctx.pc += 1;
        }
        else
            ctx.pc += 2;
    }
    else
    {
        if (emit_byte)
        {
            int v;
            if (!resolve_val(op, v, ctx.labels))
            {
                std::cerr << "Error en linea " << line_no << ": " << tokens[0] << ": no puedo resolver " << op << "\n";
                return 1;
            }

            emit_first(0, 0, opcode, ctx.sections.at(ctx.current_section).data, ctx.pc);
            ctx.sections.at(ctx.current_section).data.push_back(uint8_t(v & 0xFF));
            ctx.pc += 1;
        }
        else
            ctx.pc += 2;
    }
    return 0;
}

int handle_POP(const std::vector<std::string> &tokens, size_t line_no, AsmContext &ctx, bool emit_byte)
{
    uint8_t opcode = opcode_byte_table.at(tokens[0]);
    int r = reg_code(tokens[1]);
    if (r < 0)
    {
        std::cerr << "Error en linea " << line_no << ": " << "POP operand no reg\n";
        return 1;
    }
    if (emit_byte)
    {
        emit_first(0, r, opcode, ctx.sections.at(ctx.current_section).data, ctx.pc);
        ctx.sections.at(ctx.current_section).data.push_back(uint8_t(0));
        ctx.pc += 1;
    }
    else
        ctx.pc += 2;
    return 0;
}

int handle_POPF(const std::vector<std::string> &tokens, size_t line_no, AsmContext &ctx, bool emit_byte)
{
    uint8_t opcode = opcode_byte_table.at(tokens[0]);

    int r = reg_code(tokens[1]);
    if (r < 0)
    {
        std::cerr << "Error en linea " << line_no << ": " << "POPF operand no reg\n";
        return 1;
    }
    if (emit_byte)
    {
        emit_first(1, r, opcode, ctx.sections.at(ctx.current_section).data, ctx.pc);
        ctx.sections.at(ctx.current_section).data.push_back(uint8_t(0));
        ctx.pc += 1;
    }
    else
        ctx.pc += 2;

    return 0;
}

//======================================================================
