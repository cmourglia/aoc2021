const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const util = @import("util.zig");
const gpa = util.gpa;

// const data = @embedFile("../data/day06-tst.txt");
const data = @embedFile("../data/day06.txt");

pub fn main() !void {
    var it = tokenize(u8, data, ",\n\r");
    var days = [_]u128{0} ** 9;

    while (it.next()) |num| {
        var n = try parseInt(u8, num, 10);
        days[n] += 1;
    }

    var t0 = std.time.nanoTimestamp();
    for ([_]u0{0} ** 512) |_| {
        step(&days);
    }
    var t1 = std.time.nanoTimestamp();
    print("{}\n", .{t1 - t0});

    var total: u128 = 0;
    for (days) |n| {
        total += n;
    }

    print("{}", .{total});
}

fn step(days: *[9]u128) void {
    var day0 = days[0];
    days[0] = days[1];
    days[1] = days[2];
    days[2] = days[3];
    days[3] = days[4];
    days[4] = days[5];
    days[5] = days[6];
    days[6] = days[7] + day0;
    days[7] = days[8];
    days[8] = day0;
}

// Useful stdlib functions
const tokenize = std.mem.tokenize;
const split = std.mem.split;
const indexOf = std.mem.indexOfScalar;
const indexOfAny = std.mem.indexOfAny;
const indexOfStr = std.mem.indexOfPosLinear;
const lastIndexOf = std.mem.lastIndexOfScalar;
const lastIndexOfAny = std.mem.lastIndexOfAny;
const lastIndexOfStr = std.mem.lastIndexOfLinear;
const trim = std.mem.trim;
const sliceMin = std.mem.min;
const sliceMax = std.mem.max;

const parseInt = std.fmt.parseInt;
const parseFloat = std.fmt.parseFloat;

const min = std.math.min;
const min3 = std.math.min3;
const max = std.math.max;
const max3 = std.math.max3;

const print = std.debug.print;
const assert = std.debug.assert;

const sort = std.sort.sort;
const asc = std.sort.asc;
const desc = std.sort.desc;
