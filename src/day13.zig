const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day13.txt");
// const data = @embedFile("../data/day13-tst.txt");

pub fn main() !void {
    var it = tokenize(u8, data, "\r\n");
    var points = List([2]usize).init(gpa);
    defer points.deinit();

    var folds = List(Fold).init(gpa);
    defer folds.deinit();

    while (it.next()) |line| {
        if (std.mem.startsWith(u8, line, "fold")) {
            var fold_it = tokenize(u8, line, "fold along =");
            var dir = if (fold_it.next().?[0] == 'x') Dir.x else Dir.y;
            var index = try parseInt(usize, fold_it.next().?, 10);

            try folds.append(Fold{ .dir = dir, .index = index });
        } else {
            var points_it = tokenize(u8, line, ",");
            var x = try parseInt(usize, points_it.next().?, 10);
            var y = try parseInt(usize, points_it.next().?, 10);

            try points.append([2]usize{ x, y });
        }
    }

    // Part 1
    fold(&points.items, folds.items[0]);

    var set = Map([2]usize, void).init(gpa);
    defer set.deinit();

    for (points.items) |point| {
        try set.put(point, {});
    }

    print("{}\n", .{set.count()});

    // Part 2
    for (folds.items[1..]) |the_fold| {
        fold(&points.items, the_fold);
    }

    printGrid(points.items);
}

fn cmpValue(_: void, a: [2]usize, b: [2]usize) bool {
    if (a[0] < b[0]) return true;
    if (a[0] > b[0]) return false;
    if (a[1] < b[1]) return true;
    return false;
}

const Dir = enum { x, y };
const Fold = struct {
    dir: Dir,
    index: usize,
};

fn fold(points: *[][2]usize, the_fold: Fold) void {
    var coord: usize = switch (the_fold.dir) {
        .x => 0,
        .y => 1,
    };

    for (points.*) |*point| {
        if (point[coord] > the_fold.index) {
            point[coord] = 2 * the_fold.index - point[coord];
        }
    }

    std.sort.sort([2]usize, points.*, {}, cmpValue);
}

fn printGrid(points: [][2]usize) void {
    var xmax: usize = 0;
    var ymax: usize = 0;

    for (points) |p| {
        xmax = max(p[0], xmax);
        ymax = max(p[1], ymax);
    }

    var grid = List(bool).init(gpa);
    defer grid.deinit();

    grid.resize((xmax + 1) * (ymax + 1)) catch unreachable;

    for (points) |p| {
        var index: usize = p[0] + p[1] * (xmax + 1);
        grid.items[index] = true;
    }

    var y: usize = 0;
    while (y < ymax + 1) : (y += 1) {
        var x: usize = 0;
        while (x < xmax + 1) : (x += 1) {
            var index = x + y * (xmax + 1);
            if (grid.items[index]) {
                print("{c}", .{'#'});
            } else {
                print("{c}", .{'.'});
            }
        }
        print("\n", .{});
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
