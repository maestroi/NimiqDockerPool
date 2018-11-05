# Derived from official mysql image (our base image)
FROM mariadb:latest
# Add the content of the sql/ directory to your image
# All scripts in docker-entrypoint-initdb.d/ are automatically
# executed during container startup
COPY ./sql/ /docker-entrypoint-initdb.d/