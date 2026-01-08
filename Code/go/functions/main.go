package main

import "fmt"

func main() {
	add(1, 2, 3.4, 5.6, 1.2)
	add_many(1, 2, 3)
	add_many([]int{1, 2, 3}...)

	var a = add_return(1, 2)
	fmt.Println(a)

	fmt.Println(name_add(9, 8))

	var age, name = return_many(4, 5, "Tom", "Simpson")
	fmt.Println(age)  // 9
	fmt.Println(name) // Tom Simpson
}

func add(x, y int, a, b, c float32) {
	var z = x + y
	var d = a + b + c
	fmt.Println("x + y = ", z)
	fmt.Println("a + b + c = ", d)
}

func add_many(numbers ...int) {
	var sum = 0
	for _, number := range numbers {
		sum += number
	}
	fmt.Println("sum = ", sum)
}

func add_return(x, y int) int {
	return x + y
}

func name_add(x, y int) (z int) {
	z = x + y
	return
}

func return_many(x, y int, firstName, lastName string) (int, string) {
	var z int = x + y
	var fullName = firstName + " " + lastName
	return z, fullName
}
