const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day07.txt");
// const data = @embedFile("../data/day07-tst.txt");

pub fn main() !void {
    var it = tokenize(u8, data, ",\n\r");
    var nums = List(i32).init(gpa);

    while (it.next()) |num| {
        try nums.append(try parseInt(i32, num, 10));
    }

    var min_value: i32 = std.math.maxInt(i32);
    var max_value: i32 = 0;

    for (nums.items) |n| {
        min_value = min(min_value, n);
        max_value = max(max_value, n);
    }

    var min_cost: i32 = std.math.maxInt(i32);
    var min_cost_value: i32 = 0;

    var i: i32 = min_value;
    while (i <= max_value) : (i += 1) {
        var cost: i32 = 0;

        for (nums.items) |n| {
            var steps = try std.math.absInt(i - n);
            // part1
            // cost += steps;

            // part2
            cost += @divExact(steps * (steps + 1), 2);
        }

        if (cost < min_cost) {
            min_cost_value = i;
            min_cost = cost;
        }
    }

    print("{}\n", .{min_cost});
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
