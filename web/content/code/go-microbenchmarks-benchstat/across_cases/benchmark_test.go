// Copyright (c) Bartłomiej Płotka @bwplotka
// Licensed under the Apache License 2.0.
package across_cases

import (
	"fmt"
	"testing"

	utils "github.com/bwplotka/benchmarks/benchmarks/metrics-streaming"
	"github.com/efficientgo/core/testutil"
	"github.com/golang/snappy"
	"github.com/google/go-cmp/cmp"
	"github.com/klauspost/compress/zstd"
	"github.com/prometheus/prometheus/storage/remote"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/testing/protocmp"
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
	compressionCases = []*compressor{
		newCompressor(""),
		newCompressor(remote.SnappyBlockCompression),
		newCompressor("zstd"),
	}
	protoCases = []struct {
		name            string
		msgFromConfigFn func(config utils.GenerateConfig) vtprotobufEnhancedMessage
	}{
		{
			name: "prometheus.WriteRequest",
			msgFromConfigFn: func(config utils.GenerateConfig) vtprotobufEnhancedMessage {
				return utils.ToV1(utils.GeneratePrometheusMetricsBatch(config), true, true)
			},
		},
		{
			name: "io.prometheus.write.v2.Request",
			msgFromConfigFn: func(config utils.GenerateConfig) vtprotobufEnhancedMessage {
				return utils.ToV2(utils.ConvertClassicToCustom(utils.GeneratePrometheusMetricsBatch(config)))
			},
		},
	}
	marshallers = []*marshaller{
		newMarshaller("protobuf"), newMarshaller("vtprotobuf"),
	}
)

/*
	export bench=allcases && go test \
		 -run '^$' -bench '^BenchmarkEncode' \
		 -benchtime 5s -count 6 -cpu 2 -benchmem -timeout 999m \
	 | tee ${bench}.txt
*/
func BenchmarkEncode(b *testing.B) {
	for _, sampleCase := range sampleCases {
		b.Run(fmt.Sprintf("sample=%v", sampleCase.samples), func(b *testing.B) {
			for _, compr := range compressionCases {
				b.Run(fmt.Sprintf("compression=%v", compr.name()), func(b *testing.B) {
					for _, protoCase := range protoCases {
						b.Run(fmt.Sprintf("proto=%v", protoCase.name), func(b *testing.B) {
							for _, marshaller := range marshallers {
								b.Run(fmt.Sprintf("encoder=%v", marshaller.name()), func(b *testing.B) {
									msg := protoCase.msgFromConfigFn(sampleCase.config)

									b.ReportAllocs()
									b.ResetTimer()
									for i := 0; i < b.N; i++ {
										out, err := marshaller.marshal(msg)
										testutil.Ok(b, err)

										out = compr.compress(out)
										b.ReportMetric(float64(len(out)), "bytes/message")
									}
								})
							}
						})
					}
				})
			}
		})
	}
}

func TestEncode(t *testing.T) {
	for _, sampleCase := range sampleCases {
		t.Run(fmt.Sprintf("sample=%v", sampleCase.samples), func(t *testing.T) {
			for _, protoCase := range protoCases {
				msg := protoCase.msgFromConfigFn(sampleCase.config)
				t.Run(fmt.Sprintf("proto=%v", protoCase.name), func(t *testing.T) {
					for _, compr := range compressionCases {
						t.Run(fmt.Sprintf("compression=%v", compr.name()), func(t *testing.T) {
							for _, marsh := range marshallers {
								t.Run(fmt.Sprintf("encoder=%v", marsh.name()), func(t *testing.T) {
									out, err := marsh.marshal(msg)
									testutil.Ok(t, err)

									out = compr.compress(out)

									assertDecodability(t, out, msg, remote.Compression(compr.name()))
								})
							}
						})
					}
				})
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

func assertDecodability(t testing.TB, got []byte, expected vtprotobufEnhancedMessage, compression remote.Compression) {
	t.Helper()

	switch compression {
	case "zstd":
		z, err := zstd.NewReader(nil)
		testutil.Ok(t, err)

		got, err = z.DecodeAll(got, nil)
		testutil.Ok(t, err)
	case remote.SnappyBlockCompression:
		var err error
		got, err = snappy.Decode(nil, got)
		testutil.Ok(t, err)
	default:
		// No compression.
	}

	gotMsg := proto.Clone(expected)
	proto.Reset(gotMsg)

	testutil.Ok(t, proto.Unmarshal(got, gotMsg))
	if diff := cmp.Diff(expected, gotMsg, protocmp.Transform()); diff != "" {
		t.Fatalf("expected the same got: %v, diff: %v", gotMsg, diff)
	}
}
