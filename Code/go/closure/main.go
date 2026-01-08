package main

import "fmt"

func outer() func() { // внешняя функция
	var n int = 5     // некоторая переменная - лексическое окружение функции inner
	inner := func() { // вложенная функция
		// действия с переменной n
		n += 1
		fmt.Println(n)
	}
	return inner
}

func main() {

	fn := outer() // fn = inner, так как функция outer возвращает функцию inner
	// вызываем внутреннюю функцию inner
	fn() // 6
	fn() // 7
	fn() // 8
}
