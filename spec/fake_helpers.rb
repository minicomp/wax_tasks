require 'csv'
require 'colorized_string'

# global
$collection_data = {}

# helper methods
def slug(str)
  str.downcase.tr(' ', '_').gsub(/[^\w-]/, '')
end

def write_csv(path, hashes)
  CSV.open(path, 'wb:UTF-8') do |csv|
    csv << hashes.first.keys
    hashes.each do |hash|
      csv << hash.values
    end
  end
  puts "Writing csv data to #{path}."
rescue StandardError
  abort "Cannot write csv data to #{path} for some reason.".magenta
end
