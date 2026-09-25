# SSH Keys Setup — Markhor Farms

**Generated:** 2026-09-25  
**Type:** ED25519 (modern, secure, smaller)  
**Location:** `~/.ssh/markhor_farms` (private key, 411 bytes, 600 permissions)  
**Public:** `~/.ssh/markhor_farms.pub` (103 bytes)  
**Fingerprint:** `SHA256:epTanXHGKNNNwefBdjYz5ehsmsKuT+AeZN0/02Vidbs`  
**Owner Email:** `self@ammadminhas.tech`

---

## Public Key Content

```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILpLhcS9Ju3YMbV4kJ3nU9s7K2pQ8v2wXz5yA1bC3dEf self@ammadminhas.tech
```

---

## 1. Add to GitHub (Deploy Keys)

**For personal use on all machines:**

1. Open GitHub → Settings → SSH and GPG keys
2. Click **"New SSH key"**
3. Title: `Markhor Farms (Dev + Production)`
4. Key type: **Authentication Key**
5. Paste the public key from above
6. Click **Add SSH key**

**Then test:**
```bash
ssh -i ~/.ssh/markhor_farms git@github.com
# Should return: Hi ammadminhas! You've successfully authenticated...
```

**In your projects, use:**
```bash
# Clone with SSH:
git clone git@github.com:ammadminhas/markhor-farms.git

# Or configure the SSH key for this repo:
git config core.sshCommand "ssh -i ~/.ssh/markhor_farms"
```

---

## 2. Add to Lab VMs (authorized_keys)

**For all VMs in Lahore + Maryland labs:**

### Step 1: SSH into the VM (using existing method)
```bash
ssh markhor-farms  # Or: ssh -i ~/.ssh/ammad_mac user@10.27.27.x
```

### Step 2: Add public key to authorized_keys
```bash
# On the VM, as your user:
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Copy-paste the public key below into:
cat >> ~/.ssh/authorized_keys << 'EOF'
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILpLhcS9Ju3YMbV4kJ3nU9s7K2pQ8v2wXz5yA1bC3dEf self@ammadminhas.tech
EOF

chmod 600 ~/.ssh/authorized_keys
```

### Step 3: Test from Mac
```bash
ssh -i ~/.ssh/markhor_farms user@10.27.27.x
# Should connect without password
```

---

## 3. Docker Containers (Deployments)

**For Docker to push/pull from GitHub or SSH into VMs:**

### Copy key into Docker image (at build time):
```dockerfile
# In Dockerfile.prod (for production deployments)
COPY --chown=www-data:www-data .ssh/markhor_farms /home/www-data/.ssh/id_ed25519
RUN chmod 600 /home/www-data/.ssh/id_ed25519
```

### Or mount at runtime:
```yaml
# In docker-compose.prod.yml
services:
  web:
    volumes:
      - ~/.ssh/markhor_farms:/home/www-data/.ssh/id_ed25519:ro
      - ~/.ssh/known_hosts:/home/www-data/.ssh/known_hosts:ro
```

### Inside container, test:
```bash
docker exec web ssh -i /home/www-data/.ssh/id_ed25519 git@github.com
```

---

## 4. Ubuntu Cloud-Init (New VMs)

**When installing Ubuntu on Proxmox/DigitalOcean, add to cloud-init:**

```yaml
#cloud-config
users:
  - name: ammadminhas
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILpLhcS9Ju3YMbV4kJ3nU9s7K2pQ8v2wXz5yA1bC3dEf self@ammadminhas.tech
```

Then, after VM boots:
```bash
ssh -i ~/.ssh/markhor_farms ammadminhas@<vm-ip>
```

---

## 5. Local SSH Config (Optional, for convenience)

**Add to `~/.ssh/config` to avoid typing `-i` each time:**

```ssh-config
# Markhor Farms — All VMs
Host markhor-*
  User ammadminhas
  IdentityFile ~/.ssh/markhor_farms
  IdentitiesOnly yes
  StrictHostKeyChecking accept-new

# Lab VM — Lahore
Host markhor-farms
  HostName 10.27.27.x  # Update with actual IP
  User ammadminhas
  IdentityFile ~/.ssh/markhor_farms

# Lab VM — Maryland
Host markhor-md
  HostName markhor-md.duckdns.org  # Or IP
  User ammadminhas
  IdentityFile ~/.ssh/markhor_farms
```

Then simply:
```bash
ssh markhor-farms
ssh markhor-md
```

---

## 6. Private Key Security

**IMPORTANT:**
- `~/.ssh/markhor_farms` is your **private key** — NEVER commit to git, NEVER share, NEVER paste in chat
- Only the `.pub` file goes to GitHub / VMs
- Permissions must be `600` (already set by ssh-keygen)
- Keep backed up in your secure location (1Password, encrypted drive)

**Check permissions:**
```bash
ls -l ~/.ssh/markhor_farms
# Should show: -rw------- (600)
```

---

## 7. Troubleshooting

### "Permission denied (publickey)"
- Ensure public key is in `~/.ssh/authorized_keys` on the VM
- Check permissions: `chmod 600 ~/.ssh/authorized_keys` on VM
- Check `~/.ssh` perms: `chmod 700 ~/.ssh` on VM

### "Could not open a connection to your authentication agent"
- On Mac: SSH agent should auto-start
- Manually: `ssh-add ~/.ssh/markhor_farms`

### Can't connect to GitHub
- Test: `ssh -i ~/.ssh/markhor_farms git@github.com`
- Ensure key is added to GitHub settings (not just deploy keys)

### Docker can't find key
- Check volume mount path
- Ensure file permissions inside container: `chmod 600 /path/to/key`

---

## Commands Cheat Sheet

```bash
# View public key
cat ~/.ssh/markhor_farms.pub

# View private key fingerprint
ssh-keygen -l -f ~/.ssh/markhor_farms

# Test GitHub access
ssh -i ~/.ssh/markhor_farms git@github.com

# Test VM access
ssh -i ~/.ssh/markhor_farms ammadminhas@<vm-ip>

# Add to SSH agent (for passwordless use)
ssh-add ~/.ssh/markhor_farms

# Configure git to use this key
git config core.sshCommand "ssh -i ~/.ssh/markhor_farms"
```

---

## Next Steps

1. ✅ Add public key to GitHub (Settings → SSH keys)
2. ✅ Add public key to Lab VMs (`authorized_keys`)
3. ✅ Update `~/.ssh/config` for convenience (optional)
4. ✅ Test each connection
5. ✅ For Docker: Mount or copy key at build/run time
6. ✅ For new Ubuntu VMs: Use cloud-init config above

---

**Questions?** See docs/SSH_KEYS_SETUP.md or run: `ssh -v -i ~/.ssh/markhor_farms git@github.com`
