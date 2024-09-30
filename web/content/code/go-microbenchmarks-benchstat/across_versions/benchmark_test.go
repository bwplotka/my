// Copyright (c) Bartłomiej Płotka @bwplotka
// Licensed under the Apache License 2.0.
package across_versions

import (
	"fmt"
	"testing"

	utils "github.com/bwplotka/benchmarks/benchmarks/metrics-streaming"
	"github.com/efficientgo/core/testutil"
	"github.com/golang/snappy"
	"github.com/klauspost/compress/zstd"
	"github.com/prometheus/prometheus/storage/remote"
	"google.golang.org/protobuf/proto"
)

var (
	generateConfig200samples   = utils.NewGenerateConfig(50, 40, 10, 8, 10, 10, 0.5)
	generateConfig2000samples  = utils.NewGenerateConfig(500, 400, 100, 8, 100, 10, 0.5)
	generateConfig10000samples = utils.NewGenerateConfig(2500, 2000, 500, 8, 500, 10, 0.5)
)

type vtprotobufEnhancedMessage interface {
	proto.Message
	MarshalVT() (dAtA []byte, err error)
	UnmarshalVT(dAtA []byte) (err error)
	CloneMessageVT() proto.Message
}

var (
	sampleCases = []struct {
		samples int
		config  utils.GenerateConfig
	}{
		{samples: 200, config: generateConfig200samples},
		{samples: 2000, config: generateConfig2000samples},
		{samples: 10000, config: generateConfig10000samples},
	}
)

/*
	export bench=v2 && go test \
		 -run '^$' -bench '^BenchmarkEncode' \
		 -benchtime 5s -count 6 -cpu 2 -benchmem -timeout 999m \
	 | tee ${bench}.txt
*/
func BenchmarkEncode(b *testing.B) {
	for _, sampleCase := range sampleCases {
		b.Run(fmt.Sprintf("sample=%v", sampleCase.samples), func(b *testing.B) {
			batch := utils.GeneratePrometheusMetricsBatch(sampleCase.config)

			// Commenting out what we used in v1.txt
			//msg := utils.ToV1(batch, true, true)
			msg := utils.ToV2(utils.ConvertClassicToCustom(batch))

			compr := newCompressor("zstd")
			marsh := newMarshaller("protobuf")

			b.ReportAllocs()
			b.ResetTimer()
			for i := 0; i < b.N; i++ {
				out, err := marsh.marshal(msg)
				testutil.Ok(b, err)

				out = compr.compress(out)
				b.ReportMetric(float64(len(out)), "bytes/message")
			}
		})
	}
}

type marshaller struct {
	encoder string
	opts    proto.MarshalOptions
}

func newMarshaller(encoder string) *marshaller {
	m := &marshaller{encoder: encoder}
	if encoder == "protobuf" {
		m.opts = proto.MarshalOptions{UseCachedSize: true}
	}
	return m
}

func (m *marshaller) name() string { return m.encoder }
func (m *marshaller) marshal(msg vtprotobufEnhancedMessage) ([]byte, error) {
	switch m.encoder {
	case "vtprotobuf":
		return msg.MarshalVT()
	default:
		return m.opts.Marshal(msg)
	}
}

type compressor struct {
	compression remote.Compression
	zEnc        *zstd.Encoder
}

func newCompressor(compression remote.Compression) *compressor {
	c := &compressor{compression: compression}
	if compression == "zstd" {
		c.zEnc, _ = zstd.NewWriter(nil, zstd.WithEncoderLevel(zstd.SpeedFastest))
	}
	return c
}
func (c *compressor) name() string { return string(c.compression) }
func (c *compressor) compress(b []byte) []byte {
	switch c.compression {
	case "zstd":
		b = c.zEnc.EncodeAll(b, nil)
	case remote.SnappyBlockCompression:
		b = snappy.Encode(nil, b)
	default:
		// No compression.
	}
	return b
}
