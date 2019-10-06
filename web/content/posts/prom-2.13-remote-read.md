---
authors:
- name: "Bartek Płotka"
date: 2019-10-03
linktitle: "Prometheus 2.13.0: Remote Read is now Streaming!"
type:
- post 
- posts
title: "Prometheus 2.13.0: Remote Read is now Streaming!"
weight: 1
categories:
- prometheus
---

> **TL;DR**: Prometheus 2.13.0 is released, and it massively improves remote read API. 
Particularly for Thanos project, this means improved latency and minimized memory consumption for both Prometheus `v2.13.0+` and `v0.7.0+` Thanos sidecar, during query time.

The new version, as always, includes many fixes and improvements ([CHANGELOG](https://github.com/prometheus/prometheus/blob/release-2.13/CHANGELOG.md)). 
However, there is one feature that many projects and users were waiting for: [chunked, streamed version of remote read API](https://docs.google.com/document/d/1JqrU3NjM9HoGLSTPYOvR217f5HBKBiJTqikEB9UiJL0/edit#heading=h.3en2gbeew2sa).  

In this article I would like to explain in a litte bit of deep dive what we changed in the remote protocol, why and finally how to effectively use it.

## Remote APIs

Prometheus since the 1.x version had the ability to interact directly with its storage using [remote API](https://prometheus.io/docs/prometheus/latest/storage/#remote-storage-integrations). 

This API offers two methods: **write** and **read** which allows a 3rd party system to either:

* Receive pushed samples by Prometheus: "Write"
* Pull samples from Prometheus or to Prometheus: "Read"

![Remote read and write architecture](/images/blog/prom-2.13-remote-read/remote_integrations.png)

Both methods are using HTTP with messages encoded with [protobufs](https://github.com/protocolbuffers/protobuf). 
Additionally, both request and response for both methods are optionally compressed using [snappy](https://github.com/google/snappy).

### Remote Write 

This is the most popular way to replicate Prometheus data into 3rd party system. In this mode, Prometheus streams samples, 
by periodically sending a batch of those to the given endpoint. 

Remote read was recently improved massively in March with [WAL-based remote read](https://grafana.com/blog/2019/03/25/whats-new-in-prometheus-2.8-wal-based-remote-write/) which
improved the reliability and resource consumption. It does not technically "stream" in protobuf layer as it sends non-encoded, raw samples. 
However it does not need to as Prometheus sends the data in many small HTTP requests which had proven to be efficient given the TCP connection reuse and snappy compression.

It is also worth to note that Write is used by almost all 3rd party integrations mentioned [here](https://prometheus.io/docs/operating/integrations/#remote-endpoints-and-storage).

### Remote Read

Read method is a bit less popular. It was added in [March 2017](https://github.com/prometheus/prometheus/commit/febed48703b6f82b54b4e1927c53ab6c46257c2f) (server side) and did not change much
since back then. Prometheus 2.13 release finally fixes the known bottlenecks of the Read so we will focus on the Read method in this article.

The key idea of the remote read is to allow querying Prometheus storage, [the TSDB](https://github.com/prometheus/prometheus/tree/master/tsdb) directly without PromQL evaluation. 
Similar interface, [`Querier`](https://github.com/prometheus/prometheus/blob/91d7175eaac18b00e370965f3a8186cc40bf9f55/storage/interface.go#L53), PromQL engine is using to get data from storage. 

The remote read request is a very simple HTTP request with the following protobuf payload:

```
message Query {
  int64 start_timestamp_ms = 1;
  int64 end_timestamp_ms = 2;
  repeated prometheus.LabelMatcher matchers = 3;
  prometheus.ReadHints hints = 4;
}
```

With this client can ask for certain series matching given `matchers` and time range with `end` and `start`.

The response is equally simple. It returns the matched time series with **raw** samples of value and timestamp.

```
message Sample {
  double value    = 1;
  int64 timestamp = 2;
}

message TimeSeries {
  repeated Label labels   = 1;
  repeated Sample samples = 2;
}

message QueryResult {
  repeated prometheus.TimeSeries timeseries = 1;
}
```

This essentially allows read access to metrics in TSDB that Prometheus collected. The main use cases I am familiar with are:

* Seamless Prometheus upgrade between different data formats of Prometheus, so having [Prometheus reading from another Prometheus](https://www.robustperception.io/accessing-data-from-prometheus-1-x-in-prometheus-2-0) 
* Prometheus being able to read from 3rd party long term storage systems e.g InfluxDB.
* 3rd party system querying data from Prometheus e.g [Thanos](https://thanos.io).

## Remote Read: Problem Statement

There were two key problems for such a simple remote read. It was easy to use and understand, but there were no
streaming capabilities for protobuf. Secondly, the response was including raw samples (`float64` value and `int64` timestamp) instead of
an encoded, compressed batch of samples called "chunks" that are used to store metrics inside TSDB.

The server algorithm for remote read before improvement was follows: 

1. Parse request.
1. Select metrics from TSDB.
1. For all decoded series:
  * For all samples:
      * Add to response protobuf
1. Marshal response.
1. Snappy compress.
1. Send back the HTTP response.  
 
In the essence, this means that the whole response of the remote read had to be buffered in raw, uncompressed form to marshall it 
in potentially huge protobuf before sending it to the client. The whole response has to then be fully buffered in the client again to be able
to unmarshal it from protobuf. Only after that client could access raw samples.

What does it mean? It means that requests for, let's say, only 8 hours that matches 10 000 series can take up to 2.5GB of memory allocated by both client and server!

Find below, memory usage metric for both Prometheus and [Thanos Sidecar](https://thanos.io/components/sidecar.md/) (remote read client) during remote read request time:

![Prometheus 2.12.0: RSS of single read 8h of 10k series](/images/blog/prom-2.13-remote-read/10kseries8hours-2.12.png)

![Prometheus 2.12.0: Heap-only allocations of single read 8h of 10k series](/images/blog/prom-2.13-remote-read/10series8hours-2.12-allocs.png)

It's worth to note, that querying 10k series is never great even for Prometheus native HTTP `query_range` endpoint, simply because fetching and storing hundreds of megabytes in your browser is not great. 
Additionally, for dashboards and rendering purposes it is not practical to have that much of the data. That's why usually we craft queries that have no more than 20 series.

This is great, but a very common technique is to compose queries in such way that query returns **aggregated** 20 series, 
however underneath the query engine has to touch potentially thousands of series to evaluate the response (e.g `count()` function or [subqueries](https://prometheus.io/blog/2019/01/28/subquery-support/)) That's why systems like Thanos 
which use TSDB data from remote read - it's very often the case that the request is heavy. 

## Solution

To explain the solution and its benefits, it's important to understand the way Prometheus iterates over the data when queried.
The core concept can be shown in [`Querier's`](https://github.com/prometheus/prometheus/blob/91d7175eaac18b00e370965f3a8186cc40bf9f55/storage/interface.go#L53) 
 `Select` method returned type called `SeriesSet`. The interface is presented below:

```
// SeriesSet contains a set of series.
type SeriesSet interface {
	Next() bool
	At() Series
	Err() error
}
// Series represents a single time series.
type Series interface {
	// Labels returns the complete set of labels identifying the series.
	Labels() labels.Labels
	// Iterator returns a new iterator of the data of the series.
	Iterator() SeriesIterator
}

// SeriesIterator iterates over the data of a time series.
type SeriesIterator interface {
	// At returns the current timestamp/value pair.
	At() (t int64, v float64)
	// Next advances the iterator by one.
	Next() bool
	Err() error
}
```

This allows "streaming" the operations inside the process. We no longer have to have a list of series that hold samples.
With this interface each `SeriesSet.Next()` implementation can fetch series on-the-fly. 
In a similar way, within each series. we can also dynamically fetch each sample respectively via `SeriesIterator.Next`.  

With this contract, Prometheus can minimize allocated memory as the PromQL engine can iterate over samples optimally to evaluate the query. 
In the same way TSDB, so Prometheus storage can implement `SeriesSet` to fetch the series optimally from blocks stored in the filesystem.

Why this is important for remote read? Well, ideally we would like to reuse the same pattern of streaming using iterators.
Because protobuf has no native delimiting logic, we [`extended`](https://github.com/prometheus/prometheus/pull/5703/files#diff-7bdb1c90d5a59fc5ead16457e6d2b038R44)
proto definition to allow sending **set of small protocol buffer messages** instead of a single, huge one. This is also the recommendation from Google to keep
protobuf message [smaller than 1MB](https://developers.google.com/protocol-buffers/docs/techniques#large-data). This means that
Prometheus doesn't need to buffer the whole response anymore - we can stream that operation e.g send a single frame per
each `SeriesSet.Next` or batch of `SeriesIterator.Next` iterations!

Now the result is a set of Protobuf messages (frames) as presented below:

```
// ChunkedReadResponse is a response when response_type equals STREAMED_XOR_CHUNKS.
// We strictly stream full series after series, optionally split by time. This means that a single frame can contain
// partition of the single series, but once a new series is started to be streamed it means that no more chunks will
// be sent for previous one.
message ChunkedReadResponse {
  repeated prometheus.ChunkedSeries chunked_series = 1;
}

// ChunkedSeries represents single, encoded time series.
message ChunkedSeries {
  // Labels should be sorted.
  repeated Label labels = 1 [(gogoproto.nullable) = false];
  // Chunks will be in start time order and may overlap.
  repeated Chunk chunks = 2 [(gogoproto.nullable) = false];
}
```

As you can see the frame does not include raw samples anymore. That's the second improvement we did: We send in the message
samples batched in chunks (see [this video](https://www.youtube.com/watch?v=b_pEevMAC3I) to learn more about chunks), 
which are exactly the same chunks we store in the TSDB. 

We ended up with the following server algorithm:

1. Parse request.
1. Select metrics from TSDB.
1. For all series:
  * For all samples:
      * Encode into chunks
         * if the frame is >= 1MB; break
      * Marshal `ChunkedReadResponse` message.
      * Snappy compress
      * Send the message   

You can find full design [here](https://docs.google.com/document/d/1JqrU3NjM9HoGLSTPYOvR217f5HBKBiJTqikEB9UiJL0/edit#).

## Benchmarks

Let's compare remote read characteristics between Prometheus `2.12.0` and `2.13.0`. As the initial results presented 
at the beginning of this blog, I will use Prometheus as a server, and Thanos sidecar as a client of the remote read.

I was invoking testing remote read request by running gRPC call against Thanos sidecar using `grpcurl`.

The full test bench is available in [thanosbench repo](https://github.com/thanos-io/thanosbench/blob/master/benchmarks/remote-read/README.md).

### Memory

![Prometheus 2.12.0: Heap-only allocations of single read 8h of 10k series](/images/blog/prom-2.13-remote-read/10series8hours-2.12-allocs.png)

![Prometheus 2.13.0: Heap-only allocations of single read 8h of 10k series](/images/blog/prom-2.13-remote-read/10series8hours-2.13-allocs.png)

TBD explain

As expected if we change the time range to smaller or larger, or change the number of series to smaller/larger we keep seeing
maximum of 50MB more in allocations for Prometheus and nothing really visible for Thanos. This proves that our remote read
uses constant memory per request allowing easier capacity planning against user traffic, with help of the concurrency limt. 

### CPU

![Prometheus 2.12.0: CPU time of single read 8h of 10k series](/images/blog/prom-2.13-remote-read/10kseries8hours-2.12-cpu.png)

![Prometheus 2.13.0: CPU time of single read 8h of 10k series](/images/blog/prom-2.13-remote-read/10kseries8hours-2.13-cpu.png)

TBD explain

### Latency

On my local Kubernetes cluster remote read request for 10k series, 8h with Prometheus 2.12 took:

|      | 2.12.0: avg time | 2.13.0: avg time |
|------|------------------|------------------|
| real | 0m34.701s        | 0m8.164s         |
| user | 0m7.324s         | 0m8.181s         |
| sys  | 0m1.172s         | 0m0.749s         |

If we reduce the time range to 2h we have:

|      | 2.12.0: avg time | 2.13.0: avg time |
|------|------------------|------------------|
| real | 0m10.904s        | 0m4.145s         |
| user | 0m6.236s         | 0m4.322s         |
| sys  | 0m0.973s         | 0m0.536s         |

Additionally to ~2.5x lower latency, we can see that response is streamed immediately in comparison to the non-streamed
version where we were waiting for 27s (real minus user time) just on processing and marshaling on Prometheus and then on Thanos. 

## Compatibility

Remote read was extended in a backward and forward compatible way. This is thanks to protobuf and `accepted_response_types` field which is
ignored for older servers. In the same time server works just fine if `accepted_response_types` is not present by older clients.

## Usage

TBD

## Next Steps

While remote read protocol and Prometheus server side is improved there are still few items to gain more benefits from the extended remote read protocol:

* Support for client side of Prometheus remote read: [In progress](https://github.com/prometheus/prometheus/issues/5926) 
* Avoid reencoding of chunks for blocks during remote read: [In progress](https://github.com/prometheus/prometheus/pull/5882)

## Summary

To sum up, the main benefits of chunked, streaming of remote read are:

* Both client and server are capable to use **constant memory size and per each request**. This is because Prometheus now
at maximum buffers just a single small frame instead of the whole response during remote read. The same for client side. This massively improves
 capacity planning for non-compressible resource like memory.
* Prometheus server does not need to decode chunks to raw samples anymore during remote read. The same for client side for
encoding, **if the system is** reusing native TSDB XOR compression (like Thanos does). 
