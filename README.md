# DesignSafe-CI Notebook Images

## Summary

This repository includes the DesignSafe-CI notebook images deployed via the site's JupyterHub.
The projects organization is such that each folder includes a different notebook image with associated
components.

## Syntax

### Build

```bash
docker build ./<dir>/ -t <user>/<repo>:<tag>

# for example
docker build ./nbase/ -t jpvantassel/ds-nb-img:nbase-0.1.0rc0
```

### Run

#### Local

```bash
docker run --rm -p 8888:8888 <user>/<repo>:<tag> --user=jovyan

# for example
docker run --rm -p 8888:8888 jpvantassel/ds-nb-img:nbase-0.1.0rc0 --user=jovyan
``` 

#### Remote - Test

See [admin portal](https://designsafe-dev-admin.io.jupyter.tacc.cloud/)

#### Remote - Prod

## Notes

[jupyter-base](https://github.com/jupyter/docker-stacks/blob/master/base-notebook/Dockerfile)
[portal-agave-templates](https://bitbucket.org/taccaci/portal-agave-templates/src/master/)
[designsafe-docker-gitlab](https://gitlab.tacc.utexas.edu/cic/jupyter/-/blob/master/notebooks/tenants/designsafe/Dockerfile)
[running jupyter container](https://jupyter-docker-stacks.readthedocs.io/en/latest/using/running.html#using-jupyterhub)
[jpvantassel dockerhub](https://hub.docker.com/repository/docker/jpvantassel/)