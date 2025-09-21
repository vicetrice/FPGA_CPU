#pragma once

#include "asm.h"
#include "asm_utilities.h"

//=========================== HANDLERS ===============================

int handle_R_OR_ANY(const std::vector<std::string> &tokens, size_t line_no, AsmContext &ctx, bool emit_byte);
int handle_LDR(const std::vector<std::string> &tokens, size_t line_no, AsmContext &ctx, bool emit_byte);
int handle_STR(const std::vector<std::string> &tokens, size_t line_no, AsmContext &ctx, bool emit_byte);
int handle_JNZ(const std::vector<std::string> &tokens, size_t line_no, AsmContext &ctx, bool emit_byte);
int handle_LEA(const std::vector<std::string> &tokens, size_t line_no, AsmContext &ctx, bool emit_byte);
int handle_SHL(const std::vector<std::string> &tokens, size_t line_no, AsmContext &ctx, bool emit_byte);
int handle_SHR(const std::vector<std::string> &tokens, size_t line_no, AsmContext &ctx, bool emit_byte);
int handle_PUSH_S(const std::vector<std::string> &tokens, size_t line_no, AsmContext &ctx, bool emit_byte);
int handle_POP(const std::vector<std::string> &tokens, size_t line_no, AsmContext &ctx, bool emit_byte);
int handle_POPF(const std::vector<std::string> &tokens, size_t line_no, AsmContext &ctx, bool emit_byte);

//====================================================================