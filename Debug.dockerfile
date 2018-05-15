FROM microsoft/aspnetcore:latest
WORKDIR /app

# Install CURL and so we can install the debugger installer
RUN apt-get update && apt-get install -y --no-install-recommends curl unzip && rm -rf /var/lib/apt/lists/*

# Fetch the vsdbg install script and run it to install latest version in /app
RUN curl -sSL http://aka.ms/getvsdbgsh | bash -s -- -v latest -l .

# Install the application
ADD ./output /app

ENTRYPOINT ["dotnet", "ExampleApp.dll"]
