use std::collections::HashMap;

#[aoc_generator(day21)]
pub fn input_generator(input: &str) -> Vec<usize> {
    input
        .lines()
        .map(|x| x.chars().last().unwrap().to_digit(10).unwrap() as usize)
        .collect()
}

#[aoc(day21, part1)]
pub fn part1(input: &[usize]) -> usize {
    play_game(input, 1000)
}

#[aoc(day21, part2)]
pub fn part2(input: &[usize]) -> usize {
    let mut cache = HashMap::new();
    let scores = vec![0, 0];
    let results = play_quantum(input, &scores, 0, 21, &mut cache);
    results.1.max(results.0)
}

fn play_game(players: &[usize], goal: usize) -> usize {
    let mut players = players.to_owned();
    let mut num_rolls = 0;
    let mut scores = vec![0, 0];

    for (iterator, x) in std::iter::repeat((1..=100).map(|x| x as usize))
        .take(2000)
        .flatten()
        .collect::<Vec<usize>>()
        .chunks(3)
        .enumerate()
    {
        num_rolls += 3;
        let sum = x.iter().sum::<usize>();
        let player = iterator % players.len();

        players[player] = move_player(players[player], sum);
        scores[player] = increase_score(scores[player], players[player]);

        if check_for_win(scores[player], goal) {
            break;
        }
    }
    scores.iter().min().unwrap() * num_rolls
}

fn play_quantum(
    players: &[usize],
    scores: &[usize],
    current_player: usize,
    goal: usize,
    cache: &mut HashMap<(usize, usize, usize, usize, usize), (usize, usize)>,
) -> (usize, usize) {
    let players = players.to_owned();
    let scores = scores.to_owned();
    let mut result = (0, 0);

    if let Some(result) = cache.get(&(players[0], players[1], scores[0], scores[1], current_player))
    {
        return *result;
    }

    match get_winner(&scores, goal) {
        Winner::Player1 => {
            cache
                .entry((players[0], players[1], scores[0], scores[1], current_player))
                .or_insert((1, 0));
            result.0 = 1;
            return result;
        }
        Winner::Player2 => {
            cache
                .entry((players[0], players[1], scores[0], scores[1], current_player))
                .or_insert((0, 1));
            result.1 = 1;
            return result;
        }
        Winner::None => {}
    }

    // player rolls the die 3 times, idiot;
    for x in 1..=3 {
        for y in 1..=3 {
            for z in 1..=3 {
                let mut tmp = players.clone();
                tmp[current_player] = move_player(tmp[current_player], x + y + z);

                let mut tmp_scores = scores.clone();
                tmp_scores[current_player] =
                    increase_score(tmp_scores[current_player], tmp[current_player]);
                let temp = play_quantum(
                    &tmp,
                    &tmp_scores,
                    (current_player + 1) % players.len(),
                    goal,
                    cache,
                );
                result.0 += temp.0;
                result.1 += temp.1;
            }
        }
    }

    cache
        .entry((players[0], players[1], scores[0], scores[1], current_player))
        .or_insert(result);
    result
}

pub enum Winner {
    Player1,
    Player2,
    None,
}

pub fn get_winner(scores: &[usize], goal: usize) -> Winner {
    if scores[0] >= goal {
        Winner::Player1
    } else if scores[1] >= goal {
        Winner::Player2
    } else {
        Winner::None
    }
}

pub fn move_player(position: usize, distance: usize) -> usize {
    let movement = distance % 10;
    let mut position = (position + movement) % 10;
    if position == 0 {
        position = 10;
    }
    position
}

pub fn increase_score(score: usize, position: usize) -> usize {
    score + position
}

pub fn check_for_win(score: usize, goal: usize) -> bool {
    score >= goal
}

#[cfg(test)]
mod tests {
    use super::*;

    const INPUT: &str = r"Player 1 starting position: 4
Player 2 starting position: 8
";

    #[test]
    fn test_part1() {
        let input = input_generator(INPUT);
        assert_eq!(part1(&input), 739785);
    }

    #[test]
    fn test_part2() {
        let input = input_generator(INPUT);
        assert_eq!(part2(&input), 444356092776315);
    }
}
