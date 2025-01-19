const std = @import("std");

pub fn _calc_encode_length(input: []const u8) !usize {
    if (input.len < 3) {
        const n_output: usize = 4;
        return n_output;
    }

    const n_output: usize = try std.math.divCeil(usize, input.len, 3);
    return n_output * 4;
}

pub fn _calc_decode_length(input: []const u8) !usize {
    if (input.len < 4) {
        const n_output: usize = 3;
        return n_output;
    }

    const n_output: usize = try std.math.divCeil(usize, input.len, 4);
    return n_output * 3;
}
