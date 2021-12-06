#[aoc_generator(day6)]
pub fn input_generator(input: &str) -> Vec<i64> {
    let mut tracker = vec![0; 9];

    input.trim().split(',').for_each(|x| {
        let i = x.parse::<usize>().unwrap();
        tracker[i] += 1;
    });

    tracker
}

#[aoc(day6, part1)]
pub fn part1(input: &[i64]) -> i64 {
    calculate_life_cycle(input, 80)
}

#[aoc(day6, part2)]
pub fn part2(input: &[i64]) -> i64 {
    calculate_life_cycle(input, 256)
}

pub fn calculate_life_cycle(input: &[i64], cycles: i32) -> i64 {
    let mut tracker = input.to_vec();
    for _ in 0..cycles {
        tracker = advance_cycle(&tracker);
    }

    let mut sum: i64 = 0;

    tracker.iter().for_each(|x| {
        sum += *x as i64;
    });

    sum
}

fn advance_cycle(input: &[i64]) -> Vec<i64> {
    let mut response: Vec<i64> = vec![0; 9];

    input.iter().enumerate().for_each(|x| {
        if x.0 == 0 {
            response[8] += x.1;
            response[6] += x.1;
        } else {
            response[x.0 - 1] += x.1;
        }
    });

    response
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_calculate_cycles() {
        let input = input_generator("3,4,3,1,2\n");
        assert_eq!(calculate_life_cycle(&input, 18), 26);
    }

    #[test]
    fn test_part2() {
        let input = input_generator("3,4,3,1,2\n");
        assert_eq!(calculate_life_cycle(&input, 256), 26984457539);
    }
}
