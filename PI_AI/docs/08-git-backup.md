# 08 — Backing Up to a Private Git Repository

Target: `https://github.com/RustyJug/PI_AI.git`

This repo doesn't know whether that GitHub repository already exists or
whether you have push access configured on the machine you're pushing
from — the commands below cover both cases. **Run these yourself**, from
whichever machine has your GitHub credentials set up (this can be the
Pi, or your regular computer — it doesn't have to be the Pi itself,
since this project folder is just files and doesn't depend on the Pi's
hardware to exist as a repo).

## 0. One-time: make sure you can authenticate to GitHub

Pick one:

- **SSH (recommended):**
  ```bash
  ssh-keygen -t ed25519 -C "your_email@example.com"   # skip if you already have a key
  cat ~/.ssh/id_ed25519.pub
  ```
  Copy that output into GitHub → Settings → SSH and GPG keys → New SSH
  key. Then use SSH remote URLs (`git@github.com:...`) below.

- **HTTPS + Personal Access Token:** GitHub → Settings → Developer
  settings → Personal access tokens → generate one with `repo` scope.
  When `git push` prompts for a password over HTTPS, use the token, not
  your account password.

Do not paste tokens or keys into this repository or any file inside it.

## 1. If the repository does not exist yet on GitHub

Create it first at <https://github.com/new>:

- Owner: `RustyJug`
- Repository name: `PI_AI`
- Visibility: **Private**
- Do **not** initialize with a README, .gitignore, or license (this repo
  already has its own — initializing on GitHub first just creates a
  merge conflict you'll have to resolve).

## 2. Initialize and commit locally (if not already done)

From the root of this project folder:

```bash
git init
git add .
git commit -m "Initial commit: PI_AI local LLM build documentation and scripts"
git branch -M main
```

## 3. Point it at your GitHub repo and push

SSH remote:

```bash
git remote add origin git@github.com:RustyJug/PI_AI.git
git push -u origin main
```

or HTTPS remote:

```bash
git remote add origin https://github.com/RustyJug/PI_AI.git
git push -u origin main
```

If `origin` is already set to something else, check first:

```bash
git remote -v
```

and either `git remote set-url origin <correct-url>` or remove and
re-add it (`git remote remove origin` then the `add` command above).

## 4. Keeping the backup current

Any time you change a script, add a doc, or update model choices:

```bash
git add -A
git commit -m "Describe what changed"
git push
```

## What NOT to commit

`.gitignore` in this repo already excludes these, but worth stating
explicitly — never commit:

- Downloaded model weight files (`.hef`, the `hailo-ollama` blob store) —
  large, and re-downloadable via the scripts
- SSH private keys, GitHub tokens, `.env` files
- Anything under `~/.config/systemd/` on the actual Pi (the copy in
  `systemd/hailo-ollama.service` in this repo is the template; the live
  one is machine-specific)
