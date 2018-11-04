###########################
grafana-metadata-api README
###########################

*****
About
*****

Map Grafana template variable value to display text
using the Simple JSON Datasource plugin.

This just delivers json files after applying
some basic routing, really.

See also https://community.hiveeyes.org/t/1189


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



*****
Usage
*****

Add file
========
- Just drop some ``.json`` files into ``/var/lib/grafana-metadata-api``::

    $ cat /var/lib/grafana-metadata-api/luftdaten-stations.json
    [
        {"value": 8119, "text": "Karlsbader Stra\u00dfe, B\u00fcchenbach, Bayern, DE"},
        {"value": 1234, "text": "Hauptstra\u00dfe, Wolfratshausen, Bayern, DE"}
    ]

Synopsis
========
::

    # Will always work
    echo '{"target": "luftdaten-stations.json"}' | http POST https://weather.hiveeyes.org/metadata/search

    # Will work with custom routes
    echo '{"target": "SELECT * FROM luftdaten_stations"}' | http POST https://weather.hiveeyes.org/metadata/search



Grafana datasource
==================
Todo.

- https://github.com/grafana/simple-json-datasource
- https://community.hiveeyes.org/t/1189


Grafana variable
================
Todo.
