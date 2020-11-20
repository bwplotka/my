package go_london_meetup_2020

func copyIntoSliceAndMap(biggy []string) (a []string, b map[string]struct{}) {
	b = map[string]struct{}{}

	for _, item := range biggy {
		a = append(a, item)
		b[item] = struct{}{}
	}
	return a, b
}

func copyIntoSliceAndMap(biggy []string) (a []string, b map[string]struct{}) {
	b = make(map[string]struct{}, len(biggy))
	a = make([]string, len(biggy))

	// Copy will not even work without pre-allocation.
	copy(a, biggy)
	for _, item := range biggy {
		b[item] = struct{}{}
	}
	return a, b
}
