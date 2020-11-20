package main

import (
	"bufio"
	"io"
	"io/ioutil"
	"net/http"
)

func x() {

	resp, err := http.Get("http://example.com/")
	if err != nil {
		// handle...
	}

	scanner := bufio.NewScanner(resp.Body)
	for scanner.Scan() {
		// read...
	}
	if scanner.Err() != nil {
		// handle...
	}

	resp, err := http.Get("http://example.com/")
	if err != nil {
		// handle...
	}
	defer func() {
		_, _ = io.Copy(ioutil.Discard, resp.Body)
		_ = resp.Body.Close()
	}()

	scanner := bufio.NewScanner(resp.Body)
	// If any error happens and we return in the middle of scanning body,
	// defer will handle all well.
	for scanner.Scan() {
		// read...
	}
	if scanner.Err() != nil {
		// handle...
	}

	resp, err := http.Get("http://example.com/")
	if err != nil {
		// handle...
	}
	defer runutil.ExhaustCloseWithLogOnErr(logger, resp.Body)

	scanner := bufio.NewScanner(resp.Body)
	// If any error happens and we return in the middle of scanning body,
	// defer will handle all well.
	for scanner.Scan() {
		// read...
	}
	if scanner.Err() != nil {
		// handle...
	}

}