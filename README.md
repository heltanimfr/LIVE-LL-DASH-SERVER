# Live DASH Streaming Script

## Description

This script uses **ffmpeg** to stream a video in **DASH** format with multiple resolutions and real-time encoder timestamps. The script allows segmenting the video into different resolutions while displaying an encoding timestamp on the top-left corner of each video stream.

The script takes a source video (e.g., `Spring.mp4`) and streams it using the HTTP protocol, generating a **MPD** manifest file and associated media segments (`.m4s`).

## Prerequisites

- **ffmpeg**: The main tool used for video processing and streaming.
- HTTP server access to stream the `.m4s` files and the `.mpd` manifest.

### Dependencies

To install `ffmpeg`, follow the instructions below depending on your OS:

#### Ubuntu/Debian
```bash
sudo apt update
sudo apt install ffmpeg
```

## Features

* Video Segmentation: Streams the video in 3 different resolutions:
* 1920x1080 (HD)
* 1280x720 (HD)
* 768x432 (SD)
Encoding Timestamp Overlay: The encoding timestamp (in local time) is displayed in the top-left corner of each video stream.
Dynamic Adaptation: The script supports adaptive streams with dynamic updates to the MPD manifest.
HTTP Streaming: The .m4s video segments are sent to an HTTP server for live streaming.
