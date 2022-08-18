# fly-log-local

Local logging at Fly using Vector and Loki.

This app reads the [Fly NATS endpoint](https://community.fly.io/t/fly-logs-over-nats/1540) using [Vector](https://vector.dev/docs/reference/configuration/sources/nats/) which then sends to [Loki](https://grafana.com/docs/loki/latest/) for the datastore on the attached volume.  The logs can later be accessed via [Logcli](https://grafana.com/docs/loki/latest/tools/logcli/) or any other Loki client.  In this example the Loki endpoint is running without authentication and only accessible via [fly proxy](https://fly.io/docs/flyctl/proxy/).


## Quickstart

#### Create Fly app
```
fly apps create <insert-app-name>
```

#### Edit fly.toml

Update the app name.
```
app = "<insert-app-name>"
```

#### Create volume
```
fly volumes create log_data
```

#### Create secret

```
fly secrets set ACCESS_TOKEN=$(fly auth token)
```

#### Scale memory ( optional )

```
fly scale memory 512
```

#### Deploy

```
fly deploy
```

#### Install logcli

```
brew install logcli
```

#### Start proxy

```
fly proxy 3100:3100
```

#### Search loki

Tailing all app logs.
```
~/ logcli query -z UTC -q '{forwarder="vector"}' -t
2022-08-18T14:33:35Z {fly_app="fly-log-local-example", fly_instance="c1046e0d", forwarder="vector"} 2022-08-18 14:33:35,571 INFO success: loki entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
2022-08-18T14:33:35Z {fly_app="fly-log-local-example", fly_instance="c1046e0d", forwarder="vector"} 2022-08-18 14:33:35,572 INFO success: vector entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
2022-08-18T14:40:51Z {fly_app="bold-star-5487", fly_instance="97200383", forwarder="vector"} Starting instance
2022-08-18T14:40:58Z {fly_app="bold-star-5487", fly_instance="97200383", forwarder="vector"} Configuring virtual machine
2022-08-18T14:40:58Z {fly_app="bold-star-5487", fly_instance="97200383", forwarder="vector"} Pulling container image
2022-08-18T14:40:58Z {fly_app="bold-star-5487", fly_instance="97200383", forwarder="vector"} Unpacking image
2022-08-18T14:40:58Z {fly_app="bold-star-5487", fly_instance="97200383", forwarder="vector"} Preparing kernel init
2022-08-18T14:40:59Z {fly_app="bold-star-5487", fly_instance="97200383", forwarder="vector"} Configuring firecracker
2022-08-18T14:40:59Z {fly_app="bold-star-5487", fly_instance="97200383", forwarder="vector"} Starting virtual machine
2022-08-18T14:40:59Z {fly_app="bold-star-5487", fly_instance="97200383", forwarder="vector"} Starting init (commit: 9b0a951)...
...
```


Specific app and from time.
```
~/ logcli query -z UTC -q --from="2022-08-18T14:30:00Z" '{fly_app="fly-log-local-example"}'
2022-08-18T14:33:35Z {} 2022-08-18 14:33:35,572 INFO success: vector entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
2022-08-18T14:33:35Z {} 2022-08-18 14:33:35,571 INFO success: loki entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
```

Additional documentation can be found here: https://grafana.com/docs/loki/latest/tools/logcli/
