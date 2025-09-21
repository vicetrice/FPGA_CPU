#pragma once

#include <bits/stdc++.h>
#include <string>
#include <unordered_map>
#include <vector>
#include <functional>

struct SectionInfo
{
    std::vector<uint8_t> data;
    int start_addr;
};

struct AsmContext
{
    int pc;
    int current_section_size;
    std::string current_section;
    std::unordered_map<std::string, SectionInfo> sections;
    std::unordered_map<std::string, int> labels;
    std::vector<std::string> clean;
    std::vector<int> clean_line_no;
};

typedef std::function<int(const std::vector<std::string> &tokens, size_t line_no, AsmContext &ctx, bool emit_byte)> InstHandler;




