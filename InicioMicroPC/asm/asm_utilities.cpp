#include "asm_utilities.h"

static const std::unordered_map<std::string, int> reg_map = {
    {"R0", 0}, {"R1", 1}, {"R2", 2}, {"R3", 3}, {"R4", 4}, {"R5", 5}, {"IP", 6}, {"SP", 7}, {"R6", 6}, {"R7", 7}};

void rem_comments(std::string &l)
{

    size_t p = l.find(';');
    size_t p2 = l.find("//");
    size_t cpos = std::string::npos;
    if (p != std::string::npos)
        cpos = p;
    if (p2 != std::string::npos)
        cpos = std::min(cpos == std::string::npos ? p2 : cpos, p2);
    if (cpos != std::string::npos)
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

bool resolve_val(const std::string &tok, int &val, const std::unordered_map<std::string, int> &labels)
{
    std::string t = trim(tok);
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
        std::string inner = t.substr(1, t.size() - 2);
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

int reg_code(const std::string &r)
{
    std::string s = r;
    for (char &c : s)
        c = toupper(c);
    auto it = reg_map.find(s);
    return (it != reg_map.end()) ? it->second : -1;
}

std::string trim(const std::string &s)
{
    auto a = s.find_first_not_of(" \t\r\n");
    if (a == std::string::npos)
        return "";
    auto b = s.find_last_not_of(" \t\r\n");
    return s.substr(a, b - a + 1);
}

std::vector<std::string> tokenize(const std::string &line)
{
    std::vector<std::string> toks;
    std::string cur;
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
    std::string t = s;
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
