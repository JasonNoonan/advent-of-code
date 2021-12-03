#[aoc(day3, part1)]
pub fn part1(input: &str) -> usize {
    let mut gamma_rate_string: Vec<char> = Vec::new();
    let mut epsilon_rate_string: Vec<char> = Vec::new();
    let list_length = input.lines().count();
    let num_len = input.lines().next().unwrap().len();

    for i in 0..num_len {
        if input
            .lines()
            .filter(|line| line.len() >= num_len)
            .filter(|line| line.chars().nth(i).unwrap() == '0')
            .count()
            > list_length / 2
        {
            gamma_rate_string.push('0');
        } else {
            gamma_rate_string.push('1');
        }
    }

    for c in gamma_rate_string.iter() {
        if *c == '0' {
            epsilon_rate_string.push('1');
        } else {
            epsilon_rate_string.push('0');
        }
    }

    let gamma_rate_string = gamma_rate_string.into_iter().collect::<String>();
    let epsilon_rate_string = epsilon_rate_string.into_iter().collect::<String>();
    let gamma_rate = usize::from_str_radix(&gamma_rate_string, 2).unwrap();
    let epsilon_rate = usize::from_str_radix(&epsilon_rate_string, 2).unwrap();

    gamma_rate * epsilon_rate
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part1() {
        let input = "00100\n11110\n10110\n10111\n01111\n00111\n11100\n10000\n11001\n00010\n01010\n";
        assert_eq!(part1(input), 198);
    }
}
