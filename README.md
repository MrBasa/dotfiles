# My Dotfiles

These are my personal dotfiles, managed by [Chezmoi](https://www.chezmoi.io/). They contain my shell configuration, aliases, and automated setup scripts for tools like Fisher and Tide.

## Prerequisite

This setup assumes the `bootstrap-ansible.sh` script from the (Ansible repo)[https://github.com/MrBasa/ansible-bootstrap] has already been run successfully on the target machine. This ensures that `git`, `fish`, and `chezmoi` are installed and ready.

## Usage on a New Machine (Restoring Your Config)

This is the **second and final step** in setting up a new environment. Run the following command to apply your personal configuration.

```bash
# Switch to the fish shell first
fish

# Initialize and apply dotfiles
chezmoi init --apply https://github.com/mrbasa/dotfiles.git
```

This single command will clone the repository, create all the necessary symlinks, and run the automation scripts to install and configure your shell plugins and prompt.
