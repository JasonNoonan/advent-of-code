#[aoc(day11, part1)]
pub fn part1(input: &str) -> u32 {
    let mut result: Vec<Vec<u32>> = Vec::new();
    input.lines().for_each(|line| {
        let mut row: Vec<u32> = Vec::new();
        line.chars()
            .map(|c| c.to_digit(10).unwrap())
            .for_each(|c| row.push(c));
        result.push(row);
    });
    calculate_flashes(&mut result, 100)
}

pub fn part2(input: &str) -> u32 {
    let mut result: Vec<Vec<u32>> = Vec::new();
    input.lines().for_each(|line| {
        let mut row: Vec<u32> = Vec::new();
        line.chars()
            .map(|c| c.to_digit(10).unwrap())
            .for_each(|c| row.push(c));
        result.push(row);
    });

    0
}

fn calculate_flashes(input: &mut [Vec<u32>], steps: u32) -> u32 {
    let mut count: u32 = 0;
    for _ in 0..steps {
        for y in 0..input.len() {
            for x in 0..input[y].len() {
                increment_point(input, x, y);
            }
        }

        for y in 0..input.len() {
            for x in 0..input[y].len() {
                if input[y][x] >= 10 {
                    count += 1;
                    input[y][x] = 0;
                }
            }
        }
    }
    count
}

fn increment_point(input: &mut [Vec<u32>], x: usize, y: usize) {
    input[y][x] += 1;
    if input[y][x] == 10 {
        get_adjacent_points(input, x, y)
            .iter()
            .for_each(|p| increment_point(input, p.0, p.1))
    }
}

fn get_adjacent_points(input: &[Vec<u32>], x: usize, y: usize) -> Vec<(usize, usize)> {
    let mut result: Vec<(usize, usize)> = Vec::new();
    if x > 0 {
        result.push((x - 1, y));
    }
    if x < input[y].len() - 1 {
        result.push((x + 1, y));
    }
    if y > 0 {
        result.push((x, y - 1));
    }
    if y < input.len() - 1 {
        result.push((x, y + 1));
    }
    if x > 0 && y > 0 {
        result.push((x - 1, y - 1));
    }
    if x < input[y].len() - 1 && y > 0 {
        result.push((x + 1, y - 1));
    }
    if x > 0 && y < input.len() - 1 {
        result.push((x - 1, y + 1));
    }
    if x < input[y].len() - 1 && y < input.len() - 1 {
        result.push((x + 1, y + 1));
    }
    result
}

#[cfg(test)]
mod tests {
    use super::*;

    const INPUT: &str = r"5483143223
2745854711
5264556173
6141336146
6357385478
4167524645
2176841721
6882881134
4846848554
5283751526
";

    #[test]
    fn test_part1() {
        let mut input = generate_input(INPUT);
        assert_eq!(part1(&mut input), 1656);
    }
}
