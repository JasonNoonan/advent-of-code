#[aoc_generator(day7)]
pub fn input_generator(input: &str) -> Vec<i32> {
    input
        .split(',')
        .map(|x| x.parse::<i32>().unwrap())
        .collect()
}

#[aoc(day7, part1)]
pub fn part1(input: &[i32]) -> i32 {
    let mut fuel_cost_vec = Vec::new();
    for i in 0..input.len() {
        let cost = input
            .iter()
            .fold(0, |fuel_cost, crab| fuel_cost + (crab - input[i]).abs());

        fuel_cost_vec.push(cost);
    }

    *fuel_cost_vec.iter().min().unwrap()
}

#[aoc(day7, part2)]
pub fn part2(input: &[i32]) -> i32 {
    let mut fuel_cost_vec = Vec::new();
    let max = *input.iter().max().unwrap();

    for i in 0..max {
        let cost = input.iter().fold(0, |fuel_cost, crab| {
            let distance = (crab - i).abs();

            let cost = distance * (distance + 1) / 2;
            fuel_cost + cost
        });

        fuel_cost_vec.push(cost);
    }

    *fuel_cost_vec.iter().min().unwrap()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part1() {
        let input = input_generator("16,1,2,0,4,2,7,1,2,14");
        assert_eq!(part1(&input), 37);
    }

    #[test]
    fn test_part2() {
        let input = input_generator("16,1,2,0,4,2,7,1,2,14");
        assert_eq!(part2(&input), 168);
    }
}
