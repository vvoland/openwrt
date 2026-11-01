variable "HOME" {
  default = "."
}

variable "JOBS" {
  default = "12"
}

variable "REVISION" {
  default = "unknown"
}

variable "OPENWRT_REF" {
  default = "v25.12.6"
}

group "default" {
  targets = ["firmware"]
}

target "firmware" {
  context    = "."
  dockerfile = "Dockerfile"
  target     = "firmware"
  contexts = {
    openwrt       = "https://git.openwrt.org/openwrt/openwrt.git#${OPENWRT_REF}"
    overlay       = "./files"
    router-config = "${HOME}/src/routers"
  }
  args = {
    JOBS     = JOBS
    REVISION = REVISION
  }
  output = ["type=local,dest=./bin"]
}
