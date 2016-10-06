[![License](http://img.shields.io/:license-apache-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html) [![Build Status](https://travis-ci.org/simp/pupmod-simp-mcollective.svg)](https://travis-ci.org/simp/pupmod-simp-mcollective) [![SIMP compatibility](https://img.shields.io/badge/SIMP%20compatibility-4.2.*%2F5.1.*-orange.svg)](https://img.shields.io/badge/SIMP%20compatibility-4.2.*%2F5.1.*-orange.svg)

SIMP MCollective Deployment Guide
=================================

## Overview and Module Description

The SIMP MCollective module is an extension of
[voxpupuli/puppet-mcollective](https://github.com/voxpupuli/puppet-mcollective).
Like voxpupuli's module, this module conforms to the
[mcollective standard deployment guide](http://docs.puppetlabs.com/mcollective/deploy/standard.html),
where appropriate. This module is most effectively used in conjunction with the
[simp::mcollective stock class](https://github.com/simp/pupmod-simp-simp/blob/master/manifests/mcollective.pp),
which sets up Java, ActiveMQ, and MCollective with SSL fully enabled and
installs the Puppet, Service and Package MCollective plugins.

## Setup

MCollective has three primary components: server, client, and middleware.
By default, any node that includes the
[simp::mcollective stock class](https://github.com/simp/pupmod-simp-simp/blob/master/manifests/mcollective.pp)
will include the server and middleware components:

```
    classes:
      - 'simp::mcollective'
```

However, additional settings are required to use this stock class.

* Access to each mco server is cert based.  You will create user certs later on,
  see 'Key Setup', but first you must specify where they will be distributed from.
  It is recommended every user's cert be distributed by Puppet.  There are
  two methods:

  1. Distribute user keys per fqdn, as access requirements dictate.

     a. In keydist, create an mcollective subdirectory for each fqdn:

```
    mkdir  ${::envpath}/keydist/${::fqdn}/mcollective
    chown root.puppet ${::envpath}/keydist/${::fqdn}/mcollective
    chmod 750 ${::envpath}/keydist/${::fqdn}/mcollective
```

     **NOTE:** The simp-provided `/etc/puppet/auth.conf` file comes pre-loaded
     with ACLs protecting each `${::envpath}/keydist/${::fqdn}` directory.
     See auth.conf for more details.

     b. Set the following in hiera, default.yaml

```
    mcollective::ssl_client_certs : 'puppet:///modules/pki/keydist/%{::fqdn}/mcollective'
```

  2. Distribute user keys universally, giving every user access to every mco server.

    a. In keydist, create a global mcollective directory:

```
    mkdir ${::envpath}/keydist/mcollective
    chown root.puppet ${::envpath}/keydist/mcollective
    chmod 750 ${::envpath}/keydist/mcollective
```

    **NOTE:** The simp-provided `/etc/puppet/auth.conf` file comes pre-loaded
    with ACLs giving all hosts access to the `${::envpath}/keydist/mcollective`
    directory.

    b. Set the following in hiera, default.yaml

```
    mcollective::ssl_client_certs : 'puppet:///modules/pki/keydist/mcollective'
```

* You must set at least one ActiveMQ broker server, or each node will default
  to communicating only with itself.  For example,

```
    simp::mcollective::activemq_brokers:
      - <middleware.server.fqdn>
```

* If you want a node to be a client as well, set:

```
    simp::mcollective::mco_client: true
```

* If you do not want a node to be a server, set:

```
    simp::mcollective::mco_server: false
```


## Security

For details about the MCollective security framework, reference the
[MCollective security overview](https://puppetlabs.com/mcollective/security-overview).

When this module is used in conjunction with the
[simp::mcollective stock class](https://github.com/simp/pupmod-simp-simp/blob/master/manifests/mcollective.pp),
full SSL is enabled in every component of MCollective by default.  PAM and
IPtables support is integrated as well.

This module supports RPC authorization and auditing.  See the
[mcollective-actionpolicy-plugin documentation](https://github.com/puppetlabs/mcollective-actionpolicy-auth) for details about creating policies.

## Setting Up A User (Client)

### Key Setup

Each MCollective user (client) must have an x509 keypair, an RSA
public key, and access to the mcollective public certificate.

* The user keypair can be supplied externally or generated with the
  SIMP FakeCA, using `environments/simp/FakeCA/usergen_nopass.sh`.
  (See the README in the FakeCA directory for more details.)

* You can generate the user's RSA public key from the private key
  as follows:

```
    openssl rsa -in mco_user.pem -pubout > mco_user_rsa.pem
```

* The CA that generated the user keypair must be added to the middleware
  truststore.  By default, the `simp::mcollective` stock class will
  configure MCollective to add the certificates managed by Puppet via
  the SIMP pki module. These certificates reside in
  `/etc/pki/cacerts/cacerts.pem`.

* The user must have access to the mcollective public certificate,
  which is auto-generated and resides in
  `/etc/mcollective/ssl/mco_autokeys/mco_public.pem`.  See the 'Configuration
  File' `plugin.ssl_server_public` for more details.

* Copy each user's RSA public key to the appropriate `mcollective::ssl_client_certs`
  directory (or directories), specified earlier in this doc.

### Configuration File

Every MCollective user needs a `.mcollective` configuration file.  This
file must reference the user's keys, the CA, and the mcollective public
key, as well as the middleware host, username, and password.  This file
should only be accessible by the MCollective user.

Here is example configuration file suitable for use with the `simp::mcollective`
stock class:

    collectives = mcollective
    connector = activemq
    direct_addressing = 1
    libdir = /usr/local/libexec/mcollective:/usr/libexec/mcollective
    logger_type = console
    loglevel = warn
    main_collective = mcollective
    plugin.activemq.base64 = yes
    plugin.activemq.pool.1.host = <middleware.host.fqdn>
    plugin.activemq.pool.1.password = <broker user password>            (activemq non-admin user password)
    plugin.activemq.pool.1.port = 61614
    plugin.activemq.pool.1.ssl = 1
    plugin.activemq.pool.1.ssl.ca = /etc/pki/cacerts/cacerts.pem        (default CA)
    plugin.activemq.pool.1.ssl.cert = </home/mco_user/ssl/mco_user.pub> (x509 user cert)
    plugin.activemq.pool.1.ssl.fallback = 0
    plugin.activemq.pool.1.ssl.key = </home/mco_user/ssl/mco_user.pem>  (x509 user key)
    plugin.activemq.pool.1.user = <broker user>                         (activemq non-admin username)
    plugin.activemq.pool.size = 1
    plugin.activemq.randomize = true
    plugin.ssl_client_private = </home/mco_user/ssl/mco_user.pem>       (x509 user key)
    plugin.ssl_client_public = </home/mco_user/ssl/mco_user_rsa.pem>     (RSA user cert)
    plugin.ssl_server_public = </home/mco_user/ssl/mco_public.pem>      (auto-generated mco public key)
    securityprovider = ssl

**NOTE:** The broker username and password are generated by the `simp::mcollective`
stock class and can found in `/etc/activemq/activemq.xml`.
