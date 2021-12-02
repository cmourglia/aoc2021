const std = @import("std");

const util = @import("util.zig");
const data = @embedFile("../data/day01.txt");

pub fn main() !void {
    try part1();
    try part2();
}

fn part1() !void {
    var nums = try util.parseIntArray(data);
    var tot: i32 = 0;

    for (nums.items[1..]) |_, i| {
        const val = nums.items[i + 1];
        const previous = nums.items[i];

        if (val > previous) {
            tot += 1;
        }
    }

    print("{}\n", .{tot});
}

fn part2() !void {
    var nums = try util.parseIntArray(data);
    var tot: i32 = 0;

    for (nums.items[3..]) |_, i| {
        const val = nums.items[i + 1] + nums.items[i + 2] + nums.items[i + 3];
        const previous = nums.items[i] + nums.items[i + 1] + nums.items[i + 2];

        if (val > previous) {
            tot += 1;
        }
    }

    print("{}", .{tot});
}

const print = std.debug.print;
