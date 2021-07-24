require 'csv'
require 'erb'
require 'date'
require 'google/apis/civicinfo_v2'

puts 'Event Manager Initialized!'

def adj_zip(zipcode)
    zipcode.to_s.rjust(5, '0')[0..4]
end

def adj_phone_numbers(phone_number)
    digits = phone_number.scan(/\d/)
    if digits.length < 10 || digits.length > 11
        digits = ""
    else
        digits = digits.drop(1) if digits.length == 11
        sprintf "(%3s) %3s-%4s", digits[0,3].join, digits[3,3].join, digits[6,4].join
    end
end

def adj_date(date)
    DateTime.strptime(date, "%m/%d/%y %H:%M")
end

def legislators_by_zipcode(zipcode)
    civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
    civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

    begin
        legislators = civic_info.representative_info_by_address(
            address: zipcode,
            levels: 'country',
            roles: ['legislatorUpperBody', 'legislatorLowerBody']
        ).officials
    rescue
        'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
    end
end

def count_freq(arr)
    freq = arr.inject(Hash.new(0)) {|h,v| h[v] += 1; h}
    arr.max_by {|v| freq[v]}
end

def save_letter(id, letter)
    Dir.mkdir('output') unless Dir.exist?('output')

    filename = "output/thanks_#{id}.html"

    File.open(filename, 'w') do |file|
        file.puts letter
    end
end

contents = CSV.open(
    'event_attendees.csv',
    headers: true,
    header_converters: :symbol
)
contents_size = CSV.read('event_attendees.csv').length - 1
progress = 0

hours_arr = []
days_arr = []
week_days = {0=>"sunday",1=>"monday",2=>"tuesday",3=>"wednesday",4=>"thursday",5=>"friday",6=>"saturday"}

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents.each do |row|
    id = row[0]
    name = row[:first_name]
    zipcode = adj_zip(row[:zipcode])
    legislators = legislators_by_zipcode(zipcode)
    phone_numbers = adj_phone_numbers(row[:homephone])

    reg_date = adj_date(row[:regdate])
    hours_arr.push(reg_date.hour)
    days_arr.push(reg_date.wday)

    #personal_letter = erb_template.result(binding)
    #save_letter(id, personal_letter)

    puts "#{progress + 1}/#{contents_size}"
    puts name, phone_numbers, reg_date, "\n"

    progress += 1
end

puts "\nThe most common hour is: #{count_freq(hours_arr)}"
puts "The most common day of the week is: #{week_days[count_freq(days_arr)].capitalize}"