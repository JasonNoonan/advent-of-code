#[aoc_generator(day6)]
pub fn input_generator(input: &str) -> Vec<i32> {
    input
        .trim()
        .split(',')
        .map(|x| x.parse::<i32>().unwrap())
        .collect()
}

#[aoc(day6, part1)]
pub fn part1(input: &[i32]) -> i32 {
    calculate_life_cycle(input, 80)
}

pub fn calculate_life_cycle(input: &[i32], cycles: i32) -> i32 {
    let mut tracker: Vec<i32> = input.to_vec();
    for _ in 0..cycles {
        tracker = advance_cycle(&tracker);
    }

    tracker.len() as i32
}

fn advance_cycle(input: &[i32]) -> Vec<i32> {
    let mut response: Vec<i32> = Vec::new();

    input.iter().for_each(|x| {
        if *x == 0 {
            response.push(8);
            response.push(6);
        } else {
            response.push(x - 1);
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
}
