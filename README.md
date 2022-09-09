# homebus-aqi

![rspec](https://github.com/HomeBusProjects/homebus-aqi/actions/workflows/rspec.yml/badge.svg)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](code_of_conduct.md)

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

