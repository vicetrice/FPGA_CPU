#pragma once

#include <string>
#include <unordered_map>
#include <vector>

std::string lsubstr(const std::string &s, size_t pos);

struct InstrInfo
{
    uint8_t opcode;
    // operand pattern (for our assembler): "R,IMM8", "R,R", "R,[IMM16]", "[IMM16],R", "IMM16", "R"
    std::string pattern;
};


struct SectionInfo
{
    std::vector<uint8_t> data;
    int start_addr;
};

struct AsmContext {
    int pc;
    int current_section_size;
    std::string current_section;
    std::unordered_map<std::string,SectionInfo> sections;
    std::unordered_map<std::string,int> labels;
    std::vector<std::string> clean;
    std::vector<int> clean_line_no;
};

int reg_code(const std::string &r);

void rem_comments(std::string &l);


bool resolve_val(const std::string &tok, int &val, const std::unordered_map<std::string, int> &labels);

void emit_first(int y, int z, uint8_t opcode, std::vector<uint8_t> &out, int &pc);

std::string trim(const std::string &s);

int parse_number(const std::string &s);

void emit_first(int y, int z, uint8_t opcode, std::vector<uint8_t>& out, int &pc); 

std::vector<std::string> tokenize(const std::string &line);

inline bool is_hex(const std::string &s)
{
    return s.size() > 2 && s[0] == '0' && (s[1] == 'x' || s[1] == 'X');
}

std::string lsubstr(const std::string &s, size_t pos);