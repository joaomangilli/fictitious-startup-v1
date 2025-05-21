variable "vpc_parameters" {
  description = "VPC parameters"
  type = map(object({
    cidr_block = string
  }))
  default = {}
}

variable "subnet_parameters" {
  description = "Subnet parameters"
  type = map(object({
    cidr_block        = string
    vpc_name          = string
    availability_zone = string
  }))
  default = {}
}

variable "internet_gateway_parameters" {
  description = "Internet gateway parameters"
  type = map(object({
    vpc_name = string
  }))
  default = {}
}

variable "route_table_parameters" {
  description = "Route table parameters"
  type = map(object({
    vpc_name = string
    routes = optional(list(object({
      cidr_block = string
      gateway_id = string
    })), [])
  }))
  default = {}
}

variable "route_table_association_parameters" {
  description = "Route table association parameters"
  type = map(object({
    subnet_name = string
    rt_name     = string
  }))
  default = {}
}
