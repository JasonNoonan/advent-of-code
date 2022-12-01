#[derive(Debug, PartialEq)]
pub struct Point {
    x: i32,
    y: i32,
}

impl Point {
    fn new(input: &str) -> Point {
        let mut coords = input.split(',');
        Point {
            x: coords.next().unwrap().parse().unwrap(),
            y: coords.next().unwrap().parse().unwrap(),
        }
    }
}

#[aoc_generator(day5, part1)]
pub fn input_generator_part1(input: &str) -> Vec<Point> {
    generator(input, false)
}

#[aoc_generator(day5, part2)]
pub fn input_generator_part2(input: &str) -> Vec<Point> {
    generator(input, true)
}

fn generator(input: &str, diagnols: bool) -> Vec<Point> {
    let input = input.trim();
    input
        .lines()
        .map(|l| l.split(" -> "))
        .fold(Vec::new(), |mut acc, mut l| {
            acc.push(Point::new(l.next().unwrap()));
            acc.push(Point::new(l.next().unwrap()));
            acc
        })
        .chunks(2)
        .fold(Vec::new(), |mut acc, chunk| {
            let start = &chunk[0];
            let end = &chunk[1];

            if start.x == end.x {
                (get_point_range(start.y, end.y))
                    .iter()
                    .for_each(|y| acc.push(Point { x: start.x, y: *y }));
            } else if start.y == end.y {
                (get_point_range(start.x, end.x))
                    .iter()
                    .for_each(|x| acc.push(Point { x: *x, y: start.y }));
            } else if is_positive_slope(get_slope(start, end)) && diagnols {
                // slope of 1 means x increases as y increases
                let x_range = get_point_range(start.x, end.x);
                let y_range = get_point_range(start.y, end.y);
                let mut y = y_range[0];
                x_range.iter().for_each(|x| {
                    acc.push(Point { x: *x, y });
                    y += 1;
                });
            } else if is_negative_slope(get_slope(start, end)) && diagnols {
                // slope of -1 means x decreases as y increases
                let x_range = get_point_range(start.x, end.x);
                let y_range = get_point_range(start.y, end.y);
                let mut y = y_range[0];
                x_range.iter().rev().for_each(|x| {
                    acc.push(Point { x: *x, y });
                    y += 1;
                });
            }
            acc
        })
}

fn get_point_range(point1: i32, point2: i32) -> Vec<i32> {
    if point1 > point2 {
        (point2..=point1).collect::<Vec<i32>>()
    } else {
        (point1..=point2).collect::<Vec<i32>>()
    }
}

fn is_positive_slope(slope: f32) -> bool {
    ((1.0 - f32::EPSILON)..(1.0 + f32::EPSILON)).contains(&slope)
}

fn is_negative_slope(slope: f32) -> bool {
    ((-1.0 - f32::EPSILON)..(-1.0 + f32::EPSILON)).contains(&slope)
}

fn get_slope(point1: &Point, point2: &Point) -> f32 {
    (point2.y - point1.y) as f32 / (point2.x - point1.x) as f32
}

#[aoc(day5, part1)]
pub fn part1(input: &[Point]) -> i32 {
    count_matched_points(input)
}

#[aoc(day5, part2)]
pub fn part2(input: &[Point]) -> i32 {
    count_matched_points(input)
}

fn count_matched_points(input: &[Point]) -> i32 {
    let mut matched_points = Vec::new();
    input.iter().fold(0, |acc, point| {
        if !matched_points.contains(&point) {
            let count = input.iter().filter(|p| *p == point).count() as i32;
            if count > 1 {
                matched_points.push(point);
                acc + 1
            } else {
                acc
            }
        } else {
            acc
        }
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    const INPUT: &str = r"0,9 -> 5,9
8,0 -> 0,8
9,4 -> 3,4
2,2 -> 2,1
7,0 -> 7,4
6,4 -> 2,0
0,9 -> 2,9
3,4 -> 1,4
0,0 -> 8,8
5,5 -> 8,2
";

    #[test]
    fn test_part1() {
        let input = input_generator_part1(INPUT);
        assert_eq!(part1(&input), 5);
    }

    #[test]
    fn test_part2() {
        let input = input_generator_part2(INPUT);
        assert_eq!(part2(&input), 12);
    }
}
