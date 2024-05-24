def generate_random_list(length, min_val=0, max_val=100):
    """
    Generates a random list of integers.

    Args:
        length (int): The length of the list.
        min_val (int): The minimum value of the integers (default is 0).
        max_val (int): The maximum value of the integers (default is 100).

    Returns:
        list: A list of random integers.
    """
    import random
    random_list = [random.randint(min_val, max_val) for _ in range(length)]
    return random_list

def median_absolute_deviation(numbers):
    """
    Calculates the median absolute deviation (MAD) of a list of numbers.

    Args:
    numbers (list): A list of numerical values.

    Returns:
    float: The median absolute deviation (MAD).
    """
    if not numbers:
        return None

    # Calculate median
    sorted_numbers = sorted(numbers)
    n = len(sorted_numbers)
    if n % 2 == 0:
        median = (sorted_numbers[n//2 - 1] + sorted_numbers[n//2]) / 2
    else:
        median = sorted_numbers[n//2]

    # Calculate absolute deviations from median
    absolute_deviations = [abs(x - median) for x in numbers]

    # Calculate MAD
    mad = sorted(absolute_deviations)[len(absolute_deviations) // 2]

    return mad