package main

import "fmt"

func main() {
	var a int8 = -1
	var b uint8 = 2
	var c byte = 3 // byte - синоним типа uint8
	var d int16 = -4
	var f uint16 = 5
	var g int32 = -6
	var h rune = -7 // rune - синоним типа int32
	var j uint32 = 8
	var k int64 = -9
	var l uint64 = 10
	var m int = 102
	var n uint = 105

	fmt.Println("a: ", a)
	fmt.Println("b: ", b)
	fmt.Println("c: ", c)
	fmt.Println("d: ", d)
	fmt.Println("f: ", f)
	fmt.Println("g: ", g)
	fmt.Println("h: ", h)
	fmt.Println("j: ", j)
	fmt.Println("k: ", k)
	fmt.Println("l: ", l)
	fmt.Println("m: ", m)
	fmt.Println("n: ", n)

	var zx float32 = 18
	var xc float32 = 4.5
	var cv float64 = 0.23
	var pi float64 = 3.14
	var e float64 = 2.7

	fmt.Println("f: ", zx)
	fmt.Println("g: ", xc)
	fmt.Println("d: ", cv)
	fmt.Println("pi: ", pi)
	fmt.Println("e: ", e)

	var age int
	var isEnabled bool
	var message string

	fmt.Println("\nage: ", age)
	fmt.Printf("age type: %T", age) // age: 0
	fmt.Println("\nisEnabled: ", isEnabled)
	fmt.Printf("isEnabled type: %T", isEnabled) // isEnabled: false
	fmt.Println("\nmessage: ", message)
	fmt.Printf("message type: %T", message) // message:
	fmt.Println()
}
