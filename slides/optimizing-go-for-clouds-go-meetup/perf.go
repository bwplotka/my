	d := encoding.NewDecbufAt(r.b, int(r.toc.PostingsOffsetTable), nil)
	d.Skip(e.offsets[0].tableOff)
	lastVal := e.offsets[len(e.offsets)-1].value

	skip := 0
	for d.Err() == nil {
		if skip == 0 {
			skip = d.Len()
			d.Uvarint()      // Keycount.
			d.UvarintBytes() // Label name.
			skip -= d.Len()
		} else {
			d.Skip(skip)
		}
		s := yoloString(d.UvarintBytes()) // Label value.
		values = append(values, s)
		if s == lastVal {
			break
		}
		d.Uvarint64() // Offset.
	}
func yoloString(b []byte) string {
	return *((*string)(unsafe.Pointer(&b)))
}