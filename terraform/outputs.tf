output "gateway_public_ip" {
  description = "The public IP address of the iii API Gateway"
  value       = aws_instance.gateway.public_ip
}

output "api_endpoint" {
  description = "The HTTP API endpoint for inference"
  value       = "http://${aws_instance.gateway.public_ip}:3111/v1/chat/completions"
}

output "gateway_private_ip" {
  description = "The private IP address of the gateway (used for III_URL)"
  value       = aws_instance.gateway.private_ip
}

output "caller_worker_private_ip" {
  description = "The private IP address of the Caller Worker VM"
  value       = aws_instance.caller_worker.private_ip
}

output "inference_worker_private_ip" {
  description = "The private IP address of the Inference Worker VM"
  value       = aws_instance.inference_worker.private_ip
}
