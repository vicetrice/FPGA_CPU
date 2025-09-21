#pragma once

#include "asm.h"
#include "asm_utilities.h"


// Handler para .sect
int handle_sect(const std::vector<std::string> &tokens, size_t line_no, AsmContext &ctx, bool emit_byte);

// Handler para .DB
int handle_db(const std::vector<std::string> &tokens, size_t line_no, AsmContext &ctx, bool emit_byte);


