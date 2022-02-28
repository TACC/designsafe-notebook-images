# DesignSafe-Cyberinfrastructure Notebook Images

## Summary

This repository includes the DesignSafe-Cyberinfrastructure's Jupyter notebook images deployed
via the site's JupyterHub.

## Useful Syntax

### Build

```bash
docker build . -t <user>/<repo>:<tag>

# for example
docker build . -t jpvantassel/ds-nb-img:base-0.1.0
```

### Push

```bash
docker push <user>/<repo>:<tag>

# for example
docker push jpvantassel/ds-nb-img:base-0.1.0
```

### Run

#### Local

```bash
docker run --rm -p 8888:8888 --user=jovyan -e JUPYTER_ENABLE_LAB=yes <user>/<repo>:<tag>

# for example
docker run --rm -p 8888:8888 --user=1824 -e JUPYTER_ENABLE_LAB jpvantassel/ds-nb-img:base-0.1.0
``` 

## Notes

- [jupyter-base](https://github.com/jupyter/docker-stacks/blob/master/base-notebook/Dockerfile)
- [portal-agave-templates](https://bitbucket.org/taccaci/portal-agave-templates/src/master/)
- [designsafe-docker-gitlab](https://gitlab.tacc.utexas.edu/cic/jupyter/-/blob/master/notebooks/tenants/designsafe/Dockerfile)
- [running jupyter container](https://jupyter-docker-stacks.readthedocs.io/en/latest/using/running.html#using-jupyterhub)
- [jpvantassel dockerhub](https://hub.docker.com/repository/docker/jpvantassel/)
- [admin portal](https://designsafe-dev-admin.io.jupyter.tacc.cloud/)
