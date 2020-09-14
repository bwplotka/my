---
authors:
- name: "Bartek Płotka"
date: 2020-03-22
linktitle: Flagarize Your Go Configuration Struct!
type:
- post 
- posts
title: Flagarize Your Go Configuration Struct!
weight: 1
categories:
- go
- infra
images:
- "/og-images/ide-header.png"
featuredImage: "/og-images/ide-header.png"
---

**TL;DR In my free time I wrote a simple but powerful, open source Go library [flagarize](https://github.com/bwplotka/flagarize) to register
your flags from Go struct tags! Please try it, share feedback and read below why it was created.**

## Flags FTW

You are probably familiar with the eternal battle among all engineers on what is the best IDE: vim or emacs (of course vim 😜). 
In the [SRE](https://en.wikipedia.org/wiki/Site_Reliability_Engineering)/Developer world there is a similar dispute. 
**How we should configure our microservices?** I know about three ways (I removed `hardcoding` from the list on purpose ^^):  

* By passing `flags` using process arguments.
* By specifying `environment variables` for the process.
* Last but not the least by passing `configuration file` to your CLI in some format like JSON, YAML, Protobuf, TOML, INI, etc... 

While all of those methods have its pros and cons, Through all of my experience as a Dev/SRE and maintainers of bigger projects
like [Prometheus](https://prometheus.io) or [Thanos](https://thanos.io), **I learned that in most cases flags are superior.** Why?

* **Flags are explicit.** You always know exactly how your application was configured. You don't have this with config files and environment variables.
One can think that they passed some envvars or file, but it's just guessing! They have no idea if some process changed the file or vars
just before starting the application process. Some endpoint like `/config` which renders current configuration may help, but still, 
why not just passing this as a flag? No one can change passed arguments to CLI in runtime. 
* **Flags are easier to operate.** You don't need to copy or provision files or play with a highly dynamic environment.
* **Flags are highly discoverable.** While you can try to generate docs from configuration like [we do in Thanos](https://github.com/thanos-io/thanos/blob/55cb8ca38b3539381dc6a781e637df15c694e50a/scripts/cfggen/main.go)
there is nothing better than good old `--help` flag.
* **There are a bit fewer formats for flags than for configuration formats.** More or less there are two `-flag` or `--flag` multiplied by two with `=` or without.
Good libraries support both. How many configuration formats we have? Probably every day someone creates new. (:

However, someone can argue that there are **some** use cases for environment variables and configuration files e.g:

### Secrets
 
This is a sensitive topic, but **if you dive deeper, for example, the environment is not a safe place for secrets either.** And you can
totally pass secrets by a flag directly thanks to e.g Kubernetes from secret substitution (with `--my-flag=$(SECRET_CONTENT)` convention). 

### Complex structures
 
They say it's hard to pass map or custom structure via a flag and sometimes you have to (e.g. when dealing with configuring dynamic plugins).
**I disagree with this.** You can totally pass multiline strings via flags with ease, so you can pass custom format (e.g YAML) without 
sacrificing flag benefits:

```bash
<CLI> --some-flag1=a --some-flag2=b --objstore.config="
type: S3
config:
  bucket: some-bucket-name
  endpoint: s3.amazonaws.com
  access_key: <...>
  secret_key: <...>
"
```

With Kubernetes it's even easier. You can do it either from secret or directly render content:

```yaml
- args:
      - compact
      - --objstore.config=$(OBJSTORE_CONFIG)
        --tracing.config=
          type: JAEGER
          config:
            service_name: thanos-compact
            sampler_type: ratelimiting
            sampler_param: 2
      env:
      - name: OBJSTORE_CONFIG
        valueFrom:
          secretKeyRef:
            key: thanos.yaml
            name: some-secret
```

### Dynamic reload of configuration
 
They say you cannot have a dynamic configuration with flags. **That is also not true.** Have you seen
amazing [`go-flagz`](https://github.com/mwitkow/go-flagz) library? It's used on production and I can definitely recommend it. 

## Problem: Defining flags in Go.

Hopefully, I convinced you that flags for your Go applications are what you need in most cases. Now let's look at what is the 
problem with old-school flag definition. You are probably familiar with how it's done in most of the Go libraries like:

* standard [`flag`](https://golang.org/pkg/flag/)
* [`kingpin`](https://github.com/alecthomas/kingpin)
* [`spf13/cobra`](https://github.com/spf13/cobra)
* [Peter's](https://peter.bourgon.org/) [ff library](https://github.com/peterbourgon/ff)

For example [`kingpin/v2`](https://github.com/alecthomas/kingpin)

```go
	selectorLabels := cmd.Flag("selector-label", "Query selector labels that will be exposed in info endpoint (repeated).").Required().PlaceHolder("<name>=\"<value>\"").Strings()
```

This is great, so what's the problem? 

Well, the problem starts when you have more than 4 flags. See [this configuration of Thanos querier component](https://github.com/thanos-io/thanos/blob/d23b6a339af18b644f1398bdb5aa92c884432d67/cmd/thanos/query.go#L47):

```go
// registerQuery registers a query command.
func registerQuery(m map[string]setupFunc, app *kingpin.Application) {
    comp := component.Query
    cmd := app.Command(comp.String(), "query node exposing PromQL enabled Query API with data retrieved from multiple store nodes")
    httpBindAddr, httpGracePeriod := regHTTPFlags(cmd)
    grpcBindAddr, grpcGracePeriod, grpcCert, grpcKey, grpcClientCA := regGRPCFlags(cmd)
    secure := cmd.Flag("grpc-client-tls-secure", "Use TLS when talking to the gRPC server").Default("false").Bool()
    cert := cmd.Flag("grpc-client-tls-cert", "TLS Certificates to use to identify this client to the server").Default("").String()
    key := cmd.Flag("grpc-client-tls-key", "TLS Key for the client's certificate").Default("").String()
    caCert := cmd.Flag("grpc-client-tls-ca", "TLS CA Certificates to use to verify gRPC servers").Default("").String()
    serverName := cmd.Flag("grpc-client-server-name", "Server name to verify the hostname on the returned gRPC certificates. See https://tools.ietf.org/html/rfc4366#section-3.1").Default("").String()
    webRoutePrefix := cmd.Flag("web.route-prefix", "Prefix for API and UI endpoints. This allows thanos UI to be served on a sub-path. This option is analogous to --web.route-prefix of Promethus.").Default("").String()
    webExternalPrefix := cmd.Flag("web.external-prefix", "Static prefix for all HTML links and redirect URLs in the UI query web interface. Actual endpoints are still served on / or the web.route-prefix. This allows thanos UI to be served behind a reverse proxy that strips a URL sub-path.").Default("").String()
    webPrefixHeaderName := cmd.Flag("web.prefix-header", "Name of HTTP request header used for dynamic prefixing of UI links and redirects. This option is ignored if web.external-prefix argument is set. Security risk: enable this option only if a reverse proxy in front of thanos is resetting the header. The --web.prefix-header=X-Forwarded-Prefix option can be useful, for example, if Thanos UI is served via Traefik reverse proxy with PathPrefixStrip option enabled, which sends the stripped prefix value in X-Forwarded-Prefix header. This allows thanos UI to be served on a sub-path.").Default("").String()
    queryTimeout := modelDuration(cmd.Flag("query.timeout", "Maximum time to process query by query node.").
        Default("2m"))
    maxConcurrentQueries := cmd.Flag("query.max-concurrent", "Maximum number of queries processed concurrently by query node.").
        Default("20").Int()
    replicaLabels := cmd.Flag("query.replica-label", "Labels to treat as a replica indicator along which data is deduplicated. Still you will be able to query without deduplication using 'dedup=false' parameter.").
        Strings()
    instantDefaultMaxSourceResolution := modelDuration(cmd.Flag("query.instant.default.max_source_resolution", "default value for max_source_resolution for instant queries. If not set, defaults to 0s only taking raw resolution into account. 1h can be a good value if you use instant queries over time ranges that incorporate times outside of your raw-retention.").Default("0s").Hidden())
    selectorLabels := cmd.Flag("selector-label", "Query selector labels that will be exposed in info endpoint (repeated).").
        PlaceHolder("<name>=\"<value>\"").Strings()
    stores := cmd.Flag("store", "Addresses of statically configured store API servers (repeatable). The scheme may be prefixed with 'dns+' or 'dnssrv+' to detect store API servers through respective DNS lookups.").
        PlaceHolder("<store>").Strings()
    fileSDFiles := cmd.Flag("store.sd-files", "Path to files that contain addresses of store API servers. The path can be a glob pattern (repeatable).").
        PlaceHolder("<path>").Strings()
    fileSDInterval := modelDuration(cmd.Flag("store.sd-interval", "Refresh interval to re-read file SD files. It is used as a resync fallback.").
        Default("5m"))
    dnsSDInterval := modelDuration(cmd.Flag("store.sd-dns-interval", "Interval between DNS resolutions.").
        Default("30s"))
    dnsSDResolver := cmd.Flag("store.sd-dns-resolver", fmt.Sprintf("Resolver to use. Possible options: [%s, %s]", dns.GolangResolverType, dns.MiekgdnsResolverType)).
        Default(string(dns.GolangResolverType)).Hidden().String()
    unhealthyStoreTimeout := modelDuration(cmd.Flag("store.unhealthy-timeout", "Timeout before an unhealthy store is cleaned from the store UI page.").Default("5m"))
    enableAutodownsampling := cmd.Flag("query.auto-downsampling", "Enable automatic adjustment (step / 5) to what source of data should be used in store gateways if no max_source_resolution param is specified.").
        Default("false").Bool()
    enablePartialResponse := cmd.Flag("query.partial-response", "Enable partial response for queries if no partial_response param is specified. --no-query.partial-response for disabling.").
        Default("true").Bool()
    defaultEvaluationInterval := modelDuration(cmd.Flag("query.default-evaluation-interval", "Set default evaluation interval for sub queries.").Default("1m"))
    storeResponseTimeout := modelDuration(cmd.Flag("store.response-timeout", "If a Store doesn't send any data in this specified duration then a Store will be ignored and partial data will be returned if it's enabled. 0 disables timeout.").Default("0ms"))
    //...
```

Not only defining them is hard, but also using all those flags after parsing looks extremely bad.

<details>
  <summary>Click to see how bad...</summary>
  
```go
return runQuery(
    g,
    logger,
    reg,
    tracer,
    *grpcBindAddr,
    time.Duration(*grpcGracePeriod),
    *grpcCert,
    *grpcKey,
    *grpcClientCA,
    *secure,
    *cert,
    *key,
    *caCert,
    *serverName,
    *httpBindAddr,
    time.Duration(*httpGracePeriod),
    *webRoutePrefix,
    *webExternalPrefix,
    *webPrefixHeaderName,
    *maxConcurrentQueries,
    time.Duration(*queryTimeout),
    time.Duration(*storeResponseTimeout),
    *replicaLabels,
    selectorLset,
    *stores,
    *enableAutodownsampling,
    *enablePartialResponse,
    fileSD,
    time.Duration(*dnsSDInterval),
    *dnsSDResolver,
    time.Duration(*unhealthyStoreTimeout),
    time.Duration(*instantDefaultMaxSourceResolution),
    component.Query,
)
```

</details>

This works, but it's not readable, right? And it makes you cry if you need to add any more flags. This is why we attempted
to fix this with [some refactoring](https://github.com/thanos-io/thanos/blob/4b4021e52bb6f9d4f07095e92e018dc49c211c73/cmd/thanos/sidecar.go#L43).

With end result refactoring we probably can get close to what we have in the [Prometheus project](https://github.com/prometheus/prometheus/blob/master/cmd/prometheus/main.go#L102)
with some kind of configuration struct that is filled from flags:

```go
cfg := struct {
    configFile string

    localStoragePath    string
    notifier            notifier.Options
    notifierTimeout     model.Duration
    forGracePeriod      model.Duration
    outageTolerance     model.Duration
    resendDelay         model.Duration
    web                 web.Options
    tsdb                tsdbOptions
    lookbackDelta       model.Duration
    webTimeout          model.Duration
    queryTimeout        model.Duration
    queryConcurrency    int
    queryMaxSamples     int
    RemoteFlushDeadline model.Duration

    prometheusURL   string
    corsRegexString string

    promlogConfig promlog.Config
}{}

a := kingpin.New(filepath.Base(os.Args[0]), "The Prometheus monitoring server")
a.Version(version.Print("prometheus"))
a.HelpFlag.Short('h')

a.Flag("config.file", "Prometheus configuration file path.").
    Default("prometheus.yml").StringVar(&cfg.configFile)
a.Flag("web.listen-address", "Address to listen on for UI, API, and telemetry.").
    Default("0.0.0.0:9090").StringVar(&cfg.web.ListenAddress)
a.Flag("web.read-timeout",
    "Maximum duration before timing out read of the request, and closing idle connections.").
    Default("5m").SetValue(&cfg.webTimeout)
a.Flag("web.max-connections", "Maximum number of simultaneous connections.").
    Default("512").IntVar(&cfg.web.MaxConnections)
a.Flag("web.external-url",
    "The URL under which Prometheus is externally reachable (for example, if Prometheus is served via a reverse proxy). Used for generating relative and absolute links back to Prometheus itself. If the URL has a path portion, it will be used to prefix all HTTP endpoints served by Prometheus. If omitted, relevant URL components will be derived automatically.").
    PlaceHolder("<URL>").StringVar(&cfg.prometheusURL)
a.Flag("web.route-prefix",
    "Prefix for the internal routes of web endpoints. Defaults to path of --web.external-url.").
    PlaceHolder("<path>").StringVar(&cfg.web.RoutePrefix)
a.Flag("web.user-assets", "Path to static asset directory, available at /user.").
    PlaceHolder("<path>").StringVar(&cfg.web.UserAssetsPath)
a.Flag("web.enable-lifecycle", "Enable shutdown and reload via HTTP request.").
    Default("false").BoolVar(&cfg.web.EnableLifecycle)
a.Flag("web.enable-admin-api", "Enable API endpoints for admin control actions.").
    Default("false").BoolVar(&cfg.web.EnableAdminAPI)
a.Flag("web.console.templates", "Path to the console template directory, available at /consoles.").
    Default("consoles").StringVar(&cfg.web.ConsoleTemplatesPath)

//... Thousands more of that.

if _, err := a.Parse(os.Args[1:]); err != nil {
    fmt.Fprintln(os.Stderr, errors.Wrapf(err, "Error parsing commandline arguments"))
    a.Usage(os.Args[1:])
    os.Exit(2)
}
```

This is much better, but still not great, particularly:

1. It's not clear what fields from the Go struct are actually set from flags, which are manually set. Especially for
nested configuration structs. It's worth to note that overall, as [mentioned by Peter Bourgon](https://twitter.com/peterbourgon/status/1241775377476878337),
mixing user intent with derived config is a bad design smell. Such mistake is quite hard to detect with flag definition like above. 
2. It's easy to miss that some configuration variable is not used anymore, but some flag is still defined for it. This is
because Go will not detect it being used, as it's passed in for example `DurationVar(&cfg.var)`. In fact, during the move
of Prometheus flags to my library, I found that one config field was exactly like this.
3. We just defined a field in configuration struct, why we need to create additional 2 complex lines for each of it?
4. What if we would like to parse our configuration from JSON or YAML as well? It would require huge refactoring.
5. What about complex flags like Thanos's [`path or content`](https://github.com/thanos-io/thanos/blob/master/pkg/extflag/pathorcontent.go)? Registering
is quite tedious.   

## Solution

Fortunately, there are better ways to do it. At Red Hat, we have regular days called `Hack'n'Hustle` where we can spend a whole day
on WHATEVER you always wanted to do to improve (or break 😄) something unrelated to your work in open-source. During the last
one I created [`flagarize`](https://github.com/bwplotka/flagarize). A library that is meant to solve the problems mentioned earlier.

### Flagarize your config structure!

The main issue is that you have two places of definition for your configuration in code. Struct and flag registration. Flagarize allows 
to have just one: Struct. You can do that by adding a struct tag called `flagarize:<key=value,>`, in the same way, we do `json:`, `yaml` or `protobuf` tags!

For example:

```
type config struct {
    Field1 string         `flagarize:"name=flag1|help=Some help.|default=Some Value|envvar=FLAG1|short=f|placeholder=<put some string here>"`
    Field2 YourCustomType `flagarize:"name=custom-type-flag|help=Custom Type always add prefix 'AlwaysAddingPrefix' to the given string value.|required=true|short=c|placeholder=<put some my custom type here>"`
}
```

Once you define such a flag it's as easy as passing instantiated configuration through `Flagarize` function. Don't forget to pass
the kingpin.Application you want to register the flags in!

```go
a := kingpin.New(filepath.Base(os.Args[0]), "<Your CLI description>")

cfg := &config{}

// Flagarize your config! (Register flags from config).
if err := flagarize.Flagarize(a, cfg); err != nil {
    log.Fatal(err)
}
```  

Then as usual, parse the arguments:

```go
if _, err := a.Parse(os.Args[1:]); err != nil {
    log.Fatal(err)
}
```

With this you can run your CLI with --help which will show you the flags:

```bash
go run example/custom_type/main.go --help

usage: main --custom-type-flag=<put some my custom type here> [<flags>]

<Your CLI description>

Flags:
      --help  Show context-sensitive help (also try --help-long and --help-man).
  -f, --flag1=<put some string here>
              Some help.
  -c, --custom-type-flag=<put some my custom type here>
              Custom Type always add prefix 'AlwaysAddingPrefix' to the given string value.
```

And when you pass those flags:

```bash
go run example/custom_type/main.go --flag1=value1 -c=value2

Config Value after flagarizing & flag parsing: &{Field1:value1 Field2:AlwaysAddingPrefix=value2}
```

See this example [here](https://github.com/bwplotka/flagarize/blob/6d668ce203a70fd6e10c3cd532fe3d64a1ac77c6/example/custom_type/main.go#L23)

### But wait... how flagarize knew how to parse YourCustomType? 

Great question, glad you asked!

Flagarize checks for if your type implements `Set(s string) error` method. This is exactly the same method as `kingpin` library is using,
so everything that worked with `kingpin` will work in `flagarize` as well.

So above example works because our type looks like this:

```go
type YourCustomType string

func (cst *YourCustomType) Set(s string) error {
	*cst = YourCustomType(fmt.Sprintf("AlwaysAddingPrefix%s", s))
	return nil
}
```

What if the type would NOT implement `Set`? `Flagarize` will return error with helpful message as we expect 🤗:

```bash
go run example/custom_type/main.go --help

2020/03/22 11:59:25 flagarize: flagarize struct Tag found on not supported type string main.YourCustomType for field "Field2"
exit status 1
```

### But passing long help in struct tag is weird and what if I need to evaluate it in runtime?

True that. In this case Flagarize allows to specify `<fieldName>FlagarizeHelp` variable which will hold field's help in string.

See below example (also available [here](https://github.com/bwplotka/flagarize/blob/6d668ce203a70fd6e10c3cd532fe3d64a1ac77c6/example/custom_help/main.go#L28)):

```go
const prefix = "AlwaysAddingPrefix"

type YourCustomType string

func (cst *YourCustomType) Set(s string) error {
	*cst = YourCustomType(fmt.Sprintf("%s%s", prefix, s))
	return nil
}

func main() {
	a := kingpin.New(filepath.Base(os.Args[0]), "<Your CLI description>")

	type ConfigForCLI struct {
		Field1              string         `flagarize:"name=flag1|help=Some help.|default=Some Value|envvar=FLAG1|short=f|placeholder=<put some string here>"`
		Field2              YourCustomType `flagarize:"name=custom-type-flag|required=true|short=c|placeholder=<put some my custom type here>"`
		Field2FlagarizeHelp string
	}
    cfg := &ConfigForCLI{
		Field2FlagarizeHelp: fmt.Sprintf("Custom Type always add prefix %q to the given string value.", prefix),
	}
```

## Under the hood

There could be probably another blog post about this topic, but I will try to be brief. Everything works thanks to standard `reflect` library that
Go has. For each struct (including nested and embedded ones), we can reflect `value` and `type` of each field:

```go
for i := 0; i < value.NumField(); i++ {
		fieldType := value.Type().Field(i)
		fieldValue := value.Field(i)
``` 

Then we can parse the struct tag thanks to `fieldType.Tag` struct:

```go
val, ok := fieldType.Tag.Lookup(flagTagName)
if !ok {
    return nil, nil
}
```

Before moving forward we can detect if it's struct OR embedded type, so we recursively parse that as well:

```go
if tag == nil {
    if fieldValue.Kind() == reflect.Struct && (field.PkgPath == "" || field.Anonymous) {
        if err := parseStruct(r, fieldValue, o); err != nil {
            return err
        }
    }
    continue
}
```

After some extra checks before actually registering a flag for known types, we can check if the field's type supports any
of our two interfaces. In this case, we favor custom parsing. 

We do that by casting our interface from the field's value as `interface()` with a check. Then if make sure it's allocated.
Then we actually invoke it:

```go
if _, ok := fieldValue.Interface().(Flagarizer); ok {
    allocPtrIfNil(fieldValue)
    // Do fieldValue.Interface() once more as after alloc the copied value is not changed.
    if err := invokeCustomFlagarizer(r, fieldValue.Interface().(Flagarizer), tag, fieldValue, name); err != nil {
        return true, err
    }
    return true, nil
}
``` 

This is quite tricky as we can have some pointer to type `*type` and this will work for the above statement, but someone can put type as value `type`
so pointer for some type. Still, if the custom method is pointer receiver this will work for `flagarize` thanks to `Addr()` method. 
That's why we need 3 more checks like the above:

```go
if _, ok := fieldValue.Addr().Interface().(Flagarizer); ok {
    // ...
}
if _, ok := fieldValue.Interface().(ValueFlagarizer); ok {
    // ...
}
if _, ok := fieldValue.Addr().Interface().(ValueFlagarizer); ok {
    // ...
}
``` 

The allocation is interesting as well, you can allocate `nil` field as follows (unless it is a map!).

```go
func allocPtrIfNil(fieldValue reflect.Value) {
	if fieldValue.Kind() == reflect.Ptr {
		if fieldValue.IsNil() {
			fieldValue.Set(reflect.New(fieldValue.Type().Elem()))
		}
	}
}
```

And now the interesting part. How we register the flag for all the "native" types? We have a monster switch for all types we support
[here](https://github.com/bwplotka/flagarize/blob/74e3b786966dc060ec75245c2b6d55c5ea131ec0/flagarize.go#L233).

Let's take one case of it, for example: 

```go
clause := tag.Flag(r)
switch fieldValue.Interface().(type) {
    case float32:
        clause.Float32Var((*float32)(unsafe.Pointer(fieldValue.Addr().Pointer())))
    // ...
}
```

This registers a `kingpin` flag to be set on our field's address and expects the flag to be our field's type. In this case for `float32`.
Since the field type is a value, not a pointer, we have to first take the pointer of our field so `fieldValue.Addr()`.
Then we need to ask for `unsafe.Pointer` using `Pointer()` method. Only then we can convert this pointer to `*float32`
which is what `kingpin's` `Float32Var` expects!

And that's it! The reflection might be difficult in the beginning, but after all, it's not that complex! (: 

## Summary

I think [`flagarize`](https://github.com/bwplotka/flagarize) fixed all problems mentioned earlier without introducing many new ones! (:

1. With [`flagarize`](https://github.com/bwplotka/flagarize) it is clear what fields from the Go struct are actually set from flags. You just look if they have `flagarize` struct tag!
You can easily encapsulate deeply nested structs e.g. for components - this will work too!
2. It's harder to miss that some configuration variable is not used anymore since the field will be just clearly unused outside of `reflect` inside Flagarize. 
3. We can define the field in a struct and register as a flag in a single place.
4. What if we would like to parse our configuration from JSON or YAML as well? Just add `yaml:` or `json:` struct tag and use `json/yaml.Unmarshal`. Done.
5. What about complex flags like Thanos's [`path or content`](https://github.com/thanos-io/thanos/blob/master/pkg/extflag/pathorcontent.go)? Well ,one thing is that
`flagarize` supports some complex types natively like `Regexp, AnchoredRegexp, TimeOrDuration, PathOrContent`, secondly adding new custom ones is super easy with 2 interfaces.
explained in [README.md](https://github.com/bwplotka/flagarize)

### Other projects

Truth is that there are some nice projects in the open source already existing with similar patter:

* [`octago/sflag`](https://github.com/octago/sflags):  This is quite epic as it is more generalized and works for most of the popular flag libraries. However, it
does not support (?) custom types or custom flag registering. To me, the API and error messages could be better as well. It's nice when the library avoids allowing
more than one way of doing the same thing.

* [`alecthomas/kong`](https://github.com/alecthomas/kong): This is very similar to `flagarize`. In fact it, is actually written by
the author of [`kingpin`](https://github.com/alecthomas/kingpin) library! Even better, it's meant to replace it. Still, I think it does not support some
complex types `flagarize` supports out of the box, and there are way too many ways to extend it... and make a bug on the way. (: 
Also, I am not a great fan of `kong` struct tag format. It does not own just one struct tag, it kind of use.. all of them as a map.
This is then tricky to provide friendly error message if someone makes a typo in the struct tag, etc.
 
Still, it's worth looking on those two if you considering moving to struct tag pattern. Great job by all those maintainers
for providing such amazing tools to open source Go devs! ❤️ 

### The end

While writing [`flagarize`](https://github.com/bwplotka/flagarize) I definitely had lots of fun and learned a bit of reflect on the way.
However, this library was not purely for fun. I just released [v0.9.0](https://github.com/bwplotka/flagarize/releases/tag/v0.9.0) (wanted 0.999.0 but let's be serious ;p)
I plan to maintain and use in production for our open source projects like Prometheus ([PR is in review](https://github.com/prometheus/prometheus/pull/7026))
and [Thanos](https://github.com/thanos-io/thanos/pull/2267) thanks to [Philip](https://github.com/PhilipGough).

1,0 release is planned once we adopt it in [Thanos](https://thanos.io).
