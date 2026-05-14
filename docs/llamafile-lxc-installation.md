# Installing llamafile on LXC

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Installation and Running](#installation-and-running)
- [Configure Zed](#configure-zed)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Installation and Running

See [llamafile docs][llamafile-docs] for details.

[llamafile-docs]: https://mozilla-ai.github.io/llamafile/running_llamafile/

Use the following script to run the defined file, in both `server` and `chat` modes, on a
specific port. The `jinja` options is used to support remote systems using the API.

```bash
#!/usr/bin/env bash

#LLAMAFILE=Qwen3.5-0.8B-Q8_0.llamafile
LLAMAFILE=Qwen3.5-9B-Q5_K_S.llamafile

if [[ -x ${LLAMAFILE} ]] ;
then
  ./${LLAMAFILE} \
    --host 0.0.0.0 \
    --port 8081 \
    --jinja
else
  echo -e "llamafile ${LLAMAFILE} not found!"
  exit 1
fi
```

Models can be downloaded from [Mozilla][llamafile-models].

[llamafile-models]: https://mozilla-ai.github.io/llamafile/example_llamafiles/

## Configure Zed

Use [Zed documentation][zed-docs] to use llamafile model.

[zed-docs]: https://zed.dev/docs/ai/llm-providers#openai-api-compatible

Example configuration for `settings.json` file:

```json
"language_models": {
  "openai_compatible": {
    "Llamafile": {
      "api_url": "http://lxc-llamafile.localdomain:8081/v1",
      "available_models": [
        {
          "name": "Qwen3.5-0.8B",
          "max_tokens": 200000,
          "max_output_tokens": 32000,
          "max_completion_tokens": 200000,
          "capabilities": {
            "tools": true,
            "images": false,
            "parallel_tool_calls": false,
            "prompt_cache_key": false,
            "chat_completions": true,
            "interleaved_reasoning": false
          }
        }
      ]
    }
  },
}
```
