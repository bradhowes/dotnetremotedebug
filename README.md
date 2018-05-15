# Docker Setup

## Creating the shared environment:

* Create network: `docker network create app`

## Creating the database container:

* Create volume for database: `docker volume create --name productdb`. This is not really necessary, but it does
offer a way to keep data around when the MySql docker container gets recycled.
* Fetch latest MySql docker image: `docker pull mysql`
* Start MySql: `docker run -d  -e MYSQL_ROOT_PASSWORD=my-secret-pw -e MYSQL_USER=admin -e
  MYSQL_PASSWORD=blahblah -e MYSQL_DATABASE=productdb [--volume productdb:/var/lib/mysql] --name mysql --network
  app -p 3306:3306 mysql` Note that the `--volume` flag and argument should only appear if there is a Docker
  volume with the given name
* To see MySql logs: `docker logs -f mysql`

Note that if running mysql with '-it' flags, send `^\` to quit instead of `^C`

## Creating the app container:

* Build the app: `dotnet build`
* Publish the app binary: `dotnet publish -o output`
* Build the app container: `docker build --tag app -f Debug.dockerfile .`
* Start the app (^C to stop): `docker run -it --network app -p 80:80 --link mysql --name app app`

Visit on local machine (http://localhost)[http://localhost]. If all is well, this should show a view of rows
from the database.

## Tearing Down

* Stop the app: `docker stop app`
* Remove the app container: `docker rm app`
* Stop the database: `docker stop mysql`
* Remove the database: `docker rm mysql`

# Debugging the App

Start up Visual Studio Code. Set a break-point -- say line 25 of `HomeController.cs`

```
        public IActionResult Index()
        {
:>          ViewBag.Message = _message;
            return View(_repository.Products);
        }
```

Connect to the app running in the Docker container. First, we need to tell VS Code how to remotely connect. Here
is the configuration I've used to reach the application via a `docker exec` connection:

```
{
    "name": ".NET Core Remote Attach",
    "type": "coreclr",
    "request": "attach",
    "processId": "1",
    "pipeTransport": {
        "pipeProgram": "bash",
        "pipeArgs": [ "-c", "docker exec -i app ${debuggerCommand}" ],
        "debuggerPath": "./vsdbg",
        "pipeCwd": "${workspaceRoot}",
        "quoteArgs": true
    },
    "sourceFileMap": {
        "/Users/howes/src/dotnet/ExampleApp": "${workspaceRoot}"
    },
    "justMyCode": true
}
```


Make sure that ".NET Core Remote Attach" is selected in the debugger view and then press on the green arrow to
begin debugging the application. If all goes well, some log messages will appear and the `Call Stack` window
will show 12 or so Thread instances, all in the `RUNNING` state.

Refreshing the [browser page](http://localhost) from above should cause the app to stop in the `HomeController`
handler where you set the break-point.

## Enabling Debugging in Docker Container

The `Debug.dockerfile` file use above to create the `app` container contains instructions that install into the
container the necessary harness that allows VS Code to remotely attach to the running application. The
`Prod.dockerfile` does not contain the harness and thus will not support remote debugging.
