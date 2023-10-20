# NGINX Plus on Docker

This repo contains instructions and files for building NGINX Plus Docker image and publishes it to an image registry.

Build instructions are based on [official documentation](https://docs.nginx.com/nginx/admin-guide/installing-nginx/installing-nginx-docker/#running-nginx-plus-in-a-docker-container).

## Instructions

1. Copy [example.env](./example.env) to a `.env` file in the project root directory.
1. Configure values of environment variables in `.env` file as required.
1. Run `./run.sh`
