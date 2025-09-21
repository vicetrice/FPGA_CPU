#pragma once

#include "asm.h"
#include <functional>



typedef std::function<int(const std::vector<std::string> &tokens, size_t line_no, AsmContext &ctx, bool emit_byte)> DirectiveHandler;

// Handler para .sect
int handle_sect(const std::vector<std::string> &tokens, size_t line_no, AsmContext &ctx, bool emit_byte);

// Handler para .DB
int handle_db(const std::vector<std::string> &tokens, size_t line_no, AsmContext &ctx, bool emit_byte);


