-- -*- coding: utf-8 -*-
--[[

Server-side component of the Grafana Metadata API.
https://github.com/daq-tools/grafana-metadata-api

(c) 2018 Andreas Motl <andreas@hiveeyes.org>
License: GNU Affero General Public License, Version 3


Description

Map Grafana template variable value to display text
using the Simple JSON Datasource plugin.

This just delivers json files after applying
some basic routing, really.

]]


-- Main program
local cjson = require "cjson";

-- Ensure the request body is here
ngx.req.read_body()


-- The routes container
routes = {}

-- Collect metadata routes from shared environment
local metadata_routes = ngx.shared.metadata_routes
if metadata_routes ~= nil then
    for k,v in pairs(metadata_routes) do
        table.insert(routes, v)
    end
end

-- Return early if request body empty, i.e. no sound POST request
if ngx.var.request_body == nil then
    return 200
end

-- Decode request body from JSON
local data = cjson.decode(ngx.var.request_body)

-- Add single route for dispatching by file names ending with .json
local match, error = ngx.re.match(data.target, "^.+\\.json$", "ij")
if match then
    file_route = {
        target = data.target,
        uri    = "/" .. data.target,
    }
    table.insert(routes, file_route)
end

-- Dispatch routes
for i, route in pairs(routes) do
    if ngx.re.match(data.target, route.target, "ij") then
        res = ngx.location.capture(
            route.uri,
            { method = ngx.HTTP_GET }
        )
        ngx.print(res.body)
        ngx.status = 200
        ngx.exit(ngx.OK)
    end
end

-- Routes did not match, so croak
ngx.status = 400
ngx.print("Bad Request: Target \"" .. data.target .. "\" not implemented")
ngx.exit(ngx.OK)
