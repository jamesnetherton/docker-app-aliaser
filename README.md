# Docker App Aliaser

A simple script to create aliases for starting applications that run in [Docker](http://www.docker.com) containers.

Instead of having to go through the tedium of typing out and remembering all of the required parameters to pass to `docker run`, this script simplifies things by enabling you to treat running container applications like you would any other normal command.

For example, instead of this:

```
docker run -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix jamesnetherton/transmission
```
I can just do this to achieve the same thing:

```
transmission
```

You can override the default image `CMD` or add `ENTRYPOINT` arguments by adding command options like you would for any normal application.

```
transmission --version
```

## Dependencies

This project makes use of [jq](https://stedolan.github.io/jq/) for JSON parsing, so you'll need this available somewhere on your `$PATH` .

## Configuration

Copy or source the script from [docker-app-aliser.sh](docker-app-aliaser.sh) into your desired shell profile dotfile. Now create `${HOME}/.dockerapps`.

Docker apps can be specified in `${HOME}/.dockerapps` with JSON like the following.

```
{
  "apps": [
    {
      "name": "transmission",
      "image": "jamesnetherton/transmission",
      "args": "-e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v ${HOME}/Downloads:/downloads -v ${HOME}/.local:/home/transmission/.local -v ${HOME}/.config:/home/transmission/.config -v ${HOME}/.cache:/home/transmission/.cache"
    },
    {
      "name": "tomcat",
      "image": "tomcat:8",
      "daemonize": "false",
      "autoremove": "true"
    }
  ]
}
```

When you're done, load up your aliases by starting a new shell or sourcing your shell profile script. In future you can load new aliases simply by running `createAppAliases` from a terminal session.

### Docker apps JSON

| Attribute  | Description  | Required |
|---|---|---| 
| name  | This determines the name of the Docker container | Yes |
| image  | The Docker image to use  | Yes |
| args  | Docker command line arguments like volumes, environment variables, devices etc  | No |
| daemonize | Whether to start the container in the background. The default is __true__. | No |
| autoremove | When __true__ (the default is __false__), appends `--rm` to the docker run command. Only takes effect when daemonize is __false__. | No |
