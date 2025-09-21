#include "asm_directive.h"
#include <iostream>
#include <sstream>

int handle_sect(const std::vector<std::string> &tokens, size_t line_no, AsmContext &ctx, bool emit_byte)
{
    if (!emit_byte)
    {
        if (tokens.size() < 3)
        {
            std::cerr << "Error en linea " << line_no << ": .sect requiere nombre y direccion base\n";
            return 1;
        }
        else if (tokens.size() > 3)
        {
            std::cerr << "Error en linea " << line_no << ": .sect requiere solo nombre y direccion base\n";
            return 1;
        }

        if (ctx.sections.find(tokens[1]) != ctx.sections.end())
        {
            std::cerr << "Error en linea " << line_no << ": seccion '" << tokens[0] << "' repetida " << "\n";
            return 1;
        }
        else
        {
            /*if (ctx.current_section != "")
                ctx.sections[ctx.current_section].data.resize(ctx.current_section_size);
            ctx.current_section_size = 0;*/
            ctx.sections[tokens[1]].start_addr = parse_number(tokens[2]);
        }

        ctx.pc = ctx.sections[tokens[1]].start_addr;
    }

    ctx.current_section = tokens[1];

    return 0;
}

int handle_db(const std::vector<std::string> &tokens, size_t line_no, AsmContext &ctx, bool emit_byte)
{
    if (!emit_byte)
    {
        if (tokens.size() < 2)
        {
            std::cerr << "Error en linea " << line_no << ": .DB requiere al menos un valor\n";
            return 1;
        }
        // Reservar espacio en la sección, cada valor aumenta PC
        ctx.pc += static_cast<int>(tokens.size() - 1);
    }
    return 0;
}
