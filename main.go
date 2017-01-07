package main

import (
	"bufio"
	"encoding/hex"
	"flag"
	"fmt"
	"os"
)

const (
	// ExitCodeOK is returned when everything succeeds.
	ExitCodeOK = 0
	// ExitCodeOpenFileError is returned when opening some files fails.
	ExitCodeOpenFileError = 5
	// ExitCodeInputError is returned when a illegal hex-encoded strings are included as input.
	ExitCodeInputError = 6
)

func main() {
	os.Exit(run(os.Args))
}

func run(args []string) int {
	var scanner *bufio.Scanner
	var filename = flag.String("i", "", "file path which includes hex-encoded lines")

	flag.Parse()

	if *filename == "" {
		scanner = bufio.NewScanner(os.Stdin)
	} else {
		file, err := os.Open(*filename)
		if err != nil {
			fmt.Fprintf(os.Stderr, "file open error: %s\n", err)
			return ExitCodeOpenFileError
		}
		defer file.Close()

		scanner = bufio.NewScanner(file)
	}

	for scanner.Scan() {
		var hexString = scanner.Text()
		var decoded, err = hex.DecodeString(hexString)
		if err != nil {
			fmt.Fprintf(os.Stderr, "failed to decode \"%s\": %s\n", hexString, err)
			return ExitCodeInputError
		}
		fmt.Println(string(decoded))
	}

	if err := scanner.Err(); err != nil {
		fmt.Fprintf(os.Stderr, "scanner error: %s\n", err)
		return ExitCodeInputError
	}

	return ExitCodeOK
}
