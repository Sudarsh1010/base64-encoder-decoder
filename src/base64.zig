const std = @import("std");
const utils = @import("utils.zig");

pub const Base64 = struct {
    _table: *const [64]u8,

    pub fn init() Base64 {
        return Base64{ ._table = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/" };
    }

    fn _char_at(self: Base64, index: usize) u8 {
        return self._table[index];
    }

    fn _char_index(self: Base64, char: u8) u8 {
        if (char == '=') {
            return 64;
        }

        for (self._table, 0..) |c, i| {
            if (c == char) {
                return @intCast(i);
            }
        }

        return 0;
    }

    pub fn encode(
        self: Base64,
        allocator: std.mem.Allocator,
        input: []const u8,
    ) ![]u8 {
        if (input.len == 0) {
            return "";
        }

        const n_out = try utils._calc_encode_length(input);
        var out = try allocator.alloc(u8, n_out);
        var buf = [3]u8{ 0, 0, 0 };
        var count: u8 = 0;
        var iout: u64 = 0;

        for (input, 0..) |_, i| {
            buf[count] = input[i];
            count += 1;

            if (count == 3) {
                out[iout] = self._char_at(buf[0] >> 2);
                out[iout + 1] = self._char_at(((buf[0] & 0x03) << 4) | (buf[1] >> 4));
                out[iout + 2] = self._char_at(((buf[1] & 0x0f) << 2) | (buf[2] >> 6));
                out[iout + 3] = self._char_at(buf[2] & 0x3f);

                iout += 4;
                count = 0;
            }
        }

        if (count > 0) {
            out[iout] = self._char_at(buf[0] >> 2);

            out[iout + 1] = if (count == 2)
                self._char_at(((buf[0] & 0x03) << 4) | (buf[1] >> 4))
            else
                self._char_at((buf[0] & 0x03) << 4);

            out[iout + 2] = if (count == 2)
                self._char_at((buf[1] & 0x0f) << 2)
            else
                '=';

            out[iout + 3] = '=';
        }

        return out;
    }

    pub fn decode(
        self: Base64,
        allocator: std.mem.Allocator,
        input: []const u8,
    ) ![]u8 {
        if (input.len == 0) {
            return "";
        }

        const n_out = try utils._calc_decode_length(input);
        var out = try allocator.alloc(u8, n_out);
        var buf = [4]u8{ 0, 0, 0, 0 };
        var count: u8 = 0;
        var iout: u64 = 0;

        for (input) |c| {
            buf[count] = self._char_index(c);
            count += 1;

            if (count == 4) {
                out[iout] = (buf[0] << 2) + (buf[1] >> 4);

                if (buf[2] != 64) {
                    out[iout + 1] = (buf[1] << 4) + (buf[2] >> 2);
                }

                if (buf[3] != 64) {
                    out[iout + 2] = (buf[2] << 6) + buf[3];
                }

                count = 0;
                iout += 3;
            }
        }

        return out;
    }
};
