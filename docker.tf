resource "docker_image" "cloudflared" {
  name = "cloudflare/cloudflared:latest"
}

resource "docker_container" "portainer-cloudflared" {
  image = docker_image.cloudflared.image_id
  name  = "portainer_cloudflared"
  restart = "always"
  command = ["tunnel", "--no-autoupdate", "run", "--token", "${cloudflare_argo_tunnel.portainer.tunnel_token}"]
}

resource "docker_image" "portainer" {
  name = "portainer/portainer:latest"
}

resource "docker_container" "portainer" {
  image = docker_image.portainer.image_id
  name  = "portainer"
  restart = "always"
  ports {
    internal = "8000"
    external = "8000"
  }
  ports {
    internal = "9000"
    external = "9000"
  }
  volumes {
      host_path = "/var/run/docker.sock"
      container_path = "/var/run/docker.sock"
  }
}