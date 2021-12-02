const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const util = @import("util.zig");
const gpa = util.gpa;

//const data = @embedFile("../data/day02-tst.txt");
const data = @embedFile("../data/day02.txt");

pub fn main() !void {
    try part1();
}

pub fn part1() !void {
    var it = tokenize(u8, data, " \r\n");
    var x: i32 = 0;
    var y: i32 = 0;
    var yalt: i32 = 0;
    var aim: i32 = 0;
    while (true) {
        const command = it.next();
        if (command == null) {
            break;
        }

        const value = try parseInt(i32, it.next().?, 10);

        if (eql(u8, command.?, "forward")) {
            x += value;
            yalt += aim * value;
        } else if (eql(u8, command.?, "up")) {
            y -= value;
            aim -= value;
        } else if (eql(u8, command.?, "down")) {
            y += value;
            aim += value;
        }
    }

    print("{}\n", .{x * y});
    print("{}\n", .{x * yalt});
}

// Useful stdlib functions
const tokenize = std.mem.tokenize;
const eql = std.mem.eql;

const parseInt = std.fmt.parseInt;
const parseFloat = std.fmt.parseFloat;

const print = std.debug.print;
