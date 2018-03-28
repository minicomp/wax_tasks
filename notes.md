# Collection Tasks

## Pagemaster
- needs access to config + args
- needs collection data `source`, `layout` for each arg

## Lunr
- needs access to config
- needs collection data `lunr_index` with `fields` array.
- optional: `content` boolean, `lunr_language`

## IIIF
- needs access to args
- needs dir in data/iiif/ for each arg with images

Therefore, Wax Collection class needs to access config and args
From config, it needs:
- collection_config
- collections_dir (for jekyll >= 3.7)
- lunr_language
- permalink
