package main

func x()  {
	var messages []string{}
	for _, msg := range recv {
		messages = append(messages, msg)

		if len(messages) > maxMessageLen {
			marshalAndSend(messages)
			// This creates new array. Previous array
			// will be garbage collected only after
			// some time (seconds), which
			// can create enormous memory pressure.
			messages = []string{}
		}
	}


	var messages []string{}
	for _, msg := range recv {
		messages = append(messages, msg)

		if len(messages) > maxMessageLen {
			marshalAndSend(messages)
			// Instead of new array, reuse
			// the same, with the same capacity,
			// just length equals to zero.
			messages = messages[:0]
		}
	}
}
