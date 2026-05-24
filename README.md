
## AWS Deployment Architecture

This project is deployed across multiple VMs in an AWS VPC.

```text
                                        +-------------------------------------------------+
                                        | VPC (10.0.0.0/16)                               |
                                        |                                                 |
                                        |  +-------------------------------------------+  |
                                        |  | Public Subnet (10.0.1.0/24)               |  |
                                        |  |                                           |  |
 +-------------------+                  |  |  +-------------------------------------+  |  |
 |                   |   HTTP (3111)    |  |  |                                     |  |  |
 |  Public Internet  +------------------|--|->|  API Gateway VM (iii engine)        |  |  |
 |                   |                  |  |  |  (Public IP)                        |  |  |
 +-------------------+                  |  |  +--+-------------------------------+--+  |  |
                                        |  |     |                             ^   |  |  |
                                        |  +-------------------------------------------+  |
                                        |        |                             |          |
                                        |        | WebSocket (49134)           | WebSocket (49134)
                                        |        v                             |          |
                                        |  +-------------------------------------------+  |
                                        |  | Private Subnet (10.0.2.0/24)      |       |  |
                                        |  |                                   v       |  |
                                        |  |  +-------------------+  +-------------------+|  |
                                        |  |  | Caller Worker VM  |  | Inference Worker ||  |
                                        |  |  | (TypeScript)      |  | VM (Python)       ||  |
                                        |  |  +-------------------+  +-------------------+|  |
                                        |  +-------------------------------------------+  |
                                        +-------------------------------------------------+
```

## How to Redeploy from Scratch

The infrastructure is fully defined in Terraform and utilizes `user_data` scripts to automatically install and launch the workers via `systemd`.

1. **Push this code to a public Git repository** (e.g. GitHub).
2. **Install Terraform** and authenticate with your AWS account.
3. Change into the `terraform` directory:
   ```bash
   cd terraform
   ```
4. Initialize the Terraform workspace:
   ```bash
   terraform init
   ```
5. Apply the configuration. (It will automatically use the repository URL set in `variables.tf`):
   ```bash
   terraform apply
   ```
6. Type `yes` when prompted. Terraform will provision the network, NAT gateway, and EC2 instances.
7. Once finished, Terraform will output the `api_endpoint` IP address. *(Note: It may take 3-5 minutes for the instances to finish running their user_data initialization scripts and download the model.)*

## Testing the API

You can hit the API Gateway using the public IP outputted by Terraform:

**Sample Request:**
```bash
curl -X POST http://<GATEWAY_PUBLIC_IP>:3111/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{"messages": [{"role": "user", "content": "Explain quantum entanglement in simple terms."}]}'
```

**Sample Response:**
```json
{
  "result": "Quantum entanglement is a phenomenon in quantum physics where two or more particles become connected in such a way that the state of one particle instantly influences the state of the other...",
  "success": "You've connected two workers and they're interoperating seamlessly, now let's add a few more workers to expand this project's functionality."
}
```

*See `WRITEUP.md` for details on production hardening and scaling strategies.*
