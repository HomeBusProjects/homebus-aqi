# homebus-aqi

This is a simple HomeBus data source which publishes weather conditions from AirNow

## Usage

On its first run, `homebus-aqi` needs to know how to find the HomeBus provisioning server.

```
bundle exec homebus-aqi -z zipcode -b homebus-server-IP-or-domain-name -P homebus-server-port
```

The port will usually be 80 (its default value).

Once it's provisioned it stores its provisioning information in `.env.provisioning`.

`homebus-aqi` also needs to know:

- the zipcode being monitored

