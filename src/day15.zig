const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const Set = Map(usize, void);

const util = @import("util.zig");
const gpa = util.gpa;

// const data = @embedFile("../data/day15-tst.txt");
const data = @embedFile("../data/day15.txt");

var grid: List(u8) = undefined;
var width: usize = 0;
var height: usize = 0;

pub fn main() !void {
    var initial_grid = List(u8).init(gpa);
    var it = tokenize(u8, data, "\r\n");

    width = 0;
    height = 0;

    while (it.next()) |line| : (height += 1) {
        width = line.len;
        for (line) |c| {
            try initial_grid.append(c - '0');
        }
    }

    // Part1
    // grid = expandMap(initial_grid.items[0..], &width, &height, 1);
    // Part2
    grid = expandMap(initial_grid.items[0..], &width, &height, 5);

    // Dijkstra
    var distances_array = try List(usize).initCapacity(gpa, grid.items.len);
    try distances_array.resize(grid.items.len);

    var visitable = Set.init(gpa);

    for (distances_array.items) |_, i| {
        try visitable.put(i, {});
    }

    // Work on the slice
    var distances = distances_array.items;
    std.mem.set(usize, distances, std.math.maxInt(usize));
    // Distance for a to a is 0
    distances[0] = 0;

    while (visitable.count() > 0) {
        var next = nextToVisit(distances, visitable);

        var buffer = [_]usize{0} ** 4;
        var neighbors = util.getNeighborIndices(next, width, height, buffer[0..]);

        var this_cost = distances[next];
        for (neighbors) |idx| {
            var neighbor_cost = grid.items[idx];
            if (neighbor_cost + this_cost < distances[idx]) {
                distances[idx] = neighbor_cost + this_cost;
            }
        }

        _ = visitable.remove(next);
    }

    print("{}\n", .{distances[distances.len - 1]});
}

fn nextToVisit(distances: []usize, visitable: Map(usize, void)) usize {
    var minv: usize = std.math.maxInt(usize);
    var mini: usize = 0;

    var it = visitable.keyIterator();
    while (it.next()) |i| {
        if (minv > distances[i.*]) {
            mini = i.*;
            minv = distances[i.*];
        }
    }

    return mini;
}

fn expandMap(initial_grid: []u8, w: *usize, h: *usize, mult: usize) List(u8) {
    var new_w = w.* * mult;
    var new_h = h.* * mult;

    var new_grid = List(u8).init(gpa);
    new_grid.resize(new_w * new_h) catch unreachable;

    var j: usize = 0;
    while (j < h.*) : (j += 1) {
        var i: usize = 0;

        while (i < w.*) : (i += 1) {
            var value = initial_grid[i + j * w.*];

            for (util.range(mult)) |_, n| {
                var new_value_y = value + @intCast(u8, n);
                if (new_value_y > 9) new_value_y = @mod(new_value_y, 10) + 1;

                for (util.range(mult)) |_, m| {
                    var new_value_x = new_value_y + @intCast(u8, m);
                    if (new_value_x > 9) new_value_x = @mod(new_value_x, 10) + 1;
                    var x = i + m * w.*;
                    var y = j + n * h.*;

                    new_grid.items[x + y * new_w] = new_value_x;
                }
            }
        }
    }

    w.* = new_w;
    h.* = new_h;

    return new_grid;
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
