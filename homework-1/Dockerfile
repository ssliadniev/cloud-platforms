FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build

WORKDIR /src

COPY ["SampleWebApiAspNetCore/SampleWebApiAspNetCore.csproj", "SampleWebApiAspNetCore/"]

RUN dotnet restore "SampleWebApiAspNetCore/SampleWebApiAspNetCore.csproj"

COPY . .

WORKDIR "/src/SampleWebApiAspNetCore"

RUN dotnet build "SampleWebApiAspNetCore.csproj" -c Release -o /app/build

FROM build AS publish

RUN dotnet publish "SampleWebApiAspNetCore.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime

WORKDIR /app

EXPOSE 8080

COPY --from=publish /app/publish .

ENTRYPOINT ["dotnet", "SampleWebApiAspNetCore.dll"]
