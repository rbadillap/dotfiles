# Containers: what runs `docker` and `docker compose`, installed with
# Homebrew. Changing the value installs the new runtime and leaves the old
# one installed.

# containers runtime <docker-desktop|orbstack|rancher|colima>   what runs
# containers. docker-desktop, orbstack and rancher are apps that bring docker
# and docker compose; open the app once to finish its setup. colima has no
# app: it installs with the docker and docker-compose formulae, and you start
# it with `colima start`.
containers_runtime() {
  case $1 in
    docker-desktop|orbstack|rancher)
      brewpkg cask "$1"
      effect "Open the container runtime ($1) once to finish its setup" ;;
    colima)
      brewpkg formula colima
      brewpkg formula docker
      brewpkg formula docker-compose
      note "docker compose needs Homebrew's plugin folder in ~/.docker/config.json (cliPluginsExtraDirs)"
      effect "Start the container runtime: colima start" ;;
    *) fail "containers runtime: expected docker-desktop, orbstack, rancher or colima, got '$1'"; return ;;
  esac
}
