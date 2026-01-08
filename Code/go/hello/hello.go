package main

import "fmt"

func main() {
	fmt.Println("bububu")

	var hello1 string
	hello1 = "Hello world"
	fmt.Println(hello1)

	var hello2 string = "Hello world"
	fmt.Println(hello2)

	var (
		name string = "Tom"
		age  int    = 27
	)

	fmt.Println(name)
	fmt.Println(age)

}
