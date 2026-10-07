output "world_bucket" {
  description = "S3 bucket that stores the world backups"
  value       = aws_s3_bucket.world.id
}

output "instance_id" {
  description = "Game server instance ID (use it to connect with Session Manager)"
  value       = aws_instance.game.id
}

output "server_address" {
  description = "Address to join in Minecraft Java Edition"
  value       = "${aws_instance.game.public_ip}:25565"
}