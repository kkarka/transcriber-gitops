module "networking" {
  source = "../../modules/networking"

  environment    = var.environment
  vpc_cidr       = var.vpc_cidr
  azs            = var.azs
  public_subnets = var.public_subnets
}

module "database" {
  source = "../../modules/database"

  environment = var.environment
  
  # MODULE CHAINING: Pulling outputs dynamically from the networking module above
  vpc_id      = module.networking.vpc_id
  vpc_cidr    = var.vpc_cidr
  subnet_ids  = module.networking.public_subnet_ids
  
  db_username = var.db_username
  db_password = var.db_password
}

module "compute" {
  source = "../../modules/compute"

  environment = var.environment
  
  # MODULE CHAINING: We pass the exact subnets we created in step 1
  subnet_ids  = module.networking.public_subnet_ids
}

module "storage" {
  source            = "../../modules/storage"
  environment       = var.environment
  video_bucket_name = var.video_bucket_name
}