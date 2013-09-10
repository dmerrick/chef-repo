#!/bin/bash

cat ~/.ssh/authorized_keys | grep '^[^#]' | sed -e 's/^/"/' -e 's/$/",/'
