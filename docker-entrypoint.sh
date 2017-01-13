#!/bin/bash

confd -onetime -backend env

exec /mysql-backup.pl
