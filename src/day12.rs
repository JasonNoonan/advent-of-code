use std::collections::{HashMap, HashSet};

pub struct System {
    // The name of the cave, and a bool to indicate if it is a small cave
    pub nodes: HashMap<String, bool>,
    // list all known connections from each cave
    // use a HashSet so that we only keep unique list of connected nodes
    pub paths: HashMap<String, HashSet<String>>,
}

#[aoc_generator(day12)]
pub fn input_generator(input: &str) -> System {
    let mut system = System {
        nodes: HashMap::new(),
        paths: HashMap::new(),
    };
    input.lines().for_each(|line| {
        let mut split = line.split('-');
        let parent = split.next().unwrap().to_string();
        let child = split.next().unwrap().to_string();

        system
            .nodes
            .insert(parent.to_owned(), parent.to_lowercase() == parent);
        system
            .nodes
            .insert(child.to_owned(), child.to_lowercase() == child);
        system
            .paths
            .entry(parent.to_owned())
            .or_default()
            .insert(child.to_owned());
        system.paths.entry(child).or_default().insert(parent);
    });
    system
}

#[aoc(day12, part1)]
pub fn part1(input: &System) -> u32 {
    let visited = HashSet::new();
    check_paths(input, &visited, "start".to_string())
}

fn check_paths(system: &System, visited: &HashSet<String>, source: String) -> u32 {
    // we have visited this room before
    if visited.contains(&source) {
        // and it is a small room
        if *system.nodes.get(&source).unwrap() {
            return 0;
        }
    }

    // we found the end!
    if source == "end" {
        return 1;
    }

    let mut local_visited = visited.clone();
    local_visited.insert(source.to_owned());

    system
        .paths
        .get(&source)
        .unwrap()
        .iter()
        .map(|child| check_paths(system, &local_visited, child.to_string()))
        .sum()
}

#[cfg(test)]
mod tests {
    use super::*;

    const INPUT: &str = r"fs-end
he-DX
fs-he
start-DX
pj-DX
end-zg
zg-sl
zg-pj
pj-he
RW-he
fs-DX
pj-RW
zg-RW
start-pj
he-WI
zg-he
pj-fs
start-RW
";

    #[test]
    fn test_part1() {
        let input = input_generator(INPUT);
        assert_eq!(part1(input), 226);
    }
}
