package main

import "fmt"

func main() {

	var str = "Hello"

	var intval = 78

	var floatval = 56.8789

	var boolval = true

	fmt.Printf("intval(%%v): %v \n", intval)

	fmt.Printf("str(%%#v): %#v \n", str)

	fmt.Printf("intval(%%T): %T \n", intval)

	fmt.Printf("boolval(%%t): %t \n\n", boolval)

	fmt.Printf("intval(%%b): %b \n", intval)

	fmt.Printf("intval(%%c): %c \n", intval)

	fmt.Printf("intval(%%d): %d \n", intval)

	fmt.Printf("intval(%%o): %o \n", intval)

	fmt.Printf("intval(%%O): %O \n", intval)

	fmt.Printf("intval(%%q): %q \n", intval)

	fmt.Printf("intval(%%x): %x \n", intval)

	fmt.Printf("intval(%%X): %X \n", intval)

	fmt.Printf("intval(%%U): %U \n\n", intval)

	fmt.Printf("floatval(%%b): %b \n", floatval)

	fmt.Printf("floatval(%%e): %e \n", floatval)

	fmt.Printf("floatval(%%f): %f \n", floatval)

	fmt.Printf("floatval(%%F): %F \n", floatval)

	fmt.Printf("floatval(%%g): %g \n", floatval)

	fmt.Printf("floatval(%%G): %G \n", floatval)

	fmt.Printf("floatval(%%x): %x \n", floatval)

	fmt.Printf("floatval(%%X): %X \n", floatval)

	fmt.Printf("str(%%s): %s \n\n", str)

	fmt.Printf("str(%%q): %q \n", str)

	fmt.Printf("str(%%x): %x \n", str)

	fmt.Printf("str(%%X): %X \n", str)
}
