# ytt-docker
A dockerfile for [k14s/ytt](https://github.com/k14s/ytt)

[
    ![](https://images.microbadger.com/badges/commit/gerritk/ytt:latest.svg)
    ![](https://images.microbadger.com/badges/image/gerritk/ytt:latest.svg)
    ![](https://img.shields.io/docker/pulls/gerritk/ytt)
](https://hub.docker.com/r/gerritk/ytt)


## Usage

Simply run the container and mount your files to `/workspace`, e.g.:

```shell
docker run --rm -v ${PWD}:/workspace gerritk/ytt -f .
```

For more convenience you can create an alias:

```shell
alias ytt='docker run --rm -v ${PWD}:/workspace gerritk/ytt'

ytt -f .
```

## Feedback

If you have suggestions on the structure of the Dockerfile or are looking for a specific version that is not available yet, feel free to create an issue.
