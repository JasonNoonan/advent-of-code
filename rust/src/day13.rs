use std::collections::HashSet;

#[derive(Debug, Clone)]
pub struct Page {
    pub points: HashSet<Point>,
    pub folds: Vec<Fold>,
}

impl Page {
    pub fn fold_page(&self, fold: &Fold) -> Page {
        let mut past_fold: HashSet<Point> = HashSet::new();
        let direction = &fold.direction;
        let location = &fold.location;

        self.points.iter().for_each(|point| {
            if (direction == "x" && point.x >= *location)
                || (direction == "y" && point.y >= *location)
            {
                let _ = past_fold.insert(point.clone());
            }
        });

        let mut page = Page {
            points: self.points.clone(),
            folds: self.folds.clone(),
        };

        for point in past_fold.iter() {
            page.points.remove(point);
            let x = point.x;
            let y = point.y;

            if direction == "x" {
                page.points.insert(Point {
                    x: *location - (x - *location),
                    y,
                });
            } else {
                page.points.insert(Point {
                    x,
                    y: *location - (y - *location),
                });
            }
        }

        page
    }

    pub fn display_page(&self) {
        let mut max_x = 0;
        let mut max_y = 0;

        self.points.iter().for_each(|point| {
            if point.x > max_x {
                max_x = point.x;
            }
            if point.y > max_y {
                max_y = point.y;
            }
        });

        let mut display_vec = vec![vec!['.'; max_x + 1]; max_y + 1];
        for point in self.points.iter() {
            display_vec[point.y as usize][point.x as usize] = '#';
        }

        for y in 0..=max_y {
            for x in 0..=max_x {
                print!("{}", display_vec[y][x]);
            }
            println!();
        }
    }
}

#[derive(Hash, Eq, PartialEq, Debug, Clone)]
pub struct Point {
    pub x: usize,
    pub y: usize,
}

#[derive(Debug, Clone)]
pub struct Fold {
    pub direction: String,
    pub location: usize,
}

#[aoc_generator(day13)]
pub fn input_generator(input: &str) -> Page {
    let mut page = Page {
        points: HashSet::new(),
        folds: Vec::new(),
    };

    input.lines().for_each(|line| {
        if line.starts_with("fold") {
            let line = line.replace("fold along ", "");
            let mut fold = line.split('=');
            page.folds.push(Fold {
                direction: fold.next().unwrap().to_string(),
                location: fold.next().unwrap().parse().unwrap(),
            })
        } else if !line.is_empty() {
            let mut point = line.split(',');
            page.points.insert(Point {
                x: point.next().unwrap().parse().unwrap(),
                y: point.next().unwrap().parse().unwrap(),
            });
        }
    });

    page
}

#[aoc(day13, part1)]
pub fn part1(input: &Page) -> u32 {
    let fold = &input.folds[0].clone();
    let page = input.fold_page(fold);

    page.points.len() as u32
}

#[aoc(day13, part2)]
pub fn part2(input: &Page) -> u32 {
    let mut page = input.clone();
    for fold in input.folds.iter() {
        page = page.fold_page(fold);
    }

    page.display_page();
    page.points.len() as u32
}

#[cfg(test)]
mod tests {
    use super::*;

    const INPUT: &str = r"6,10
0,14
9,10
0,3
10,4
4,11
6,0
6,12
4,1
0,13
10,12
3,4
3,0
8,4
1,10
2,14
8,10
9,0

fold along y=7
fold along x=5
";

    #[test]
    fn test_part1() {
        let input = input_generator(INPUT);
        assert_eq!(part1(&input), 17);
    }

    #[test]
    fn test_part2() {
        let input = input_generator(INPUT);
        assert_eq!(part2(&input), 16);
    }
}
