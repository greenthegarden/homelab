# Zed

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Configuration](#configuration)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

Using [Zed][zed] as my primary code editor.

[zed]: https://zed.dev/

## Configuration

Config

```yaml
// Zed settings
//
// For information on how to configure Zed, see the Zed
// documentation: https://zed.dev/docs/configuring-zed
//
// To see all of Zed's default settings without changing your
// custom settings, run `zed: open default settings` from the
// command palette (cmd-shift-p / ctrl-shift-p)
//
{
  "language_models": {
    "openai_compatible": {
      "Llamafile": {
        "api_url": "http://lxc-llamafile.localdomain:8081/v1",
        "available_models": [
          {
            "name": "llamafile",
            "max_tokens": 200000,
            "max_output_tokens": 32000,
            "max_completion_tokens": 200000,
            "capabilities": {
              "tools": true,
              "images": false,
              "parallel_tool_calls": false,
              "prompt_cache_key": false,
              "chat_completions": true,
              "interleaved_reasoning": false,
            },
          },
        ],
      },
    },
    "ollama": {
      "api_url": "http://lxc-ollama-gpu:11434",
    },
  },
  "cli_default_open_behavior": "existing_window",
  "project_panel": {
    "dock": "left",
  },
  "outline_panel": {
    "dock": "left",
  },
  "collaboration_panel": {
    "dock": "left",
  },
  "agent": {
    "default_profile": "minimal",
    "default_model": {
      "provider": "ollama",
      "model": "qwen2.5-coder:7b",
      "enable_thinking": false,
    },
    "dock": "right",
    "favorite_models": [],
    "model_parameters": [],
  },
  "git_panel": {
    "dock": "left",
  },
  "ssh_connections": [
    {
      "host": "ansible",
      "username": "root",
      "port": 22,
      "args": [],
      "projects": [],
    },
    {
      "host": "lxc-controller",
      "username": "root",
      "port": 22,
      "args": ["-i", "~/.ssh/id_ed25519_controller"],
      "projects": [
        {
          "paths": ["/root/homelab"],
        },
      ],
    },
  ],
  "autosave": "on_focus_change",
  "base_keymap": "VSCode",
  "multi_cursor_modifier": "cmd_or_ctrl",
  "minimap": {
    "show": "never",
  },
  "buffer_font_fallbacks": [
    "JetBrains Mono",
    "Consolas",
    "Courier New",
    "monospace",
  ],
  "buffer_font_family": "Fira Code",
  "auto_indent_on_paste": true,
  "indent_guides": {
    "enabled": false,
  },
  "file_types": {
    "Ansible": [
      "**.ansible.yml",
      "**.ansible.yaml",
      "**/defaults/*.yml",
      "**/defaults/*.yaml",
      "**/meta/*.yml",
      "**/meta/*.yaml",
      "**/tasks/*.yml",
      "**/tasks/*.yaml",
      "**/handlers/*.yml",
      "**/handlers/*.yaml",
      "**/group_vars/*.yml",
      "**/group_vars/*.yaml",
      "**/host_vars/*.yml",
      "**/host_vars/*.yaml",
      "**/playbooks/*.yml",
      "**/playbooks/*.yaml",
      "**playbook*.yml",
      "**playbook*.yaml",
    ],
    "env": ["*.env.j2"],
    "YAML": ["*.yml.j2", "*.yaml.j2"],
    "Dockerfile": ["Dockerfile*"],
  },
  "soft_wrap": "none",
  "tab_size": 2,
  "ui_font_size": 14.0,
  "buffer_font_size": 12.0,
  "theme": {
    "mode": "system",
    "light": "One Light",
    "dark": "One Dark Pro",
  },
}
```
