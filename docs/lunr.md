# wax:lunr

## What it does
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

## Requirements
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

## Configuration

Add to `_config.yml`:
```yaml
lunr:
  content: true
  multi-language: true
  meta:
    - dir: projects
      fields:
        - title
        - era
        - tags
    - dir: _posts
      fields:
        - title
        - category
        - tags
```

## To use
`$ bundle exec rake wax:lunr`
