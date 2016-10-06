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

* You must set the location of the client certificates.  For example,
  to use public key distribution managed by Puppet via the SIMP pki
  module:

```
    mcollective::ssl_client_certs : 'puppet:///modules/pki/keydist/mcollective'
```

  **NOTE:** This directory must exist for MCollective to start. Also,
  if this directory is to be managed by Puppet, it must be accessible
  to the `puppet` or `pe-puppet` user.

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

* The CA that generated the user keypair must be added to the middleware
  truststore.  By default, the `simp::mcollective` stock class will
  configure MCollective to add the certificates managed by the
  Puppet via the SIMP pki module. These certificates reside in
  `/etc/pki/cacerts/cacerts.pem`.

* You can generate the user's RSA public key from the private key
  as follows:

```
    openssl rsa -in mco_user.pem -pubout > mco_user_rsa.pem
```

* The user must have access to the mcollective public certificate,
  which is auto-generated and resides in
  `/etc/mcollective/ssl/mco_autokeys/mco_public.pem`.

* In order to use public key distribution managed by Puppet via
  the SIMP pki module, it is recommended the user's RSA public key
  be copied to `/etc/puppet/environments/simp/keydist/mcollective`.

  **NOTE:** Make sure this file as well as the `mcollective`
  sub-directory in which it is placed are accessible to the `puppet`
  or `pe-puppet` user.


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
