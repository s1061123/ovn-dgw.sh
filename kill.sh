#!/bin/bash


for i in master worker; do
	sudo podman kill $i
done

