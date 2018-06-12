require 'colorize'

def rm_diacritics(str)
  to_replace  = 'ÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćĈĉĊċČčÐðĎďĐđÈÉÊËèéêëĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħÌÍÎÏìíîïĨĩĪīĬĭĮįİıĴĵĶķĸĹĺĻļĽľĿŀŁłÑñŃńŅņŇňŉŊŋÒÓÔÕÖØòóôõöøŌōŎŏŐőŔŕŖŗŘřŚśŜŝŞşŠšſŢţŤťŦŧÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲųŴŵÝýÿŶŷŸŹźŻżŽž'
  replaced_by = 'AAAAAAaaaaaaAaAaAaCcCcCcCcCcDdDdDdEEEEeeeeEeEeEeEeEeGgGgGgGgHhHhIIIIiiiiIiIiIiIiIiJjKkkLlLlLlLlLlNnNnNnNnnNnOOOOOOooooooOoOoOoRrRrRrSsSsSsSssTtTtTtUUUUuuuuUuUuUuUuUuUuWwYyyYyYZzZzZz'
  str.tr(to_replace, replaced_by)
end

def clean(str)
  str.gsub!(/\A---(.|\n)*?---/, '') # remove yaml front matter
  str.gsub!(/{%(.*)%}/, '') # remove functional liquid
  str.gsub!(%r{<\/?[^>]*>}, '') # remove html
  str.gsub!('\\n', '') # remove newlines
  str.gsub!(/\s+/, ' ') # remove extra space
  str.tr!('"', "'") # replace double quotes with single
  str
end

def slug(str)
  str.downcase.tr(' ', '_').gsub(/[^:\w-]/, '')
end

# document
module Error
  def self.complain(error)
    abort error.magenta
  end

  def self.missing_key(key, name)
    complain("Key '#{key}' not found for '#{name}'. Check config and rerun.")
  end

  def self.invalid_type(ext, name)
    complain("Source file for #{name} must be .csv .json  or .yml. Found #{ext}.")
  end

  def self.duplicate_pids(duplicates, name)
    complain("Fix the following duplicate pids for collection '#{name}': #{duplicates}")
  end

  def self.bad_source(source, name)
    complain("Cannot load source '#{source}' for collection '#{name}'. Check for typos and rebuild.")
  end

  def self.missing_pids(source, pids)
    complain("Source '#{source}' is missing #{pids.count(nil)} `pid` values.")
  end

  def self.invalid_collection(name)
    complain("Configuration for the collection '#{name}' is invalid.")
  end

  def self.page_generation_failure(completed)
    complain("Failure after #{completed} pages, likely from missing pid.")
  end

  def self.no_collections_to_index
    complain('There are no valid collections to index.')
  end

  def self.missing_iiif_src(dir)
    complain("Source path '#{dir}' does not exist. Exiting.")
  end
end

# document
class Message
  def self.share(msg)
    puts msg.cyan
  end

  def self.processing_source(source)
    share("\nProcessing #{source}...")
  end

  def self.pagemaster_results(completed, dir)
    share("\n#{completed} pages were generated to #{dir} directory.")
  end

  def self.writing_index(path)
    share("Writing lunr index to #{path}")
  end

  def self.ui_exists(path)
    share("Lunr UI already exists at #{path}. Skipping.")
  end

  def self.writing_ui(path)
    share("Writing lunr ui to #{path}")
  end

  def self.writing_package_json(names)
    share("Writing #{names} to simple package.json.")
  end

  def self.skipping_package_json
    share('Cannot find js dependencies in config. Skipping package.json.')
  end
end
