pub const OpCode = enum(u8) {
    /// No Operation.
    NOP = 0x0,

    /// Decrement B.
    DEC_B = 0x05,
    /// Decrement D.
    DEC_D = 0x15,
    /// Decrement H.
    DEC_H = 0x25,
    /// Decrement C.
    DEC_C = 0x0D,
    /// Decrement E.
    DEC_E = 0x1D,
    /// Decrement L.
    DEC_L = 0x2D,
    /// Decrement A.
    DEC_A = 0x3D,

    /// Jump the pointer to the address of the next 2 bytes.
    JP_an16 = 0xC3,

    /// If the zero flag is set, add the next byte to the pointer.
    JR_cZ_an8 = 0x20,
    /// If the zero flag is NOT set, add the next byte to the pointer.
    JR_nZ_an8 = 0x30,

    /// Write A to address of DE.
    LD_aDE_A = 0x12,

    /// Increment B.
    INC_B = 0x04,
    /// Increment D.
    INC_D = 0x14,
    /// Increment H.
    INC_H = 0x24,
    /// Increment C.
    INC_C = 0x0C,
    /// Increment E.
    INC_E = 0x1C,
    /// Increment L.
    INC_L = 0x2C,
    /// Increment A.
    INC_A = 0x3C,

    /// Load the next 2 bytes into BC.
    LD_BC_n16 = 0x01,
    /// Load the next 2 bytes into DE.
    LD_DE_n16 = 0x11,
    /// Load the next 2 bytes into HL.
    LD_HL_n16 = 0x21,
    /// Load the next 2 bytes into SP.
    LD_SP_n16 = 0x31,

    /// Load the next byte into C.
    LD_C_n8 = 0x0E,
    /// Load the next byte into E.
    LD_E_n8 = 0x1E,
    /// Load the next byte into L.
    LD_L_n8 = 0x2E,
    /// Load the next byte into A.
    LD_A_n8 = 0x3E,

    /// Load the value at HL into A. Increment HL.
    LD_A_aHLp = 0x2A,

    LD_B_B = 0x40,
    LD_D_B = 0x50,
    LD_H_B = 0x60,
    LD_B_C = 0x41,
    LD_D_C = 0x51,
    LD_H_C = 0x61,
    LD_B_D = 0x42,
    LD_D_D = 0x52,
    LD_H_D = 0x62,
    LD_B_E = 0x43,
    LD_D_E = 0x53,
    LD_H_E = 0x63,
    LD_B_H = 0x44,
    LD_D_H = 0x54,
    LD_H_H = 0x64,
    LD_B_L = 0x45,
    LD_D_L = 0x55,
    LD_H_L = 0x65,
    LD_B_A = 0x47,
    LD_D_A = 0x57,
    LD_H_A = 0x67,

    LD_C_B = 0x48,
    LD_E_B = 0x58,
    LD_L_B = 0x68,
    LD_A_B = 0x78,
    LD_C_C = 0x49,
    LD_E_C = 0x59,
    LD_L_C = 0x69,
    LD_A_C = 0x79,
    LD_C_D = 0x4A,
    LD_E_D = 0x5A,
    LD_L_D = 0x6A,
    LD_A_D = 0x7A,
    LD_C_E = 0x4B,
    LD_E_E = 0x5B,
    LD_L_E = 0x6B,
    LD_A_E = 0x7B,
    LD_C_H = 0x4C,
    LD_E_H = 0x5C,
    LD_L_H = 0x6C,
    LD_A_H = 0x7C,
    LD_C_L = 0x4D,
    LD_E_L = 0x5D,
    LD_L_L = 0x6D,
    LD_A_L = 0x7D,
    LD_C_A = 0x4F,
    LD_E_A = 0x5F,
    LD_L_A = 0x6F,
    LD_A_A = 0x7F,
};
