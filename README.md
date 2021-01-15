# ytt-docker
A dockerfile for [vmware-tanzu/carvel-ytt](https://github.com/vmware-tanzu/carvel-ytt)

[
    ![](https://images.microbadger.com/badges/commit/gerritk/ytt:latest.svg)
    ![](https://images.microbadger.com/badges/image/gerritk/ytt:latest.svg)
    ![](https://img.shields.io/docker/pulls/gerritk/ytt)
](https://hub.docker.com/r/gerritk/ytt)


## Usage

### Templating

Simply run the container and mount your files to `/workspace`, e.g.:

```shell
docker run --rm -v ${PWD}:/workspace gerritk/ytt -f .
```


### Website docs

`ytt` originally comes with a built-in webserver that hosts the tools documentation.
To be able to use it in docker however you have to pass some command line flags:

```shell
docker run --rm -p 8080:8080 gerritk/ytt website --listen-addr=0.0.0.0:8080 --redirect-to-https=false
```


### Using an alias / function

It might be convenient to create an alias or function for the commands above.
Here are a couple of examples:

1. An alias for the base templating tool:
  ```shell
  alias ytt='docker run --rm -v ${PWD}:/workspace gerritk/ytt'
  ```
2. An alias for the website command:
  ```shell
  alias ytt-website='docker run --rm -p 8080:8080 gerritk/ytt website --listen-addr=0.0.0.0:8080 --redirect-to-https=false'
  ```
3. A function combining both:
  ```shell
  ytt () {
      if [ "$#" = "1" ] && [ "$1" = "website" ]; then
          docker run --rm -p 8080:8080 gerritk/ytt website --listen-addr=0.0.0.0:8080 --redirect-to-https=false
      else
          docker run --rm -v "${PWD}":/workspace gerritk/ytt "$@"
      fi
  }
  ```

## Feedback

If you have suggestions on the structure of the Dockerfile or are looking for a specific version that is not available yet, feel free to create an issue.
