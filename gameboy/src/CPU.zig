const std = @import("std");

const Memory = @import("Memory.zig").Memory();
const Registers = @import("Registers.zig").Registers();
const OpCode = @import("OpCodes.zig").OpCode;

const DEC_R = @import("./instructions/DEC_R.zig");
const INC_R = @import("./instructions/INC_R.zig");
const JP = @import("./instructions/JP.zig");
const JR = @import("./instructions/JR.zig");
const LD_RR_n16 = @import("./instructions/LD_RR_n16.zig");
const LD_R_R = @import("./instructions/LD_R_R.zig");
const LD_R_aRR = @import("./instructions/LD_R_aRR.zig");
const LD_R_n8 = @import("./instructions/LD_R_n8.zig");
const LD_aRR_R = @import("./instructions/LD_aRR_R.zig");

pub fn CPU() type {
    return struct {
        pointer: u16,
        noop_count: usize,

        pub fn init() @This() {
            return .{ .pointer = 0x100, .noop_count = 0 };
        }

        pub fn readNextU8(cpu: *@This(), memory: *Memory) u8 {
            const byte = memory.memory[cpu.pointer];
            cpu.pointer += 1;
            return byte;
        }

        pub fn readNextI8(cpu: *@This(), memory: *Memory) i8 {
            const byte = @as(i8, @intCast(memory.memory[cpu.pointer]));
            cpu.pointer += 1;
            return byte;
        }

        pub fn skip(cpu: *@This(), value: u16) void {
            cpu.pointer += value;
        }

        pub fn execute(cpu: *@This(), memory: *Memory, registers: *Registers) !void {
            const byte = cpu.readNextU8(memory);
            const opcode: OpCode = std.meta.intToEnum(OpCode, byte) catch {
                logByte(byte);
                return error.UnknownOpCode;
            };

            var noop = false;
            switch (opcode) {
                OpCode.NOP => {
                    noop = true;
                    cpu.noop_count += 1;
                },

                OpCode.DEC_B => DEC_R.DEC_B(registers),
                OpCode.DEC_D => DEC_R.DEC_D(registers),
                OpCode.DEC_H => DEC_R.DEC_H(registers),
                OpCode.DEC_C => DEC_R.DEC_C(registers),
                OpCode.DEC_E => DEC_R.DEC_E(registers),
                OpCode.DEC_L => DEC_R.DEC_L(registers),
                OpCode.DEC_A => DEC_R.DEC_A(registers),

                OpCode.INC_B => INC_R.INC_B(registers),
                OpCode.INC_D => INC_R.INC_D(registers),
                OpCode.INC_H => INC_R.INC_H(registers),
                OpCode.INC_C => INC_R.INC_C(registers),
                OpCode.INC_E => INC_R.INC_E(registers),
                OpCode.INC_L => INC_R.INC_L(registers),
                OpCode.INC_A => INC_R.INC_A(registers),

                OpCode.JP_an16 => JP.JP_an16(cpu, memory),

                OpCode.JR_cZ_an8 => JR.JR_cZ_an8(cpu, registers, memory),
                OpCode.JR_nZ_an8 => JR.JR_nZ_an8(cpu, registers, memory),

                OpCode.LD_BC_n16 => LD_RR_n16.LD_BC_n16(cpu, registers, memory),
                OpCode.LD_DE_n16 => LD_RR_n16.LD_DE_n16(cpu, registers, memory),
                OpCode.LD_HL_n16 => LD_RR_n16.LD_HL_n16(cpu, registers, memory),
                OpCode.LD_SP_n16 => LD_RR_n16.LD_SP_n16(cpu, registers, memory),

                OpCode.LD_B_B => LD_R_R.LD_R_R(&registers.B, registers.B),
                OpCode.LD_D_B => LD_R_R.LD_R_R(&registers.D, registers.B),
                OpCode.LD_H_B => LD_R_R.LD_R_R(&registers.H, registers.B),
                OpCode.LD_C_B => LD_R_R.LD_R_R(&registers.C, registers.B),
                OpCode.LD_E_B => LD_R_R.LD_R_R(&registers.E, registers.B),
                OpCode.LD_L_B => LD_R_R.LD_R_R(&registers.L, registers.B),
                OpCode.LD_A_B => LD_R_R.LD_R_R(&registers.L, registers.B),

                OpCode.LD_B_C => LD_R_R.LD_R_R(&registers.B, registers.C),
                OpCode.LD_D_C => LD_R_R.LD_R_R(&registers.D, registers.C),
                OpCode.LD_H_C => LD_R_R.LD_R_R(&registers.H, registers.C),
                OpCode.LD_C_C => LD_R_R.LD_R_R(&registers.C, registers.C),
                OpCode.LD_E_C => LD_R_R.LD_R_R(&registers.E, registers.C),
                OpCode.LD_L_C => LD_R_R.LD_R_R(&registers.L, registers.C),
                OpCode.LD_A_C => LD_R_R.LD_R_R(&registers.A, registers.C),

                OpCode.LD_B_D => LD_R_R.LD_R_R(&registers.B, registers.D),
                OpCode.LD_D_D => LD_R_R.LD_R_R(&registers.D, registers.D),
                OpCode.LD_H_D => LD_R_R.LD_R_R(&registers.H, registers.D),
                OpCode.LD_C_D => LD_R_R.LD_R_R(&registers.C, registers.D),
                OpCode.LD_E_D => LD_R_R.LD_R_R(&registers.E, registers.D),
                OpCode.LD_L_D => LD_R_R.LD_R_R(&registers.L, registers.D),
                OpCode.LD_A_D => LD_R_R.LD_R_R(&registers.A, registers.D),

                OpCode.LD_B_E => LD_R_R.LD_R_R(&registers.B, registers.E),
                OpCode.LD_D_E => LD_R_R.LD_R_R(&registers.D, registers.E),
                OpCode.LD_H_E => LD_R_R.LD_R_R(&registers.H, registers.E),
                OpCode.LD_C_E => LD_R_R.LD_R_R(&registers.C, registers.E),
                OpCode.LD_E_E => LD_R_R.LD_R_R(&registers.E, registers.E),
                OpCode.LD_L_E => LD_R_R.LD_R_R(&registers.L, registers.E),
                OpCode.LD_A_E => LD_R_R.LD_R_R(&registers.A, registers.E),

                OpCode.LD_B_H => LD_R_R.LD_R_R(&registers.B, registers.H),
                OpCode.LD_D_H => LD_R_R.LD_R_R(&registers.D, registers.H),
                OpCode.LD_H_H => LD_R_R.LD_R_R(&registers.H, registers.H),
                OpCode.LD_C_H => LD_R_R.LD_R_R(&registers.C, registers.H),
                OpCode.LD_E_H => LD_R_R.LD_R_R(&registers.E, registers.H),
                OpCode.LD_L_H => LD_R_R.LD_R_R(&registers.L, registers.H),
                OpCode.LD_A_H => LD_R_R.LD_R_R(&registers.A, registers.H),

                OpCode.LD_B_L => LD_R_R.LD_R_R(&registers.B, registers.L),
                OpCode.LD_D_L => LD_R_R.LD_R_R(&registers.D, registers.L),
                OpCode.LD_H_L => LD_R_R.LD_R_R(&registers.H, registers.L),
                OpCode.LD_C_L => LD_R_R.LD_R_R(&registers.C, registers.L),
                OpCode.LD_E_L => LD_R_R.LD_R_R(&registers.E, registers.L),
                OpCode.LD_L_L => LD_R_R.LD_R_R(&registers.L, registers.L),
                OpCode.LD_A_L => LD_R_R.LD_R_R(&registers.A, registers.L),

                OpCode.LD_B_A => LD_R_R.LD_R_R(&registers.B, registers.A),
                OpCode.LD_D_A => LD_R_R.LD_R_R(&registers.D, registers.A),
                OpCode.LD_H_A => LD_R_R.LD_R_R(&registers.H, registers.A),
                OpCode.LD_C_A => LD_R_R.LD_R_R(&registers.C, registers.A),
                OpCode.LD_E_A => LD_R_R.LD_R_R(&registers.D, registers.A),
                OpCode.LD_L_A => LD_R_R.LD_R_R(&registers.L, registers.A),
                OpCode.LD_A_A => LD_R_R.LD_R_R(&registers.A, registers.A),

                OpCode.LD_A_aHLp => LD_R_aRR.LD_A_aHLp(registers, memory),

                OpCode.LD_C_n8 => LD_R_n8.LD_C_n8(cpu, registers, memory),
                OpCode.LD_E_n8 => LD_R_n8.LD_E_n8(cpu, registers, memory),
                OpCode.LD_L_n8 => LD_R_n8.LD_L_n8(cpu, registers, memory),
                OpCode.LD_A_n8 => LD_R_n8.LD_A_n8(cpu, registers, memory),

                OpCode.LD_aDE_A => LD_aRR_R.LD_aDE_A(registers, memory),
            }

            if (noop == false and cpu.noop_count != 0) {
                std.log.info("skipped {} noop's", .{
                    cpu.noop_count,
                });
                cpu.noop_count = 0;
            }

            if (opcode != OpCode.NOP) {
                logOpCode(cpu.pointer, opcode);
                std.time.sleep(1000000000 / 16);
            }
        }

        fn logOpCode(pointer: u16, opcode: OpCode) void {
            const byte = @intFromEnum(opcode);
            std.log.info("pointer = {x:0>4} , byte = {b:0>8} {x:0>2} , opcode = {}", .{
                pointer,
                byte,
                byte,
                opcode,
            });
        }

        fn logByte(byte: u8) void {
            std.log.info("byte = {b:0>8} {x:0>2}", .{
                byte,
                byte,
            });
        }
    };
}
