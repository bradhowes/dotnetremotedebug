FROM microsoft/aspnetcore:latest
WORKDIR /app
ADD ./output .
ENTRYPOINT ["dotnet", "ExampleApp.dll"]
