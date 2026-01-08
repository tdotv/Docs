package main

import "fmt"

func main() {
	str := "Hello"
	for index, value := range str {
		fmt.Println("Index:", index, " Value:", value)
	}

	for index, value := range str {
		fmt.Printf("Index: %d, Value: %c\n", index, value)
	}

	var users = [3]string{"Tom", "Alice", "Kate"}
	for index, value := range users {
		fmt.Println(index, value)
	}

	for i := 0; i < len(users); i++ {
		fmt.Println(users[i])
	}

	var numbers = [10]int{1, -2, 3, -4, 5, -6, -7, 8, -9, 10}
	var sum = 0

	for _, value := range numbers {
		if value < 0 {
			continue // переходим к следующей итерации
		}
		sum += value
	}
	fmt.Println("Sum:", sum) // Sum: 27

OuterLoop:
	for i := 1; i <= 3; i++ {
		for j := 1; j <= 3; j++ {

			fmt.Printf("i = %d, j = %d\n", i, j)

			if i == 2 && j == 2 {

				fmt.Println("Выход из внешнего цикла...")

				break OuterLoop // выходим из внешнего цикла
			}
		}
	}

	fmt.Println("Цикл завершен...")
}
