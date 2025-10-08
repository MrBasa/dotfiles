# My Dotfiles

These are my personal dotfiles, managed by [Chezmoi](https://www.chezmoi.io/).

## Prerequisite

This setup assumes the `ansible-bootstrap` playbook has already been run successfully on the target machine. This ensures that `git`, `fish`, and `chezmoi` are installed and ready.

## Usage on a New Machine (Restoring Your Config)

Run the following command to apply the configuration. Replace `your-username` with your GitHub username.

```bash
# Switch to the fish shell first
fish

# Initialize and apply dotfiles
chezmoi init --apply [https://github.com/your-username/dotfiles.git](https://github.com/your-username/dotfiles.git)
```
