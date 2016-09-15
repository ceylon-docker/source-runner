# Ceylon Source Runner

The following images/tags are available:

 - `1.3.0-jre8`, `1.3.0`, `latest` ([ceylon/Dockerfile](https://github.com/ceylon-docker/source-runner/blob/1.3.0-jre8/Dockerfile))
 - `1.2.2-jre8`, `1.2.2` ([ceylon/Dockerfile](https://github.com/ceylon-docker/source-runner/blob/1.2.2-jre8/Dockerfile))
 - `1.2.1-jre8`, `1.2.1` ([ceylon/Dockerfile](https://github.com/ceylon-docker/source-runner/blob/1.2.1-jre8/Dockerfile))
 - `1.2.0-jre8`, `1.2.0` ([ceylon/Dockerfile](https://github.com/ceylon-docker/source-runner/blob/1.2.0-jre8/Dockerfile))
 - `1.1.0-jre8`, `1.1.0` ([ceylon/Dockerfile](https://github.com/ceylon-docker/source-runner/blob/1.1.0-jre8/Dockerfile))
 - `1.0.0-jre8`, `1.0.0` ([ceylon/Dockerfile](https://github.com/ceylon-docker/source-runner/blob/1.0.0-jre8/Dockerfile))

*For all these images there is also a `x.y.z-jre7` version available*

This set of images can be used to very quickly and easily download, compile and run Ceylon code from a variety of sources. The image itself when run without any arguments will tell you:

```
Usage: docker run ceylon/source-runner [-q] <repo-module-url> [<module>] [args...]

The <repo-module-url> argument can either be:
 - a GitHub repository name, eg: "ceylon/ceylon.formatter"
 - a GitHub repository URL, eg: "https://github.com/ceylon/ceylon.formatter"
 - a URL to a ZIP file, eg: "https://github.com/ceylon/ceylon.formatter/archive/master.zip"
 - a Ceylon module on the Herd that has a source artifact, eg: "ceylon.formatter/1.2.1"

The runner will try to figure out which module to run, but if it can't or if you want
to override the choice it makes you can specify its name as the <module> argument.

Use the option -q option to suppress output from the runner itself.

And finally any arguments after the <module> argument will be passed on to the `ceylon run` command.
```

### Example

Running the following docker command will automatically download, compile and start the [Ceylon Web IDE](https://github.com/ceylon/ceylon-web-ide-backend):

    docker run -t -p 8080 ceylon/source-runner ceylon/ceylon-web-ide-backend "" --address 0.0.0.0

When it has finished starting up you can connect to it with your browser at http://localhost:8080

