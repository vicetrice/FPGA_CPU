#pragma once

#include "asm.h"

int reg_code(const std::string &r);

void rem_comments(std::string &l);

bool resolve_val(const std::string &tok, int &val, const std::unordered_map<std::string, int> &labels);

void emit_first(int y, int z, uint8_t opcode, std::vector<uint8_t> &out, int &pc);

std::string trim(const std::string &s);

int parse_number(const std::string &s);

void emit_first(int y, int z, uint8_t opcode, std::vector<uint8_t> &out, int &pc);

std::vector<std::string> tokenize(const std::string &line);

inline bool is_hex(const std::string &s)
{
    return s.size() > 2 && s[0] == '0' && (s[1] == 'x' || s[1] == 'X');
}

std::string lsubstr(const std::string &s, size_t pos);