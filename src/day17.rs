#[derive(Debug, Clone)]
pub struct Point {
    x: isize,
    y: isize,
}

#[derive(Debug, Clone)]
pub struct Probe {
    pub x: isize,
    pub y: isize,
    pub vel_x: isize,
    pub vel_y: isize,
    pub steps: Vec<Point>,
}

impl Probe {
    pub fn new(vel_x: isize, vel_y: isize) -> Probe {
        Probe {
            x: 0,
            y: 0,
            vel_x,
            vel_y,
            steps: vec![],
        }
    }

    pub fn step(&mut self) {
        self.x += self.vel_x;
        self.y += self.vel_y;

        let _ = &self.steps.push(Point {
            x: self.x,
            y: self.y,
        });

        // we only start with positive X velocities
        if self.vel_x > 0 {
            self.vel_x -= 1;
        }

        self.vel_y -= 1;
    }

    pub fn check(&mut self, other: &Target) -> bool {
        if self.x >= other.x_min
            && self.x <= other.x_max
            && self.y >= other.y_min
            && self.y <= other.y_max
        {
            return true;
        }

        false
    }

    pub fn fire(&mut self, other: &Target) -> isize {
        loop {
            self.step();
            if self.check(other) {
                return self.steps.iter().map(|p| p.y).max().unwrap() as isize;
            }

            if other.x_max < self.x || self.y < other.y_min {
                return i64::MAX as isize;
            }
        }
    }
}

#[derive(Debug)]
pub struct Target {
    pub x_max: isize,
    pub x_min: isize,
    pub y_max: isize,
    pub y_min: isize,
}

#[aoc_generator(day17)]
pub fn input_generator(input: &str) -> Target {
    let input = input
        .trim()
        .replace("target area: x=", "")
        .replace(" y=", "");

    let splits = input.split(',').collect::<Vec<&str>>();
    let xsplit: Vec<&str> = splits[0].split("..").collect();
    let ysplit: Vec<&str> = splits[1].split("..").collect();

    Target {
        x_max: xsplit[1].parse::<isize>().unwrap(),
        x_min: xsplit[0].parse::<isize>().unwrap(),
        y_max: ysplit[1].parse::<isize>().unwrap(),
        y_min: ysplit[0].parse::<isize>().unwrap(),
    }
}

#[aoc(day17, part1)]
pub fn part1(target: &Target) -> isize {
    *aim_and_fire(target, 100, -100).iter().max().unwrap()
}

#[aoc(day17, part2)]
pub fn part2(target: &Target) -> isize {
    aim_and_fire(target, 500, -500).len() as isize
}

fn aim_and_fire(target: &Target, max: isize, min: isize) -> Vec<isize> {
    let mut probes = Vec::new();

    // don't shoot behind us...
    for vel_x in 0..max {
        for vel_y in min..max {
            probes.push(Probe::new(vel_x, vel_y));
        }
    }

    probes
        .iter_mut()
        .filter_map(|p| {
            let result = p.fire(target);
            if result != i64::MAX as isize {
                Some(result)
            } else {
                None
            }
        })
        .collect::<Vec<isize>>()
}

#[cfg(test)]
mod tests {
    use super::*;

    const INPUT: &str = r"target area: x=20..30, y=-10..-5
    ";

    #[test]
    fn test_part1() {
        let input = input_generator(INPUT);
        assert_eq!(part1(&input), 45);
    }

    #[test]
    fn test_part2() {
        let input = input_generator(INPUT);
        assert_eq!(part2(&input), 112);
    }
}
