<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a id="readme-top"></a>

<!-- PROJECT SHIELDS -->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![Unlicense License][license-shield]][license-url]

<br />

<!-- PROJECT LOGO -->
<div align="center">
  <a href="https://github.com/telekom-mms/terraform-aws-vpc">
    <img src="logo.png" alt="Logo" width="80" height="80">
  </a>

  <h3 align="center">AWS VPC Foundation Module</h3>

  <p align="center">
    PSA-compliant VPC module with multi-tier subnet architecture, NAT Gateways, and mandatory Flow Logs.
    <br />
    <a href="https://github.com/telekom-mms/terraform-aws-vpc"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/telekom-mms/terraform-aws-vpc">View Demo</a>
    ·
    <a href="https://github.com/telekom-mms/terraform-aws-vpc/issues/new?labels=bug&template=bug-report---.md">Report Bug</a>
    ·
    <a href="https://github.com/telekom-mms/terraform-aws-vpc/issues/new?labels=enhancement&template=feature-request---.md">Request Feature</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#about-the-project">About The Project</a></li>
    <li><a href="#getting-started">Getting Started</a></li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#security-features">Security Features</a></li>
    <li><a href="#psa-compliance-features">PSA Compliance Features</a></li>
    <li><a href="#outputs">Outputs</a></li>
    <li><a href="#troubleshooting">Troubleshooting</a></li>
    <li><a href="#license">License</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
## About The Project

This module creates a hardened, multi-AZ networking environment according to AWS and Telekom best practices. It enforces strict separation between public, private, and database tiers.

### Features

- **3-Tier Architecture**: Separate subnets for Public (DMZ), Private (App), and Database tiers.
- **Multi-AZ by Default**: Spreads subnets across specified AZs for high availability.
- **Managed NAT Gateways**: Configurable as single or per-AZ for egress control.
- **Mandatory Flow Logs**: Integrated CloudWatch logging for all network traffic.
- **Hardened Defaults**: Auto-assign public IP is disabled; default Security Group is locked down.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE -->
## Usage

### Basic Usage

```hcl
module "vpc" {
  source = "./terraform-aws-vpc"

  project_name = "myapp"
  environment  = "prod"
  
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  
  public_subnets   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets  = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
  database_subnets = ["10.0.20.0/24", "10.0.21.0/24", "10.0.22.0/24"]
}
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- SECURITY FEATURES -->
## Security Features

- **Traffic Isolation**: Database subnets have no direct route to NAT Gateways or the Internet.
- **Egress Control**: Private subnets route through NAT Gateways located in public subnets.
- **Hardened Default SG**: The VPC's default Security Group is stripped of all rules (Deny All).
- **Auditability**: VPC Flow Logs are enabled by default with 30-day retention.
- **No Auto-Public IPs**: Subnets are configured to NOT assign public IPs to instances on launch.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- PSA COMPLIANCE FEATURES -->
## PSA Compliance Features

This module implements the following PSA compliance features (referencing `10-Strukturierte_PSA_Anforderungen_Netzwerk_LLM.pdf`):

### Security Controls

- **Req 4 (DMZ zones)**: Public subnets act as the dedicated DMZ for load balancers.
- **Req 5 (Logging)**: VPC Flow Logs mandatory for all traffic auditing.
- **Req 6 (Access Control)**: Lockdown of the default SG to prevent unauthorized internal lateral movement.
- **Req 3.66-04 (Mandantentrennung)**: Consistent tagging and naming prefixing for clear resource isolation.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- TROUBLESHOOTING -->
## Troubleshooting

### No Internet Access in Private Subnets

- Verify `enable_nat_gateway = true`.
- Check that public subnets have a route to the Internet Gateway.
- Ensure NAT Gateways are created in the public subnets.

### Flow Log Permission Issues

- Ensure the IAM role for Flow Logs has permissions to `logs:CreateLogStream` and `logs:PutLogEvents`.
- Check if the CloudWatch log group has reached its quota.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
[contributors-shield]: https://img.shields.io/github/contributors/telekom-mms/terraform-aws-vpc.svg?style=for-the-badge
[contributors-url]: https://github.com/telekom-mms/terraform-aws-vpc/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/telekom-mms/terraform-aws-vpc.svg?style=for-the-badge
[forks-url]: https://github.com/telekom-mms/terraform-aws-vpc/network/members
[stars-shield]: https://img.shields.io/github/stars/telekom-mms/terraform-aws-vpc.svg?style=for-the-badge
[stars-url]: https://github.com/telekom-mms/terraform-aws-vpc/stargazers
[issues-shield]: https://img.shields.io/github/issues/telekom-mms/terraform-aws-vpc.svg?style=for-the-badge
[issues-url]: https://github.com/telekom-mms/terraform-aws-vpc/issues
[license-shield]: https://img.shields.io/github/license/telekom-mms/terraform-aws-vpc.svg?style=for-the-badge
[license-url]: https://github.com/telekom-mms/terraform-aws-vpc/blob/master/LICENSE.txt
