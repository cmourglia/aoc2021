const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day10.txt");
// const data = @embedFile("../data/day10-tst.txt");

pub fn main() !void {
    var it = tokenize(u8, data, "\r\n");

    var part1: usize = 0;
    var part2 = List(usize).init(gpa);
    while (it.next()) |line| {
        var p2: usize = 0;
        try handleLine(line, &part1, &p2);
        if (p2 > 0) {
            try part2.append(p2);
        }
    }

    std.sort.sort(usize, part2.items, {}, comptime std.sort.asc(usize));
    print("{} {}\n", .{ part1, part2.items[(part2.items.len / 2)] });
}

fn handleLine(line: []const u8, part1: *usize, part2: *usize) !void {
    var stack = List(u8).init(gpa);
    defer stack.deinit();

    for (line) |c| {
        if (isOpening(c)) {
            try stack.append(c);
        } else {
            assert(isClosing(c));
            const top = stack.pop();
            if (getCorresponding(c) != top) {
                switch (c) {
                    ')' => part1.* += 3,
                    ']' => part1.* += 57,
                    '}' => part1.* += 1197,
                    '>' => part1.* += 25137,
                    else => unreachable,
                }
                return;
            }
        }
    }

    var score: usize = 0;
    while (stack.popOrNull()) |top| {
        score *= 5;

        const c = getCorresponding(top);
        switch (c) {
            ')' => score += 1,
            ']' => score += 2,
            '}' => score += 3,
            '>' => score += 4,
            else => unreachable,
        }
    }
    part2.* = score;
}

fn getCorresponding(char: u8) u8 {
    switch (char) {
        '(' => return ')',
        '{' => return '}',
        '[' => return ']',
        '<' => return '>',
        ')' => return '(',
        '}' => return '{',
        ']' => return '[',
        '>' => return '<',
        else => unreachable,
    }
}

fn isOpening(char: u8) bool {
    switch (char) {
        '(', '[', '<', '{' => return true,
        else => return false,
    }
}

fn isClosing(char: u8) bool {
    switch (char) {
        ')', ']', '>', '}' => return true,
        else => return false,
    }
}

fn getCost(char: u8) usize {
    switch (char) {
        ')' => return 3,
        ']' => return 57,
        '}' => return 1197,
        '>' => return 25137,
        else => unreachable,
    }
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
