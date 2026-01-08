package main

import "fmt"

func add(x int, y int) int      { return x + y }
func multiply(x int, y int) int { return x * y }

func action(n1 int, n2 int, operation func(int, int) int) {

	result := operation(n1, n2)
	fmt.Println(result)
}

func display(message string) {
	fmt.Println(message)
}

func main() {

	f := add             //или так var f func(int, int) int = add
	fmt.Println(f(3, 4)) // 7

	f = multiply         // теперь переменная f указывает на функцию multiply
	fmt.Println(f(3, 4)) // 12

	// f = display      // ошибка, так как функция display имеет тип func(string)

	var f1 func(string) = display // норм
	f1("hello")

	// ----
	action(10, 25, add)    // 35
	action(5, 6, multiply) // 30
}
