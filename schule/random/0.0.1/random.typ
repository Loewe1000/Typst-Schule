// note: true random behaviour is not possible, and this implementation isn't even state of the art, but 

#let default_seed = 42


// an implementation of minstd_rand
// equivalent to minstd_rand
#let m = calc.pow(2, 32) - 1 // m is lowered to 2^16 - 1 to provide more randomness at lower values
#let a = 48271

#let lcg(seed, steps: 100) = {
    // linear congruent generator
    // lehmer implementation
    for i in range(steps) { seed = calc.rem(seed * a, m) }
    seed / m
}

// random number in [0, 1), experimentally tested for low seeds of <= 10000
// uses minstd but consistently far more random, particularly for small seeds
// Produces Z statistics averaging around Z = 0.6
// i.e. numbers from the model can be detected as non-random with less than 75%
// confidence. For comparison, Python's built-in random generator performs
// roughly the same.
#let low_cminstd_rand(seed: default_seed) = {
    let new_seed = calc.rem(calc.floor(calc.pow(2, 31) * lcg(seed)) + 1, m)
    let steps = calc.floor(lcg(seed, steps: 99) * 100) + 50 // between 50 and 150 steps
    return lcg(new_seed, steps: steps)
}

// produces a random integer from start to end, inclusive of start and end.
// if no start is specified, it is assumed to be 0. If no end is specified, it is assumed to be 10
#let low_cminstd_randint(start, end, seed: default_seed) = {
    let dist = end - start + 1
    let rand = calc.floor(dist * low_cminstd_rand(seed: seed))
    return rand + start
}

// INTERFACE: generates n random numbers in [0, 1) using the previous random number as next seed, to create relatively unpredictable patterns
// use this array when you want to generate multiple random numbers
#let step_seed(cur_seed) = {
    return calc.rem(low_cminstd_randint(1, calc.pow(2, 31) * lcg(cur_seed)) + 1, m)
}

// takes in an array and outputs a random permutation of the array.
#let fisher_yates_shuffle(arr, seed) = {
    let new_array = ()
    let inseed = seed
    while arr.len() > 0 {
        inseed = step_seed(inseed)
        new_array.push(arr.remove(low_cminstd_randint(0, arr.len() - 1, seed: inseed)))
    }
    new_array
}

// INTERFACES: will remain the same even as implementations change so that improvements can be made without any breakage. Try to only use these functions, so that you don't expose your code to any breaking changes.

#let rand(seed) = low_cminstd_rand(seed: seed)
#let randint(start, end, seed) = low_cminstd_randint(start, end, seed: seed)
#let shuffle(arr, seed) = fisher_yates_shuffle(arr, seed)
