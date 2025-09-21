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

int handle_db(const std::vector<std::string> &tokens,
              size_t line_no,
              AsmContext &ctx,
              bool emit_byte)
{
    if (tokens.size() < 2)
    {
        std::cerr << "Error en linea " << line_no
                  << ": .DB requiere al menos un valor\n";
        return 1;
    }

    for (size_t i = 1; i < tokens.size(); ++i)
    {
        std::vector<uint8_t> bytes = parse_db_token(tokens[i], line_no, ctx.labels);

        for (uint8_t b : bytes)
        {
            if (emit_byte)
            {
                ctx.sections[ctx.current_section].data.push_back(b);
            }
            ctx.pc++;
        }
    }
    return 0;
}

std::vector<uint8_t> parse_db_token(const std::string &tok,
                                    size_t line_no,
                                    const std::unordered_map<std::string, int> &labels)
{
    std::vector<uint8_t> bytes;

    // Caso 1: caracter entre comillas simples: 'A'
    if (tok.size() == 3 && tok.front() == '\'' && tok.back() == '\'')
    {
        bytes.push_back(static_cast<uint8_t>(tok[1]));
    }
    // Caso 2: cadena entre comillas dobles: "Hola"
    else if (tok.size() >= 2 && tok.front() == '"' && tok.back() == '"')
    {
        std::string inner = tok.substr(1, tok.size() - 2);
        for (char c : inner)
            bytes.push_back(static_cast<uint8_t>(c));
    }
    // Caso 3: etiqueta o número
    else
    {
        int val = 0;
        if (!resolve_val(tok, val, labels))
        {
            std::cerr << "Error en linea " << line_no << ": valor invalido en .DB (" << tok << ")\n";
            return bytes;
        }
        bytes.push_back(static_cast<uint8_t>(val));
    }
    return bytes;
}
