#[aoc_generator(day1)]
pub fn input_generator(input: &str) -> Vec<i32> {
    input
        .lines()
        .map(|line| line.parse::<i32>().unwrap())
        .collect()
}

#[aoc(day1, part1)]
pub fn part1(input: &[i32]) -> i32 {
    let mut counter = 0;
    for x in 0..input.len() {
        if x > 0 && input[x] > input[x - 1] {
            counter += 1;
        }
    }
    counter
}

#[aoc(day1, part2)]
pub fn part2(input: &[i32]) -> i32 {
    input
        .windows(3)
        .map(|window| window.iter().sum())
        .collect::<Vec<i32>>()
        .windows(2)
        .filter(|window| window[1] > window[0])
        .count() as i32
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part2() {
        let input = input_generator("199\n200\n208\n210\n200\n207\n240\n269\n260\n263\n");
        assert_eq!(part2(&input), 5);
    }
}
