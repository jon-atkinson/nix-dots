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

    # Ensure ~/repo exists 
    run mkdir -p "${repoDir}"

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
