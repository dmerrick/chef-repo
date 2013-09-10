#!/bin/bash

vagrant destroy -f
knife node delete -y app0
knife client delete -y app0
vagrant up
