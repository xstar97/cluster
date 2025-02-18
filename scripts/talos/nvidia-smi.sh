#!/bin/bash

echo testing nvidia-smi through the cluster...

kubectl run nvidia-test --restart=Never -ti --rm --image nvcr.io/nvidia/cuda:12.1.0-base-ubuntu22.04 --overrides='{"spec": {"runtimeClassName": "nvidia"}}' -- nvidia-smi
