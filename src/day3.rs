#[aoc(day3, part1, base)]
pub fn part1_base(input: &str) -> usize {
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

#[aoc(day3, part1, updated)]
pub fn part1_updated(input: &str) -> usize {
    let mut gamma_rate_string: Vec<char> = Vec::new();
    let mut epsilon_rate_string: Vec<char> = Vec::new();
    let num_len = input.lines().next().unwrap().len();

    for i in 0..num_len {
        if input
            .trim()
            .lines()
            .filter(|line| line.chars().nth(i).unwrap() == '0')
            .count()
            > input.trim().lines().count() / 2
        {
            gamma_rate_string.push('0');
            epsilon_rate_string.push('1');
        } else {
            gamma_rate_string.push('1');
            epsilon_rate_string.push('0');
        }
    }

    let gamma_rate_string = gamma_rate_string.into_iter().collect::<String>();
    let epsilon_rate_string = epsilon_rate_string.into_iter().collect::<String>();
    let gamma_rate = usize::from_str_radix(&gamma_rate_string, 2).unwrap();
    let epsilon_rate = usize::from_str_radix(&epsilon_rate_string, 2).unwrap();

    gamma_rate * epsilon_rate
}

#[aoc(day3, part2)]
pub fn part2(input: &str) -> usize {
    let mut oxygen_rating_string = input.trim().lines().collect::<Vec<&str>>();
    let mut co2_scrubber_rating_string = input.trim().lines().collect::<Vec<&str>>();
    let num_len = input.lines().next().unwrap().len();
    let mut i = 0;

    while oxygen_rating_string.len() > 1 || co2_scrubber_rating_string.len() > 1 && i < num_len {
        if oxygen_rating_string.len() > 1 {
            let oxygen_bit = calculate_majority_bit(&oxygen_rating_string, i);
            oxygen_rating_string.retain(|line| line.chars().nth(i).unwrap() == oxygen_bit.0);
        }

        if co2_scrubber_rating_string.len() > 1 {
            let co2_bit = calculate_majority_bit(&co2_scrubber_rating_string, i);
            co2_scrubber_rating_string.retain(|line| line.chars().nth(i).unwrap() == co2_bit.1);
        }

        i += 1;
    }

    let oxygen_rating = usize::from_str_radix(oxygen_rating_string[0], 2).unwrap();
    let co2_scrubber_rating = usize::from_str_radix(co2_scrubber_rating_string[0], 2).unwrap();

    println!("{}", oxygen_rating);
    println!("{}", co2_scrubber_rating);

    oxygen_rating * co2_scrubber_rating
}

fn calculate_majority_bit(input: &[&str], i: usize) -> (char, char) {
    let mut response = ('1', '0');

    if input
        .iter()
        .filter(|line| line.chars().nth(i).unwrap() == '0')
        .count()
        > input.len() / 2
    {
        response = ('0', '1');
    }

    response
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part1_base() {
        let input =
            "00100\n11110\n10110\n10111\n10101\n01111\n00111\n11100\n10000\n11001\n00010\n01010\n";
        assert_eq!(part1_base(input), 198);
    }

    #[test]
    fn test_part1_update() {
        let input =
            "00100\n11110\n10110\n10111\n10101\n01111\n00111\n11100\n10000\n11001\n00010\n01010\n";
        assert_eq!(part1_updated(input), 198);
    }

    #[test]
    fn test_part2() {
        let input =
            "00100\n11110\n10110\n10111\n10101\n01111\n00111\n11100\n10000\n11001\n00010\n01010\n";
        assert_eq!(part2(input), 230);
    }
}
