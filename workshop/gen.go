package main

import (
	"encoding/json"
	"math/rand"
	"os"
)

type Car struct {
	IsNew bool   `json:"isNew"`
	Style string `json:"style"`
	Color string `json:"color"`
}

func main() {
	isNew := []bool{true, false}
	styles := []string{"Sedan", "Coupe", "Convertible", "Minivan", "SUV", "Truck"}
	colors := []string{"Beige", "Black", "Blue", "Brown", "Gold", "Gray", "Green", "Orange", "Pink", "Purple", "Red", "Silver", "White", "Yellow"}

	f, _ := os.Create("cars.json")
	defer f.Close()
	nl := "\n"
	for i := 0; i < 250000; i++ {
		doc := Car{isNew[rand.Intn(len(isNew))], styles[rand.Intn(len(styles))], colors[rand.Intn(len(colors))]}
		b, _ := json.Marshal(doc)
		f.Write(append(b, nl...))
	}
}
