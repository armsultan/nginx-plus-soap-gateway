# Nginx Plus Base

A NGINX Plus base dockerfile and configuration for testing

## File Structure

```
/
├── etc/
│    ├── nginx/
│    │    ├── conf.d/ # ADD your HTTP/S configurations here
│    │    │   ├── vinrouter.conf......HTTP Virtual Server configuration
│    │    │   ├── dummy_vin_servers_json.conf...Dummy loopback web servers responds with application/json
│    │    │   ├── dummy_servers.conf............Dummy Upstream configurations: PRODUCTION, ENTERTAINMENT and "X"
│    │    │   ├── health_checks.conf............Custom health check definitions
│    │    │   └── status_api.conf...........NGINX Plus Live Activity Monitoring available on port 8080 - [Source](https://gist.github.com/nginx-gists/│a51 341a11ff1cf4e94ac359b67f1c4ae)
│    │    ├── includes
│    │    │    ├── add_headers
│    │    │    │   └── security.conf_ ....................Recommended response headers for security
│    │    │    ├── proxy_headers
│    │    │    │   └── load_balancing_algorithms.conf.....Recommended request headers for security and performance
│    │    │    └── ssl
│    │    │        ├── ssl_intermediate.conf.....Recommended SSL configuration for General-purpose servers with a variety of clients, recommended for almost all systems
│    │    │        ├── ssl_a+_strong.conf........Recommended SSL configuration for Based on SSL Labs A+ (https://www.ssllabs.com/ssltest/)
│    │    │        ├── ssl_modern.conf...........Recommended SSL configuration for Modern clients: TLS 1.3 and don't need backward compatibility
│    │    │        └── ssl_old.conf..............Recommended SSL configuration for compatiblity ith a number of very old clients, and should be used only as a last resort
│    │    ├── nginx.conf ...............Main NGINX configuration file with global settings
|    |    └── api_json_errors.conf .....Custom API error reponses (used when proxy_intercept_errors on)
|    |          
│    └── ssl/
│          ├── nginx/
│          │   ├── nginx-repo.crt........NGINX Plus repository certificate file (**Use your own license**)
│          │   └── nginx-repo.key........NGINX Plus repository key file (**Use your own license**)
│          ├── dhparam_2048.pem..........Diffie-Hellman parameters for testing (2048 bit)
│          ├── dhparam_4096.pem..........Diffie-Hellman parameters for testing (4096 bit)
│          ├── example.com.crt...........Self-signed wildcard certifcate for testing (*.example.com)
│          └── example.com.key...........Self-signed private key for testing
├── usr/
│   └── share/
│        └── nginx/
│              └── html/
│                    └── demo-index.html...Demo HTML webpage with placeholder values
└── var/
     ├── cache/
     │    └── nginx/ # Example NGINX cache path for storing cached content
     └── lib/
          └── nginx/
               └── state/ # The recommended path for storing state files on Linux distributions
```

## Build Docker container

 1. Copy and paste your `nginx-repo.crt` and `nginx-repo.key` into `etc/ssl/nginx` directory

 2. Build an image from your Dockerfile:
    ```bash
    # Run command from the folder containing the `Dockerfile`
    $ docker build -t nginx-plus .
    ```
 3. Start the Nginx Plus container, e.g.:
    ```bash
    # Start a new container and publish container ports 80, 443 and 8080 to the host
    $ docker run -d -p 80:80 -p 443:443 -p 8080:8080 nginx-plus
    ```

    **To mount local volume:**

    ```bash
      docker run -d -p 80:80 -p 443:443 -p 8080:8080 \
      -v $PWD/etc/nginx/conf.d:/etc/nginx/conf.d \
      -v $PWD/etc/nginx/includes:/etc/nginx/includes \
      -v $PWD/etc/nginx/nginx.conf:/etc/nginx/nginx.conf \
      -v $PWD/etc/nginx/api_soap_errors.conf:/etc/nginx/api_soap_errors.conf \
      nginx-plus
    ```

 1. To run commands in the docker container you first need to start a bash session inside the nginx container
    ```bash
    docker ps # get Docker IDs of running containers
    sudo docker exec -i -t [CONTAINER ID] /bin/sh
    ```

 2. To open logs
    ```bash
    docker ps # get Docker IDs of running containers
    sudo docker logs -f [CONTAINER ID]
    ```