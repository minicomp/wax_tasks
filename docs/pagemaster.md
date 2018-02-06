# wax:pagemaster

## What it does
Takes a CSV file of metadata and generates a Markdown page for each record to a specified directory and using a specified layout. If a Markdown page already exists, pagemaster will skip over it and not overwrite the data. (e.g. to regenerate pages, delete them first.)

## Requirements
One CSV file of metadata per collection. Each file MUST have a column called `pid` of persistent, unique identifiers for the records, which CANNOT have spaces or special characters since they will be used to name the pages. Column names CANNOT have spaces or special characters. Please use camel_case format, e.g. `current_primary_location` instead of `current / primary location`.

**Note:** Some fields are used by Jekyll for specific tasks, and should not be used as metadata headers (e.g. `name`,`id`, and `date`). If you need to use these terms to name your columns, prepend them with an underscore: `_date`.

**For example:** `_data/objects.csv`

| pid | iiif_image | artist                      | location | title                               | _date        | object_type | current_location                   | wiki_link                                                                                                                                            |
|-----|------------|-----------------------------|----------|-------------------------------------|--------------|-------------|------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------|
| 1   | 1          | Al-Hajj Hafiz Muhammad Nuri | Turkey   | The Dala'il al-Khayrat of al-Juzuli | 1801         | manuscript  | "The Museum of Islamic Art, Qatar" | "https://commons.wikimedia.org/wiki/File:Al-Hajj_Hafiz_Muhammad_Nuri,_Turkey,_1801_-_The_Dala%27il_al-Khayrat_of_al-Juzuli_-_Google_Art_Project.jpg" |
| 2   | 2          | Mihr 'Ali                   | Iran     | Portrait of Fath 'Ali Shah          | 1816         | portrait    | "The Museum of Islamic Art, Qatar" | "https://commons.wikimedia.org/wiki/File:Mihr_%27Ali,_Iran,_1816_-_Portrait_of_Fath_%27Ali_Shah_-_Google_Art_Project.jpg"                            |
| 3   | 3          | Unknown                     | Egypt    | Sulwan Al-Muta'a                    | 14th century | manuscript  | "The Museum of Islamic Art, Qatar" | "https://commons.wikimedia.org/wiki/File:Unknown,_Egypt_or_Syria,_14th_Century_-_Sulwan_Al-Muta%27a_-_Google_Art_Project.jpg"                        |
| 4   | 4          | Unknown                     | Egypt    | Map of the World                    | 15th century | map         | "The Museum of Islamic Art, Qatar" | "https://commons.wikimedia.org/wiki/File:Unknown,_Egypt,_15th_Century_-_Map_of_World_-_Google_Art_Project.jpg"                                       |



## Configuration

Put your metadata file(s) in the `_data` directory, and add the info to `collections` in `_config.yml`:
```yaml
collections:
  objects:
    source: objects.csv
    layout: iiif-image-page
```

## To use
`$ bundle exec rake wax:pagemaster <collection>`

(For the above example, `$ bundle exec rake wax:pagemaster objects` would generate pages with the `iiif-image-page.html` layout to the directory `objects` from `_data/objects.csv`.
