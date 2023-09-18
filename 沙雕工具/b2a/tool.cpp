#include <iostream>
#include <fstream>
#include <vector>
#include <algorithm> // 用于逆序转换

using namespace std;
using MIPSInstruction = unsigned int;

// 将小端序数据转换为大端序
MIPSInstruction convertToBigEndian(MIPSInstruction data) {
    unsigned char* bytes = reinterpret_cast<unsigned char*>(&data);
    std::reverse(bytes, bytes + sizeof(MIPSInstruction));
    return data;
}

// 从MIPS指令中提取字段值
void extractFields(const MIPSInstruction& instruction, ofstream & output_file, unsigned int pc) {
    unsigned int opcode = (instruction >> 26) & 0x3F;    // 前6位是opcode字段
    unsigned int rs = (instruction >> 21) & 0x1F;        // 接下来的5位是rs字段
    unsigned int rt = (instruction >> 16) & 0x1F;        // 再接下来的5位是rt字段
    unsigned int rd = (instruction >> 11) & 0x1F;        // 然后是rd字段
    unsigned int shamt = (instruction >> 6) & 0x1F;      // 再然后是shamt字段
    unsigned int funct = instruction & 0x3F;            // 最后的6位是funct字段
    unsigned int imm = instruction & 0xffff;

    if (instruction != 0)
    {
        for (int j = 31; j >= 0; j--) {
                output_file << ((instruction >> j) & 1);
                }
        output_file << endl;
    }

    // std::cout << "Opcode: " << opcode << std::endl;
    // std::cout << "RS: " << rs << std::endl;
    // std::cout << "RT: " << rt << std::endl;
    // std::cout << "RD: " << rd << std::endl;
    // std::cout << "Shamt: " << shamt << std::endl;
    // std::cout << "Funct: " << funct << std::endl;

    // output_file << "0x" << hex << pc << "           ";

    if (instruction != 0)
    {
        output_file << "0x" << hex << pc << "           ";
        switch (opcode){
            case 0x0c:
                output_file << "andi" << " r" << rt << " r" << rs << " 0x" << hex << imm;
                break;
            case 0x0f:
                output_file << "lui" << " r" << rt << " 0x" << hex << imm;
                break;
            case 0x0d:
                output_file << "ori" << " r" << rt << " r" << rs << " 0x" << hex << imm;
                break;
            case 0x0e:
                output_file << "xori" << " r" << rt << " r" << rs << " 0x" << hex << imm;
                break;
            case 0x09:
                output_file << "addiu" << " r" << rt << " r" << rs << " 0x" << hex << imm;
                break;
            case 0x20:
                output_file << "lb" << " r" << rt << " 0x" << hex << imm << "(r" << rs << ")";
                break;
            case 0x28:
                output_file << "sb" << " r" << rt << " 0x" << hex << imm << "(r" << rs << ")";
                break;
            case 0x23:
                output_file << "lw" << " r" << rt << " 0x" << hex << imm << "(r" << rs << ")";
                break;
            case 0x2b:
                output_file << "sw" << " r" << rt << " 0x" << hex << imm << "(r" << rs << ")";
                break;
            case 0x04:
                output_file << "beq" << " r" << rs << " r" << rt << " 0x" << hex << imm;
                break;
            case 0x01:
                output_file << "bgez" << " r" << rs << " 0x" << hex << imm;
                break;
            case 0x07:
                output_file << "bgtz" << " r" << rs << " 0x" << hex << imm;
                break;
            case 0x05:
                output_file << "bne" << " r" << rs << " r" << rt << " 0x" << hex << imm;
                break;
            case 0x02:
                output_file << "j";
                break;
            case 0x03:
                output_file << "jal";
                break;
            case 0x1c:
                output_file << "mul" << " r" << rs << " r" << rt;
                break;
            case 0x00:
                switch (funct)
                {
                case 0x24:
                    output_file << "and" << " r" << rd << " r" << rs << " r" << rt;
                    break;
                case 0x25:
                    output_file << "or" << " r" << rd << " r" << rs << " r" << rt;
                    break;
                case 0x26:
                    output_file << "xor" << " r" << rd << " r" << rs << " r" << rt;
                    break;
                case 0x00:
                    output_file << "sll" << " r" << rd << " r" << rt << " sa:" << " 0x" << hex << shamt;
                    break;
                case 0x02:
                    output_file << "srl" << " r" << rd << " r" << rt << " sa:" << " 0x" << hex << shamt;
                    break;
                case 0x21:
                    output_file << "addu" << " r" << rd << " r" << rs << " r" << rt;
                    break;
                case 0x08:
                    output_file << "jr" << " r" << rs;
                    break;

                case 0x2a:
                    output_file << "slt" << " r" << rd << " r" << rt << " r" << rs;
                    break;
                case 0x07:
                    output_file << "srav" << " r" << rd << " r" << rt << " r" << rs;
                    break;
                default:
                    output_file << "unknow";
                    break;
                }
                break;
            default:
                output_file << "unknow2";
                break;
        }
        output_file << endl << endl;
    }
    // else
    //     output_file << "none";
    // output_file << endl << endl;
}


int main(int argc, char* argv[]) {

    if (argc != 3) {
        std::cout << "使用方法: " << argv[0] << " <输入文件> <输出文件>" << std::endl;
        return 1;
    }

    std::string input_filename = argv[1];  // 输入二进制文件名
    std::string output_filename = argv[2]; // 输出文本文件名

    std::ifstream file(input_filename, std::ios::binary);

    if (!file) {
        std::cout << "无法打开文件：" << input_filename << std::endl;
        return 1;
    }

    std::vector<MIPSInstruction> instructions;

    while (!file.eof()) {
        MIPSInstruction instruction;
        file.read(reinterpret_cast<char*>(&instruction), sizeof(MIPSInstruction));

        if (file.gcount() == sizeof(MIPSInstruction)) {
            // 将读取到的32-bit数据转换为大端序并存入数组中
            // instruction = convertToBigEndian(instruction);
            instructions.push_back(instruction);
        }
    }

    file.close();

    // 现在可以在数组instructions中进行解码等操作

    // 将解码结果输出到文件
    std::ofstream output_file(output_filename);
    if (!output_file) {
        std::cout << "无法打开输出文件" << std::endl;
        return 1;
    }

    for (int i = 0; i < instructions.size(); ++i) {
        extractFields(instructions[i], output_file, i * 4 + 0x80000000);
    }

    output_file.close();

    return 0;
}
