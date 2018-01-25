require 'csv'

# helper methods
def slug(str)
  return str.downcase.tr(' ', '_').gsub(/[^\w-]/, '')
end

def write_csv(path, data)
  CSV.open(path, 'wb:UTF-8') do |csv|
    csv << data.first.keys
    data.each do |hash|
      csv << hash.values
    end
  end
  puts "Writing csv data to #{path}."
rescue StandardError
  raise "Cannot write csv data to #{path} for some reason."
end

# global
$collection_data = {}
