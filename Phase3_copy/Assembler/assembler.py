# <instr><WW_code><PPP_code>
# <instr> is consistent with the ISA instr names
# possible WW_codes: b, h, w, d
# possible PPP_codes: a, u, d, e, o
# if WW_code or PPP_code is not provided, default values are taken
# Ex: VAND_ba rD, rA, rB
# Ex: VLD_NIC1 rD, 10

read_code = []
def read_assembly(): # Function to read the input asm code
    a = input("Enter input file name: ")
    global read_code
    with open(a, 'r') as file:
        read_code = file.readlines() # Store the code lines in read_code list
    


def assembler():
    clean_code = []
    ALUtype = ["VAND", "VOR", "VXOR", "VNOT", "VMOV", "VADD", "VSUB", "VMULEU", "VMULEO", "VSLL", "VSRL", "VSRA", "VRTTH", "VDIV", "VMOD", "VSQEU", "VSQOU", "VSQRT"]
    Hex_code = []

    # Remove the comments in the read_code and store the cleaned code in clean_code
    for i in read_code:
        if "//" in i:
            if len(i[0:i.index("//")])>0:
                clean_code.append(i[0:i.index("//")].strip().strip(";").strip())
        else:
            clean_code.append(i.strip().strip(";").strip()) 

     
    for i in clean_code:
        Bin_instr = ""
        opcode = ""
        rD = ""
        rA = ""
        rB = ""
        Imm = ""
        PPP = "000" # default value for PPP
        WW = "11" # default value for WW
        func_code = ""

        if "VNOP" in i: # if it's a NOP, place the following value
            Bin_instr = "11110000000000000000000000000000"
        elif ("VLD" in i) or ("VSD" in i) or ("VBEZ" in i) or ("VBNEZ" in i):    
            # assign opcode
            if ("VSD" in i):
                opcode = "100001"
            elif ("VBEZ" in i):
                opcode = "100010"
            elif ("VBNEZ" in i):
                opcode = "100011"
            else:
                opcode = "100000"    
            rD = format(int(''.join(i.split()[1:]).split(",")[0][1:])& 0xFFFF, '05b') # turn the given value into 5 bit binary
            rA = "00000" # rA is 0 for these instructions
            Imm = format(int(''.join(i.split()[1:]).split(",")[-1])& 0xFFFF, '016b') # turn the given value into 16 bit binary

            Bin_instr = opcode + rD + rA + Imm

            # change bits 16 and 17 to 11 if NIC type LD or SD
            # Also change the bits 30, 31 based on the address of NIC registers
            if "NIC" in i:
                Bin_instr = Bin_instr[0:16] + "11" + Bin_instr[18:]
                if i[7] == "0":
                    Bin_instr = Bin_instr[0:30] + "00"
                elif i[7] == "1":
                    Bin_instr = Bin_instr[0:30] + "01"
                elif i[7] == "2":
                    Bin_instr = Bin_instr[0:30] + "10"
                elif i[7] == "3":
                    Bin_instr = Bin_instr[0:30] + "11"
                    
            

        else:
            if i.split()[0][0:-2] in ALUtype or i.split()[0] in ALUtype:
                
                opcode ="101010" # opcode for ALU type instructions
                rD = format(int(''.join(i.split()[1:]).split(",")[0][1:])& 0xFFFF, '05b')  # turn the given value into 5 bit binary
                rA = format(int(''.join(i.split()[1:]).split(",")[1][1:])& 0xFFFF, '05b')  # turn the given value into 16 bit binary
                if ("VNOT" in i) or ("VMOV" in i) or ("VRTTH" in i) or ("VSQEU" in i) or ("VSQOU" in i) or ("VSQRT" in i):
                    rB = "00000" # these instructions have rB as 00000
                else:
                    rB = format(int(''.join(i.split()[1:]).split(",")[2][1:])& 0xFFFF, '05b') # else turn the given value into 5 bit binary
                    
                    
                
                if i.split()[0][0:-2] in ALUtype:
                    # assign WW value based on the WW_code
                    if i.split()[0][-2] == "b":
                        WW = "00"
                    elif i.split()[0][-2] == "h":
                        WW = "01"
                    elif i.split()[0][-2] == "w":
                        WW = "10"
                    elif i.split()[0][-2] == "d":
                        WW = "11"
                    else:
                        print(f"invalid instruction: {i} \nassembler terminated!")
                        return
                    
                    # assign PPP value based on the PPP_code
                    if i.split()[0][-1] == "a":
                        PPP = "000"
                    elif i.split()[0][-1] == "u":
                        PPP = "001"
                    elif i.split()[0][-1] == "d":
                        PPP = "010"
                    elif i.split()[0][-1] == "e":
                        PPP = "011"
                    elif i.split()[0][-1] == "o":
                        PPP = "100"
                    else:
                        print(f"invalid instruction: {i}\nassembler terminated!")
                        return
                        
                    func_code = format(ALUtype.index(i.split()[0][0:-2]) & 0xFFFF, '06b')
                elif i.split()[0] in ALUtype:
                    func_code = format(ALUtype.index(i.split()[0]) & 0xFFFF, '06b')
                
                # concatenate all the parts to get the binary string
                Bin_instr = opcode + rD + rA + rB + PPP + WW + func_code
                
                
            else:
                # return if invalid instruction
                print(f"invalid instruction: {i} \nassembler terminated!")
                return

            
        if Bin_instr != "":
            # turn the Binary instruction to Hex and append to Hex_code list
            Hex_code.append(str(hex(int(Bin_instr, 2))[2:].zfill(16)).upper()[8:] + f" // {i};")

    a = input("Enter output file name: ")
    with open(a, "w") as file:
        # write the Hex_code list to output file
        for i in Hex_code:
            file.write(i + "\n")
        
read_assembly()
assembler()
