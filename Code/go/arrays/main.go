package main

import "fmt"

func main() {
	var numbers = [...]int{1, 2, 3, 4, 5} // длина массива 5
	numbers2 := [...]int{1, 2, 3}         // длина массива 3
	fmt.Println(numbers)                  // [1 2 3 4 5]
	fmt.Println(numbers2)                 // [1 2 3]

	// ---
	var new_numbers [5]int = [5]int{1, 2, 3, 4, 5}
	fmt.Println(new_numbers[0]) // 1
	fmt.Println(new_numbers[4]) // 5
	new_numbers[0] = 87
	fmt.Println(new_numbers[0]) // 87

	// ---
	array := [3][2]int{
		{1, 2},
		{4, 5},
		{7, 8},
	}
	fmt.Println(array) // [[1 2] [4 5] [7 8]]
	fmt.Println("Numbers length:", len(numbers))
	fmt.Println("Numbers length:", len(new_numbers))
	fmt.Println("Numbers length:", len(array))

	// ---
	nums1 := [4]int{3, 4, 5, 6}
	nums2 := [4]int{3, 4, 5}

	fmt.Println("nums1 == nums2:", nums1 == nums2) // false

	nums3 := [3][2]int{{2}, {5}}
	nums4 := [3][2]int{{2, 1}, {5}}
	fmt.Println("nums3 == nums4:", nums3 == nums4) // false

	nums5 := [4]int{3, 4, 5, 0}
	fmt.Println("nums2 == nums5:", nums2 == nums5) // true

}
