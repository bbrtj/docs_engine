# Docs engine

This is a very simple web server intended to work as a local wiki. It renders pod, md and other files into HTML pages and allows manipulating them using CRUD interface.

Work in progress - works, but is very plain.

## Setup

### Requirements
- Perl 5.38 with Carmel module
- pandoc (for markdown files)

### Installation
- copy *.example files in the root directory of the project and adjust their contents
- run `carmel install && carmel rollout`
- run `script/docs daemon`
- done, navigate to your browser (IP address / port will be printed). All directories from .config will be available for viewing

