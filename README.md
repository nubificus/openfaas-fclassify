# openfaas-fclassify

This repo features an example image classification function pipeline for OpenFaaS supporting hardware acceleration using vAccel. The weird part is that we need to pipe the input from the HTTP request received from the watchdog to `stdin`, read it through `C` and feed it to the vAccel `image_classify()` API call. We use `fileread` and `pipe` to do that.

### build the OpenFaaS function container image

```
docker build -t registry.nubificus.co.uk/openfaas/openfaas-fclassify:latest --build-arg ARCH=$(uname -m) -f Dockerfile .
```
