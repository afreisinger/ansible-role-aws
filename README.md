ansible-role-aws
=========

Ansible role for AWS

Initial hardening for Ubuntu EC2 instances: hostname, users, SSH hardening, UFW firewall, and package installation.

Requirements
------------

- Ansible >= 2.12
- Collections: `ansible.posix`, `community.general`
- Target platform: Ubuntu 24.04 (Noble)

Role Variables
--------------

### Hostname

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_hostname` | `""` | Hostname to set. AWS defaults the hostname to the instance's internal IP; set this to override it. Skipped when empty. Also writes `/etc/cloud/cloud.cfg.d/99-preserve-hostname.cfg` so cloud-init does not reset it on reboot. |

### Users

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_users` | `[]` | List of users to create (see structure below). |
| `aws_root_password` | `""` | Plaintext root password (hashed with sha512). Skipped when empty. |

Each entry in `aws_users`:

```yaml
aws_users:
  - name: claude              # username
    password: "secret"        # plaintext, hashed with sha512 (store in vault)
    groups:                   # supplementary groups
      - users
    sudo: false               # true adds the user to the sudo group
    github_user: afreisinger  # optional: import SSH public keys from github.com/<user>.keys
```

### SSH

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_ssh_permit_root_login` | `"no"` | `PermitRootLogin` value. |
| `aws_ssh_password_authentication` | `"no"` | `PasswordAuthentication` value. |
| `aws_ssh_pubkey_authentication` | `"yes"` | `PubkeyAuthentication` value. |

Settings are written to `/etc/ssh/sshd_config.d/00-hardening.conf` (drop-in), which precedes `50-cloud-init.conf` so they survive cloud-init.

### Packages

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_packages` | `[tmux, fail2ban]` | Extra apt packages to install. |
| `aws_gh_enabled` | `false` | Install the GitHub CLI (`gh`) from the official apt repository. |

### UFW

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_ufw_enabled` | `false` | Enable the UFW firewall. |
| `aws_ufw_rules` | `[22/tcp, 80/tcp, 443/tcp]` | Allowed ports. Each rule: `port`, `proto` (default `tcp`), `comment`. |

Default policy is deny incoming / allow outgoing. Rules are tracked by checksum, so removed rules are cleaned up on the next run.

Dependencies
------------

None.

Example Playbook
----------------

    - hosts: servers
      become: true
      roles:
        - role: afreisinger.aws
          vars:
            aws_hostname: web-prod-01
            aws_root_password: "{{ vault_root_password }}"
            aws_ufw_enabled: true
            aws_gh_enabled: true
            aws_users:
              - name: claude
                password: "{{ vault_claude_password }}"
                groups:
                  - users
                sudo: true
                github_user: afreisinger

License
-------

MIT


Author Information
------------------

© Adrián Freisinger 2026
