#!/bin/bash

psql -d painel -c 'vacuum full;'
