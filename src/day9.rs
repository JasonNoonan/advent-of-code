use std::collections::HashMap;

#[aoc_generator(day9)]
pub fn input_generator(input: &str) -> Vec<Vec<u32>> {
    let mut input_vec: Vec<Vec<u32>> = Vec::new();
    let input_str: Vec<String> = input.lines().map(|x| x.to_string()).collect();
    for line in input_str {
        let mut line_vec: Vec<u32> = Vec::new();
        for num in line.chars() {
            line_vec.push(num.to_string().parse::<u32>().unwrap());
        }
        input_vec.push(line_vec);
    }
    input_vec
}

// #[aoc(day9, part1)]
pub fn part1(input: &[Vec<u32>]) -> u32 {
    let mut risk_level = 0;
    let low_points = find_low_points(input);
    for p in low_points {
        risk_level += 1 + input[p.0][p.1];
    }
    risk_level
}

fn find_low_points(input: &[Vec<u32>]) -> Vec<(usize, usize)> {
    let mut low_points: Vec<(usize, usize)> = Vec::new();

    for y in 0..input.len() {
        for x in 0..input[y].len() {
            let mut adjacent_heights: Vec<u32> = Vec::new();
            let current_height = input[y][x];
            let adjacent_points = get_adjacent_points(input, y, x, true);
            for point in adjacent_points {
                adjacent_heights.push(input[point.0][point.1]);
            }

            adjacent_heights.sort_unstable();
            if current_height < adjacent_heights[0] {
                low_points.push((y, x));
            }
        }
    }

    low_points
}

fn get_adjacent_points(
    input: &[Vec<u32>],
    y: usize,
    x: usize,
    allow_nines: bool,
) -> Vec<(usize, usize)> {
    let mut adjacent_points: Vec<(usize, usize)> = Vec::new();
    if y > 0 && (allow_nines || input[y - 1][x] != 9) {
        adjacent_points.push((y - 1, x));
    }
    if y < input.len() - 1 && (allow_nines || input[y + 1][x] != 9) {
        adjacent_points.push((y + 1, x));
    }
    if x < input[y].len() - 1 && (allow_nines || input[y][x + 1] != 9) {
        adjacent_points.push((y, x + 1));
    }
    if x > 0 && (allow_nines || input[y][x - 1] != 9) {
        adjacent_points.push((y, x - 1));
    }
    adjacent_points
}

pub fn part2(input: &[Vec<u32>]) -> u32 {
    let low_points = find_low_points(input);
    let mut basins: Vec<u32> = Vec::new();

    for point in low_points {
        // starting at low point, spread out in all directions from each adjacent point
        let mut basin_points: HashMap<(usize, usize), u32> = HashMap::new();
    }
    0
}

#[cfg(test)]
mod tests {
    use super::*;

    const INPUT: &str = r"2199943210
3987894921
9856789892
8767896789
9899965678
";

    #[test]
    fn test_part1() {
        let input = input_generator(INPUT);
        assert_eq!(part1(&input), 15);
    }
}
