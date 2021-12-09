const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day09.txt");
// const data = @embedFile("../data/day09-tst.txt");

fn sortAscFn(context: void, a: u32, b: u32) bool {
    return std.sort.asc(u32)(context, a, b);
}

fn sortDescFn(context: void, a: u32, b: u32) bool {
    return std.sort.desc(u32)(context, a, b);
}

pub fn main() !void {
    var grid = try Grid.init();

    var j: isize = 0;

    var part1: u32 = 0;

    var part2 = List(u32).init(gpa);

    while (j < grid.h) : (j += 1) {
        var i: isize = 0;
        while (i < grid.w) : (i += 1) {
            const value = grid.value(Point{ .x = i, .y = j });
            const neighbors = grid.neighbors(i, j);

            var ok = true;
            for (neighbors) |neighbor| {
                if (value >= grid.value(neighbor)) {
                    ok = false;
                    break;
                }
            }

            if (ok) {
                part1 += @intCast(u32, value + 1);

                try part2.append(grid.floodFill(i, j));
            }
        }
    }

    print("{}\n", .{part1});

    std.sort.sort(u32, part2.items, {}, sortDescFn);
    print("{}\n", .{part2.items[0] * part2.items[1] * part2.items[2]});
}

const Point = struct {
    x: isize,
    y: isize,
};

const Grid = struct {
    grid: List(u8),
    hist: List(bool),
    w: isize,
    h: isize,
    buffer: [4]Point,

    fn init() !Grid {
        var grid = Grid{
            .grid = List(u8).init(gpa),
            .hist = List(bool).init(gpa),
            .w = 0,
            .h = 0,
            .buffer = [_]Point{Point{ .x = 0, .y = 0 }} ** 4,
        };

        var it = tokenize(u8, data, "\r\n");

        while (it.next()) |line| {
            if (grid.w == 0) {
                grid.w = @intCast(isize, line.len);
            }

            assert(grid.w == line.len);
            grid.h += 1;

            for (line) |c| {
                try grid.grid.append(c - '0');
                try grid.hist.append(false);
            }
        }

        return grid;
    }

    fn index(self: Grid, p: Point) usize {
        return @intCast(usize, p.x + p.y * self.w);
    }

    fn value(self: Grid, p: Point) u8 {
        return self.grid.items[self.index(p)];
    }

    fn neighbors(self: *Grid, i: isize, j: isize) []Point {
        const l = i - 1;
        const r = i + 1;
        const t = j - 1;
        const b = j + 1;

        var result: []Point = self.buffer[0..];
        var idx: usize = 0;

        if (l >= 0) {
            result[idx] = Point{ .x = l, .y = j };
            idx += 1;
        }
        if (r < self.w) {
            result[idx] = Point{ .x = r, .y = j };
            idx += 1;
        }
        if (t >= 0) {
            result[idx] = Point{ .x = i, .y = t };
            idx += 1;
        }
        if (b < self.h) {
            result[idx] = Point{ .x = i, .y = b };
            idx += 1;
        }

        result.len = idx;
        return result;
    }

    fn visited(self: Grid, p: Point) bool {
        return self.hist.items[self.index(p)];
    }

    fn visit(self: *Grid, p: Point) void {
        self.hist.items[self.index(p)] = true;
    }

    fn floodFill(self: *Grid, i: isize, j: isize) u32 {
        var result: u32 = 0;
        self.floodFillRecurse(Point{ .x = i, .y = j }, &result);
        return result;
    }

    fn floodFillRecurse(self: *Grid, p: Point, result: *u32) void {
        self.visit(p);
        result.* += 1;

        const neighs_tmp = self.neighbors(p.x, p.y);
        var neighs = [_]Point{Point{ .x = 0, .y = 0 }} ** 4;
        std.mem.copy(Point, neighs[0..], neighs_tmp);

        for (neighs) |neigh| {
            if (!self.visited(neigh) and self.value(neigh) != 9) {
                self.floodFillRecurse(neigh, result);
            }
        }
    }
};

// Useful stdlib functions
const tokenize = std.mem.tokenize;
const split = std.mem.split;
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
