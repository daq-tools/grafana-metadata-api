####################
grafana-metadata-api
####################


*****
About
*****

The `Simple JSON Datasource`_ plugin is a generic backend datasource
plugin serving the purpose of a hackable datasource implementation.

The goal is to map Grafana template variable values to display text
using the `Simple JSON Datasource`_ plugin.

This is the server-side component of the Grafana Metadata API.
It just delivers json files after applying some basic routing, really.

See also `Map Grafana template variable identifiers to text labels using HTTP calls <https://community.hiveeyes.org/t/1189>`_.


*****
Setup
*****

Backend
=======

Source code
-----------
::

    git clone https://github.com/daq-tools/grafana-metadata-api /opt/grafana-metadata-api


Nginx server section
--------------------
::

    lua_shared_dict metadata_routes 1M;


Nginx virtual host section
--------------------------
::

    server {

        # ...

        # Configure Grafana Metadata API
        include /opt/grafana-metadata-api/src/grafana-metadata-api.conf;

    }


*************
General usage
*************

Add file
========
- Just drop some ``.json`` files into ``/var/lib/grafana-metadata-api``::

    $ cat /var/lib/grafana-metadata-api/luftdaten-stations.json
    [
        {"value": 8119, "text": "Karlsbader Stra\u00dfe, B\u00fcchenbach, Bayern, DE"},
        {"value": 1234, "text": "Hauptstra\u00dfe, Wolfratshausen, Bayern, DE"}
    ]

HTTP API
========
::

    # Will always work
    echo '{"target": "luftdaten-stations.json"}' | http POST https://weather.hiveeyes.org/metadata/search

    # Will work with custom routes
    echo '{"target": "SELECT * FROM luftdaten_stations"}' | http POST https://weather.hiveeyes.org/metadata/search



******************
Usage from Grafana
******************

Grafana plugin
==============
Please install the plugin `Simple JSON Datasource`_ - a generic backend datasource
into your Grafana instance::

    grafana-cli plugins install grafana-simple-json-datasource
    systemctl restart grafana-server


Grafana datasource
==================
Add a new data source to your Grafana instance::

    Name:   environmental-metadata
    Type:   SimpleJson
    URL:    https://weather.hiveeyes.org/metadata
    Access: proxy

See also https://community.hiveeyes.org/t/1189.


Grafana variable
================
Add a new data source to your Grafana dashboard::

    Name:           location_id
    Label:          Location
    Type:           Query

    Data source:    environmental-metadata
    Refresh:        On Dashboard Load
    Query:          luftdaten-stations.json
    Sort:           Alphabetical (asc)

    Multi-value:    yes

See also https://community.hiveeyes.org/t/1189.


.. _Simple JSON Datasource: https://grafana.com/plugins/grafana-simple-json-datasource
.. _simple-json-datasource: https://github.com/grafana/simple-json-datasource
