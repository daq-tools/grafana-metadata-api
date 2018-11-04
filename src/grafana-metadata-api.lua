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
-- Compute designated target
local target

-- For non-body requests (e.g. GET), use target from URI
if ngx.var.request_body == nil then
    target = "luftdaten-stations.json"
    -- ngx.log(ngx.ERR, "request_uri: ", ngx.var.request_uri)
    -- ngx.log(ngx.ERR, "request_uri_prefix: ", ngx.var.request_uri_prefix)
    target = ngx.var.request_uri:gsub(ngx.var.request_uri_prefix .. "/", "")

-- For requests with bodies (e.g. POST), use target from JSON body
else
    -- Decode request body from JSON
    local data = cjson.decode(ngx.var.request_body)

    -- Use designated target from "target" attribute
    target = data.target

    --return 200
end


-- Add single route for dispatching by file names ending with .json
local match, error = ngx.re.match(target, "^.+\\.json$", "ij")
if match then
    file_route = {
        target = target,
        uri    = "/" .. target,
    }
    table.insert(routes, file_route)
end

-- Dispatch routes
for i, route in pairs(routes) do
    if ngx.re.match(target, route.target, "ij") then
        local response = ngx.location.capture(
            route.uri,
            { method = ngx.HTTP_GET }
        )
        -- ngx.log(ngx.ERR, target, route.target)
        -- ngx.log(ngx.ERR, err)
        -- ngx.log(ngx.ERR, "'" .. response.body .. "'")
        if response.body ~= "" then
            ngx.status = 200
            ngx.print(response.body)
            ngx.exit(ngx.OK)
        end
    end
end

-- Routes did not match, so croak
--ngx.status = 400
--ngx.print("Bad Request: Target \"" .. target .. "\" not implemented")
ngx.status = 404
ngx.print("Resource not found: " .. target)
ngx.exit(ngx.OK)
