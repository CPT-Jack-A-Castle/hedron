#!/bin/sh

set -e

# Assumes we are in the extracted amd gpu directory.

dpkg -i amdgpu-pro-core_17.40-492261_all.deb libopencl1-amdgpu-pro_17.40-492261_amd64.deb clinfo-amdgpu-pro_17.40-492261_amd64.deb opencl-amdgpu-pro-icd_17.40-492261_amd64.deb libdrm2-amdgpu-pro_2.4.82-492261_amd64.deb amdgpu-pro-dkms_17.40-492261_all.deb libdrm-amdgpu-pro-amdgpu1_2.4.82-492261_amd64.deb ids-amdgpu-pro_1.0.0-492261_all.deb
