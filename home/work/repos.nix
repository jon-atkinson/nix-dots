{ config, lib, pkgs, ... }:

let
  homeDir = lib.removeSuffix "/" config.home.homeDirectory;
  repoDir = "${homeDir}/repo";
  sshKey = "${homeDir}/.ssh/officepc";
  ssh = "${pkgs.openssh}/bin/ssh";

  repos = [
    "nectar"
    "dwt"
    "vivspack"
    "chakra"
    "deployment"
  ];

  cloneScript = lib.concatMapStringsSep "\n" (name: ''
    if [ ! -d "${repoDir}/${name}" ]; then
      echo "Cloning ${name}..."
      GIT_SSH_COMMAND="${ssh} -i ${sshKey} -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new" \
        ${lib.getExe pkgs.git} clone "git@bitbucket.org:vivcourt/${name}.git" "${repoDir}/${name}"
    fi
  '') repos;

in
{
  home.activation.cloneWorkRepos = lib.hm.dag.entryAfter [ "writeBoundary" "sops-nix" ] ''
    # Ensure this script has access to git
    export PATH="${lib.makeBinPath [ pkgs.git pkgs.openssh ]}:$PATH"

    # Ensure repo directory exists
    run mkdir -p "${repoDir}"

    # Wait for SSH key to become available (sops-nix decrypts asynchronously)
    _timeout=30
    _elapsed=0
    while [ ! -f "${sshKey}" ] && [ "$_elapsed" -lt "$_timeout" ]; do
      sleep 1
      _elapsed=$((_elapsed + 1))
    done

    if [ ! -f "${sshKey}" ]; then
      echo "WARNING: SSH key ${sshKey} not available after ''${_timeout}s. Skipping repo cloning."
      echo "Run 'systemctl --user restart sops-nix' then re-run activation to clone repos."
    else
      ${cloneScript}

      # Fetch q32 if not present
      if [ ! -d "${homeDir}/q32" ]; then
        echo "Fetching q32..."
        _q32_tmp=$(mktemp -d)
        GIT_SSH_COMMAND="${ssh} -i ${sshKey} -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new" \
          ${lib.getExe pkgs.git} clone --depth 1 "git@github.com:jon-atkinson/qbin.git" "$_q32_tmp" \
          && cp -r "$_q32_tmp/q32" "${homeDir}/q32" \
          && echo "q32 installed to ~/q32" \
          || echo "WARNING: Failed to fetch q32"
        rm -rf "$_q32_tmp"
      fi

      # Symlink nectar bin utilities
      if [ -d "${repoDir}/nectar/var/common/bin" ]; then
        run mkdir -p "${homeDir}/bin"
        for f in "${repoDir}/nectar/var/common/bin/"*; do
          ln -sf "$f" "${homeDir}/bin/$(basename "$f")"
        done
      fi

      # On rebuild with existing nectar: update conda environment
      if [ -d "${homeDir}/miniconda/envs/olympus" ] && [ -x "${repoDir}/nectar/etc/env/update_env.sh" ]; then
        echo "Updating olympus conda environment..."
        "${repoDir}/nectar/etc/env/update_env.sh" || echo "WARNING: update_env.sh failed"
      fi

      # Check if first-time setup is needed
      if [ ! -d "${homeDir}/miniconda" ] || [ ! -d "${homeDir}/miniconda/envs/olympus" ]; then
        echo ""
        echo "=============================================="
        echo "  WORK SETUP: First-time setup required"
        echo "=============================================="
        echo "  Run: ~/bin/work-setup.sh"
        echo "=============================================="
      fi
    fi
  '';

  home.packages = [ pkgs.remmina pkgs.slirp4netns ];

  home.file.".config/containers/registries.conf".text = ''
    unqualified-search-registries = ["docker.io"]
  '';

  home.file.".config/containers/policy.json".text = builtins.toJSON {
    default = [{ type = "reject"; }];
    transports = {
        containers-storage = {
            "" = [ { type = "insecureAcceptAnything"; } ];
        };
        docker = {
          "docker.io" = [{ type = "insecureAcceptAnything"; }];
        };
    };
  };
  home.file.".local/share/applications/remmina.desktop".text = ''
    [Desktop Entry]
    Name=Remmina
    Comment=Remote Desktop Client
    Exec=${pkgs.remmina}/bin/activate
    Icon=${pkgs.remmina}/share/icons/hicolor/scalable/apps/org.remmina.Remmina.svg
    Terminal=false
    Type=Application
    Categories=Network;RemoteAccess
  '';
  sops.secrets."remmina_pc331" = {
      path = "${homeDir}/.local/share/remmina/group_rdp_pc331-(jon-windows-box)_pc331-vivcourt-com.remmina";
      mode = "0600";
  };

  sops.secrets."dwt_config" = {
    path = "${homeDir}/.dwt/dwt.yaml";
    mode = "0600";
  };

  home.file."bin/work-setup.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      REPO_DIR="${repoDir}"
      HOME_DIR="${homeDir}"

      echo "=== Work Environment Setup ==="
      echo ""

      # 0. Initial Setup
      # Ensure /data exists with correct ownership
      if [ ! -d /data ]; then
        echo "[0] Creating /data directory..."
        sudo mkdir -p /data
        sudo chown "$USER:$(id -gn)" /data
      fi
      mkdir -p /data/worktrees /data/kdb

      # Check system dependencies (require sudo to install)
      _missing=""
      command -v newuidmap >/dev/null 2>&1 || _missing="$_missing uidmap"
      [ -f /lib/ld-linux.so.2 ] || _missing="$_missing libc6-i386"
      if [ -n "$_missing" ]; then
        echo "[0a] Missing system packages:$_missing"
        echo "     Install with: sudo apt install$_missing"
        read -p "     Install now? [y/N] " _reply
        if [[ "$_reply" =~ ^[Yy]$ ]]; then
          sudo apt-get install -y $_missing
        else
          echo "     Skipping. Some steps (e.g. dwt build) may fail without these."
        fi
      fi

      # Ensure rootless podman has subuid/subgid ranges
      if ! grep -q "^$USER:" /etc/subuid 2>/dev/null; then
        echo "[0b] Configuring subordinate UID/GID ranges for rootless podman..."
        sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 "$USER"
        podman system migrate
      fi

      # 1. Nectar - install miniconda
      if [ ! -d "$HOME_DIR/miniconda" ]; then
        echo "[1/6] Installing miniconda..."
        "$REPO_DIR/nectar/etc/env/conda_install.sh"
      else
        echo "[1/6] Miniconda already installed, skipping."
      fi

      # 2. Nectar - create/update olympus conda env
      echo "[2/6] Creating/updating olympus conda environment..."
      "$REPO_DIR/nectar/etc/env/update_env.sh"

      # 3. dwt - pip install
      if [ -d "$REPO_DIR/dwt" ]; then
        echo "[3/6] Installing dwt (pip install -e)..."
        "$HOME_DIR/miniconda/envs/olympus/bin/pip" install -e "$REPO_DIR/dwt"
      else
        echo "[3/6] dwt repo not found, skipping."
      fi

      # 4. dwt - enable linger (Linux only)
      if [[ "$(uname)" == "Linux" ]]; then
        echo "[4/6] Enabling loginctl linger..."
        loginctl enable-linger "$USER" || echo "WARNING: loginctl enable-linger failed"
      else
        echo "[4/6] Skipping loginctl linger (not Linux)."
      fi

      # 5. dwt - build container
      if [ -d "$REPO_DIR/dwt" ]; then
        echo "[5/6] Building dwt container image (this may take a while)..."
        export PATH="$HOME_DIR/miniconda/envs/olympus/bin:$PATH"
        dwt build || echo "WARNING: dwt build failed. You can retry with 'dwt build'."
      else
        echo "[5/6] dwt repo not found, skipping."
      fi

      # 6. vivspack - CA cert + install
      if [ -d "$REPO_DIR/vivspack" ]; then
        echo "[6/6] Installing vivspack (requires sudo)..."
        cd "$REPO_DIR/vivspack"
        sudo ./add-vivcourt-ca
        ./install
      else
        echo "[6/6] vivspack repo not found, skipping."
      fi

      echo ""
      echo "=== Setup complete ==="
    '';
  };
}
