# Rowaia

Rowaia (ロワイア) is an AI agent for remote office workers, designed to streamline information processing. The name combines "Remote Work + AI + Assistant".

## Overview

This system uses the "OODA loop" (Observe-Orient-Decide-Act) as its basic structure, with Fluentd as the core information stream processing engine. The system operates completely offline for privacy protection.

## Architecture

Rowaia consists of two main Fluentd processes:

1. **Observe-Orient Process**: Collects information from various sources and analyzes it using local LLM
2. **Decide-Act Process**: Prioritizes the analyzed information and presents notifications with action suggestions

### Information Flow

The system processes information in four phases, implemented as Fluentd pipelines:

1. **Observe**: Collects data from multiple sources (files, audio recordings, etc.)
2. **Orient**: Processes and analyzes data using LLM
3. **Decide**: Prioritizes information based on importance and urgency
4. **Act**: Delivers notifications with suggested actions

## Requirements

- Ruby 3.4.1 or higher
- Fluentd 1.12 or higher
- [Ollama](https://ollama.ai/) for local LLM execution
- A desktop assistant supporting SSTP (like SSP)

## Installation

Clone the repository:

```bash
git clone https://github.com/yourusername/rowaia.git
cd rowaia
```

Install dependencies:

```bash
bundle install
```

Install Ollama and download the required model:

```bash
# Install Ollama from https://ollama.ai/
ollama pull hf.co/elyza/Llama-3-ELYZA-JP-8B-GGUF:latest
```

Install a desktop assistant (e.g., SSP):
Download from http://ssp.shillest.net/

## Usage

Start the Observe-Orient process:

```bash
./start_observe_orient.sh
```

In another terminal, start the Decide-Act process:

```bash
./start_decide_act.sh
```

## Components

### Custom Fluentd Plugins

- **in_context**: Input plugin to read information from files
- **out_context**: Output plugin to process text with LLM and save results
- **filter_llm_generate**: Filter plugin to analyze text with LLM
- **out_sstp**: Output plugin to send desktop notifications via SSTP

### LLM Processing

The system uses `llmalfr` to process text with local language models:

- Text summarization
- Information extraction
- Prioritization
- Transcription formatting

### Input Sources

Rowaia supports multiple input sources:

- **File-based**: Reads information from files (e.g., Obsidian notes, logs)
- **Audio**: Records and transcribes audio for meeting notes (using `audio_recorder`, `audio_transcoder` and `audio_transcriber` plugins)

## Configuration Files

### Main Configuration Files

- `observe_orient.conf`: Basic configuration for information collection and analysis
- `decide_act.conf`: Configuration for prioritization and notification

### Specialized Configuration Files

- `observe_orient_audio_transcribe.conf`: Configuration for audio recording, transcription and processing

## Audio Transcription

The audio transcription pipeline consists of the following steps:

1. **Recording**: Uses the `audio_recorder` plugin to capture audio
2. **Transcoding**: Normalizes audio using the `audio_transcoder` plugin
3. **Transcription**: Converts speech to text with the `audio_transcriber` plugin
4. **Processing**: Analyzes the transcribed text with LLM

Example configuration:

```
<source>
  @type audio_recorder
  tag audio.raw
  # Audio recording settings
</source>

<filter audio.raw>
  @type audio_transcoder
  # Audio normalization settings
</filter>

<filter audio.raw>
  @type audio_transcriber
  model mlx-community/whisper-large-v3-turbo
  language ja
  # Transcription settings
</filter>

<match audio.raw>
  @type context
  # LLM processing settings
</match>
```

## Dependencies

This project relies on the following gems:

- fluentd (~> 1.12)
- llmalfr
- fluent-plugin-llm-generate
- fluent-plugin-sstp

## Future Development

Planned enhancements include:

- Integration with more data sources (Slack, email, calendar)
- Improved LLM-based prioritization algorithms
- Task automation capabilities
- Team collaboration features

## License

Apache License, Version 2.0
