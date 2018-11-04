####################
grafana-metadata-api
####################


*****
About
*****

The `Simple JSON Datasource`_ plugin is a backend datasource
that sends generic HTTP requests to a given URL.

The goal is to map Grafana template variable values to display
text using the `Simple JSON Datasource`_ plugin.

This is the server-side component of the Grafana Metadata API,
serving as a hackable datasource implementation.

Being in its infancy, it just delivers static JSON files after
applying some basic routing.

See also `Map Grafana template variable identifiers to text labels using HTTP requests <https://community.hiveeyes.org/t/1189>`_.


*****
Setup
*****

See also `Setup grafana-metadata-api <https://community.hiveeyes.org/t/1189/3>`_.


Backend
=======

Prerequisities
--------------
::

    apt install nginx-extras lua-cjson git


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
Just drop some ``.json`` files into ``/var/lib/grafana-metadata-api``::

    $ cat /var/lib/grafana-metadata-api/luftdaten-stations-grafana.json
    [
        {"value": 8119, "text": "Karlsbader Stra\u00dfe, B\u00fcchenbach, Bayern, DE"},
        {"value": 1234, "text": "Hauptstra\u00dfe, Wolfratshausen, Bayern, DE"}
    ]

Grafana will use the ``text`` property as a the template variable's label,
and the ``value`` property as the raw value of the template variable.


HTTP API
========
The files dropped into ``/var/lib/grafana-metadata-api`` will be
offered through a HTTP API::

    # GET request with filename in URI
    http https://weather.hiveeyes.org/metadata/luftdaten-stations-grafana.json

    # POST with filename as target
    echo '{"target": "luftdaten-stations-grafana.json"}' | http POST https://weather.hiveeyes.org/metadata/search

    # POST with query expression as target (using custom routes)
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

See also https://community.hiveeyes.org/t/1189/3.


Grafana variable
================
Add a new data source to your Grafana dashboard::

    Name:           location_id
    Label:          Location
    Type:           Query

    Data source:    environmental-metadata
    Refresh:        On Dashboard Load
    Query:          luftdaten-stations-grafana.json
    Sort:           Alphabetical (asc)

    Multi-value:    yes

See also https://community.hiveeyes.org/t/1189/4.


.. _Simple JSON Datasource: https://grafana.com/plugins/grafana-simple-json-datasource
.. _simple-json-datasource: https://github.com/grafana/simple-json-datasource
