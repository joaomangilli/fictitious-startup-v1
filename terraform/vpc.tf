module "vpc" {
  source = "./modules/vpc"

  vpc_parameters = {
    main = {
      cidr_block = "172.32.0.0/16"
    }
  }

  internet_gateway_parameters = {
    main = {
      vpc_name = "main"
    }
  }

  subnet_parameters = {
    private_a = {
      vpc_name          = "main"
      cidr_block        = "172.32.16.0/20"
      availability_zone = "us-east-2a"
    }

    private_b = {
      vpc_name          = "main"
      cidr_block        = "172.32.32.0/20"
      availability_zone = "us-east-2b"
    }

    public_a = {
      vpc_name          = "main"
      cidr_block        = "172.32.64.0/20"
      availability_zone = "us-east-2a"
    }

    public_b = {
      vpc_name          = "main"
      cidr_block        = "172.32.128.0/20"
      availability_zone = "us-east-2b"
    }
  }

  route_table_parameters = {
    private_a_table = {
      vpc_name = "main"
    }

    private_b_table = {
      vpc_name = "main"
    }

    public_a_table = {
      vpc_name = "main"
      routes = [
        {
          cidr_block = "0.0.0.0/0"
          gateway_name = "main"
        }
      ]
    }

    public_b_table = {
      vpc_name = "main"
      routes = [
        {
          cidr_block = "0.0.0.0/0"
          gateway_name = "main"
        }
      ]
    }
  }

  route_table_association_parameters = {
    private_a_table_association = {
      subnet_name = "private_a"
      rt_name     = "private_a_table"
    }

    private_b_table_association = {
      subnet_name = "private_b"
      rt_name     = "private_b_table"
    }

    public_a_table_association = {
      subnet_name = "public_a"
      rt_name     = "public_a_table"
    }

    public_b_table_association = {
      subnet_name = "public_b"
      rt_name     = "public_b_table"
    }
  }
}
