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

#[aoc(day9, part1)]
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

#[aoc(day9, part2)]
pub fn part2(input: &[Vec<u32>]) -> u32 {
    let low_points = find_low_points(input);
    let mut basins: Vec<u32> = Vec::new();

    for point in low_points {
        // starting at low point, spread out in all directions from each adjacent point
        let mut basin_points: HashMap<(usize, usize), u32> = HashMap::new();
        basin_points.insert(point, input[point.0][point.1]);

        for root_point in get_adjacent_points(input, point.0, point.1, false) {
            let mut adjacent_points: Vec<(usize, usize)> =
                get_adjacent_points(input, root_point.0, root_point.1, false);
            while !adjacent_points.is_empty() {
                for p in adjacent_points.clone().iter() {
                    for inner_p in get_adjacent_points(input, p.0, p.1, false) {
                        if let std::collections::hash_map::Entry::Vacant(e) =
                            basin_points.entry(inner_p)
                        {
                            e.insert(input[inner_p.0][inner_p.1]);
                            adjacent_points.push(inner_p);
                        } else {
                            adjacent_points.retain(|x| x != p);
                        }
                    }
                }
            }
        }

        basins.push(basin_points.len() as u32);
    }

    basins.sort_unstable();

    let mut result = 1;

    basins[basins.len() - 3..basins.len()].iter().for_each(|x| {
        result *= *x;
    });

    result
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

    #[test]
    fn test_part2() {
        let input = input_generator(INPUT);
        assert_eq!(part2(&input), 1134);
    }
}
