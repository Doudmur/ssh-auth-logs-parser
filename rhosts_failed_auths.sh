#!/bin/bash
# Script to get failed SSH rhosts from /var/log/auth.log

awk -F'rhost=' '/authentication failure/ {
    split($2,a," ");
    print a[1]
}' /var/log/auth.log | wc -l
