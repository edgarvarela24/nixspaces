# Morning standup, need to review PR
$ nixspace open github.com/company/api/pull/1234
🚀 Launching PR environment...
✓ Environment ready: https://nixspace.dev/env/abc123
✓ VS Code: https://nixspace.dev/env/abc123/code
✓ Terminal: nixspace ssh abc123

# Quick test of a different Node version
$ nixspace branch my-env --node=20
🌿 Branched: my-env → my-env-node20
$ nixspace ssh my-env-node20

# Share with teammate
$ nixspace share my-env-node20 --expire=2h
📋 Share link: https://nixspace.dev/env/abc123?token=xyz