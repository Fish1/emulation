const Registers = @import("../Registers.zig").Registers();
const Memory = @import("../Memory.zig").Memory();

pub fn LD_A_aHLp(registers: *Registers, memory: *Memory) void {
    registers.A = memory.read(registers.getHL());
    registers.setHL(registers.getHL() + 1);
}
