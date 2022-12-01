use regex::Regex;

pub struct Command {
    pub direction: String,
    pub distance: u32,
}

#[aoc_generator(day2)]
pub fn input_generator(input: &str) -> Vec<Command> {
    let regex = Regex::new(r"(\w+) (\d+)").unwrap();
    input
        .lines()
        .map(|line| {
            let captures = regex.captures(line).unwrap();
            Command {
                direction: captures[1].to_string(),
                distance: captures[2].parse::<u32>().unwrap(),
            }
        })
        .collect()
}

#[aoc(day2, part1)]
pub fn part1(input: &[Command]) -> u32 {
    let mut horizontal: u32 = 0;
    let mut depth: u32 = 0;
    for c in input.iter() {
        match c.direction.as_str() {
            "forward" => {
                horizontal += c.distance;
            }
            "up" => {
                depth -= c.distance;
            }
            "down" => {
                depth += c.distance;
            }
            _ => panic!("Unknown direction"),
        }
    }

    horizontal * depth
}

#[aoc(day2, part2)]
pub fn part2(input: &[Command]) -> u32 {
    let mut horizontal: u32 = 0;
    let mut depth: u32 = 0;
    let mut aim: u32 = 0;

    for c in input.iter() {
        match c.direction.as_str() {
            "forward" => {
                horizontal += c.distance;
                depth += aim * c.distance;
            }
            "up" => {
                aim -= c.distance;
            }
            "down" => {
                aim += c.distance;
            }
            _ => panic!("Unknown direction"),
        }
    }

    horizontal * depth
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part1() {
        let input = input_generator("forward 5\ndown 5\nforward 8\nup 3\ndown 8\nforward 2\n");
        assert_eq!(part1(&input), 150);
    }

    #[test]
    fn test_part2() {
        let input = input_generator("forward 5\ndown 5\nforward 8\nup 3\ndown 8\nforward 2\n");
        assert_eq!(part2(&input), 900);
    }
}
