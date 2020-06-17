package example

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
	// If any error happens and we return in the middle of scanning
	// body, we can end up with unread buffer, which
	// will use memory and hold TCP connection!
	for scanner.Scan() {
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
	}

}